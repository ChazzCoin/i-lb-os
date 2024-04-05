//
//  IconProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/7/24.
//

import Foundation
import SwiftUI

enum UserRole: CaseIterable {
    case player
    case parent
    case coach
    case admin
    case assistant
    case volunteer
    case member
    case temp
    
    var name: String {
        switch self {
            case .player: return "player"
            case .parent: return "parent"
            case .coach: return "coach"
            case .admin: return "admin"
            case .assistant: return "assistant"
            case .volunteer: return "volunteer"
            case .member: return "member"
            case .temp: return "temp"
        }
    }
    
}

struct PickerUserRole: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("User Role", text: selection)
        } else {
            Picker("User Role", selection: $selection) {
                ForEach(UserRole.allCases, id: \.self) { status in
                    Text(status.name).tag(status.name)
                }
            }
            .foregroundColor(.blue)
        }
    }
}

enum UserAuth: CaseIterable {
    case visitor
    case viewer
    case editor
    case admin
    case owner
    
    var name: String {
        switch self {
            case .visitor: return "visitor"
            case .viewer: return "viewer"
            case .editor: return "editor"
            case .admin: return "admin"
            case .owner: return "owner"
        }
    }
    
}
struct PickerUserAuth: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("User Auth", text: selection)
        } else {
            Picker("User Auth", selection: $selection) {
                ForEach(UserAuth.allCases, id: \.self) { status in
                    Text(status.name).tag(status.name)
                }
            }
            .foregroundColor(.blue)
        }
    }
}


enum ShareStatus: CaseIterable {
    case pending
    case active
    case inactive
    
    var name: String {
        switch self {
            case .pending: return "pending"
            case .active: return "active"
            case .inactive: return "inactive"
        }
    }
    
}
struct PickerShareStatus: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Share Status", text: selection)
        } else {
            Picker("Share Status", selection: $selection) {
                ForEach(ShareStatus.allCases, id: \.self) { status in
                    Text(status.name).tag(status.name)
                }
            }
            .foregroundColor(.blue)
        }
    }
}


enum RosterStatus: CaseIterable {
    case pending
    case pending_documents
    case active
    case inactive
    case suspended
    
    var name: String {
        switch self {
            case .pending: return "pending"
            case .pending_documents: return "pending documents"
            case .active: return "active"
            case .inactive: return "inactive"
            case .suspended: return "suspended"
        }
    }
    
}
struct PickerRosterStatus: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Roster Status", text: selection)
        } else {
            Picker("Roster Status", selection: $selection) {
                ForEach(RosterStatus.allCases, id: \.self) { status in
                    Text(status.name).tag(status.name)
                }
            }
            .foregroundColor(.blue)
        }
    }
}
