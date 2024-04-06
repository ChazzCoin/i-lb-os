//
//  HistoryListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

// SwiftUI View for the Emoji Picker
struct ToolHistoryList: View {
//    var callback: (ManagedViewAction) -> Void
    @EnvironmentObject var BEO: BoardEngineObject
    @State var screenHeight = UIScreen.main.bounds.height
    @State var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    
    @State var showLoadAlert = false
    @State var showDeleteAlert = false
    @State var currentActionId = ""
    @State var currentViewId = ""
    
    
    @ObservedResults(ManagedViewAction.self) var allToolActions
    var allToolActionsInCurrentActivity: Results<ManagedViewAction> {
        return allToolActions
            .filter("boardId == %@", self.BEO.currentActivityId)
            .sorted(byKeyPath: "dateCreated", ascending: true)
    }
    func getToolActions(viewId:String) -> Results<ManagedViewAction> {
        return allToolActions
            .filter("viewId == %@", viewId)
            .sorted(byKeyPath: "dateCreated", ascending: true)
    }
    func loadToolAction(viewId:String, actionId:String) {
        if let action = self.BEO.realmInstance.findByField(ManagedViewAction.self, value: actionId) {
            self.BEO.realmInstance.safeFindByField(ManagedView.self, value: viewId) { obj in
                obj.absorbAction(from: action, saveRealm: self.BEO.realmInstance)
            }
        }
    }
    
    func deleteToolAction(actionId:String) {
        if let action = self.BEO.realmInstance.findByField(ManagedViewAction.self, value: actionId) {
            self.BEO.realmInstance.safeWrite { r in
                if action.isInvalidated { return }
                r.delete(action)
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(allToolActionsInCurrentActivity, id: \.self) { key in
                    HStack {
                        
                        HistoryItemView(action: key)
                            .onTapAnimation {
                                self.currentActionId = key.id
                                self.currentViewId = key.viewId
                                self.showLoadAlert = true
                            }
                            .onLongPress {
                                self.currentActionId = key.id
                                self.showDeleteAlert = true
                            }
                        
                        BodyText(TimeProvider.convertTimestampToReadableDate(timestamp: key.dateCreated) ?? key.dateCreated)
                            
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(height: screenHeight * 0.75, alignment: .leading)
        .solBackground()
        .alertConfirm(isPresented: $showLoadAlert, title: "Load Action", message: "Do you want to load this tool action?", action: {
            self.loadToolAction(viewId: self.currentViewId, actionId: self.currentActionId)
        })
        .alertDelete(isPresented: $showDeleteAlert, deleteAction: {
            self.deleteToolAction(actionId: self.currentActionId)
        })
        
    }
    
}

