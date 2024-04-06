//
//  UserView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/4/24.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import CoreEngine

struct UserView: View {
    @State var user: CoreUser
    @Binding var sessionId: String
    @EnvironmentObject var BEO: BoardEngineObject
    @State var realmInstance = realm()
    @State var friendIconImage = "person.badge.plus"
    @State var sharedIconImage = "person.badge.plus"

    var body: some View {
        HStack {
//            AsyncImage(url: URL(user.imageURL)) { image in
//                image.resizable()
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: 60, height: 60)
//            .clipShape(Circle())
//            .padding(.trailing, 10)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .padding(.top, 30)

            VStack(alignment: .leading) {
                Text(user.userName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
            }

            Spacer()

            Button(action: { shareSessionAction() }) {
                Image(systemName: sharedIconImage)
            }
            .buttonStyle(FriendshipButtonStyle())
            
            Button(action: { friendRequestAction() }) {
                Image(systemName: friendIconImage)
            }
            .buttonStyle(FriendshipButtonStyle())
        }
        .padding()
        .onAppear() {
            getSharedSession()
            getFriend()
        }
    }
    
    func getFriend() {
//        if let results: Results<Connection> = self.realmInstance.findAllByField(Connection.self, field: "userOneId", value: self.user.userId) {
//            for item in results {
//                if item.status == "Accepted" {
//                    friendIconImage = "checkmark.circle.fill"
//                }
//                else if item.status == "pending" {
//                    friendIconImage = "hourglass"
//                } else {
//                    friendIconImage = "person.badge.plus"
//                }
//            }
//            return
//        }
        
//        if let results: Results<Connection> = self.realmInstance.findAllByField(Connection.self, field: "userTwoId", value: self.user.userId) {
//            for item in results {
//                if item.status == "Accepted" {
//                    friendIconImage = "checkmark.circle.fill"
//                }
//                else if item.status == "pending" {
//                    friendIconImage = "hourglass"
//                } else {
//                    friendIconImage = "person.badge.plus"
//                }
//            }
//            return
//        }
        
    }
    
    func getSharedSession() {
        if let results: Results<UserToSession> = self.realmInstance.findAllByField(UserToSession.self, field: "guestId", value: self.user.userId) {
            for item in results {
                if item.sessionId == self.sessionId {
                    sharedIconImage = "checkmark.circle.fill"
                    return
                }
            }
            sharedIconImage = "person.badge.plus"
        }
    }
    
    func shareSessionAction() {
//        realmInstance.getCurrentSolUser(action: { cur in
//            let request = UserToSession()
////            request.hostId = cur.userId
////            request.hostUserName = cur.userName
////            request.guestId = user.userId
////            request.guestUserName = user.userName
//            request.sessionId = self.sessionId
//            self.realmInstance.safeWrite { _ in
//                self.realmInstance.create(UserToSession.self, value: request, update: .all)
//            }
//            
//            request.fireSave(id: request.id)
//            firebaseDatabase { db in
//                db.child(DatabasePaths.userToActivity.rawValue).child(request.id).setValue(request.toDict())
//            }
//            sharedIconImage = "checkmark.circle.fill"
//        })
    }

    func friendRequestAction() {
//        realmInstance.getCurrentSolUser(action: { cur in
//            let request = Connection()
//            request.userOneId = cur.userId
//            request.userOneName = cur.userName
//            request.userTwoId = user.userId
//            request.userTwoName = user.userName
//            request.connectionId = cur.userId + ":"
//            self.realmInstance.safeWrite { _ in
//                self.realmInstance.create(UserToSession.self, value: request, update: .all)
//            }
//            
//            request.fireSave(id: request.id)
//            
////            firebaseDatabase { db in
////                db.child(DatabasePaths.connections.rawValue).child(request.id).setValue(request.toDict())
////            }
//            friendIconImage = "hourglass"
//        })
    }
}

struct FriendshipButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .imageScale(.large)
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())
    }
}
