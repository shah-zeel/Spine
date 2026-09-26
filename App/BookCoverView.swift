import SwiftUI

struct BookCoverView: View {
  var progress: Double
  var onContinue: () -> Void

  var body: some View {
    GeometryReader { geometry in
      let isLandscape = geometry.size.width > geometry.size.height
      let coverHeight = isLandscape
        ? min(geometry.size.height * 0.76, 320)
        : min(geometry.size.height * 0.52, 405)

      ZStack {
        FolioPalette.canvas.ignoresSafeArea()

        RadialGradient(
          colors: [FolioPalette.page.opacity(0.55), FolioPalette.canvas.opacity(0.1)],
          center: .init(x: 0.5, y: 0.44),
          startRadius: 20,
          endRadius: max(geometry.size.width, geometry.size.height) * 0.72
        )
        .ignoresSafeArea()

        if isLandscape {
          HStack(spacing: min(geometry.size.width * 0.07, 54)) {
            BookCoverArtwork()
              .frame(width: coverHeight * 0.68, height: coverHeight)

            coverDetails
              .frame(maxWidth: 310, alignment: .leading)
          }
          .frame(maxWidth: 760, maxHeight: .infinity)
          .padding(.horizontal, 28)
        } else {
          VStack(spacing: 20) {
            Spacer(minLength: 8)

            BookCoverArtwork()
              .frame(width: coverHeight * 0.68, height: coverHeight)

            Text("A quiet story about finding your way home.")
              .font(.system(.subheadline, design: .serif))
              .foregroundStyle(FolioPalette.mutedInk)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 36)

            continueButton

            Spacer(minLength: 8)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.horizontal, 20)
        }
      }
    }
  }

  private var coverDetails: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text("YOUR PLACE IN THE STORY")
        .font(.system(.caption2, design: .rounded, weight: .semibold))
        .tracking(1.7)
        .foregroundStyle(FolioPalette.mutedInk)

      Text("The Wild Between")
        .font(.system(.largeTitle, design: .serif))
        .foregroundStyle(FolioPalette.ink)

      Text("Mira Sol  ·  Sample edition")
        .font(.system(.subheadline, design: .rounded))
        .foregroundStyle(FolioPalette.mutedInk)

      ProgressView(value: progress)
        .tint(FolioPalette.accent)
        .padding(.top, 6)
        .accessibilityLabel("Reading progress")
        .accessibilityValue("\(Int(progress * 100)) percent")

      continueButton
        .padding(.top, 8)
    }
  }

  private var continueButton: some View {
    Button(action: onContinue) {
      Label("Continue reading", systemImage: "book.closed.fill")
        .font(.system(.headline, design: .rounded))
        .foregroundStyle(FolioPalette.page)
        .padding(.horizontal, 23)
        .frame(minHeight: 54)
        .background(Capsule().fill(FolioPalette.forest))
    }
    .buttonStyle(.plain)
    .accessibilityHint("Opens the book at your last page")
  }
}

private struct BookCoverArtwork: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 6, style: .continuous)
        .fill(FolioPalette.forest)

      Canvas { context, size in
        let sun = CGRect(
          x: size.width * 0.59,
          y: size.height * 0.30,
          width: size.width * 0.26,
          height: size.width * 0.26
        )
        context.fill(Path(ellipseIn: sun), with: .color(FolioPalette.gold.opacity(0.78)))

        var farHills = Path()
        farHills.move(to: CGPoint(x: 0, y: size.height * 0.62))
        farHills.addCurve(
          to: CGPoint(x: size.width, y: size.height * 0.62),
          control1: CGPoint(x: size.width * 0.30, y: size.height * 0.46),
          control2: CGPoint(x: size.width * 0.60, y: size.height * 0.69)
        )
        farHills.addLine(to: CGPoint(x: size.width, y: size.height))
        farHills.addLine(to: CGPoint(x: 0, y: size.height))
        farHills.closeSubpath()
        context.fill(farHills, with: .color(Color(red: 0.16, green: 0.31, blue: 0.25)))

        var nearHills = Path()
        nearHills.move(to: CGPoint(x: 0, y: size.height * 0.80))
        nearHills.addCurve(
          to: CGPoint(x: size.width, y: size.height * 0.70),
          control1: CGPoint(x: size.width * 0.32, y: size.height * 0.66),
          control2: CGPoint(x: size.width * 0.72, y: size.height * 0.90)
        )
        nearHills.addLine(to: CGPoint(x: size.width, y: size.height))
        nearHills.addLine(to: CGPoint(x: 0, y: size.height))
        nearHills.closeSubpath()
        context.fill(nearHills, with: .color(FolioPalette.forestShade))

        for tree in [
          (CGFloat(0.12), CGFloat(0.76), CGFloat(0.25)),
          (CGFloat(0.23), CGFloat(0.79), CGFloat(0.18)),
          (CGFloat(0.82), CGFloat(0.73), CGFloat(0.28)),
          (CGFloat(0.91), CGFloat(0.79), CGFloat(0.20))
        ] {
          let centerX = size.width * tree.0
          let baseY = size.height * tree.1
          let treeHeight = size.height * tree.2
          var silhouette = Path()
          silhouette.move(to: CGPoint(x: centerX, y: baseY - treeHeight))
          silhouette.addLine(to: CGPoint(x: centerX - treeHeight * 0.30, y: baseY))
          silhouette.addLine(to: CGPoint(x: centerX + treeHeight * 0.30, y: baseY))
          silhouette.closeSubpath()
          context.fill(silhouette, with: .color(FolioPalette.forestShade.opacity(0.9)))
        }
      }

      VStack(spacing: 0) {
        Text("F O L I O")
          .font(.system(size: 8, weight: .medium, design: .rounded))
          .tracking(1.2)
          .foregroundStyle(FolioPalette.gold.opacity(0.95))
          .padding(.top, 27)

        Spacer(minLength: 14)

        VStack(spacing: 2) {
          Text("THE WILD")
          Text("BETWEEN")
        }
        .font(.system(size: 27, weight: .regular, design: .serif))
        .tracking(1.7)
        .foregroundStyle(FolioPalette.page)
        .shadow(color: FolioPalette.forestShade.opacity(0.5), radius: 9, y: 2)

        Text("A NOVEL")
          .font(.system(size: 8, weight: .medium, design: .rounded))
          .tracking(2.2)
          .foregroundStyle(FolioPalette.gold)
          .padding(.top, 11)

        Spacer(minLength: 12)

        Rectangle()
          .fill(FolioPalette.gold.opacity(0.75))
          .frame(width: 34, height: 1)
          .padding(.bottom, 12)

        Text("M I R A   S O L")
          .font(.system(size: 8, weight: .medium, design: .rounded))
          .foregroundStyle(FolioPalette.page.opacity(0.88))
          .padding(.bottom, 27)
      }

      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .strokeBorder(FolioPalette.gold.opacity(0.56), lineWidth: 0.8)
        .padding(10)
    }
    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    .overlay(alignment: .leading) {
      Rectangle()
        .fill(LinearGradient(colors: [FolioPalette.forestShade, FolioPalette.forest.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
        .frame(width: 8)
        .padding(.vertical, 5)
    }
    .shadow(color: FolioPalette.ink.opacity(0.23), radius: 18, x: 8, y: 14)
    .accessibilityLabel("Cover of The Wild Between by Mira Sol")
  }
}
