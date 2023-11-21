//
//  BuddyListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct BuddyListView: View {
    @State private var buddies: [Buddy] = getSampleBuddies()
    @State private var showingAddBuddyView = false

    var body: some View {
        NavigationStack {
            List($buddies) { $buddy in
                HStack {
                    Circle()
                        .fill(buddy.status == "Online" ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                    Text(buddy.userName ?? "No Name")
                        .font(.system(size: 14))
                    Spacer()
                    Text(buddy.status ?? "Away")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    print("Tapped on \(buddy.userName ?? "Unknown")")
                    CodiChannel.general.send(value: MenuBarProvider.profile.tool.title)
                }
            }
            .navigationBarTitle("Buddy List", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBuddyView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBuddyView) {
                AddBuddyView(isPresented: $showingAddBuddyView)
            }
        }
    }
}

struct BuddyListView_Previews: PreviewProvider {
    static var previews: some View {
        BuddyListView()
    }
}
