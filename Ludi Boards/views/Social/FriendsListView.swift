//
//  BuddyRequestListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import SwiftUI

struct FriendsListView: View {
    @LiveConnections(friends: true) var connections
    @State var currentUserId = ""
    
    var body: some View {
        List($connections, id: \.id) { $r in
            NavigationLink(destination: BuddyProfileView(
                solUserId: currentUserId == r.userOneId ? r.userTwoId : r.userOneId,
                friendStatus: "friends"
            )) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text(currentUserId == r.userOneId ? r.userTwoName : r.userOneName)
                        .font(.system(size: 14))
                    Spacer()
                    Text("Friend")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .task {
            if let uid = getFirebaseUserId() {
                currentUserId = uid
            }
        }
        .onDisappear() {
            _connections.destroy()
        }
    }
}

