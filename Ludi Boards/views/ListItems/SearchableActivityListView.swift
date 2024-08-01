//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct SearchableActivityListView: View {
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
    
    @ObservedResults(ActivityPlan.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [ActivityPlan] = []
    @State private var showSheet: Bool = false
    @State private var currentAP: ActivityPlan? = nil
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search Activities")
                .padding(.top)
            ScrollView {
                LazyVGrid(columns: columns, alignment: HorizontalAlignment.leading, spacing: 5) {
                    ForEach(filteredItems) { item in
                        SolListItem(title: item.title, subTitle: item.subTitle, isShared: false)
                            .onTapAnimation {
                                self.currentAP = item
                                self.showSheet = true
                            }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .activityPlanSheet(isPresented: $showSheet, activityId: currentAP?.id ?? "SOL", BEO: BEO)
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

