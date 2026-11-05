import AppKit
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

struct FloatNoteView: View {
    @ObservedObject var store: NoteStore
    let noteID: UUID
    let showManager: () -> Void

    private var note: FloatNote { store.note(id: noteID) ?? FloatNote(id: noteID) }
    private let paper = Color(hex: "#FFF4B8")
    private let fonts = ["Avenir Next", "Helvetica Neue", "Georgia", "Menlo", "Noteworthy"]
    private let colors: [(String, String)] = [("Charcoal", "#242424"), ("Blue", "#174EA6"), ("Red", "#A12622"), ("Green", "#28623A"), ("Purple", "#633B83")]
    private let sizes: [Double] = [12, 14, 16, 18, 20, 24, 28, 32]

    var body: some View {
        TextEditor(text: Binding(
            get: { note.text },
            set: { var changed = note; changed.text = $0; store.update(changed) }
        ))
        .font(.custom(note.fontName, size: note.fontSize))
        .foregroundStyle(Color(hex: note.colorHex))
        .scrollContentBackground(.hidden)
        .padding(12)
        .background(paper)
        .contextMenu {
            Menu("Font") {
                ForEach(fonts, id: \.self) { font in
                    Button(font) { var changed = note; changed.fontName = font; store.update(changed) }
                }
            }
            Menu("Text Color") {
                ForEach(colors, id: \.0) { color in
                    Button(color.0) { var changed = note; changed.colorHex = color.1; store.update(changed) }
                }
            }
            Menu("Font Size") {
                ForEach(sizes, id: \.self) { size in
                    Button("\(Int(size)) pt") { var changed = note; changed.fontSize = size; store.update(changed) }
                }
            }
            Divider()
            Button("Notes Manager", action: showManager)
        }
        .frame(minWidth: 260, minHeight: 180)
    }
}

struct NoteManagerView: View {
    @ObservedObject var store: NoteStore
    let newNote: () -> Void
    let showNote: (UUID) -> Void
    let deleteNote: (UUID) -> Void
    let exportPDF: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Floats").font(.title2.weight(.semibold))
                    Text("Notes Manager").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: exportPDF) { Label("Export PDF", systemImage: "doc.richtext") }
                Button(action: newNote) { Label("New Note", systemImage: "plus") }
                    .keyboardShortcut("n", modifiers: .command)
            }
            .padding(18)

            if store.notes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "note.text").font(.system(size: 28)).foregroundStyle(.secondary)
                    Text("No Notes Yet").font(.headline)
                    Text("Create a note to get started.").font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.notes) { note in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).font(.headline).lineLimit(1)
                                Text(note.text.isEmpty ? "Empty note" : note.text.replacingOccurrences(of: "\n", with: " "))
                                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                            }
                            Spacer(minLength: 8)
                            Button("Show") { showNote(note.id) }
                                .buttonStyle(.bordered)
                            Button(role: .destructive) { deleteNote(note.id) } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .help("Delete note")
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) { showNote(note.id) }
                    }
                }
                .listStyle(.inset)
            }
        }
        .frame(minWidth: 540, minHeight: 390)
    }
}

@MainActor
func exportNotesAsPDF(_ notes: [FloatNote]) {
    guard !notes.isEmpty else { return }
    let panel = NSSavePanel()
    panel.allowedContentTypes = [.pdf]
    panel.nameFieldStringValue = "Floats-Notes.pdf"
    panel.title = "Export Notes as PDF"
    guard panel.runModal() == .OK, let url = panel.url else { return }

    let document = PDFDocument()
    for note in notes {
        let pageFrame = NSRect(x: 0, y: 0, width: 612, height: 792)
        let textView = NSTextView(frame: pageFrame)
        textView.string = note.text
        textView.font = NSFont(name: note.fontName, size: CGFloat(note.fontSize)) ?? .systemFont(ofSize: CGFloat(note.fontSize))
        textView.textColor = NSColor(hex: note.colorHex)
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 42, height: 48)
        textView.textContainer?.containerSize = NSSize(width: 528, height: 696)
        textView.textContainer?.widthTracksTextView = true
        let data = textView.dataWithPDF(inside: pageFrame)
        if let page = PDFDocument(data: data)?.page(at: 0) {
            document.insert(page, at: document.pageCount)
        }
    }
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    _ = document.write(to: url)
}
