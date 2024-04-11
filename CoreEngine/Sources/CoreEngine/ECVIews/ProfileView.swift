//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift


public struct CoreProfileView: View {
    
    public init() {}
    
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @State public var realmInstance = realm()
    
    @ObservedResults(CoreUser.self) public var solUsers

    @State public var showNewPlanSheet = false
    @State public var showChatButton = true
    @State public var showAddBuddyButton = true
    @State public var showShareActivityButton = true
    
    public var body: some View {
        Form {
            Group() {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                HStack {
//                    Text(currentUser.object?.userName ?? "")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
                    
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
//                Text(currentUser.object?.userId ?? "")
//                    .font(.subheadline)
//                    .fontWeight(.bold)
//                Text(currentUser.object?.email ?? "")
//                    .font(.subheadline)
//                    .fontWeight(.bold)
                
                if self.isLoggedIn {
                    Section(header: Text("Connection Status")) {
//                        InternetSpeedChecker()
                    }
                }
                
//                Section(header: Text("Friend Requests")) {
//                    BuddyRequestListView()
//                }
//                
//                Section(header: Text("Friends")) {
//                    FriendsListView()
//                }
                
//                SolButton(title: "Search Buddy", action: {
//                    // Add buddy action
//                    showNewPlanSheet = true
//                }, isEnabled: showAddBuddyButton)
//                
//                SolConfirmButton(
//                    title: "Sign Out",
//                    message: "Are you sure you want to logout?",
//                    action: {
////                        runLoading()
//                        UserTools.logout()
//                    },
//                    isEnabled: true)
                
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
//            currentUser.destroy()
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
//            AddBuddyView(isPresented: $showNewPlanSheet, sessionId: .constant("none"))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile action
                }
            }
        }
    }
    
    public func loadUser() {
//        currentUser.start()
//        FirebaseConnectionsService.refreshOnce()
//       
//        print("Current User: \(String(describing: currentUser))")
    }
    
    public func profileInfoRow(title: String, value: String) -> some View {
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
