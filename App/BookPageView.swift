import SwiftUI
import UIKit

struct BookPageView: View {
  var page: BookPage
  var notebook: ReaderNotebook
  var activeSpeechLine: SpeechLine?
  var onSelectionChange: (SelectedPassage?) -> Void

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
          .padding(.bottom, page.title == nil ? 24 : 20)

        if let title = page.title {
          Text(title)
            .font(.system(.title2, design: .serif))
            .foregroundStyle(FolioPalette.ink)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 14)
        }

        SelectablePageTextView(
          pageIndex: page.number - 1,
          text: page.content,
          highlights: notebook.highlights(on: page.number - 1),
          activeRange: activeSpeechLine?.pageIndex == page.number - 1 ? activeSpeechLine?.range : nil,
          onSelectionChange: onSelectionChange
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        .padding(.top, 12)
      }
      .padding(.horizontal, min(max(geometry.size.width * 0.095, 25), 68))
      .padding(.vertical, min(max(geometry.size.height * 0.065, 22), 56))
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    .background(FolioPalette.page)
    .overlay {
      Rectangle()
        .strokeBorder(FolioPalette.rule.opacity(0.42), lineWidth: 0.7)
    }
    .accessibilityElement(children: .contain)
  }
}

private struct SelectablePageTextView: UIViewRepresentable {
  var pageIndex: Int
  var text: String
  var highlights: [PassageHighlight]
  var activeRange: NSRange?
  var onSelectionChange: (SelectedPassage?) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIView(context: Context) -> BookSelectableTextView {
    let textView = BookSelectableTextView()
    textView.delegate = context.coordinator
    textView.backgroundColor = .clear
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = true
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.adjustsFontForContentSizeCategory = true
    textView.accessibilityLabel = "Book text, page \(pageIndex + 1)"
    render(in: textView)
    return textView
  }

  func updateUIView(_ textView: BookSelectableTextView, context: Context) {
    context.coordinator.parent = self
    textView.accessibilityLabel = "Book text, page \(pageIndex + 1)"
    render(in: textView)
  }

  private func render(in textView: BookSelectableTextView) {
    let ranges = highlights.map { "\($0.range.location):\($0.range.length):\($0.color.rawValue)" }.joined(separator: "|")
    let active = activeRange.map { "\($0.location):\($0.length)" } ?? "none"
    let signature = "\(text)|\(ranges)|\(active)"
    guard textView.renderedSignature != signature else { return }

    let baseFont = UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17)
    let font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 7
    let attributed = NSMutableAttributedString(
      string: text,
      attributes: [
        .font: font,
        .foregroundColor: UIColor(FolioPalette.ink),
        .paragraphStyle: paragraph
      ]
    )
    for highlight in highlights where isValid(highlight.range, length: attributed.length) {
      attributed.addAttribute(.backgroundColor, value: UIColor(highlight.color.tint.opacity(0.34)), range: highlight.range)
    }
    if let activeRange, isValid(activeRange, length: attributed.length) {
      attributed.addAttribute(.backgroundColor, value: UIColor(FolioPalette.gold.opacity(0.46)), range: activeRange)
    }

    let selectedRange = textView.selectedRange
    textView.attributedText = attributed
    let safeLocation = min(selectedRange.location, attributed.length)
    let safeLength = min(selectedRange.length, attributed.length - safeLocation)
    textView.selectedRange = NSRange(location: safeLocation, length: safeLength)
    textView.renderedSignature = signature
  }

  private func isValid(_ range: NSRange, length: Int) -> Bool {
    range.location != NSNotFound && range.location >= 0 && range.length > 0 && NSMaxRange(range) <= length
  }

  final class Coordinator: NSObject, UITextViewDelegate {
    var parent: SelectablePageTextView

    init(parent: SelectablePageTextView) {
      self.parent = parent
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
      let selection = textView.selectedRange
      guard selection.length > 0, NSMaxRange(selection) <= (textView.text as NSString).length,
        let value = textView.text else {
        parent.onSelectionChange(nil)
        return
      }
      let quote = (value as NSString).substring(with: selection).trimmingCharacters(in: .whitespacesAndNewlines)
      guard !quote.isEmpty else {
        parent.onSelectionChange(nil)
        return
      }
      parent.onSelectionChange(SelectedPassage(pageIndex: parent.pageIndex, quote: quote, range: selection))
    }
  }
}

private final class BookSelectableTextView: UITextView {
  var renderedSignature = ""
}
