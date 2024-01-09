//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct ProfileView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var realmObserver = RealmObserver<CurrentSolUser>()
    @State private var realmInstance = realm()
    
    @LiveCurrentUser var currentUser
    @LiveStateObjects(SolUser.self) var solUsers
    @LiveStateObjects(Connection.self) var solRequests
    @LiveConnections(friends: true) var connections
    
    @State private var aboutMe: String = "Just enjoying the world of coding and tech!"
    @State private var email: String = "email@example.com"
    @State private var phoneNumber: String = "123-456-7890"
    @State private var membershipType: Int = 0
    @State private var accountCreationDate: String = "Jan 1, 2020"
    @State private var visibility: String = "closed"
    @State private var photoUrl: String = "default_image_url"
    
    @State private var showNewPlanSheet = false
    @State private var showChatButton = true
    @State private var showAddBuddyButton = true
    @State private var showShareActivityButton = true
    
    @State private var friends: [SolUser] = []
//    @State private var requests: [Request] = []
    
    var body: some View {
        LoadingForm() { runLoading in
            Group() {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                HStack {
                    Text(currentUser?.userName ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Text(currentUser?.userId ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(currentUser?.email ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Section(header: Text("Friend Requests")) {
                    BuddyRequestListView()
                }
                
                Section(header: Text("Friends")) {
                    FriendsListView()
                }
                
                if showAddBuddyButton {
                    Button("Search Buddy") {
                        // Add buddy action
                        showNewPlanSheet = true
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
                solButton(title: "Sign Out", action: {
                    runLoading()
                    
                    logoutUser() { result in
                        print("User Logged Out. \(result)")
                    }
                    if let user = self.BEO.realmInstance.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
                        self.BEO.realmInstance.safeWrite { r in
                            user.userId = ""
                            user.userName = ""
                            user.email = ""
                            user.imgUrl = ""
                            user.isLoggedIn = false
                        }
                    }
                    self.BEO.userId = nil
                    self.BEO.userName = nil
                    self.BEO.isLoggedIn = false
                }, isEnabled: true)
                
            }
            .padding(.bottom, 20)
        }
        .task {
            _connections.refreshOnce()
            if let uId = getFirebaseUserId() {
                _solRequests.startFirebaseObservation(block: { db in
                    return db
                        .child("connections")
                        .queryOrdered(byChild: "userTwoId")
                        .queryEqual(toValue: uId)
                })
            }
        }
        .refreshable {
            loadUser()
        }
        .onAppear() {
            loadUser()
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            AddBuddyView(isPresented: $showNewPlanSheet, sessionId: .constant("none"))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile action
                }
            }
        }
    }
    
    func loadFriendRequests() {
        if let uId = getFirebaseUserId() {
            _solRequests.startFirebaseObservation(block: { db in
                return db
                    .child("connections")
                    .queryOrdered(byChild: "userTwoId")
                    .queryEqual(toValue: uId)
            })
        }
    }
    
    
    
    func loadUser() {
        
        
        print("Current User: \(String(describing: currentUser))")
    }
    
    private func profileInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title + ":")
                .font(.headline)
            Text(value)
                .font(.body)
            Divider()
        }
    }
}


//struct ActionButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .padding(.horizontal)
//            .scaleEffect(configuration.isPressed ? 0.95 : 1)
//    }
//}

//struct BuddyProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuddyProfileView()
//    }
//}
