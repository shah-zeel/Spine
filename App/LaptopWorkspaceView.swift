import SwiftUI

struct LaptopWorkspaceView: View {
  @Binding var pageIndex: Int
  var pages: [BookPage]
  var notebook: ReaderNotebook
  var audio: AudioReadingModel

  @State private var selectedPassage: SelectedPassage?
  @State private var isShowingAnnotations = false

  var body: some View {
    if #available(iOS 27.1, *) {
      ArrangementView {
        bookPane
      } secondary: {
        notesPane
      }
      .arrangementViewStyle(.split.axes(.vertical))
      .background(FolioPalette.canvas)
      .ignoresSafeArea()
    } else {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          bookPane
            .frame(height: geometry.size.height * 0.54)
          notesPane
            .frame(maxHeight: .infinity)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
      }
      .ignoresSafeArea()
    }
  }

  private var bookPane: some View {
    PageCurlReaderView(
      pages: pages,
      pageIndex: $pageIndex,
      showsSpread: false,
      notebook: notebook,
      activeSpeechLine: audio.currentLine,
      onSelectionChange: { selectedPassage = $0 }
    )
    .background(FolioPalette.page)
    .accessibilityLabel("Book reading area")
  }

  private var notesPane: some View {
    LaptopNotesPane(
      passage: $selectedPassage,
      audio: audio,
      notebook: notebook,
      onShowAnnotations: { isShowingAnnotations = true }
    )
    .sheet(isPresented: $isShowingAnnotations) {
      AnnotationLibraryView(notebook: notebook)
    }
  }
}

private struct LaptopNotesPane: View {
  @Binding var passage: SelectedPassage?
  var audio: AudioReadingModel
  var notebook: ReaderNotebook
  var onShowAnnotations: () -> Void

  @State private var comment = ""
  @State private var selectedColor: PassageColor = .honey
  @State private var isSaved = false
  @FocusState private var notesFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        Button {
          audio.toggle(startingAtPage: passage?.pageIndex ?? audio.currentLine?.pageIndex ?? 0)
        } label: {
          Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(FolioPalette.ink)
            .frame(width: 42, height: 42)
            .background(FolioPalette.page, in: Circle())
            .overlay(Circle().strokeBorder(FolioPalette.rule.opacity(0.6), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(audio.isPlaying ? "Pause audiobook" : "Play audiobook")

        Text("AUDIO")
          .font(.system(.caption2, design: .rounded, weight: .semibold))
          .tracking(1.1)
          .foregroundStyle(FolioPalette.mutedInk)

        Spacer()

        Button(action: onShowAnnotations) {
          Image(systemName: "quote.bubble")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(FolioPalette.ink)
            .frame(width: 42, height: 42)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View annotations")
      }

      if let passage {
        HStack(alignment: .top, spacing: 10) {
          Rectangle()
            .fill(FolioPalette.accent)
            .frame(width: 3)
          Text("“\(passage.quote)”")
            .font(.system(.subheadline, design: .serif))
            .foregroundStyle(FolioPalette.ink)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 2)

        PassageActionBar(
          onHighlight: { color in
            selectedColor = color
            notebook.highlight(passage, color: color)
          },
          onAddNote: { notesFocused = true },
          onDismiss: { self.passage = nil },
          onShowAnnotations: onShowAnnotations
        )
        .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Text("Select a passage above to link a note to the book.")
          .font(.system(.caption, design: .rounded))
          .foregroundStyle(FolioPalette.mutedInk)
          .padding(.vertical, 8)
      }

      Rectangle()
        .fill(FolioPalette.rule.opacity(0.7))
        .frame(height: 1)

      TextEditor(text: $comment)
        .font(.system(.body, design: .serif))
        .foregroundStyle(FolioPalette.ink)
        .scrollContentBackground(.hidden)
        .focused($notesFocused)
        .padding(.horizontal, -5)
        .accessibilityLabel("Write a note about the selected passage")
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      HStack {
        if isSaved {
          Label("Saved", systemImage: "checkmark")
            .font(.system(.caption, design: .rounded, weight: .medium))
            .foregroundStyle(FolioPalette.mutedInk)
        }
        Spacer()
        Button("Save note", systemImage: "square.and.pencil") {
          saveNote()
        }
        .buttonStyle(.borderedProminent)
        .tint(FolioPalette.forest)
        .disabled(passage == nil || comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(FolioPalette.canvas)
    .onChange(of: passage) { _, newPassage in
      if let newPassage {
        let existing = notebook.annotation(for: newPassage)
        comment = existing?.comment ?? ""
        selectedColor = existing?.color ?? .honey
      } else {
        comment = ""
      }
      isSaved = false
    }
  }

  private func saveNote() {
    guard let passage else { return }
    notebook.saveComment(comment, for: passage, color: selectedColor)
    isSaved = true
    notesFocused = false
  }
}
