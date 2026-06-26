//
//  BoardScreenState.swift
//  Ludi Boards — tactical board redesign (RD-1 scaffold)
//
//  Drives which right-hand panel the redesigned board shows, plus the
//  editor mode. This is the seam later phases wire to the live engine:
//  `selectedToolId` becomes the engine's real selection (TASK-004),
//  `libraryOpen` is toggled by the rail/library affordance (TASK-010),
//  and `mode` drives Plan/Animate/Present (TASK-008). For the scaffold
//  it's a self-contained, observable state machine with no engine deps.
//

import SwiftUI

/// The right-hand panel currently resolved from board state.
enum RightPanel: Equatable { case squad, properties, library }

final class BoardScreenState: ObservableObject {

    /// id of the selected board tool; `nil` = nothing selected.
    /// Placeholder until wired to the engine's selection in TASK-004.
    @Published var selectedToolId: String?

    /// Library drawer open (toggled from the rail / a library affordance).
    @Published var libraryOpen: Bool

    /// Board editor mode (Plan / Animate / Present).
    @Published var mode: EditorMode

    init(selectedToolId: String? = nil,
         libraryOpen: Bool = false,
         mode: EditorMode = .plan) {
        self.selectedToolId = selectedToolId
        self.libraryOpen = libraryOpen
        self.mode = mode
    }

    /// Panel resolution: an open Library wins; otherwise a selection shows
    /// Properties; otherwise the default Squad panel.
    var panel: RightPanel {
        if libraryOpen { return .library }
        if selectedToolId != nil { return .properties }
        return .squad
    }

    var hasSelection: Bool { selectedToolId != nil }

    // MARK: Transitions

    func select(_ id: String) {
        libraryOpen = false
        selectedToolId = id
    }

    func clearSelection() {
        selectedToolId = nil
    }

    func toggleLibrary() {
        libraryOpen.toggle()
        if libraryOpen { selectedToolId = nil }
    }

    /// Seed a state equivalent to a static demo screen (previews / render
    /// harness). Lets the three handoff screens render without interaction.
    convenience init(demo: BoardScreen) {
        switch demo {
        case .board:    self.init()
        case .selected: self.init(selectedToolId: "9")
        case .library:  self.init(libraryOpen: true)
        }
    }
}
