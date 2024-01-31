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
    @EnvironmentObject var ROOM: FirebaseRoomService
    @State private var showingAddBuddyView = false

    var body: some View {
        
        VStack {
            if self.ROOM.objsInCurrentRoom.isEmpty {
                Text("This room seems to be empty.")
                    .frame(maxWidth: .infinity)
            }
            
            List(self.ROOM.objsInCurrentRoom) { buddy in
                NavigationLink(destination: BuddyProfileView(solUserId: buddy.userId, friendStatus: "unknown")) { // Replace DestinationView with your desired destination view
                    HStack {
                        Circle()
                            .fill(buddy.status == "IN" ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                        Text(buddy.userName)
                            .font(.system(size: 14))
                        Spacer()
                        Text(buddy.status == "IN" ? "Online" : "Away")
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
        .refreshable {
            restart()
        }
        .sheet(isPresented: $showingAddBuddyView) {
            AddBuddyView(isPresented: $showingAddBuddyView, sessionId: .constant("none"))
        }
        
        
    }
    
    func restart() {
        self.ROOM.stopObserving()
        self.ROOM.startObserving(roomId: self.BEO.currentActivityId)
    }
    
    
}

