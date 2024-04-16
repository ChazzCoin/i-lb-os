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

//struct FriendsListView: View {
//    
//    @ObservedResults(Connection.self) var connections
//    
//    var friends: Results<Connection> {
//        return self.connections.filter("status == %@", "Accepted")
//    }
//    
//    @State var currentUserId = getFirebaseUserId() ?? ""
//    
//    var body: some View {
//        
//        if !(self.connections.realm?.isInWriteTransaction ?? true) {
//            List(friends) { r in
//                if !r.isInvalidated {
//                    NavigationLink(destination: BuddyProfileView(
//                        solUserId: currentUserId == r.userOneId ? r.userTwoId : r.userOneId,
//                        friendStatus: "friends"
//                    )) {
//                        HStack {
//                            Circle()
//                                .fill(Color.green)
//                                .frame(width: 10, height: 10)
//                            Text(currentUserId == r.userOneId ? r.userTwoName : r.userOneName)
//                                .font(.system(size: 14))
//                            Spacer()
//                            Text("Friend")
//                                .font(.system(size: 12))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//                
//            }
//            .refreshable {
//                
//            }
//            .onAppear() {
//                if let uid = getFirebaseUserId() {
//                    currentUserId = uid
//                }
//            }
//            .onDisappear() {
//             
//            }
//        }
//        
//    }
//}
//
