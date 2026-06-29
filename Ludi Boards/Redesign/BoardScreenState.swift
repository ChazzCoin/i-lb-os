//
//  BoardScreenState.swift
//  Ludi Boards — tactical board redesign
//
//  Drives the right-hand drawer + editor mode. Reworked (req 4/5) to an
//  EXPLICIT drawer model: a switcher rail picks `activeDrawer`, and a single
//  `drawerOpen` slides the whole drawer on/off screen regardless of which view
//  is loaded. Properties is the one auto-routed view (a tool tap opens it).
//

import SwiftUI

/// The dedicated right-hand drawer views. The switcher rail offers squad /
/// boards / library / layers; `properties` is opened by selecting a tool.
enum RightPanel: String, Equatable, CaseIterable, Identifiable {
    case squad, boards, library, layers, properties
    var id: String { rawValue }

    /// Rail entries (properties is selection-driven, not a rail button).
    static var railDrawers: [RightPanel] { [.squad, .boards, .library, .layers] }

    var icon: String {
        switch self {
        case .squad:      return "person.2.fill"
        case .boards:     return "square.grid.2x2"
        case .library:    return "plus.square.on.square"
        case .layers:     return "square.3.layers.3d"
        case .properties: return "slider.horizontal.3"
        }
    }
    var title: String {
        switch self {
        case .squad: return "Squad"; case .boards: return "Boards"
        case .library: return "Library"; case .layers: return "Layers"
        case .properties: return "Properties"
        }
    }
}

final class BoardScreenState: ObservableObject {

    /// id of the selected board tool; `nil` = nothing selected.
    @Published var selectedToolId: String?

    /// Which dedicated drawer is loaded (req 4).
    @Published var activeDrawer: RightPanel = .squad

    /// Global drawer visibility — slides the drawer on/off screen (req 5),
    /// regardless of which view is in it.
    @Published var drawerOpen: Bool = true

    /// Board editor mode (Plan / Animate / Present).
    @Published var mode: EditorMode

    init(selectedToolId: String? = nil,
         activeDrawer: RightPanel = .squad,
         drawerOpen: Bool = true,
         mode: EditorMode = .plan) {
        self.selectedToolId = selectedToolId
        self.activeDrawer = activeDrawer
        self.drawerOpen = drawerOpen
        self.mode = mode
    }

    /// The drawer view to render (back-compat name used by the host).
    var panel: RightPanel { activeDrawer }
    var hasSelection: Bool { selectedToolId != nil }

    // MARK: Transitions

    /// Switcher-rail tap: show that drawer, or close the drawer if it's already
    /// the open one (so the rail icon toggles its own drawer).
    func showDrawer(_ d: RightPanel) {
        if activeDrawer == d && drawerOpen {
            drawerOpen = false
        } else {
            activeDrawer = d
            drawerOpen = true
        }
    }

    /// Global on/off toggle (req 5) — works for whatever view is loaded.
    func toggleDrawer() { drawerOpen.toggle() }

    func select(_ id: String) {
        selectedToolId = id
        activeDrawer = .properties
        drawerOpen = true
    }

    func clearSelection() {
        selectedToolId = nil
        if activeDrawer == .properties { activeDrawer = .squad }
    }

    func openLayers() {
        selectedToolId = nil
        activeDrawer = .layers
        drawerOpen = true
    }
    func closeLayers() { if activeDrawer == .layers { drawerOpen = false } }

    func toggleLibrary() { showDrawer(.library) }

    /// Seed a state equivalent to a static demo screen (previews / render harness).
    convenience init(demo: BoardScreen) {
        switch demo {
        case .board:    self.init()
        case .selected: self.init(selectedToolId: "9", activeDrawer: .properties)
        case .library:  self.init(activeDrawer: .library)
        }
    }
}
