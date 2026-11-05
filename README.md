# Floats

A native macOS floating notes app. This is a fresh implementation based on the feature history recorded in the ChatGPT `floats` project because its original source ZIP and Xcode project were not available in the project files or on this Mac. It is not recovered original source.

## Features implemented

- Always-on-top note windows
- Notes Manager for creating, showing, and deleting notes
- Per-note font, text color, and font size menus (right-click in a note)
- Menu bar controls for creating notes and showing or hiding note windows
- Local note persistence in `~/Library/Application Support/Floats/notes.json`
- Export notes as a text-based PDF

## Build

Open `Floats.xcodeproj` in Xcode and build the `Floats` scheme. The project uses SwiftUI, AppKit, and PDFKit and targets macOS 13.0 or newer. No third-party packages are required.

The project includes a shared `Floats` scheme and targets macOS 13.0 or newer. The local app bundle in `build/Floats.app` was compiled for Apple silicon with the installed Swift compiler. The bundle is ad hoc signed for local use; it is not Developer ID signed or notarized. This Mac has Apple command-line tools but not the full Xcode app, so an `xcodebuild` build could not be run here.

## Project structure

- `Floats/FloatsApp.swift` — app entry point
- `Floats/AppDelegate.swift` — menu bar item and floating windows
- `Floats/FloatNotesModel.swift` — note model and local persistence
- `Floats/FloatNoteViews.swift` — note editor, manager, and PDF export

## Source provenance and limitations

The original source archive was referred to in project chats as `FloatNotes-FINAL-Working-Source.zip`, but no archive was attached to the ChatGPT project and the referenced Desktop backup folder was empty. This implementation follows the recorded v1.1 feature notes; its UI and behavior may differ from the earlier app. The source has type-checked and produced a local app bundle, but the app has not been launched or compared with the earlier app. Treat it as a reconstruction for review, not as recovered original source.

No screenshots or app icon were available.

## License

See [LICENSE](LICENSE).
