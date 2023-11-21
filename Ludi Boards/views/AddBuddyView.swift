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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Buddy Details")) {
                    TextField("Buddy Name", text: $buddyName)
                    TextField("Status", text: $buddyStatus)
                }

                Section {
                    Button("Add Buddy") {
                        // Logic to add buddy
                        isPresented = false
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
