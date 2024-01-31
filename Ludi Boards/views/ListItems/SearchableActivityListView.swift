//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchableActivityListView: View {
    // Sample data structure

    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @ObservedResults(UserToSession.self, where: { $0.guestId == getFirebaseUserId() ?? "" && $0.status != "removed" }) var guestSessions
    var sharedSessionIds: [String] {
        var temp = Array(guestSessions.map { $0.sessionId })
        if !temp.contains("SOL-LIVE-DEMO") {
            temp.append("SOL-LIVE-DEMO")
        }
        return temp
    }
    
    @ObservedResults(ActivityPlan.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [ActivityPlan] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search items")
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink(
                            destination: 
                                ActivityPlanSingleView(inComingAP: .constant(item), sessionId: .constant(item.sessionId), isShowing: .constant(true))
                                    .environmentObject(self.BEO)
                                    .environmentObject(self.NavStack)
                        ){
                            SolListItem(title: item.title, subTitle: item.subTitle, isShared: false)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
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

