import SwiftUI

struct BookReaderView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding var pageIndex: Int
  var pages: [BookPage]

  @State private var turnDirection: PageTurnDirection?
  @State private var turnProgress: CGFloat = 0

  private var isShowingSpread: Bool {
    horizontalSizeClass == .regular
  }

  private var safePageIndex: Int {
    min(max(pageIndex, 0), pages.count - 1)
  }

  private var canTurnBackward: Bool {
    safePageIndex >= backwardTurnDistance
  }

  private var canTurnForward: Bool {
    safePageIndex + (isShowingSpread ? 2 : 1) < pages.count
  }

  private var pageLabel: String {
    if isShowingSpread, safePageIndex > 0 {
      return "\(pages[safePageIndex - 1].number)–\(pages[safePageIndex].number)"
    }
    return "\(pages[safePageIndex].number)"
  }

  private var progressValue: Double {
    Double(safePageIndex) / Double(max(pages.count - 1, 1))
  }

  private var backwardTurnDistance: Int {
    guard isShowingSpread else { return 1 }
    return safePageIndex.isMultiple(of: 2) ? 1 : 2
  }

  var body: some View {
    VStack(spacing: 15) {
      readerHeader

      GeometryReader { geometry in
        PageTurnSpreadView(
          pages: pages,
          pageIndex: safePageIndex,
          showsSpread: isShowingSpread,
          direction: turnDirection,
          progress: turnProgress
        )
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 12)
            .onChanged { value in
              updateDrag(value.translation.width, pageWidth: isShowingSpread ? geometry.size.width / 2 : geometry.size.width)
            }
            .onEnded { value in
              endDrag(
                value,
                pageWidth: isShowingSpread ? geometry.size.width / 2 : geometry.size.width
              )
            }
        )
        .accessibilityAction(named: Text("Previous page")) {
          performTurn(.backward)
        }
        .accessibilityAction(named: Text("Next page")) {
          performTurn(.forward)
        }
      }

      readerFooter
    }
    .padding(.horizontal, horizontalSizeClass == .compact ? 18 : 34)
    .padding(.top, 10)
    .padding(.bottom, 12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(FolioPalette.canvas)
    .sensoryFeedback(.impact(weight: .light, intensity: 0.45), trigger: pageIndex)
    .onAppear {
      pageIndex = safePageIndex
    }
  }

  private var readerHeader: some View {
    HStack(alignment: .bottom, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text("A SAMPLE READING")
          .font(.system(.caption2, design: .rounded, weight: .semibold))
          .tracking(1.8)
          .foregroundStyle(FolioPalette.mutedInk)

        Text("The Wild Between")
          .font(.system(.title2, design: .serif))
          .foregroundStyle(FolioPalette.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }

      Spacer(minLength: 4)

      Text(pages[safePageIndex].section.components(separatedBy: " · ").first ?? "A story")
        .font(.system(.caption, design: .rounded, weight: .medium))
        .foregroundStyle(FolioPalette.mutedInk)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(.bottom, 4)
    }
    .frame(maxWidth: 900)
    .frame(maxWidth: .infinity, alignment: .center)
  }

  private var readerFooter: some View {
    HStack(spacing: 15) {
      pageButton(direction: .backward, title: "Previous page", symbol: "chevron.left")
        .disabled(!canTurnBackward)

      VStack(alignment: .leading, spacing: 7) {
        HStack {
          Text("Drag a page to turn")
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(FolioPalette.mutedInk)

          Spacer(minLength: 8)

          Text("PAGE \(pageLabel)")
            .font(.system(.caption2, design: .rounded, weight: .semibold))
            .tracking(0.8)
            .monospacedDigit()
            .foregroundStyle(FolioPalette.ink)
        }

        ProgressView(value: progressValue)
          .tint(FolioPalette.accent)
          .accessibilityLabel("Reading progress")
          .accessibilityValue("\(Int(progressValue * 100)) percent")
      }

      pageButton(direction: .forward, title: "Next page", symbol: "chevron.right")
        .disabled(!canTurnForward)
    }
    .frame(maxWidth: 900)
    .frame(maxWidth: .infinity, alignment: .center)
  }

  private func pageButton(direction: PageTurnDirection, title: String, symbol: String) -> some View {
    Button {
      performTurn(direction)
    } label: {
      Label(title, systemImage: symbol)
        .labelStyle(.iconOnly)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(FolioPalette.ink)
        .frame(width: 46, height: 46)
        .background(Circle().fill(FolioPalette.page.opacity(0.88)))
        .overlay(Circle().strokeBorder(FolioPalette.rule.opacity(0.7), lineWidth: 1))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }

  private func updateDrag(_ translation: CGFloat, pageWidth: CGFloat) {
    guard abs(translation) > 4 else { return }

    let direction: PageTurnDirection = translation < 0 ? .forward : .backward
    guard canTurn(direction) else {
      turnDirection = nil
      turnProgress = 0
      return
    }

    turnDirection = direction
    turnProgress = min(abs(translation) / max(pageWidth, 1), 1)
  }

  private func endDrag(_ value: DragGesture.Value, pageWidth: CGFloat) {
    guard let direction = turnDirection else { return }

    let predictedProgress = min(abs(value.predictedEndTranslation.width) / max(pageWidth, 1), 1)
    let projectedInSameDirection = direction == .forward
      ? value.predictedEndTranslation.width < 0
      : value.predictedEndTranslation.width > 0
    if turnProgress > 0.16 || (projectedInSameDirection && predictedProgress > 0.34) {
      animateTurnToCompletion(direction)
    } else {
      cancelTurn()
    }
  }

  private func canTurn(_ direction: PageTurnDirection) -> Bool {
    direction == .forward ? canTurnForward : canTurnBackward
  }

  private func performTurn(_ direction: PageTurnDirection) {
    guard turnDirection == nil, canTurn(direction) else { return }
    turnDirection = direction
    animateTurnToCompletion(direction)
  }

  private func animateTurnToCompletion(_ direction: PageTurnDirection) {
    if reduceMotion {
      finishTurn(direction)
    } else {
      withAnimation(.spring(duration: 0.42, bounce: 0.05)) {
        turnProgress = 1
      } completion: {
        finishTurn(direction)
      }
    }
  }

  private func cancelTurn() {
    if reduceMotion {
      turnProgress = 0
      turnDirection = nil
    } else {
      withAnimation(.spring(duration: 0.28, bounce: 0.02)) {
        turnProgress = 0
      } completion: {
        turnDirection = nil
      }
    }
  }

  private func finishTurn(_ direction: PageTurnDirection) {
    if direction == .forward {
      pageIndex += isShowingSpread ? 2 : 1
    } else {
      pageIndex -= backwardTurnDistance
    }
    turnProgress = 0
    turnDirection = nil
  }
}
