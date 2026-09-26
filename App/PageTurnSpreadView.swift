import SwiftUI

enum PageTurnDirection: Equatable {
  case forward
  case backward
}

struct PageTurnSpreadView: View {
  var pages: [BookPage]
  var pageIndex: Int
  var showsSpread: Bool
  var direction: PageTurnDirection?
  var progress: CGFloat

  var body: some View {
    GeometryReader { geometry in
      let divisionGap = divisionWidth(in: geometry)
      let pageWidth = showsSpread ? max((geometry.size.width - divisionGap) / 2, 0) : geometry.size.width

      ZStack {
        basePages(in: geometry.size, pageWidth: pageWidth, divisionGap: divisionGap)

        if let direction {
          turningLeaf(direction: direction, pageWidth: pageWidth, height: geometry.size.height)
            .offset(x: showsSpread ? leafOffset(for: direction, pageWidth: pageWidth, gap: divisionGap) : 0)
            .zIndex(2)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(FolioPalette.pageShade)
      .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
      .shadow(color: FolioPalette.ink.opacity(0.13), radius: 18, x: 0, y: 9)
    }
  }

  @ViewBuilder
  private func basePages(in size: CGSize, pageWidth: CGFloat, divisionGap: CGFloat) -> some View {
    if showsSpread {
      HStack(spacing: divisionGap) {
        BookPageView(page: baseSpreadLeftPage)
          .frame(width: pageWidth, height: size.height)

        BookPageView(page: baseSpreadRightPage)
          .frame(width: pageWidth, height: size.height)
      }
      .overlay {
        Rectangle()
          .fill(
            LinearGradient(
              colors: [FolioPalette.ink.opacity(0.02), FolioPalette.ink.opacity(0.17), FolioPalette.ink.opacity(0.02)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(width: 13)
          .allowsHitTesting(false)
      }
    } else {
      BookPageView(page: baseCompactPage)
        .frame(width: size.width, height: size.height)
    }
  }

  private func turningLeaf(direction: PageTurnDirection, pageWidth: CGFloat, height: CGFloat) -> some View {
    PageTurnLeaf(
      front: leafFrontPage(for: direction),
      back: leafBackPage(for: direction),
      direction: direction,
      progress: progress
    )
    .frame(width: pageWidth, height: height)
  }

  private var baseSpreadLeftPage: BookPage {
    switch direction {
    case .forward:
      return page(at: pageIndex - 1)
    case .backward:
      return page(at: pageIndex - backwardTurnDistance - 1)
    case nil:
      return page(at: pageIndex - 1)
    }
  }

  private var baseSpreadRightPage: BookPage {
    switch direction {
    case .forward:
      return page(at: pageIndex + 2)
    case .backward:
      return page(at: pageIndex)
    case nil:
      return page(at: pageIndex)
    }
  }

  private var baseCompactPage: BookPage {
    switch direction {
    case .forward:
      return page(at: pageIndex + 1)
    case .backward:
      return page(at: pageIndex - 1)
    case nil:
      return page(at: pageIndex)
    }
  }

  private func leafFrontPage(for direction: PageTurnDirection) -> BookPage {
    if showsSpread {
      return direction == .forward ? page(at: pageIndex) : page(at: pageIndex - 1)
    }
    return page(at: pageIndex)
  }

  private func leafBackPage(for direction: PageTurnDirection) -> BookPage {
    if showsSpread {
      return direction == .forward ? page(at: pageIndex + 1) : page(at: pageIndex - backwardTurnDistance)
    }
    return page(at: direction == .forward ? pageIndex + 1 : pageIndex - 1)
  }

  private func page(at requestedIndex: Int) -> BookPage {
    let safeIndex = min(max(requestedIndex, 0), pages.count - 1)
    return pages[safeIndex]
  }

  private var backwardTurnDistance: Int {
    guard showsSpread else { return 1 }
    return pageIndex.isMultiple(of: 2) ? 1 : 2
  }

  private func leafOffset(for direction: PageTurnDirection, pageWidth: CGFloat, gap: CGFloat) -> CGFloat {
    let offset = (pageWidth + gap) / 2
    return direction == .forward ? offset : -offset
  }

  private func divisionWidth(in geometry: GeometryProxy) -> CGFloat {
    if #available(iOS 27.1, *) {
      return geometry.reservedRegions(kind: .division).reduce(0) { total, region in
        total + region.frame.width
      }
    }
    return 0
  }
}

private struct PageTurnLeaf: View {
  var front: BookPage
  var back: BookPage
  var direction: PageTurnDirection
  var progress: CGFloat

  private var isForward: Bool {
    direction == .forward
  }

  var body: some View {
    ZStack {
      BookPageView(page: front)
        .opacity(progress < 0.5 ? 1 : 0)

      BookPageView(page: back)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .opacity(progress >= 0.5 ? 1 : 0)

      LinearGradient(
        colors: [
          FolioPalette.ink.opacity(0.015),
          FolioPalette.ink.opacity(0.13),
          FolioPalette.page.opacity(0.18)
        ],
        startPoint: isForward ? .trailing : .leading,
        endPoint: isForward ? .leading : .trailing
      )
      .opacity(sin(Double(progress) * .pi))
      .allowsHitTesting(false)
    }
    .clipped()
    .rotation3DEffect(
      .degrees((isForward ? -180.0 : 180.0) * Double(progress)),
      axis: (x: 0, y: 1, z: 0),
      anchor: isForward ? .leading : .trailing,
      perspective: 0.48
    )
    .shadow(color: FolioPalette.ink.opacity(0.18), radius: 18, x: isForward ? -8 : 8, y: 3)
    .accessibilityHidden(true)
  }
}
