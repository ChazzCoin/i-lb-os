//
//  BuddyRequestListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import SwiftUI

struct BuddyConnectionListView: View {
    @LiveConnections(friends: true) var connections
    
    var body: some View {
        List($connections, id: \.id) { $r in
            NavigationLink(destination: BuddyProfileView(solUserId: r.userOneId, friendStatus: "friends")) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text(r.userOneName)
                        .font(.system(size: 14))
                    Spacer()
                    Text("Friends")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }.onAppear() {
//            loadFriends()
        }
    }
    
//    func loadFriends() {
//        if let uId = getFirebaseUserId() {
//            _connections.startFirebaseObservation(block: { db in
//                return db
//                    .child("connections")
//                    .queryOrdered(byChild: "userTwoId")
//                    .queryEqual(toValue: uId)
//            })
//        }
//    }
}

