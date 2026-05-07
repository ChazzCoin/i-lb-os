//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift

public struct CoreProfileView: View {

    public init() {}

    @StateObject private var USER = UserToolsObservable()
    @ObservedResults(CoreUser.self) private var allUsers

    private var currentUser: CoreUser? {
        guard let id = UserTools.currentUserId else { return nil }
        return allUsers.first(where: { $0.id == id })
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Avatar + Name
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .foregroundStyle(.secondary)

                    Text(UserTools.currentUserName ?? "Not Set")
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 6) {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.green)

                        Text("Online")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 32)

                // MARK: - Profile Details
                VStack(spacing: 16) {
                    ProfileRow(
                        title: "User ID",
                        value: UserTools.currentUserId ?? "Not Set"
                    )

                    ProfileRow(
                        title: "Handle",
                        value: UserTools.currentUserHandle ?? "Not Set"
                    )
                }
                .padding(.horizontal)

                // MARK: - Actions
                VStack(spacing: 12) {
                    CoreConfirmButton(
                        title: "Sign Out",
                        message: "Are you sure you want to sign out?",
                        action: {
                            UserTools.logout()
                        },
                        isEnabled: true
                    )
                }
                .padding(.top, 12)

                Spacer(minLength: 32)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile
                }
            }
        }
    }
}

private struct ProfileRow: View {

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.body)
                .fontWeight(.medium)

            Divider()
        }
    }
}
