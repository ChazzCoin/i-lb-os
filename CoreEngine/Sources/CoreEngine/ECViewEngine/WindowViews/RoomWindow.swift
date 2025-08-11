//
//  RoomWindow.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//

import SwiftUI

// MARK: - Editable Draft (safe working copy for the sheet)
public struct RoomDraft: Equatable {
    public var id: String
    public var title: String
    public var ownerName: String
    public var status: String

    init(id: String, title: String, ownerName: String, status: String) {
        self.id = id
        self.title = title
        self.ownerName = ownerName
        self.status = status
    }
}

// MARK: - Main
public struct RoomWindow: View {
    @EnvironmentObject public var fusedRoom: FusedRoom

    @AppStorage("isLoggedIn", store: UserDefaults(suiteName: "worlds")) public var isLoggedIn: Bool = false
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""

    @State private var enteredRoomId = ""
    @State private var isLoading = false
    @State private var statusMsg: String?
    @State private var showEditor = false
    @State private var draft = RoomDraft(id: "", title: "", ownerName: "", status: "")
    @State private var showLeaveConfirm = false
    @FocusState private var roomFieldFocused: Bool

    /// Wire this to your backend (e.g., fusedRoom.updateRoom(...))
    public var onEditSave: ((RoomDraft) -> Void)?

    public init(onEditSave: ((RoomDraft) -> Void)? = nil) {
        self.onEditSave = onEditSave
    }

    public var body: some View {
        VStack(spacing: 16) {
            if !isLoggedIn && currentUserId.isEmpty {
                AuthGateCard()
            } else if fusedRoom.currentRoomId.isEmpty {
                JoinOrCreateCard(
                    enteredRoomId: $enteredRoomId,
                    isLoading: isLoading,
                    onEnter: enterRoom
                )
                .focused($roomFieldFocused)
                .task {
                    // Autofocus for fast entry
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    roomFieldFocused = true
                }
                if let statusMsg { StatusToast(text: statusMsg) }
            } else {
                ActiveRoomCard(
                    fusedRoom: fusedRoom,
                    onEdit: openEditor,
                    onShare: shareRoom,
                    onCopy: copyRoomId,
                    onLeaveTapped: { showLeaveConfirm = true }
                )
                .alert("Leave room?", isPresented: $showLeaveConfirm) {
                    Button("Leave", role: .destructive) {
                        fusedRoom.leaveRoom()
                        statusMsg = nil
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You can rejoin anytime with the room ID.")
                }

                // Optional: child content area
                RoomContentView(myUserId: currentUserId)
                    .environmentObject(fusedRoom)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                RoomEditorSheet(
                    draft: $draft,
                    canEditOwnership: fusedRoom.room?.ownerId == currentUserId || currentUserId.isEmpty, // tweak logic as needed
                    onCancel: { showEditor = false },
                    onSave: { newDraft in
                        // Hand off to your app
                        onEditSave?(newDraft)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        showEditor = false
                        statusMsg = "Room updated."
                    }
                )
            }
            .presentationDetents([.medium, .large])
//            .presentationCornerRadius(24)
        }
    }

    // MARK: - Actions

    private func enterRoom() {
        guard !enteredRoomId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        UISelectionFeedbackGenerator().selectionChanged()
        fusedRoom.enterOrCreateRoom(withId: enteredRoomId) { didCreate, error in
            isLoading = false
            if let error {
                statusMsg = error.localizedDescription
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            } else {
                statusMsg = didCreate ? "Room created!" : "Entered room."
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        enteredRoomId = ""
    }

    private func openEditor() {
        guard let r = fusedRoom.room else { return }
        draft = RoomDraft(
            id: fusedRoom.currentRoomId,
            title: r.title.isEmpty ? "" : r.title,
            ownerName: r.ownerName.isEmpty ? "" : r.ownerName,
            status: r.status.isEmpty ? "" : r.status
        )
        showEditor = true
    }

    private func copyRoomId() {
        UIPasteboard.general.string = fusedRoom.currentRoomId
        statusMsg = "Copied room ID."
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func shareRoom() {
        // Using ShareLink when available
        let text = "Join my room: \(fusedRoom.room?.title ?? "Room") (\(fusedRoom.currentRoomId))"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController?.present(av, animated: true)
        // Fallbacks handled by iOS; no extra state needed here.
    }
}

// MARK: - Cards & Components

private struct AuthGateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Label("You’re signed out", systemImage: "person.crop.circle.badge.exclam")
                .font(.headline)
            Text("Sign in to join or create rooms.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))
    }
}

private struct JoinOrCreateCard: View {
    @Binding var enteredRoomId: String
    var isLoading: Bool
    var onEnter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Enter or Create a Room", systemImage: "waveform.circle.fill")
                .font(.headline)

            VStack(spacing: 10) {
                TextField("Room ID", text: $enteredRoomId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                HStack(spacing: 10) {
                    Button {
                        enteredRoomId = Self.generateFriendlyCode()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Random ID", systemImage: "die.face.5")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(action: onEnter) {
                        HStack {
                            if isLoading { ProgressView().controlSize(.small) }
                            Text(isLoading ? "Entering…" : "Enter")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || enteredRoomId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))
    }

    private static func generateFriendlyCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return (0..<6).map { _ in alphabet.randomElement()! }.chunked(3).joined(separator: "-")
    }
}

private struct ActiveRoomCard: View {
    let fusedRoom: FusedRoom
    var onEdit: () -> Void
    var onShare: () -> Void
    var onCopy: () -> Void
    var onLeaveTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Label("Room", systemImage: "rectangle.and.pencil.and.ellipsis")
                    .font(.headline)
                Spacer()
                StatusPill(text: "Active")
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(fusedRoom.roomTitle.isEmpty == false ? fusedRoom.roomTitle : "Untitled")
                        .font(.title2.weight(.semibold))
                        .lineLimit(2)
                    Spacer(minLength: 8)
                }

                HStack(spacing: 8) {
                    IconRow(label: "ID", value: fusedRoom.currentRoomId, icon: "number")
                        .contextMenu {
                            Button("Copy ID", action: onCopy)
                            Button("Share…", action: onShare)
                        }
                }

                if let room = fusedRoom.room {
                    IconRow(label: "Owner", value: room.ownerName, icon: "person.fill")
                    IconRow(label: "Status", value: room.status.isEmpty ? "—" : room.status, icon: "dot.radiowaves.left.and.right")
                }

                IconRow(label: "Users", value: "\(fusedRoom.usersInRoom.count)", icon: "person.2.fill")
            }

            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "square.and.pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onShare) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive, action: onLeaveTapped) {
                    Label("Leave", systemImage: "door.right.hand.open")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))
    }
}

private struct IconRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(.secondary)
            Text("\(label):")
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "—" : value)
                .lineLimit(2)
            Spacer(minLength: 8)
        }
        .font(.subheadline)
    }
}

private struct StatusPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGreen).opacity(0.15), in: Capsule())
    }
}

private struct StatusToast: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text(text)
        }
        .font(.footnote)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.quaternary))
    }
}

// MARK: - Editor Sheet

private struct RoomEditorSheet: View {
    @Binding var draft: RoomDraft
    var canEditOwnership: Bool
    var onCancel: () -> Void
    var onSave: (RoomDraft) -> Void

    @State private var validationMessage: String?

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $draft.title)
                    .textInputAutocapitalization(.words)
                TextField("Status", text: $draft.status)
                    .textInputAutocapitalization(.sentences)
            }

            Section("Ownership") {
                TextField("Owner name", text: $draft.ownerName)
                    .disabled(!canEditOwnership)
                    .opacity(canEditOwnership ? 1 : 0.6)
                HStack {
                    Text("Room ID")
                    Spacer()
                    Text(draft.id).foregroundStyle(.secondary)
                }
            }

            if let msg = validationMessage {
                Section {
                    Text(msg).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Room")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if validate() {
                        onSave(draft)
                    }
                }
                .disabled(!canSave)
            }
        }
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func validate() -> Bool {
        guard canSave else {
            validationMessage = "Title can’t be empty."
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return false
        }
        validationMessage = nil
        return true
    }
}

// MARK: - Helpers

private extension Array {
    func chunked(_ stride: Int) -> [String] where Element == Character {
        var result: [String] = []
        var current: [Character] = []
        for (i, ch) in self.enumerated() {
            current.append(ch)
            if (i + 1) % stride == 0 {
                result.append(String(current))
                current.removeAll()
            }
        }
        if !current.isEmpty { result.append(String(current)) }
        return result
    }
}

private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        // iOS 15+
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

public struct RoomContentView: View {
    @EnvironmentObject public var fusedRoom: FusedRoom
    public let myUserId: String
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Example: Show users in the room (optional)
            if fusedRoom.usersInRoom.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(fusedRoom.usersInRoom, id: \.id) { user in
                            VStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.4))
                                    .frame(width: 32, height: 32)
                                Text(user.name ?? user.id)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }

            // Chat view (can be replaced with your full-featured chat)
//            RoomChatView(fusedRoom: fusedRoom, myUserId: myUserId)
//                .frame(maxHeight: 420)
        }
        .padding(.top)
    }
}

