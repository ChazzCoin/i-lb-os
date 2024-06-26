//
//  AddBuddyView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI
import CoreEngine

struct AddBuddyView: View {
    @Binding var isPresented: Bool
    @Binding var sessionId: String
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var buddyName: String = ""
    @State private var buddyStatus: String = ""
    @State private var searchResults: [CoreUser] = []
    @State private var realmInstance = realm()

    var body: some View {
        NavigationView {
            LoadingForm { runLoading in
                Section(header: Text("Buddy Details")) {
                    TextField("Buddy UserName", text: $buddyName)
                }
                
                // Display search results
                if !searchResults.isEmpty {
                    Section(header: Text("Search Results")) {
                        List($searchResults, id: \.userId) { $user in
                            UserView(user: user, sessionId: self.$sessionId)
                                .onTapGesture {
                                    // Handle tap event for each user
                                    print("Tapped on \(user.userName)")
//                                    BuddyProfileView(solUserId: user.userId, friendStatus: "pending")
                                    
                                }
                        }
                    }
                }
                
                Section {
                    Button("Search Buddy") {
                        // Logic to add buddy
                        searchForUser(userName: buddyName)
                    }
                }
            }
            .navigationBarTitle("Search Buddy", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    func searchForUser(userName: String) {
        firebaseDatabase { db in
            db
            .child(DatabasePaths.users.rawValue)
            .queryOrdered(byChild: "userName")
            .queryEqual(toValue: userName)
            .observeSingleEvent(of: .value) { snapshot, _ in
                let _ = snapshot.toLudiObjects(CoreUser.self)
                let map = snapshot.toHashMap()
                for (_,v) in map {
                    searchResults.append(CoreUser(dictionary: v as! [String:Any]))
                }
            }
        }
    }
}
