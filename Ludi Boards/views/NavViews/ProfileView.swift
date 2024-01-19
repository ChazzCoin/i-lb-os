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
    @State private var realmInstance = realm()
    
    @StateObject var currentUser = LiveCurrentUser()
    @ObservedResults(SolUser.self) var solUsers
    @ObservedResults(Connection.self) var connections
    
    var friends: Results<Connection> {
        return self.connections.filter("status == %@", "Accepted")
    }
    var friendRequests: Results<Connection> {
        return self.connections.filter("status == %@", "pending")
    }
    
    @State private var showNewPlanSheet = false
    @State private var showChatButton = true
    @State private var showAddBuddyButton = true
    @State private var showShareActivityButton = true
    
    var body: some View {
        LoadingForm() { runLoading in
            Group() {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                HStack {
                    Text(currentUser.object?.userName ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Text(currentUser.object?.userId ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(currentUser.object?.email ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                if self.BEO.isLoggedIn {
                    Section(header: Text("Connection Status")) {
                        InternetSpeedChecker()
                    }
                }
                
                Section(header: Text("Friend Requests")) {
                    BuddyRequestListView()
                }
                
                Section(header: Text("Friends")) {
                    FriendsListView()
                }
                
                solButton(title: "Search Buddy", action: {
                    // Add buddy action
                    showNewPlanSheet = true
                }, isEnabled: showAddBuddyButton)
                
                solConfirmButton(
                    title: "Sign Out",
                    message: "Are you sure you want to logout?",
                    action: {
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
                    },
                    isEnabled: true)
                
            }
            .padding(.bottom, 20)
        }
        .refreshable {
            loadUser()
        }
        .onAppear() {
            loadUser()
        }
        .onDisappear() {
            currentUser.destroy()
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
    
    func loadUser() {
        currentUser.start()
        FirebaseConnectionsService.refreshOnce()
       
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
