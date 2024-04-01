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
    case temp
    
    var name: String {
        switch self {
            case .player: return "player"
            case .parent: return "parent"
            case .coach: return "coach"
            case .admin: return "admin"
            case .assistant: return "assistant"
            case .volunteer: return "volunteer"
            case .temp: return "temp"
        }
    }
    
}

struct PickerUserRole: View {
    @Binding var selection: String
    @Binding var isEdit: Bool
    let title = "User Role"
    
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(UserRole.allCases, id: \.self) { item in
                    Text(item.name).tag(item.name)
                }
            }
            .foregroundColor(.blue)
            .pickerStyle(MenuPickerStyle())
            
        }
        .compositingGroup()
        .shadow(radius: 5)
        .padding()
        
    }
}


struct UserPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerShareStatus(selection: .constant(""), isEdit: .constant(true))
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
    let title = "User Auth"
    
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(UserAuth.allCases, id: \.self) { item in
                    Text(item.name).tag(item.name)
                }
            }
            .foregroundColor(.blue)
            .pickerStyle(MenuPickerStyle())
            
        }
        .compositingGroup()
        .shadow(radius: 5)
        .padding()
        
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
    let title = "Share Status"
    
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(ShareStatus.allCases, id: \.self) { item in
                    Text(item.name).tag(item.name)
                }
            }
            .foregroundColor(.blue)
            .pickerStyle(MenuPickerStyle())
            
        }
        .compositingGroup()
        .shadow(radius: 5)
        .padding()
        
    }
}
