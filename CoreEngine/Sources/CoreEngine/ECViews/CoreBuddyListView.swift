//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/16/24.
//

import Foundation
import SwiftUI

public struct CoreBuddyListView: View {
    // Sample data structure
    public struct Buddy {
        let id: Int
        let name: String
        let avatar: String // URL or asset name
        let isOnline: Bool
        let lastActive: String
    }
    
    // Sample buddies data
    public let buddies: [Buddy] = [
        .init(id: 1, name: "Alex Morgan", avatar: "avatar1", isOnline: true, lastActive: "Now"),
        .init(id: 2, name: "Chris Paul", avatar: "avatar2", isOnline: false, lastActive: "5 minutes ago")
    ]

    public var body: some View {
        Group {
            List(buddies, id: \.id) { buddy in
                HStack(spacing: 12) {
                    Image(buddy.avatar)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(buddy.isOnline ? Color.green : Color.gray, lineWidth: 2))
                    VStack(alignment: .leading) {
                        Text(buddy.name)
                            .fontWeight(.medium)
                        Text(buddy.isOnline ? "Online" : "Last active: \(buddy.lastActive)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if buddy.isOnline {
                        Button(action: {}) {
                            Label("Invite", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Buddies")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    CoreBuddyListView()
}
