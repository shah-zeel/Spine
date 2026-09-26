import SwiftUI
import UIKit

struct TentPostureView: View {
  var audio: AudioReadingModel
  var notebook: ReaderNotebook

  var body: some View {
    if #available(iOS 27.1, *) {
      ArrangementView {
        BookCoverReadingLayout(
          audio: audio,
          startingPage: audio.currentLine?.pageIndex ?? 0,
          showsPlayControl: false
        )
      } secondary: {
        TentAudioView(audio: audio, notebook: notebook)
          .rotationEffect(.degrees(180))
      }
      .arrangementViewStyle(.overlay)
      .background(FolioPalette.forestShade)
    } else {
      TentAudioView(audio: audio, notebook: notebook)
    }
  }
}

struct TentAudioView: View {
  var audio: AudioReadingModel
  var notebook: ReaderNotebook

  @State private var selectedPassage: SelectedPassage?
  @State private var isShowingAnnotations = false
  @State private var editingPassage: SelectedPassage?

  private var visibleLines: [SpeechLine] {
    guard !audio.lines.isEmpty else { return [] }
    let center = min(max(audio.currentLineIndex, 0), audio.lines.count - 1)
    let lowerBound = max(center - 1, 0)
    let upperBound = min(center + 2, audio.lines.count)
    return Array(audio.lines[lowerBound..<upperBound])
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        LinearGradient(
          colors: [Color(red: 0.12, green: 0.25, blue: 0.21), FolioPalette.forestShade],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollViewReader { proxy in
          VStack(spacing: 0) {
            Text("THE WILD BETWEEN")
              .font(.system(.caption2, design: .rounded, weight: .semibold))
              .tracking(1.8)
              .foregroundStyle(FolioPalette.gold.opacity(0.9))
              .padding(.top, max(geometry.safeAreaInsets.top, 18) + 28)

            Button {
              audio.toggle(startingAtPage: audio.currentLine?.pageIndex ?? 0)
            } label: {
              Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FolioPalette.forestShade)
                .frame(width: 58, height: 58)
                .background(FolioPalette.gold, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(audio.isPlaying ? "Pause audiobook" : "Play audiobook")
            .padding(.top, 24)

            Text(audio.isPlaying ? "FOLLOWING AUDIO" : audio.hasStartedPlayback ? "PAUSED" : "READY TO READ")
              .font(.system(.caption2, design: .rounded, weight: .semibold))
              .tracking(1.4)
              .foregroundStyle(.white.opacity(0.55))
              .padding(.top, 11)

            ScrollView {
              LazyVStack(spacing: 12) {
                ForEach(visibleLines) { line in
                  TentSentenceLine(
                    line: line,
                    isCurrent: audio.hasStartedPlayback && line.id == audio.activeLineID,
                    spokenCharacterRange: audio.activeLineID == line.id ? audio.spokenCharacterRange : nil,
                    annotation: annotation(for: line)
                  ) {
                    selectedPassage = SelectedPassage(pageIndex: line.pageIndex, quote: line.text, range: line.range)
                  }
                  .id(line.id)
                }
              }
              .frame(maxWidth: 620)
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 28)
              .padding(.vertical, 26)
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: .infinity)
            .onChange(of: audio.activeLineID) { _, lineID in
              guard audio.hasStartedPlayback, let lineID else { return }
              withAnimation(.smooth(duration: 0.4)) {
                proxy.scrollTo(lineID, anchor: .center)
              }
            }
            .task(id: audio.activeLineID) {
              guard audio.hasStartedPlayback, let lineID = audio.activeLineID else { return }
              await Task.yield()
              proxy.scrollTo(lineID, anchor: .center)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        if let selectedPassage {
          PassageActionBar(
            onHighlight: { color in notebook.highlight(selectedPassage, color: color) },
            onAddNote: { editingPassage = selectedPassage },
            onDismiss: { self.selectedPassage = nil },
            onShowAnnotations: { isShowingAnnotations = true }
          )
          .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20) + 18)
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .animation(.smooth(duration: 0.2), value: selectedPassage)
    }
    .sheet(isPresented: $isShowingAnnotations) {
      AnnotationLibraryView(notebook: notebook)
    }
    .sheet(item: $editingPassage) { passage in
      AnnotationEditorView(notebook: notebook, passage: passage, existing: notebook.annotation(for: passage))
    }
  }

  private func annotation(for line: SpeechLine) -> PassageAnnotation? {
    notebook.annotations(on: line.pageIndex).first {
      $0.hasHighlight && NSIntersectionRange($0.range, line.range).length > 0
    }
  }
}

private struct TentSentenceLine: View {
  var line: SpeechLine
  var isCurrent: Bool
  var spokenCharacterRange: NSRange?
  var annotation: PassageAnnotation?
  var onSelect: () -> Void

  var body: some View {
    Button(action: onSelect) {
      SpeechSynchronizedText(
        line: line,
        spokenCharacterRange: isCurrent ? spokenCharacterRange : nil,
        textColor: isCurrent ? FolioPalette.page : FolioPalette.page.opacity(0.48),
        spokenTextColor: FolioPalette.forestShade,
        spokenBackgroundColor: FolioPalette.gold
      )
        .font(.system(isCurrent ? .title3 : .body, design: .serif, weight: isCurrent ? .medium : .regular))
        .lineSpacing(5)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
          if isCurrent {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(FolioPalette.gold.opacity(0.19))
          } else if let annotation {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(annotation.color.tint.opacity(0.16))
          }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Select passage: \(line.text)")
    .accessibilityHint("Opens highlight and note actions for this sentence")
  }
}

struct SpeechSynchronizedText: View {
  var line: SpeechLine
  var spokenCharacterRange: NSRange?
  var textColor: Color
  var spokenTextColor: Color
  var spokenBackgroundColor: Color

  private var attributedText: AttributedString {
    let source = NSMutableAttributedString(string: line.text)
    let fullRange = NSRange(location: 0, length: (line.text as NSString).length)
    source.addAttribute(.foregroundColor, value: UIColor(textColor), range: fullRange)

    if let spokenCharacterRange,
      spokenCharacterRange.location >= 0,
      spokenCharacterRange.length > 0,
      NSMaxRange(spokenCharacterRange) <= fullRange.length {
      source.addAttributes(
        [
          .foregroundColor: UIColor(spokenTextColor),
          .backgroundColor: UIColor(spokenBackgroundColor)
        ],
        range: spokenCharacterRange
      )
    }

    return (try? AttributedString(source, including: \.uiKit)) ?? AttributedString(line.text)
  }

  var body: some View {
    Text(attributedText)
  }
}
