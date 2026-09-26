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
      content: "For the ones who still take the long way home. Somewhere between the last streetlight and the first star, the world remembers how to be quiet.\n\nThe road grows soft beneath our feet, and familiar windows shine like little lanterns. We stop hurrying. We notice the rain caught on a leaf, the warm square of a kitchen, the moon following us over the rooftops.\n\nA home is not always the place we left. Sometimes it is a door we have not opened in years, waiting patiently at the end of a lane. Sometimes it is the small courage to turn a key and see what the evening has kept for us.\n\nThe quiet is not empty. It is a place where small thoughts can settle, where the names we have forgotten return gently, and where a beginning can wait without making a sound."
    ),
    BookPage(
      number: 2,
      section: "Chapter one · The orchard at dusk",
      title: "The orchard at dusk",
      content: "At the end of Alder Lane, where the pavement gave way to fern and mud, there stood a house with one blue door. Mara had not seen it since she was nine, but she knew the door at once. The paint had faded around the handle, and one hinge leaned slightly lower than the other. Her grandmother had promised to fix it every spring.\n\nThe key turned in the lock as if it had been waiting. Inside, the hall smelled of cedar, rain, and the apples her grandmother used to leave on the windowsill. Mara set down her bag and listened. A clock ticked somewhere upstairs. The house made a quiet settling sound, like someone waking and deciding there was no need to get up yet.\n\nOn the narrow table sat a bowl of smooth stones, each one a different shade of gray. Mara remembered choosing them from the creek and arranging them by size. She had expected the house to feel smaller after all these years. Instead, every familiar thing seemed to have kept its proper distance, leaving room for the person she had become."
    ),
    BookPage(
      number: 3,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "She set her bag beneath the coat hooks. A small brass bell hung beside the kitchen, polished bright by years of passing hands. When Mara touched it, one clear note moved through the house. She remembered ringing it at breakfast, then waiting for her grandmother to answer from the garden with a wave of her trowel.\n\nBeyond the back steps, the orchard leaned toward the evening. Its trees had grown wild while she was away, their branches stitched together with the last light of the day. Grass covered the old path, but the apple trees still stood in a careful row. Mara found the crooked one by the stone wall and placed her palm against its bark.\n\nA shallow groove marked the trunk where she and her grandmother had measured her height each summer. The last line ended just above Mara's shoulder. She wondered whether the tree had grown around the mark or whether she had simply stopped looking. A fallen apple rested in the grass. She picked it up and carried it toward the kitchen."
    ),
    BookPage(
      number: 4,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "At the far fence, a narrow gate opened onto the path she had followed as a child. It led past the creek, under the old railway bridge, and eventually to the hill where the whole town fit inside a single glance. The latch caught against the post. Mara lifted it the way she used to, with one finger beneath the iron loop.\n\nShe took the path slowly. The first crickets had begun their careful tuning, and the creek carried the day's last color between its stones. Near the bridge, a row of small footprints crossed the mud and disappeared into the grass. She wondered whose they were, then followed the path before the light could fade.\n\nThe railway bridge had not changed, though the boards sounded different under her steps. One plank gave a hollow knock, another a soft creak. Mara paused in the middle and watched the creek pass beneath her. A moth settled on the iron rail, opened its pale wings once, and moved on. She continued toward the hill with the sound of water keeping pace."
    ),
    BookPage(
      number: 5,
      section: "Chapter one · The orchard at dusk",
      title: nil,
      content: "Halfway up the hill she found a paper boat, folded from a page of her grandmother's garden journal. Someone had written a date inside it: tomorrow. The ink had blurred at the edges, but the letters were unmistakably her grandmother's, round and patient as stones.\n\nMara turned the boat over in her palm. A seed rested in its crease, small as a comma. She tucked both into her coat pocket and climbed until the roofs of Alder Lane opened below her. From the hill, the blue door was only a dot among the trees. The sight made the distance feel kind instead of large.\n\nShe sat on the grass and unfolded the paper. The page was covered with a list of flowers that bloom after the first rain. Her grandmother had circled one name and written, save a place for this. Mara looked at the seed in her hand. It might be a flower, or a tree, or something neither of them had seen before."
    ),
    BookPage(
      number: 6,
      section: "Chapter two · A map of small things",
      title: "A map of small things",
      content: "The journal was waiting on the kitchen table the next morning. Its pages held no directions, only lists: three good stones, a window that catches rain, the name of every neighbor's dog. Beside each list her grandmother had drawn a tiny map, no bigger than a postage stamp. None of the maps pointed north. They pointed toward whatever was worth noticing.\n\nMara began where the list began, with the river pebble tucked under the blue door. It was smooth and gray, with a white stripe that looked like a narrow river from above. She carried it in her pocket all day and felt it there whenever she forgot to look around.\n\nThe journal's paper smelled faintly of dust and mint. On the inside cover her grandmother had written that a map was a promise to return, even if the place changed. Mara read the sentence twice, then tucked a pencil into the journal's spine. She wanted to add a list of her own before the day was done."
    ),
    BookPage(
      number: 7,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "By noon she had walked the length of Alder Lane and learned that the baker had a daughter in Lisbon, the postman kept a jar of buttons, and the oldest maple had survived a winter split by lightning. At each doorstep somebody offered a new detail. The baker's daughter sent postcards with blue stamps. The postman sorted his buttons by size and guessed which coat they had once belonged to.\n\nMara drew each discovery in the margin. Her pencil made a soft scratching sound as she added a tiny jar beside the post office and a bright square beside the bakery. The map started to look less like a place and more like a way of paying attention.\n\nAt the end of the lane she found the maple, its lightning scar silver against the dark bark. Someone had tied a strip of blue cloth around the lowest branch. A small bird hopped along it, testing the knot with its beak. Mara drew the tree carefully and left the cloth out of the picture. Some things, she thought, belonged to the day that made them."
    ),
    BookPage(
      number: 8,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "On the bridge, Mara met a boy carrying a jar of rainwater. He said it was for the garden, though the garden was already green. A paper label on the glass read JULY, in careful block letters. The jar was cool from the shade and full almost to its silver lid.\n\n“For when it isn't,” he said, as if this explained everything. Mara smiled. It did, a little. They watched a leaf spin beneath the bridge and disappear around the bend. Before they parted, the boy told her where the best blackberries grew. Mara drew the spot in her journal, leaving room beside it for his name.\n\nHis name was Eli, and he had lived near the creek since spring. He knew which stones stayed dry after a storm and where swallows nested beneath the bridge. Mara wrote these things down, then asked why he carried the jar himself. Eli shrugged. The water was too precious to send by post, he said. She laughed, and the sound startled a pair of birds from the railing."
    ),
    BookPage(
      number: 9,
      section: "Chapter two · A map of small things",
      title: nil,
      content: "That evening Mara planted the seed beside the kitchen window. She loosened the soil with a spoon and tucked the seed into a small blue pot. She watered it with the jar from the bridge and wrote one line in the journal: begin with what is here. Then she set the jar beside the sink, where tomorrow's light would find it.\n\nThe house settled around her, familiar as a hand held open. Outside, the orchard moved gently in the dark. She could not see the trees, but she knew the wind was passing through them, touching every branch without asking it to stay.\n\nBefore bed, she returned to the first page and drew the little pot beside the blue door. A new leaf had not appeared yet, but the dark soil looked different now that she knew what waited beneath it. She left the curtain open. In the morning, the window could be the first thing the seed saw."
    ),
    BookPage(
      number: 10,
      section: "Chapter three · What the hill keeps",
      title: "What the hill keeps",
      content: "By the end of the week, the seed had sent up two bright leaves. Mara brought the journal to the hill and sat where the grass grew warmest. She had drawn a map for every day of her return, though none of them could be followed in a straight line. One began at a neighbor's gate. Another started at the sound of the brass bell.\n\nFrom the hill, the town seemed to be made of small promises: a light left on, a gate mended, a loaf cooling behind glass. She recognized the bakery window by its amber glow and the post office by the bicycle leaning against the steps. Each place held somebody's ordinary care.\n\nA cloud moved over the ridge and cooled the grass beneath her hands. Mara wrote the day's date in the margin, then sketched the two leaves as carefully as she could. The drawing was crooked, but the seedling in the window was not asking to be admired. It was only asking for water, a little light, and enough time to become itself."
    ),
    BookPage(
      number: 11,
      section: "Chapter three · What the hill keeps",
      title: nil,
      content: "The brass bell rang once in the distance. Mara could not tell whether the sound came from the house or from somewhere inside her memory. Either way, she answered it. She stood, brushed the grass from her skirt, and turned toward the lane. The evening had gone lavender at its edges.\n\nOn the last page of the journal, her grandmother had drawn a blue door and left the rest of the paper blank. Mara traced the little door with one finger. There were no instructions beneath it, no final list to complete. The blank space felt less like an ending than a chair pulled out for someone who had not arrived yet.\n\nShe thought of Eli's rainwater, the maple's blue cloth, and the key waiting in her pocket. They were not clues that led to a single answer. They were small ways of staying close to a place. Mara closed the journal and let the hill keep the rest of the evening for her."
    ),
    BookPage(
      number: 12,
      section: "Chapter three · What the hill keeps",
      title: nil,
      content: "Mara opened the journal to the first empty line. The sun slid behind the ridge, and the town began to gather its evening lights. She wrote the date, then the name of the place where she had returned. Underneath, she drew a small seed, no bigger than a comma, and watched the ink settle into the paper.\n\nThe orchard waited beyond the house. Tomorrow she would mend the gate, clear the grass from the path, and ask the boy by the bridge what he liked to grow. Tonight, it was enough to be here. She closed the journal but kept one hand on its cover, listening as the quiet house made room for her.\n\nThe blue door held a faint line of lamplight beneath it. Mara thought about the blank page at the back of the journal and the map she would draw there someday. She did not know what it would contain yet. That seemed right. For now, the first small seed had found a place to begin."
    )
  ]

  static var chapters = [
    BookChapter(title: "The orchard at dusk", subtitle: "A blue door, left waiting", pageIndex: 1),
    BookChapter(title: "A map of small things", subtitle: "The town, one detail at a time", pageIndex: 5),
    BookChapter(title: "What the hill keeps", subtitle: "A place to begin again", pageIndex: 9)
  ]
}
