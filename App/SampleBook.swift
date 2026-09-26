import Foundation

struct BookChapter: Identifiable {
  var id: Int { pageIndex }
  var title: String
  var subtitle: String
  var pageIndex: Int
}

enum SampleBook {
  static var pages = [
    BookPage(
      number: 1,
      section: "A small beginning",
      title: nil,
      content: "For the ones who still take the long way home.\n\nSomewhere between the last streetlight and the first star, the world remembers how to be quiet."
    ),
    BookPage(
      number: 2,
      section: "Chapter one · The orchard at dusk",
      title: "The orchard at dusk",
      content: "At the end of Alder Lane, where the pavement gave way to fern and mud, there stood a house with one blue door. Mara had not seen it since she was nine, but she knew the door at once.\n\nHer key turned in the lock as if it had been waiting. Inside, the hall smelled of cedar, rain, and the apples her grandmother used to leave on the windowsill."
    ),
    BookPage(
      number: 3,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "She set her bag beneath the coat hooks. A small brass bell hung beside the kitchen, polished bright by years of passing hands. When Mara touched it, one clear note moved through the house.\n\nBeyond the back steps, the orchard leaned toward the evening. Its trees had grown wild while she was away, their branches stitched together with the last light of the day."
    ),
    BookPage(
      number: 4,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "At the far fence, a narrow gate opened onto the path she had followed as a child. It led past the creek, under the old railway bridge, and eventually to the hill where the whole town fit inside a single glance.\n\nMara took the path slowly. The first crickets had begun their careful tuning."
    ),
    BookPage(
      number: 5,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "Halfway up the hill she found a paper boat, folded from a page of her grandmother's garden journal. Someone had written a date inside it: tomorrow.\n\nShe turned the boat over in her palm. A seed rested in its crease, small as a comma."
    ),
    BookPage(
      number: 6,
      section: "Chapter two · A map of small things",
      title: "A map of small things",
      content: "The journal was waiting on the kitchen table the next morning. Its pages held no directions, only lists: three good stones, a window that catches rain, the name of every neighbor's dog.\n\nMara began where the list began, with the river pebble tucked under the blue door."
    ),
    BookPage(
      number: 7,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "By noon she had walked the length of Alder Lane and learned that the baker had a daughter in Lisbon, the postman kept a jar of buttons, and the oldest maple had survived a winter split by lightning.\n\nShe drew each discovery in the margin. The map started to look less like a place and more like a way of paying attention."
    ),
    BookPage(
      number: 8,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "On the bridge, she met a boy carrying a jar of rainwater. He said it was for the garden, though the garden was already green.\n\n“For when it isn't,” he said, as if this explained everything. Mara smiled. It did, a little."
    ),
    BookPage(
      number: 9,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "That evening she planted the seed beside the kitchen window. She watered it with the jar from the bridge and wrote one line in the journal: begin with what is here.\n\nThe house settled around her, familiar as a hand held open."
    ),
    BookPage(
      number: 10,
      section: "Chapter three · What the hill keeps",
      title: "What the hill keeps",
      content: "By the end of the week, the seed had sent up two bright leaves. Mara brought the journal to the hill and sat where the grass grew warmest.\n\nFrom there the town seemed to be made of small promises: a light left on, a gate mended, a loaf cooling behind glass."
    ),
    BookPage(
      number: 11,
      section: "Chapter three · What the hill keeps",
      title: nil,
      content: "The brass bell rang once in the distance. She could not tell whether the sound came from the house or from somewhere inside her memory. Either way, she answered it.\n\nOn the last page of the journal, her grandmother had drawn a blue door and left the rest of the paper blank."
    ),
    BookPage(
      number: 12,
      section: "Chapter three · What the hill keeps",
      title: nil,
      content: "Mara opened the journal to the first empty line. The sun slid behind the ridge, and the town began to gather its evening lights.\n\nShe wrote the date, then the name of the place where she had returned. Underneath, she drew a small seed."
    )
  ]

  static var chapters = [
    BookChapter(title: "The orchard at dusk", subtitle: "A blue door, left waiting", pageIndex: 1),
    BookChapter(title: "A map of small things", subtitle: "The town, one detail at a time", pageIndex: 5),
    BookChapter(title: "What the hill keeps", subtitle: "A place to begin again", pageIndex: 9)
  ]
}
