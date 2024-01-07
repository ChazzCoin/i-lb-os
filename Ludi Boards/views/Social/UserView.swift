//
//  UserView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/4/24.
//

import Foundation
import SwiftUI
import Combine

struct UserView: View {
    @State var user: SolUser
    @State var realmInstance = realm()
    @State var friendIconImage = "person.badge.plus"

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

            Button(action: { friendRequestAction() }) {
                Image(systemName: friendIconImage)
            }
            .buttonStyle(FriendshipButtonStyle())
        }
        .padding()
    }

    func friendRequestAction() {
        realmInstance.getCurrentSolUser(action: { cur in
            let request = Connection()
            request.userOneId = cur.userId
            request.userOneName = cur.userName
            request.userTwoId = user.userId
            request.userTwoName = user.userName
            request.connectionId = cur.userId + ":"
            
            firebaseDatabase { db in
                db.child("connections").child(request.id).setValue(request.toDict())
            }
            friendIconImage = "hourglass"
        })
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
