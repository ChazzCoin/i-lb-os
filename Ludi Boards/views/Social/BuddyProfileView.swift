//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct BuddyProfileView: View {
    @State var solUserId: String
    @State var friendStatus: String
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var realmInstance = realm()
    
    @ObservedResults(CoreUser.self) var users
    var solUser: CoreUser? {
        return self.users.filter("userId == %@", self.solUserId).first
    }
        
    @State private var showNewPlanSheet = false
//    @State private var showChatButton = false
    @State private var showAddBuddyButton = false
    @State private var showAcceptBuddyButton = false
    
    var body: some View {
    
        LoadingForm() { runLoading in
            Group() {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                HStack {
                    Text(solUser?.userName ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Text(solUser?.userId ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(solUser?.email ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                if showAddBuddyButton {
                    Button("Add Buddy") {
                        // Add buddy action
                        showNewPlanSheet = true
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
                if showAcceptBuddyButton {
                    Button("Accept Buddy Request") {
                        // Add buddy action
                        runLoading()
//                        if let obj = self.realmInstance.findByField(Connection.self, field: "userOneId", value: self.solUserId) {
//                            self.realmInstance.safeWrite { _ in
//                                obj.status = "Accepted"
//                                obj.connectionId = obj.connectionId + self.solUserId
//                                firebaseDatabase { db in
//                                    db.child("connections").child(obj.id).setValue(obj.toDict())
//                                }
//                            }
//                        }
                        
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
            }
            .padding(.bottom, 20)
        }
        .refreshable {
            loadUser()
        }
        .onAppear() {
            loadUser()
            
            switch (friendStatus) {
                case "pending": self.showAcceptBuddyButton = true
                case "friends":  self.showAddBuddyButton = false
                default: self.showAddBuddyButton = true
            }
            
            if friendStatus == "pending" {
                self.showAddBuddyButton = true
            }
            
        }
        .onDisappear() {
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            AddBuddyView(isPresented: $showNewPlanSheet, sessionId: .constant(""))
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
        print("Sol Buddy: [ \(String(describing: solUser)) ]")
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


struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

