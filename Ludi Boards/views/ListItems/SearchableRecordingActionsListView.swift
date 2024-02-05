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
    
    @State var alertDeleteItem = false
    @State var alertDeleteItemTitle = ""
    
    
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

    var filteredItems: Results<RecordingAction> {
        return allItems
            .filter("recordingId == %@", self.recordingId)
            .sorted(byKeyPath: "orderIndex", ascending: true)
    }
    
    @State var alertDelete = false
    @State var deleteItemId = ""
    
    var body: some View {
        VStack {
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(filteredItems) { recording in
                        TimelineItemView(recording: recording)
                            .onTapAnimation {
                                deleteItemId = recording.id
                                alertDelete = true
                            }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .frame(height: 125) // Adjust based on your design
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .alertDelete(isPresented: $alertDelete, deleteAction: {
                self.BEO.realmInstance.safeFindByField(RecordingAction.self, value: deleteItemId) { obj in
                    self.BEO.realmInstance.safeWrite { r in
                        r.delete(obj)
                    }
                }
            })
        }

    }
    
}

struct TimelineItemView: View {
    let recording: RecordingAction
    
    var body: some View {
        VStack {
            Spacer()
            if let temp = SoccerToolProvider.parseByTitle(title: recording.toolType)?.tool.image {
                Image(temp)
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            
            Text("Action")
                .font(.subheadline)
                .padding(.top, 5)
            Text(recording.orderIndex == 0 ? "Start" : String(recording.orderIndex))
                .font(.caption)
                .padding(.bottom, 5)
            Spacer()
        }
        .frame(width: 75, height: 100)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
struct HistoryItemView: View {
    let action: ManagedViewAction
    
    var body: some View {
        VStack {
            Spacer()
            ToolIconFactory(toolType: action.toolType)
            Text("Action")
                .font(.subheadline)
                .padding(.top, 5)
            Spacer()
        }
        .frame(width: 50, height: 75)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
