import SwiftUI

struct BookPageView: View {
  var page: BookPage

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .firstTextBaseline) {
          Text(page.section.uppercased())
            .font(.system(.caption2, design: .rounded, weight: .semibold))
            .tracking(1.1)
            .lineLimit(1)
            .minimumScaleFactor(0.75)

          Spacer(minLength: 8)

          Text("FOLIO")
            .font(.system(size: 8, weight: .medium, design: .rounded))
            .tracking(1.4)
            .foregroundStyle(FolioPalette.mutedInk.opacity(0.72))
        }
        .foregroundStyle(FolioPalette.mutedInk)

        Rectangle()
          .fill(FolioPalette.rule.opacity(0.7))
          .frame(height: 1)
          .padding(.top, 11)

        Spacer(minLength: 20)

        if let title = page.title {
          Text(title)
            .font(.system(.title2, design: .serif))
            .foregroundStyle(FolioPalette.ink)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 17)
        }

        Text(page.content)
          .font(.system(.body, design: .serif))
          .lineSpacing(5)
          .foregroundStyle(FolioPalette.ink)
          .fixedSize(horizontal: false, vertical: true)
          .textSelection(.enabled)

        Spacer(minLength: 20)

        HStack {
          Rectangle()
            .fill(FolioPalette.accent.opacity(0.75))
            .frame(width: 26, height: 1)

          Spacer()

          Text(String(format: "%02d", page.number))
            .font(.system(.caption2, design: .rounded, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(FolioPalette.mutedInk)
        }
      }
      .padding(.horizontal, min(max(geometry.size.width * 0.095, 18), 42))
      .padding(.vertical, min(max(geometry.size.height * 0.075, 18), 48))
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    .background(FolioPalette.page)
    .overlay {
      Rectangle()
        .strokeBorder(FolioPalette.rule.opacity(0.42), lineWidth: 0.7)
    }
  }
}
