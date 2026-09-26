import AVFoundation
import Foundation
import Observation

struct SpeechLine: Identifiable, Equatable {
  var pageIndex: Int
  var text: String
  var location: Int
  var length: Int

  var id: String { "\(pageIndex):\(location)" }
  var range: NSRange { NSRange(location: location, length: length) }
}

enum BookSpeech {
  static let lines = SampleBook.pages.enumerated().flatMap { pageIndex, page in
    sentenceLines(in: page.content, pageIndex: pageIndex)
  }

  private static func sentenceLines(in text: String, pageIndex: Int) -> [SpeechLine] {
    guard let expression = try? NSRegularExpression(pattern: "[^.!?\\n]+[.!?]?") else { return [] }
    let source = text as NSString
    return expression.matches(in: text, range: NSRange(location: 0, length: source.length)).compactMap { match in
      var location = match.range.location
      var length = match.range.length
      while length > 0 && isWhitespace(source.substring(with: NSRange(location: location, length: 1))) {
        location += 1
        length -= 1
      }
      while length > 0 && isWhitespace(source.substring(with: NSRange(location: location + length - 1, length: 1))) {
        length -= 1
      }
      guard length > 0 else { return nil }
      let range = NSRange(location: location, length: length)
      return SpeechLine(pageIndex: pageIndex, text: source.substring(with: range), location: location, length: length)
    }
  }

  private static func isWhitespace(_ value: String) -> Bool {
    value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

@MainActor
@Observable
final class AudioReadingModel: NSObject, AVSpeechSynthesizerDelegate {
  private(set) var isPlaying = false
  private(set) var hasStartedPlayback = false
  private(set) var currentLineIndex = 0

  var lines: [SpeechLine] { BookSpeech.lines }
  var currentLine: SpeechLine? { lines.indices.contains(currentLineIndex) ? lines[currentLineIndex] : nil }
  var activeLineID: String? { currentLine?.id }

  @ObservationIgnored private let synthesizer = AVSpeechSynthesizer()
  @ObservationIgnored private var lineIndices: [ObjectIdentifier: Int] = [:]
  @ObservationIgnored private var activeUtterance: ObjectIdentifier?

  override init() {
    super.init()
    synthesizer.delegate = self
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
  }

  func toggle(startingAtPage pageIndex: Int? = nil) {
    if synthesizer.isPaused {
      synthesizer.continueSpeaking()
      isPlaying = true
      hasStartedPlayback = true
    } else if synthesizer.isSpeaking {
      synthesizer.pauseSpeaking(at: .immediate)
      isPlaying = false
    } else {
      if let pageIndex,
        let firstLine = lines.firstIndex(where: { $0.pageIndex >= pageIndex }) {
        currentLineIndex = firstLine
      } else if currentLineIndex >= lines.count {
        currentLineIndex = 0
      }
      speakCurrentLine()
    }
  }

  func start(atPage pageIndex: Int) {
    invalidateCurrentUtterance()
    currentLineIndex = lines.firstIndex(where: { $0.pageIndex >= pageIndex }) ?? 0
    speakCurrentLine()
  }

  func synchronize(toPage pageIndex: Int) {
    let shouldResume = isPlaying
    invalidateCurrentUtterance()
    currentLineIndex = lines.firstIndex(where: { $0.pageIndex >= pageIndex }) ?? 0
    if shouldResume {
      speakCurrentLine()
    }
  }

  private func invalidateCurrentUtterance() {
    if synthesizer.isSpeaking || synthesizer.isPaused {
      isPlaying = false
      activeUtterance = nil
      lineIndices.removeAll()
      synthesizer.stopSpeaking(at: .immediate)
    }
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    willSpeakRangeOfSpeechString characterRange: NSRange,
    utterance: AVSpeechUtterance
  ) {
    let id = ObjectIdentifier(utterance)
    if activeUtterance == id, let index = lineIndices[id] {
      currentLineIndex = index
    }
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    let id = ObjectIdentifier(utterance)
    lineIndices.removeValue(forKey: id)
    guard activeUtterance == id else { return }
    activeUtterance = nil
    guard isPlaying else { return }
    currentLineIndex += 1
    if currentLineIndex < lines.count {
      speakCurrentLine()
    } else {
      isPlaying = false
      currentLineIndex = max(lines.count - 1, 0)
    }
  }

  private func speakCurrentLine() {
    guard lines.indices.contains(currentLineIndex) else {
      isPlaying = false
      return
    }
    let utterance = AVSpeechUtterance(string: lines[currentLineIndex].text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
    lineIndices[ObjectIdentifier(utterance)] = currentLineIndex
    activeUtterance = ObjectIdentifier(utterance)
    isPlaying = true
    hasStartedPlayback = true
    synthesizer.speak(utterance)
  }
}
