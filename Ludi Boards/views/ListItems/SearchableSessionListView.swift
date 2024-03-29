//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchableSessionListView: View {
    // Sample data structure

    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @ObservedResults(UserToSession.self, where: { $0.status != "removed" }) var guestSessions
    var sharedSessionIds: [String] {
        var temp = Array(guestSessions.map { $0.sessionId })
        if !temp.contains("SOL-LIVE-DEMO") {
            temp.append("SOL-LIVE-DEMO")
        }
        return temp
    }
    
    @ObservedResults(SessionPlan.self, where: { $0.isDeleted != true }) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [SessionPlan] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search Sessions")
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        if !item.isDeleted {
                            NavigationLink(
                                destination: SessionPlanView(sessionId: item.id, isShowing: .constant(true), isMasterWindow: false)
                                    .environmentObject(self.BEO)
                                    .environmentObject(self.NavStack)
                            ){
                                SolListItem(title: item.title, subTitle: item.subTitle, isShared: self.sharedSessionIds.contains(item.id))
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationBarTitle("Sessions")
        .onAppear {
            self.filteredItems = self.allItems.toArray()
            self.filterItems()
        }
        .onChange(of: searchText) { _ in
            self.filterItems()
        }
    }
    
    private func filterItems() {
        if searchText.isEmpty {
            filteredItems = allItems.toArray()
        } else {
            filteredItems = allItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

