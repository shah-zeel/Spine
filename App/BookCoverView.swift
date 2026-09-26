import SwiftUI

struct BookCoverView: View {
  @Bindable var audio: AudioReadingModel
  var startingPage: Int = 1

  var body: some View {
    BookCoverReadingLayout(audio: audio, startingPage: startingPage, showsPlayControl: true)
      .accessibilityElement(children: .contain)
  }
}

struct BookCoverReadingLayout: View {
  var audio: AudioReadingModel
  var startingPage: Int
  var showsPlayControl: Bool

  var body: some View {
    GeometryReader { geometry in
      if geometry.size.width > geometry.size.height {
        HStack(spacing: 0) {
          BookCoverPane(audio: audio, startingPage: startingPage, showsPlayControl: showsPlayControl)
            .frame(width: geometry.size.width * 0.52)

          LiveReadingLinesPane(audio: audio, startingPage: startingPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      } else {
        VStack(spacing: 0) {
          BookCoverPane(audio: audio, startingPage: startingPage, showsPlayControl: showsPlayControl)
            .frame(height: geometry.size.height * 0.56)

          LiveReadingLinesPane(audio: audio, startingPage: startingPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
    .ignoresSafeArea()
  }
}

private struct BookCoverPane: View {
  var audio: AudioReadingModel
  var startingPage: Int
  var showsPlayControl: Bool

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        BookCoverArtwork()
          .frame(width: geometry.size.width, height: geometry.size.height)

        if showsPlayControl {
          Button {
            audio.toggle(startingAtPage: startingPage)
          } label: {
            Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(.white.opacity(0.94))
              .frame(width: 48, height: 48)
              .background(.ultraThinMaterial.opacity(0.82), in: Circle())
              .overlay(Circle().strokeBorder(.white.opacity(0.20), lineWidth: 0.8))
          }
          .buttonStyle(.plain)
          .accessibilityLabel(audio.isPlaying ? "Pause audiobook" : "Play audiobook")
          .accessibilityHint("Reads The Wild Between aloud")
          .padding(.bottom, max(geometry.safeAreaInsets.bottom, 22) + 15)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}

private struct LiveReadingLinesPane: View {
  var audio: AudioReadingModel
  var startingPage: Int

  private var focusIndex: Int {
    if audio.hasStartedPlayback {
      return min(max(audio.currentLineIndex, 0), max(audio.lines.count - 1, 0))
    }
    return audio.lines.firstIndex(where: { $0.pageIndex >= startingPage }) ?? 0
  }

  private var visibleLines: [SpeechLine] {
    guard !audio.lines.isEmpty else { return [] }
    let center = min(max(focusIndex, 0), audio.lines.count - 1)
    let lowerBound = max(center - 1, 0)
    let upperBound = min(center + 2, audio.lines.count)
    return Array(audio.lines[lowerBound..<upperBound])
  }

  private var focusLineID: String? {
    audio.lines.indices.contains(focusIndex) ? audio.lines[focusIndex].id : nil
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        LinearGradient(
          colors: [FolioPalette.forest, FolioPalette.forestShade],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        VStack(alignment: .leading, spacing: 0) {
          VStack(alignment: .leading, spacing: 7) {
            Text("FOLLOW ALONG")
              .font(.system(.caption2, design: .rounded, weight: .semibold))
              .tracking(1.8)
              .foregroundStyle(FolioPalette.gold.opacity(0.9))

            Text(audio.isPlaying ? "READING NOW" : audio.hasStartedPlayback ? "PAUSED" : "READY TO READ")
              .font(.system(.caption, design: .rounded, weight: .medium))
              .tracking(1.2)
              .foregroundStyle(FolioPalette.page.opacity(0.60))
          }
          .padding(.bottom, 22)

          ScrollViewReader { proxy in
            ScrollView {
              LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(visibleLines) { line in
                  let isCurrent = line.id == focusLineID

                  SpeechSynchronizedText(
                    line: line,
                    spokenCharacterRange: audio.hasStartedPlayback && isCurrent ? audio.spokenCharacterRange : nil,
                    textColor: isCurrent ? FolioPalette.page : FolioPalette.page.opacity(0.42),
                    spokenTextColor: FolioPalette.gold,
                    spokenBackgroundColor: FolioPalette.gold.opacity(0.16)
                  )
                  .font(.system(isCurrent ? .title3 : .body, design: .serif, weight: isCurrent ? .medium : .regular))
                  .lineSpacing(5)
                  .multilineTextAlignment(.leading)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .id(line.id)
                }
              }
              .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            .onChange(of: focusLineID) { _, lineID in
              guard audio.hasStartedPlayback, let lineID else { return }
              withAnimation(.smooth(duration: 0.35)) {
                proxy.scrollTo(lineID, anchor: .center)
              }
            }
            .task(id: focusLineID) {
              guard let focusLineID else { return }
              await Task.yield()
              proxy.scrollTo(focusLineID, anchor: .center)
            }
          }
          .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, min(max(geometry.size.width * 0.08, 24), 56))
        .padding(.vertical, max(geometry.safeAreaInsets.top, 28))
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .accessibilityLabel("Audiobook text, synchronized with playback")
  }
}

struct BookCoverArtwork: View {
  var body: some View {
    GeometryReader { geometry in
      let size = geometry.size
      ZStack {
        LinearGradient(
          colors: [Color(red: 0.12, green: 0.27, blue: 0.23), FolioPalette.forestShade],
          startPoint: .top,
          endPoint: .bottom
        )

        Canvas { context, canvasSize in
          let sunDiameter = min(canvasSize.width, canvasSize.height) * 0.40
          let sun = CGRect(
            x: canvasSize.width * 0.5 - sunDiameter / 2,
            y: canvasSize.height * 0.30 - sunDiameter / 2,
            width: sunDiameter,
            height: sunDiameter
          )
          context.fill(Path(ellipseIn: sun), with: .color(FolioPalette.gold.opacity(0.82)))

          for star in [
            CGPoint(x: 0.15, y: 0.14), CGPoint(x: 0.30, y: 0.23), CGPoint(x: 0.75, y: 0.13),
            CGPoint(x: 0.86, y: 0.26), CGPoint(x: 0.65, y: 0.19), CGPoint(x: 0.42, y: 0.11)
          ] {
            let dot = CGRect(x: canvasSize.width * star.x, y: canvasSize.height * star.y, width: 2, height: 2)
            context.fill(Path(ellipseIn: dot), with: .color(FolioPalette.page.opacity(0.78)))
          }

          var distantHill = Path()
          distantHill.move(to: CGPoint(x: 0, y: canvasSize.height * 0.62))
          distantHill.addCurve(
            to: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.63),
            control1: CGPoint(x: canvasSize.width * 0.28, y: canvasSize.height * 0.48),
            control2: CGPoint(x: canvasSize.width * 0.72, y: canvasSize.height * 0.74)
          )
          distantHill.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height))
          distantHill.addLine(to: CGPoint(x: 0, y: canvasSize.height))
          distantHill.closeSubpath()
          context.fill(distantHill, with: .color(Color(red: 0.16, green: 0.33, blue: 0.27)))

          var nearHill = Path()
          nearHill.move(to: CGPoint(x: 0, y: canvasSize.height * 0.82))
          nearHill.addCurve(
            to: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.74),
            control1: CGPoint(x: canvasSize.width * 0.30, y: canvasSize.height * 0.68),
            control2: CGPoint(x: canvasSize.width * 0.72, y: canvasSize.height * 0.93)
          )
          nearHill.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height))
          nearHill.addLine(to: CGPoint(x: 0, y: canvasSize.height))
          nearHill.closeSubpath()
          context.fill(nearHill, with: .color(FolioPalette.forestShade))

          for tree in [(0.12, 0.82, 0.21), (0.23, 0.84, 0.15), (0.79, 0.77, 0.25), (0.90, 0.83, 0.18)] {
            let center = CGPoint(x: canvasSize.width * tree.0, y: canvasSize.height * tree.1)
            let height = canvasSize.height * tree.2
            var silhouette = Path()
            silhouette.move(to: CGPoint(x: center.x, y: center.y - height))
            silhouette.addLine(to: CGPoint(x: center.x - height * 0.3, y: center.y))
            silhouette.addLine(to: CGPoint(x: center.x + height * 0.3, y: center.y))
            silhouette.closeSubpath()
            context.fill(silhouette, with: .color(Color(red: 0.04, green: 0.12, blue: 0.11)))
          }
        }

        VStack(spacing: 0) {
          Text("F O L I O")
            .font(.system(size: min(size.width * 0.025, 13), weight: .medium, design: .rounded))
            .tracking(2.2)
            .foregroundStyle(FolioPalette.gold)
            .padding(.top, size.height * 0.11)

          Spacer(minLength: 20)

          VStack(spacing: 3) {
            Text("THE WILD")
            Text("BETWEEN")
          }
          .font(.system(size: min(size.width * 0.092, 46), weight: .regular, design: .serif))
          .tracking(2.2)
          .foregroundStyle(FolioPalette.page)
          .shadow(color: FolioPalette.forestShade.opacity(0.7), radius: 10, y: 3)

          Text("A NOVEL")
            .font(.system(size: min(size.width * 0.022, 11), weight: .medium, design: .rounded))
            .tracking(3.2)
            .foregroundStyle(FolioPalette.gold)
            .padding(.top, 12)

          Spacer(minLength: 20)

          Rectangle()
            .fill(FolioPalette.gold.opacity(0.76))
            .frame(width: min(size.width * 0.10, 40), height: 1)
            .padding(.bottom, 12)

          Text("M I R A   S O L")
            .font(.system(size: min(size.width * 0.021, 10), weight: .medium, design: .rounded))
            .foregroundStyle(FolioPalette.page.opacity(0.88))
            .padding(.bottom, max(size.height * 0.16, 76))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
      }
      .frame(width: size.width, height: size.height)
    }
    .accessibilityLabel("The Wild Between, a novel by Mira Sol")
  }
}
