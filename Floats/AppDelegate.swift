import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = NoteStore()
    private var statusItem: NSStatusItem?
    private var noteWindows: [UUID: NSWindow] = [:]
    private var managerWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        installMenuBarItem()
        if store.notes.isEmpty { _ = store.addNote() }
        showAllNotes()
        showManager()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    private func installMenuBarItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "◉"
        item.button?.toolTip = "Floats Notes"
        let menu = NSMenu()
        menu.addItem(menuItem("New Note", action: #selector(newNote), key: "n", modifiers: [.command]))
        menu.addItem(menuItem("Show / Hide Notes", action: #selector(toggleNotes)))
        menu.addItem(menuItem("Notes Manager", action: #selector(openManager), key: "m", modifiers: [.command, .shift]))
        menu.addItem(.separator())
        menu.addItem(menuItem("Quit Floats", action: #selector(quitApp)))
        item.menu = menu
        statusItem = item
    }

    private func menuItem(_ title: String, action: Selector, key: String = "", modifiers: NSEvent.ModifierFlags = []) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.keyEquivalentModifierMask = modifiers
        item.target = self
        return item
    }

    @objc private func newNote() {
        let id = store.addNote()
        showNote(id)
    }

    @objc private func toggleNotes() {
        let visible = noteWindows.values.contains(where: \.isVisible)
        if visible {
            noteWindows.values.forEach { $0.orderOut(nil) }
        } else {
            showAllNotes()
        }
    }

    @objc private func openManager() { showManager() }
    @objc private func quitApp() { NSApp.terminate(nil) }

    private func showAllNotes() {
        for note in store.notes { showNote(note.id) }
    }

    private func showNote(_ id: UUID) {
        guard store.note(id: id) != nil else { return }
        if let window = noteWindows[id] {
            window.makeKeyAndOrderFront(nil)
            return
        }
        let offset = CGFloat(noteWindows.count % 8) * 26
        let frame = NSRect(x: 160 + offset, y: 580 - offset, width: 330, height: 270)
        let window = NSWindow(contentRect: frame, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Floats Note"
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.minSize = NSSize(width: 250, height: 170)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: FloatNoteView(store: store, noteID: id, showManager: { [weak self] in self?.showManager() }))
        noteWindows[id] = window
        window.makeKeyAndOrderFront(nil)
    }

    private func showManager() {
        if let managerWindow {
            managerWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 620, height: 470), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Floats — Notes Manager"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: NoteManagerView(
            store: store,
            newNote: { [weak self] in self?.newNote() },
            showNote: { [weak self] in self?.showNote($0) },
            deleteNote: { [weak self] id in self?.deleteNote(id) },
            exportPDF: { [weak self] in guard let self else { return }; exportNotesAsPDF(self.store.notes) }
        ))
        window.center()
        managerWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func deleteNote(_ id: UUID) {
        noteWindows[id]?.close()
        noteWindows.removeValue(forKey: id)
        store.delete(id: id)
    }
}
