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
    @State private var searchResults: [User] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Buddy Details")) {
                    TextField("Buddy UserName", text: $buddyName)
                }

                // Display search results
                if !searchResults.isEmpty {
                    Section(header: Text("Search Results")) {
                        List(searchResults, id: \.id) { user in
                            HStack {
                                Text(user.username)
                                Spacer()
                                Text(user.status ?? "Unknown") // Assuming status is an optional property
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
                        searchResults = [
                            User(),
                            User()
                        ]
                    }
                }
            }
            .navigationBarTitle("Search Buddy", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
