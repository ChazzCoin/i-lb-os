//
//  BuddyRequestListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

//import Foundation
//import SwiftUI
//import RealmSwift
//import CoreEngine

//struct BuddyRequestListView: View {
//    @ObservedResults(Connection.self) var connections
//    
//    var requests: Results<Connection> {
//        return self.connections.filter("status == %@", "pending")
//    }
//    @State private var showingAddBuddyView = false
//    
//    var body: some View {
//        List(requests) { r in
//            if r.userTwoId == getFirebaseUserId() {
//                NavigationLink(destination: BuddyProfileView(solUserId: r.userOneId, friendStatus: "pending")) { 
//                    // Replace DestinationView with your desired destination view
//                    HStack {
//                        Circle()
//                            .fill(r.status != "pending" ? Color.green : Color.gray)
//                            .frame(width: 10, height: 10)
//                        Text(r.userOneName)
//                            .font(.system(size: 14))
//                        Spacer()
//                        Text(r.status != "pending" ? "Friends" : "Not Friends")
//                            .font(.system(size: 12))
//                            .foregroundColor(.gray)
//                    }
//            }
//            
//            }
//        }.onDisappear() {
//            
//        }
//    }
//}

