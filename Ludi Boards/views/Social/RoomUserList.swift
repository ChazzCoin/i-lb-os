//
//  BuddyListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct RoomUserList: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var roomFireService = FirebaseRoomService()
    @State private var showingAddBuddyView = false

    var body: some View {
        List(self.roomFireService.rooms, id: \.id) { buddy in
            if !buddy.isInvalidated {
                NavigationLink(destination: BuddyProfileView(solUserId: buddy.userId, friendStatus: "unknown")) { // Replace DestinationView with your desired destination view
                    HStack {
                        Circle()
                            .fill(buddy.status == "AWAY" ? Color.gray : Color.green)
                            .frame(width: 10, height: 10)
                        Text(buddy.userId)
                            .font(.system(size: 14))
                        Spacer()
                        Text(buddy.status == "AWAY" ? "Away" : "Online")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Buddy List", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddBuddyView = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBuddyView) {
            AddBuddyView(isPresented: $showingAddBuddyView, sessionId: .constant("none"))
        }
        .onAppear() {
            roomFireService.startObserving(roomId: self.BEO.currentActivityId, realmInstance: self.BEO.realmInstance)
        }
    }
}

