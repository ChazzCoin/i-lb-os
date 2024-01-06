//
//  BuddyRequestListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import SwiftUI

struct BuddyRequestListView: View {
    @Binding var requests: [Request]
    @State private var showingAddBuddyView = false
    
    var body: some View {
        List($requests, id: \.id) { $r in
            if r.toUserId == getFirebaseUserId() {
                NavigationLink(destination: BuddyProfileView(solUserId: r.fromUserId, friendStatus: "pending")) { // Replace DestinationView with your desired destination view
                    HStack {
                        Circle()
                            .fill(r.status != "pending" ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                        Text(r.fromUserName)
                            .font(.system(size: 14))
                        Spacer()
                        Text(r.status != "pending" ? "Friends" : "Not Friends")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
            }
            
            }
        }
    }
}

