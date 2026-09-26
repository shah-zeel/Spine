# Spine

Spine is an adaptive reading companion for iOS. It pairs a page-turn reading experience with spoken narration, passage annotations, and summaries based on what you choose to highlight and note.

The app currently ships with a 12-page sample edition, *The Wild Between*.

## Features

- **Page-turn reader:** Read one page at a time or view a two-page spread in landscape. Turn pages with the page-curl reader and jump between chapters from the table of contents.
- **Adaptive reading layouts:** The interface responds to device orientation and, on supported hinge devices running iOS 27.1 or later, the device's fold posture. It includes a cover view, open reading layouts, a tent-style audio view, and a split reading-and-notes workspace.
- **Highlights and notes:** Select passages, apply honey, sage, or rose highlights, and create, edit, browse, or remove notes linked to the text.
- **Spoken narration:** Listen to the sample book with Apple speech synthesis. The reader follows the spoken sentence and highlights the characters as they are read. Audio-focused layouts keep the current text visible.
- **Personalized reading summaries:** Request a concise summary that uses the book and your saved highlights and notes as context. Summary generation uses Apple's on-device Foundation Models when a compatible model is available.
- **Local continuity:** The current page and annotations are saved on the device, so your reading position and notebook remain available after reopening the app.
- **Accessibility and motion preferences:** Reader controls have accessibility labels, and the app respects Reduce Motion for its reader transitions.

## Technology

- **Swift 5** and **SwiftUI** for the app and interface.
- **UIKit** through SwiftUI representables for the page-curl controller and selectable passage text.
- **AVFoundation** (`AVSpeechSynthesizer`) for spoken narration and synchronized reading progress.
- **Foundation Models** for optional on-device summaries. The app reports when the system model is unavailable.
- **Observation**, **Codable**, **UserDefaults**, and SwiftUI `AppStorage` for app state and local persistence.
- **Apple frameworks only:** no third-party package dependencies or remote backend are required for the included reader, narration, or notebook features.

## Requirements

- iOS 26.0 or later.
- A compatible iOS 27.1 or later device is needed for the hinge-aware layouts. Other supported iOS devices use the orientation-based reader layouts.
- Summary generation requires Apple’s on-device language model to be available on the device. Reading, narration, and annotations remain usable when it is unavailable.

## Build and run

Open this Bitrig-managed project in Bitrig, choose an iOS simulator or connected iPhone as the run destination, and build the **Spine** target. The app includes its sample book and does not require account setup.

## Project structure

- `App/ContentView.swift` selects the reader layout for the current device posture.
- `App/BookReaderView.swift`, `App/PageCurlReaderView.swift`, and `App/BookPageView.swift` implement page navigation and reading.
- `App/ReaderNotebook.swift` stores highlights and notes locally.
- `App/AudioReadingModel.swift` coordinates speech synthesis and the active text range.
- `App/BookSummaryAgent.swift` creates summaries from the sample book and saved annotations.
- `App/SampleBook.swift` contains the bundled sample edition and chapter list.
- `Project.json` defines the iOS app target and project settings.
