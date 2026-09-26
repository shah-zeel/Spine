import Foundation

struct BookPage: Identifiable {
  var id: Int { number }
  var number: Int
  var section: String
  var title: String?
  var content: String
}
