import SwiftUI

private enum FoldState {
  case unknown
  case closed
  case partiallyOpen
  case fullyOpen
  case noHinge
}

private enum ReaderPosture: Equatable {
  case cover
  case openLandscape
  case openPortrait
  case tentAudio
  case laptopNotes
}

struct ContentView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @AppStorage("folio.readingPage") private var readingPageIndex = 1
  @State private var foldState = FoldState.unknown
  @State private var notebook = ReaderNotebook()
  @State private var audio = AudioReadingModel()

  var body: some View {
    foldAwareReader
      .tint(FolioPalette.accent)
      .statusBarHidden(true)
  }

  @ViewBuilder
  private var foldAwareReader: some View {
    if #available(iOS 27.1, *) {
      readerContainer
        .onHingeChange { _, context in
          guard let hinge = context.hinge else {
            foldState = .noHinge
            return
          }
          switch hinge.status {
          case .closed:
            foldState = .closed
          case .partiallyOpen:
            foldState = .partiallyOpen
          case .fullyOpen:
            foldState = .fullyOpen
          default:
            foldState = .unknown
          }
        }
    } else {
      readerContainer
    }
  }

  private var readerContainer: some View {
    GeometryReader { geometry in
      let posture = resolvePosture(in: geometry)

      Group {
        switch posture {
        case .cover:
          BookCoverView(audio: audio, startingPage: readingPageIndex)
        case .openLandscape:
          BookReaderView(
            pageIndex: $readingPageIndex,
            pages: SampleBook.pages,
            showsSpread: true,
            notebook: notebook,
            audio: audio
          )
        case .openPortrait:
          BookReaderView(
            pageIndex: $readingPageIndex,
            pages: SampleBook.pages,
            showsSpread: false,
            notebook: notebook,
            audio: audio
          )
        case .tentAudio:
          TentPostureView(audio: audio, notebook: notebook)
        case .laptopNotes:
          LaptopWorkspaceView(
            pageIndex: $readingPageIndex,
            pages: SampleBook.pages,
            notebook: notebook,
            audio: audio
          )
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(FolioPalette.canvas)
      .animation(reduceMotion ? nil : .smooth(duration: 0.35), value: posture)
    }
    .ignoresSafeArea()
  }

  private func resolvePosture(in geometry: GeometryProxy) -> ReaderPosture {
    switch foldState {
    case .closed:
      return .cover
    case .fullyOpen:
      return geometry.size.width > geometry.size.height ? .openLandscape : .openPortrait
    case .partiallyOpen:
      if #available(iOS 27.1, *), let division = geometry.reservedRegions(kind: .division).first {
        return division.frame.width > division.frame.height ? .laptopNotes : .tentAudio
      }
      return geometry.size.width > geometry.size.height ? .tentAudio : .laptopNotes
    case .noHinge:
      return geometry.size.width > geometry.size.height ? .openLandscape : .openPortrait
    case .unknown:
      return geometry.size.width > geometry.size.height ? .openLandscape : .openPortrait
    }
  }
}
