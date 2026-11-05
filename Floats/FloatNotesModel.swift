import AppKit
import Foundation
import SwiftUI

struct FloatNote: Codable, Identifiable, Equatable {
    var id: UUID
    var text: String
    var fontName: String
    var fontSize: Double
    var colorHex: String

    init(id: UUID = UUID(), text: String = "", fontName: String = "Avenir Next", fontSize: Double = 16, colorHex: String = "#242424") {
        self.id = id
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.colorHex = colorHex
    }

    var title: String {
        let firstLine = text.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.isEmpty ? "New Note" : String(firstLine.prefix(48))
    }
}

@MainActor
final class NoteStore: ObservableObject {
    @Published private(set) var notes: [FloatNote] = []
    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = support.appendingPathComponent("Floats", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("notes.json")
        load()
    }

    func note(id: UUID) -> FloatNote? {
        notes.first { $0.id == id }
    }

    @discardableResult
    func addNote() -> UUID {
        let note = FloatNote()
        notes.insert(note, at: 0)
        save()
        return note.id
    }

    func update(_ updated: FloatNote) {
        guard let index = notes.firstIndex(where: { $0.id == updated.id }) else { return }
        notes[index] = updated
        save()
    }

    func delete(id: UUID) {
        notes.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let saved = try? JSONDecoder().decode([FloatNote].self, from: data) else { return }
        notes = saved
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var number: UInt64 = 0
        Scanner(string: value).scanHexInt64(&number)
        let red = Double((number >> 16) & 0xff) / 255
        let green = Double((number >> 8) & 0xff) / 255
        let blue = Double(number & 0xff) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

extension NSColor {
    convenience init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var number: UInt64 = 0
        Scanner(string: value).scanHexInt64(&number)
        self.init(
            calibratedRed: CGFloat((number >> 16) & 0xff) / 255,
            green: CGFloat((number >> 8) & 0xff) / 255,
            blue: CGFloat(number & 0xff) / 255,
            alpha: 1
        )
    }
}
