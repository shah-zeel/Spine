import Foundation
import Observation
import SwiftUI

enum PassageColor: String, CaseIterable, Codable, Identifiable {
  case honey
  case sage
  case rose

  var id: String { rawValue }

  var title: String {
    switch self {
    case .honey: "Honey"
    case .sage: "Sage"
    case .rose: "Rose"
    }
  }

  var tint: Color {
    switch self {
    case .honey: Color(red: 0.91, green: 0.75, blue: 0.36)
    case .sage: Color(red: 0.53, green: 0.72, blue: 0.54)
    case .rose: Color(red: 0.83, green: 0.51, blue: 0.49)
    }
  }
}

struct SelectedPassage: Equatable, Identifiable {
  var pageIndex: Int
  var quote: String
  var range: NSRange

  var id: String { "\(pageIndex):\(range.location):\(range.length)" }
}

struct PassageHighlight: Equatable, Identifiable {
  var id: UUID
  var range: NSRange
  var color: PassageColor
}

struct PassageAnnotation: Codable, Identifiable, Equatable {
  var id: UUID
  var pageIndex: Int
  var quote: String
  var location: Int
  var length: Int
  var color: PassageColor
  var hasHighlight: Bool
  var comment: String
  var createdAt: Date
  var updatedAt: Date

  var range: NSRange { NSRange(location: location, length: length) }
}

@MainActor
@Observable
final class ReaderNotebook {
  private(set) var annotations: [PassageAnnotation]

  @ObservationIgnored private let defaults: UserDefaults
  @ObservationIgnored private let storageKey = "folio.passageAnnotations"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    if let data = defaults.data(forKey: storageKey),
      let decoded = try? JSONDecoder().decode([PassageAnnotation].self, from: data) {
      annotations = decoded
    } else {
      annotations = Self.demoAnnotations(in: SampleBook.pages)
      if !annotations.isEmpty { persist() }
    }
  }

  func highlights(on pageIndex: Int) -> [PassageHighlight] {
    annotations.compactMap { annotation in
      guard annotation.pageIndex == pageIndex, annotation.hasHighlight else { return nil }
      return PassageHighlight(id: annotation.id, range: annotation.range, color: annotation.color)
    }
  }

  func annotations(on pageIndex: Int) -> [PassageAnnotation] {
    annotations.filter { $0.pageIndex == pageIndex }
  }

  func annotation(for passage: SelectedPassage) -> PassageAnnotation? {
    find(passage)
  }

  func highlight(_ passage: SelectedPassage, color: PassageColor) {
    var annotation = find(passage) ?? makeAnnotation(for: passage, color: color)
    annotation.color = color
    annotation.hasHighlight = true
    annotation.updatedAt = .now
    store(annotation)
  }

  func saveComment(_ comment: String, for passage: SelectedPassage, color: PassageColor = .honey) {
    var annotation = find(passage) ?? makeAnnotation(for: passage, color: color)
    annotation.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
    annotation.color = color
    annotation.updatedAt = .now
    store(annotation)
  }

  func update(_ annotation: PassageAnnotation, comment: String, color: PassageColor) {
    guard let index = annotations.firstIndex(where: { $0.id == annotation.id }) else { return }
    annotations[index].comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
    annotations[index].color = color
    annotations[index].updatedAt = .now
    persist()
  }

  func remove(_ annotation: PassageAnnotation) {
    annotations.removeAll { $0.id == annotation.id }
    persist()
  }

  private func find(_ passage: SelectedPassage) -> PassageAnnotation? {
    annotations.first {
      $0.pageIndex == passage.pageIndex
        && $0.location == passage.range.location
        && $0.length == passage.range.length
    }
  }

  private func makeAnnotation(for passage: SelectedPassage, color: PassageColor) -> PassageAnnotation {
    PassageAnnotation(
      id: UUID(),
      pageIndex: passage.pageIndex,
      quote: passage.quote,
      location: passage.range.location,
      length: passage.range.length,
      color: color,
      hasHighlight: false,
      comment: "",
      createdAt: .now,
      updatedAt: .now
    )
  }

  private static func demoAnnotations(in pages: [BookPage]) -> [PassageAnnotation] {
    let examples: [(pageNumber: Int, quote: String, color: PassageColor, hasHighlight: Bool, comment: String)] = [
      (
        pageNumber: 2,
        quote: "Mara had not seen it since she was nine, but she knew the door at once.",
        color: .honey,
        hasHighlight: true,
        comment: ""
      ),
      (
        pageNumber: 5,
        quote: "The sight made the distance feel kind instead of large.",
        color: .rose,
        hasHighlight: false,
        comment: "Mara's return feels less lonely once home starts to seem close and welcoming."
      ),
      (
        pageNumber: 7,
        quote: "The map started to look less like a place and more like a way of paying attention.",
        color: .sage,
        hasHighlight: true,
        comment: ""
      ),
      (
        pageNumber: 12,
        quote: "Tonight, it was enough to be here.",
        color: .honey,
        hasHighlight: false,
        comment: "Returning can be a beginning on its own."
      )
    ]

    return examples.compactMap { example in
      guard let pageIndex = pages.firstIndex(where: { $0.number == example.pageNumber }),
        let quoteRange = pages[pageIndex].content.range(of: example.quote) else {
        return nil
      }

      let storedRange = NSRange(quoteRange, in: pages[pageIndex].content)
      return PassageAnnotation(
        id: UUID(),
        pageIndex: pageIndex,
        quote: example.quote,
        location: storedRange.location,
        length: storedRange.length,
        color: example.color,
        hasHighlight: example.hasHighlight,
        comment: example.comment,
        createdAt: .now,
        updatedAt: .now
      )
    }
  }

  private func store(_ annotation: PassageAnnotation) {
    if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
      annotations[index] = annotation
    } else {
      annotations.append(annotation)
    }
    persist()
  }

  private func persist() {
    guard let data = try? JSONEncoder().encode(annotations) else { return }
    defaults.set(data, forKey: storageKey)
  }
}
