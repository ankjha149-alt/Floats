# Floats implementation status

This repository candidate is a fresh implementation based on feature details recorded in the ChatGPT `floats` project. It is not extracted from the original ZIP or source tree.

## Original materials checked

- ChatGPT project Sources tab: no files listed
- Project chats: describe floating notes, Notes Manager, per-note font/color/size, and PDF export, but contain no Swift source
- Mac: no original Xcode project, Swift source, ZIP, or installed app found in the checked locations
- Existing GitHub repository `ankjha149-alt/Floats`: public and previously contained only a README

## Current implementation

- SwiftUI/AppKit Xcode project and shared scheme
- Always-on-top floating note windows, Notes Manager, context menus for per-note font/color/size, menu-bar controls, local persistence, and PDF export
- Swift source type-checks for arm64 macOS 13.0
- Local arm64 app bundle compiled with Swift 6.4.2 and ad hoc signed

## Limits

This Mac has Apple command-line tools but not the full Xcode app, so `xcodebuild` could not be run. The app has not been launched or compared with the original. Review it before treating it as a release. No original screenshots or icon were available.
