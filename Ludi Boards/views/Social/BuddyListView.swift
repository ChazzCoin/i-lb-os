//
//  BuddyListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct BuddyListView: View {
    @State private var buddies: [SolUser] = []
    @State private var showingAddBuddyView = false
    @State var realmInstance = realm()

    var body: some View {
        List($buddies, id: \.userId) { $buddy in
            
            NavigationLink(destination: BuddyProfileView()) { // Replace DestinationView with your desired destination view
                HStack {
                    Circle()
                        .fill(buddy.isLoggedIn ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                    Text(buddy.userName)
                        .font(.system(size: 14))
                    Spacer()
                    Text(buddy.isLoggedIn ? "Online" : "Away")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
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
            AddBuddyView(isPresented: $showingAddBuddyView)
        }
        .onAppear() {
            
        }
    }
}
struct BuddyRequestListView: View {
    @Binding var requests: [Request]
    @State private var showingAddBuddyView = false
    
    var body: some View {
        List($requests, id: \.id) { $r in
            if r.toUserId == getFirebaseUserId() {
                NavigationLink(destination: BuddyProfileView()) { // Replace DestinationView with your desired destination view
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

