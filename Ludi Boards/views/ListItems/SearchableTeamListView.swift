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

struct SearchableTeamListView: View {
    // Sample data structure

    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @ObservedResults(Team.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [Team] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    @State private var currentTeamId = ""
    @State private var showCurrentTeamSheet = false
    
    var body: some View {
        VStack {
            
            SearchBar(text: $searchText, placeholder: "Search Teams")
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        SolListSingleItem(title: item.name, isShared: false)
                            .onTapAnimation {
                                currentTeamId = item.id
                                showCurrentTeamSheet = true
                            }
                    }
                    .clearSectionBackground()
                }
                .clearSectionBackground()
            }
            .clearSectionBackground()
        }
        .clearSectionBackground()
        .sheet(isPresented: $showCurrentTeamSheet) {
            TeamView(teamId: $currentTeamId, isShowing: $showCurrentTeamSheet)
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
            filteredItems = allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

