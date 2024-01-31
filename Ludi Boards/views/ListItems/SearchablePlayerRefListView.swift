//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchablePlayerRefListView: View {
    // Sample data structure

    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @ObservedResults(PlayerRef.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [PlayerRef] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    @State private var currentPlayerId = ""
    @State private var showCurrentPlayerSheet = false
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search Players")
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        SolListSingleItem(title: item.name, isShared: false)
                            .onTapAnimation {
                                currentPlayerId = item.id
                                showCurrentPlayerSheet = true
                            }
                    }
                    .clearSectionBackground()
                }
                .clearSectionBackground()
            }
            .clearSectionBackground()
        }
        .clearSectionBackground()
        .sheet(isPresented: $showCurrentPlayerSheet) {
            PlayerRefView(playerId: $currentPlayerId, isShowing: $showCurrentPlayerSheet)
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

