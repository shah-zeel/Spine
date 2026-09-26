import SwiftUI

struct ContentView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @AppStorage("folio.readingPage") private var readingPageIndex = 1
  @AppStorage("folio.bookmarked") private var isBookmarked = false
  @State private var isFoldedByHinge = false
  @State private var hasOpenedBook = false
  @State private var isReadingOnOuterDisplay = false
  @State private var isShowingContents = false

  private var isCompactDisplay: Bool {
    horizontalSizeClass == .compact
  }

  private var showsCover: Bool {
    (isFoldedByHinge && !isReadingOnOuterDisplay) || (isCompactDisplay && !hasOpenedBook)
  }

  private var readingProgress: Double {
    let safePageIndex = min(max(readingPageIndex, 0), SampleBook.pages.count - 1)
    return Double(safePageIndex) / Double(max(SampleBook.pages.count - 1, 1))
  }

  var body: some View {
    hingeAwareNavigation
      .tint(FolioPalette.accent)
      .sheet(isPresented: $isShowingContents) {
        TableOfContentsView { selectedPage in
          readingPageIndex = selectedPage
          hasOpenedBook = true
          isReadingOnOuterDisplay = true
          isShowingContents = false
        }
      }
  }

  @ViewBuilder
  private var hingeAwareNavigation: some View {
    if #available(iOS 27.1, *) {
      navigation
        .onHingeChange { _, newContext in
          updateFoldedState(newContext.hinge?.status == .closed)
        }
    } else {
      navigation
    }
  }

  private var navigation: some View {
    NavigationStack {
      ZStack {
        FolioPalette.canvas.ignoresSafeArea()

        if showsCover {
          BookCoverView(progress: readingProgress) {
            withAnimation(.spring(duration: 0.45, bounce: 0.04)) {
              hasOpenedBook = true
              isReadingOnOuterDisplay = true
            }
          }
          .transition(.opacity)
        } else {
          BookReaderView(pageIndex: $readingPageIndex, pages: SampleBook.pages)
            .transition(.opacity)
        }
      }
      .animation(reduceMotion ? nil : .spring(duration: 0.45, bounce: 0.04), value: showsCover)
      .navigationTitle(showsCover ? "" : "The Wild Between")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if !showsCover {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              isShowingContents = true
            } label: {
              Label("Contents", systemImage: "list.bullet")
            }
          }

          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isBookmarked.toggle()
            } label: {
              Label(isBookmarked ? "Saved" : "Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
            }
          }
        }
      }
      .toolbar(showsCover ? .hidden : .visible, for: .navigationBar)
      .toolbarBackground(.hidden, for: .navigationBar)
    }
  }

  private func updateFoldedState(_ isFolded: Bool) {
    let applyChange = {
      isFoldedByHinge = isFolded
      isReadingOnOuterDisplay = false
    }

    if reduceMotion {
      applyChange()
    } else {
      withAnimation(.spring(duration: 0.45, bounce: 0.04), applyChange)
    }
  }
}
