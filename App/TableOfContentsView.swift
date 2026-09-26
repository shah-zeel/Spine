import SwiftUI

struct TableOfContentsView: View {
  @Environment(\.dismiss) private var dismiss
  var onSelect: (Int) -> Void

  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(SampleBook.chapters) { chapter in
            Button {
              onSelect(chapter.pageIndex)
              dismiss()
            } label: {
              VStack(alignment: .leading, spacing: 5) {
                Text(chapter.title)
                  .font(.system(.headline, design: .serif))
                  .foregroundStyle(FolioPalette.ink)

                HStack {
                  Text(chapter.subtitle)
                  Spacer()
                  Text("Page \(SampleBook.pages[chapter.pageIndex].number)")
                    .monospacedDigit()
                }
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(FolioPalette.mutedInk)
              }
              .padding(.vertical, 5)
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        } header: {
          Text("The Wild Between")
        } footer: {
          Text("Sample edition · 12 pages")
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Contents")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
    .presentationDragIndicator(.visible)
  }
}
