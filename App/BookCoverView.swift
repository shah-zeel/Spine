import SwiftUI

struct BookCoverView: View {
  @Bindable var audio: AudioReadingModel
  var startingPage: Int = 1

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        BookCoverArtwork()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .ignoresSafeArea()

        LiveReadingCaptionOverlay(audio: audio)
          .allowsHitTesting(false)

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
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .ignoresSafeArea()
    .accessibilityElement(children: .contain)
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
