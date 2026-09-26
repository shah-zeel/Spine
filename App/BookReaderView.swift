import SwiftUI

struct BookReaderView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding var pageIndex: Int
  var pages: [BookPage]
  var showsSpread: Bool
  var notebook: ReaderNotebook
  var audio: AudioReadingModel

  @State private var controlsVisible = false
  @State private var selectedPassage: SelectedPassage?
  @State private var isShowingContents = false
  @State private var isShowingAnnotations = false
  @State private var isShowingBookSummary = false
  @State private var editingPassage: SelectedPassage?

  private var safePageIndex: Int {
    let safeIndex = min(max(pageIndex, 0), pages.count - 1)
    return showsSpread && safeIndex.isMultiple(of: 2)
      ? min(safeIndex + 1, pages.count - 1)
      : safeIndex
  }

  private var turnDistance: Int { showsSpread ? 2 : 1 }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottomTrailing) {
        FolioPalette.pageShade
          .ignoresSafeArea()

        PageCurlReaderView(
          pages: pages,
          pageIndex: $pageIndex,
          showsSpread: showsSpread,
          notebook: notebook,
          activeSpeechLine: audio.currentLine,
          onSelectionChange: { selectedPassage = $0 }
        )
        .id(showsSpread)
        .simultaneousGesture(
          TapGesture().onEnded {
            if controlsVisible {
              collapseControls()
            }
          }
        )
        .accessibilityAction(named: Text("Previous page")) { turnPage(backward: true) }
        .accessibilityAction(named: Text("Next page")) { turnPage(backward: false) }

        if let selectedPassage {
          PassageActionBar(
            onHighlight: { color in
              notebook.highlight(selectedPassage, color: color)
            },
            onAddNote: { editingPassage = selectedPassage },
            onDismiss: { self.selectedPassage = nil },
            onShowAnnotations: { isShowingAnnotations = true }
          )
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.bottom, max(geometry.safeAreaInsets.bottom, 18) + 76)
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }

        if controlsVisible {
          ReaderControlDock(
            pageIndex: safePageIndex,
            pageCount: pages.count,
            showsSpread: showsSpread,
            isPlaying: audio.isPlaying,
            onPrevious: { turnPage(backward: true) },
            onNext: { turnPage(backward: false) },
            onAudio: { audio.toggle(startingAtPage: safePageIndex) },
            onContents: { isShowingContents = true },
            onAnnotations: { isShowingAnnotations = true },
            onBookSummary: { isShowingBookSummary = true }
          )
          .padding(.trailing, 20)
          .padding(.bottom, max(geometry.safeAreaInsets.bottom, 18) + 75)
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }

        Button {
          setControlsVisible(!controlsVisible)
        } label: {
          Image(systemName: controlsVisible ? "xmark" : "ellipsis")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(FolioPalette.ink)
            .frame(width: 48, height: 48)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().strokeBorder(FolioPalette.rule.opacity(0.55), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(controlsVisible ? "Hide reader controls" : "Show reader controls")
        .padding(.trailing, 20)
        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 18) + 14)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .animation(reduceMotion ? nil : .smooth(duration: 0.22), value: controlsVisible)
      .animation(reduceMotion ? nil : .smooth(duration: 0.22), value: selectedPassage)
    }
    .ignoresSafeArea()
    .onAppear { pageIndex = safePageIndex }
    .onChange(of: pageIndex) { _, _ in selectedPassage = nil }
    .sensoryFeedback(.impact(weight: .light, intensity: 0.45), trigger: pageIndex)
    .sheet(isPresented: $isShowingContents) {
      TableOfContentsView { pageIndex = $0 }
    }
    .sheet(isPresented: $isShowingAnnotations) {
      AnnotationLibraryView(notebook: notebook)
    }
    .sheet(isPresented: $isShowingBookSummary) {
      BookSummaryView(pages: pages, annotations: notebook.annotations)
    }
    .sheet(item: $editingPassage) { passage in
      AnnotationEditorView(
        notebook: notebook,
        passage: passage,
        existing: notebook.annotation(for: passage)
      )
    }
    .task(id: controlsVisible) {
      guard controlsVisible else { return }
      try? await Task.sleep(for: .seconds(4))
      guard !Task.isCancelled else { return }
      collapseControls()
    }
  }

  private func turnPage(backward: Bool) {
    let target = safePageIndex + (backward ? -turnDistance : turnDistance)
    pageIndex = min(max(target, 0), pages.count - 1)
  }

  private func setControlsVisible(_ visible: Bool) {
    if reduceMotion {
      controlsVisible = visible
    } else {
      withAnimation(.smooth(duration: 0.22)) {
        controlsVisible = visible
      }
    }
  }

  private func collapseControls() {
    guard controlsVisible else { return }
    setControlsVisible(false)
  }
}

private struct ReaderControlDock: View {
  var pageIndex: Int
  var pageCount: Int
  var showsSpread: Bool
  var isPlaying: Bool
  var onPrevious: () -> Void
  var onNext: () -> Void
  var onAudio: () -> Void
  var onContents: () -> Void
  var onAnnotations: () -> Void
  var onBookSummary: () -> Void

  private var step: Int { showsSpread ? 2 : 1 }

  var body: some View {
    HStack(spacing: 4) {
      dockButton("Previous page", symbol: "chevron.left", action: onPrevious)
        .disabled(pageIndex < step)
      dockButton(isPlaying ? "Pause audiobook" : "Play audiobook", symbol: isPlaying ? "pause.fill" : "play.fill", action: onAudio)
      dockButton("Contents", symbol: "list.bullet", action: onContents)
      dockButton("Annotations", symbol: "quote.bubble", action: onAnnotations)
      dockButton("Summarize notes with AI", symbol: "sparkles", action: onBookSummary)
      dockButton("Next page", symbol: "chevron.right", action: onNext)
        .disabled(pageIndex + step >= pageCount)
    }
    .padding(6)
    .background(.regularMaterial, in: Capsule())
    .overlay(Capsule().strokeBorder(FolioPalette.rule.opacity(0.54), lineWidth: 0.8))
    .shadow(color: FolioPalette.ink.opacity(0.16), radius: 14, y: 6)
  }

  private func dockButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(FolioPalette.ink)
        .frame(width: 42, height: 42)
        .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}
