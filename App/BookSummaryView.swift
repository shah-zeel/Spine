import SwiftUI

struct BookSummaryView: View {
  @Environment(\.dismiss) private var dismiss

  var pages: [BookPage]
  var annotations: [PassageAnnotation]

  @State private var summary: String?
  @State private var errorMessage: String?
  @State private var isGenerating = false

  private var savedAnnotations: [PassageAnnotation] {
    annotations.filter { $0.hasHighlight || !$0.comment.isEmpty }
  }

  var body: some View {
    NavigationStack {
      Group {
        if savedAnnotations.isEmpty {
          ContentUnavailableView(
            "No saved notes or highlights",
            systemImage: "quote.bubble",
            description: Text("Highlight a passage or add a note while reading, then return here for a personalized summary.")
          )
        } else {
          ScrollView {
            VStack(alignment: .leading, spacing: 20) {
              Label("On-device AI summary", systemImage: "sparkles")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(FolioPalette.accent)

              Text("Uses your \(savedAnnotations.count) saved \(savedAnnotations.count == 1 ? "annotation" : "annotations") and the full book text to connect your marked passages to the story. Your notes stay on this device.")
                .font(.subheadline)
                .foregroundStyle(FolioPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

              if let summary {
                VStack(alignment: .leading, spacing: 10) {
                  Text("Your reading summary")
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(FolioPalette.ink)
                  Text(summary)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(FolioPalette.ink)
                    .lineSpacing(5)
                    .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(FolioPalette.page, in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                  RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(FolioPalette.rule.opacity(0.55), lineWidth: 0.8)
                }
              }

              if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                  .fixedSize(horizontal: false, vertical: true)
              }

              if isGenerating {
                ProgressView("Summarizing your notes with the book context…")
                  .tint(FolioPalette.accent)
                  .frame(maxWidth: .infinity, alignment: .leading)
              } else {
                Button {
                  Task { await createSummary() }
                } label: {
                  Label(summary == nil ? "Create summary" : "Create a new summary", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(FolioPalette.accent)
              }
            }
            .padding(24)
            .frame(maxWidth: 620, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
          }
        }
      }
      .background(FolioPalette.canvas)
      .navigationTitle("Reading summary")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
  }

  @MainActor
  private func createSummary() async {
    guard !isGenerating else { return }
    isGenerating = true
    errorMessage = nil
    defer { isGenerating = false }

    do {
      summary = try await BookSummaryAgent().summarize(pages: pages, annotations: savedAnnotations)
    } catch let error as BookSummaryError {
      errorMessage = error.localizedDescription
    } catch {
      errorMessage = "Couldn’t create a summary. Please try again."
    }
  }
}
