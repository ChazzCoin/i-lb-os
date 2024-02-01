//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchableRecordingActionsListView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    
    @ObservedResults(RecordingAction.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [RecordingAction] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            HeaderText("Action Timeline")
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        SolListItem(title: item.boardId, subTitle: String(item.orderIndex), isShared: false)
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
            filteredItems = allItems.filter { $0.boardId.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct RecordingActionsTimelineListView: View {
    @Binding var recordingId: String
    @EnvironmentObject var BEO: BoardEngineObject
    
    @ObservedResults(RecordingAction.self) var allItems
    @State private var searchText = ""
//    @State private var filteredItems: [RecordingAction] = []
    var filteredItems: Results<RecordingAction> {
        return allItems
            .filter("recordingId == %@", self.recordingId)
            .sorted(byKeyPath: "orderIndex", ascending: true)
    }
    
    var body: some View {
        VStack {
//            SearchBar(text: $searchText, placeholder: "Search Recorded Actions")
//                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(filteredItems) { recording in
                        TimelineItemView(recording: recording)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            }
            .frame(height: 150) // Adjust based on your design
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 20) {
//                    ForEach(filteredItems) { item in
//                        SolListItem(title: item.boardId, subTitle: String(item.orderIndex), isShared: false)
//                    }
//                }
//                .listStyle(GroupedListStyle())
//            }
        }
//        .onAppear {
////            self.filteredItems = self.allItems.toArray()
//            self.filterItems()
//        }
//        .onChange(of: searchText) { _ in
//            self.filterItems()
//        }
    }
    
//    private func filterItems() {
//        if searchText.isEmpty {
//            filteredItems = allItems.toArray()
//        } else {
//            filteredItems = allItems.filter { $0.boardId.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
}

