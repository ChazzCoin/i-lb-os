//
//  SearchableList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchableRecordingsListView: View {
    @Binding var isShowing: Bool
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }

    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @ObservedResults(Recording.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [Recording] = []
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    @State var selectedRecordingId = ""
    @State var showRecordingSheet = false
    
    var body: some View {
        VStack {
            
            SearchBar(text: $searchText, placeholder: "Search Recordings")
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            RecordingView(recordingId: item.id, isShowing: self.$isShowing)
                        } label: {
                            SolListItem(title: item.name, subTitle: String(item.duration), isShared: false)
//                                .onTapAnimation {
//                                    self.selectedRecordingId = item.id
//                                    self.showRecordingSheet = true
//                                }
                        }
                        
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
//        .sheet(isPresented: self.$showRecordingSheet, content: {
//            RecordingView(recordingId: self.$selectedRecordingId, isShowing: self.$showRecordingSheet)
//        })
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

