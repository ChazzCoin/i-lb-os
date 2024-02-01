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
    @EnvironmentObject var BEO: BoardEngineObject
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    
    @ObservedResults(Recording.self) var allItems
    @State private var searchText = ""
    @State private var filteredItems: [Recording] = []
    
    var activityItems: Results<Recording> {
        return allItems.filter("boardId == %@", self.BEO.currentActivityId)
    }
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    @State var selectedRecordingId = ""
    @State var showRecordingSheet = false
    
    @State var showDeleteAlert = false
    @State var itemToDeleteId = ""
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                
                SearchBar(text: $searchText, placeholder: "Search Recordings")
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                RecordingView(recordingId: item.id, isShowing: self.$isShowing)
                            } label: {
                                SolListItem(title: item.name, subTitle: String(item.duration), isShared: false)
                            }
//                            .gesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
//                                showDeleteAlert = true
//                                itemToDeleteId = item.id
//                            })
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            }
        }
        .onChange(of: self.BEO.currentActivityId, perform: { value in
            self.filteredItems = self.activityItems.toArray()
            self.filterItems()
        })
        .onChange(of: searchText) { _ in
            self.filterItems()
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Recording"),
                message: Text("Are you sure you want to delete this recording? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    self.BEO.realmInstance.safeFindByField(Recording.self, value: self.itemToDeleteId) { obj in
                        self.BEO.realmInstance.safeWrite { r in
                            r.delete(obj)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            self.filteredItems = self.activityItems.toArray()
            print(self.filteredItems)
            self.filterItems()
        }
    }
    
    private func filterItems() {
        if searchText.isEmpty {
            filteredItems = activityItems.toArray()
        } else {
            filteredItems = activityItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Method to handle deletion
    private func deleteItems(at offsets: IndexSet) {
        print("On Delete!")
    }
}

