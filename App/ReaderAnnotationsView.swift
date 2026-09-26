import SwiftUI

struct PassageActionBar: View {
  var onHighlight: (PassageColor) -> Void
  var onAddNote: () -> Void
  var onDismiss: () -> Void
  var onShowAnnotations: (() -> Void)? = nil

  var body: some View {
    HStack(spacing: 5) {
      Menu {
        ForEach(PassageColor.allCases) { color in
          Button {
            onHighlight(color)
          } label: {
            Label(color.title, systemImage: "highlighter")
          }
        }
      } label: {
        Label("Highlight", systemImage: "highlighter")
          .font(.system(.subheadline, design: .rounded, weight: .medium))
          .padding(.horizontal, 12)
          .frame(minHeight: 44)
          .contentShape(Capsule())
      }

      Button(action: onAddNote) {
        Label("Add note", systemImage: "square.and.pencil")
          .font(.system(.subheadline, design: .rounded, weight: .medium))
          .padding(.horizontal, 12)
          .frame(minHeight: 44)
          .contentShape(Capsule())
      }
      .buttonStyle(.plain)

      if let onShowAnnotations {
        Button(action: onShowAnnotations) {
          Image(systemName: "quote.bubble")
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View annotations")
      }

      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .semibold))
          .frame(width: 44, height: 44)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Dismiss passage actions")
    }
    .foregroundStyle(FolioPalette.ink)
    .padding(5)
    .background(.regularMaterial, in: Capsule())
    .overlay(Capsule().strokeBorder(FolioPalette.rule.opacity(0.55), lineWidth: 0.8))
    .shadow(color: FolioPalette.ink.opacity(0.18), radius: 14, y: 6)
  }
}

struct AnnotationLibraryView: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var notebook: ReaderNotebook
  @State private var selectedAnnotation: PassageAnnotation?

  private var sortedAnnotations: [PassageAnnotation] {
    notebook.annotations.sorted {
      $0.pageIndex == $1.pageIndex ? $0.location < $1.location : $0.pageIndex < $1.pageIndex
    }
  }

  var body: some View {
    NavigationStack {
      Group {
        if sortedAnnotations.isEmpty {
          ContentUnavailableView(
            "No annotations yet",
            systemImage: "quote.bubble",
            description: Text("Select a passage while reading to highlight it or add a note.")
          )
        } else {
          List {
            ForEach(sortedAnnotations) { annotation in
              Button {
                selectedAnnotation = annotation
              } label: {
                AnnotationRow(annotation: annotation)
              }
              .buttonStyle(.plain)
              .listRowBackground(FolioPalette.page)
              .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                  notebook.remove(annotation)
                }
              }
            }
          }
          .listStyle(.insetGrouped)
          .scrollContentBackground(.hidden)
          .background(FolioPalette.canvas)
        }
      }
      .background(FolioPalette.canvas)
      .navigationTitle("Annotations")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDragIndicator(.visible)
    .sheet(item: $selectedAnnotation) { annotation in
      AnnotationEditorView(
        notebook: notebook,
        passage: SelectedPassage(pageIndex: annotation.pageIndex, quote: annotation.quote, range: annotation.range),
        existing: annotation
      )
    }
  }
}

private struct AnnotationRow: View {
  var annotation: PassageAnnotation

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      RoundedRectangle(cornerRadius: 2)
        .fill(annotation.color.tint)
        .frame(width: 4)

      VStack(alignment: .leading, spacing: 6) {
        Text("“\(annotation.quote)”")
          .font(.system(.body, design: .serif))
          .foregroundStyle(FolioPalette.ink)
          .lineLimit(3)
          .multilineTextAlignment(.leading)

        if !annotation.comment.isEmpty {
          Text(annotation.comment)
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(FolioPalette.mutedInk)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
        }

        Text("PAGE \(annotation.pageIndex + 1) · \(annotation.hasHighlight ? "HIGHLIGHT" : "NOTE")")
          .font(.system(.caption2, design: .rounded, weight: .semibold))
          .tracking(0.7)
          .foregroundStyle(FolioPalette.mutedInk)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
  }
}

struct AnnotationEditorView: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var notebook: ReaderNotebook
  var passage: SelectedPassage
  var existing: PassageAnnotation?

  @State private var comment: String
  @State private var color: PassageColor

  init(notebook: ReaderNotebook, passage: SelectedPassage, existing: PassageAnnotation?) {
    self.notebook = notebook
    self.passage = passage
    self.existing = existing
    _comment = State(initialValue: existing?.comment ?? "")
    _color = State(initialValue: existing?.color ?? .honey)
  }

  private var canSave: Bool {
    existing != nil || !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Selected passage · Page \(passage.pageIndex + 1)") {
          Text("“\(passage.quote)”")
            .font(.system(.body, design: .serif))
            .foregroundStyle(FolioPalette.ink)
            .textSelection(.enabled)
        }

        Section("Highlight") {
          Picker("Color", selection: $color) {
            ForEach(PassageColor.allCases) { option in
              HStack {
                Circle().fill(option.tint).frame(width: 12, height: 12)
                Text(option.title)
              }
              .tag(option)
            }
          }
          .pickerStyle(.menu)
        }

        Section("My note") {
          TextEditor(text: $comment)
            .frame(minHeight: 150)
            .accessibilityLabel("Note about the selected passage")
        }

        if let existing {
          Section {
            Button("Delete annotation", systemImage: "trash", role: .destructive) {
              notebook.remove(existing)
              dismiss()
            }
          }
        }
      }
      .scrollContentBackground(.hidden)
      .background(FolioPalette.canvas)
      .navigationTitle(existing == nil ? "New note" : "Edit annotation")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") { save() }
            .disabled(!canSave)
        }
      }
    }
    .presentationDragIndicator(.visible)
  }

  private func save() {
    if let existing {
      notebook.update(existing, comment: comment, color: color)
    } else {
      notebook.saveComment(comment, for: passage, color: color)
    }
    dismiss()
  }
}
