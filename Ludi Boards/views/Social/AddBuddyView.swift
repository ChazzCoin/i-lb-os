//
//  AddBuddyView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct AddBuddyView: View {
    @Binding var isPresented: Bool
    @State private var buddyName: String = ""
    @State private var buddyStatus: String = ""
    @State private var searchResults: [SolKnight] = []

    var body: some View {
        NavigationView {
            LoadingForm { runLoading in
                Section(header: Text("Buddy Details")) {
                    TextField("Buddy UserName", text: $buddyName)
                }

                // Display search results
                if !searchResults.isEmpty {
                    Section(header: Text("Search Results")) {
                        List($searchResults, id: \.tempId) { $user in
                            HStack {
                                Text(user.username)
                                Spacer()
                            }
                            .onTapGesture {
                                // Handle tap event for each user
                                print("Tapped on \(user.username)")
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
            db.child(DatabasePaths.users.rawValue).queryOrdered(byChild: "username").queryEqual(toValue: userName).observeSingleEvent(of: .value) { snapshot, _ in
                let map = snapshot.toHashMap()
                for (_,v) in map {
                    searchResults.append(SolKnight(dictionary: v as! [String:Any]))
                }
            }
        }
    }
}
