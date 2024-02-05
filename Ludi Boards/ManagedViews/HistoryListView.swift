//
//  HistoryListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import SwiftUI
import RealmSwift

// SwiftUI View for the Emoji Picker
struct ToolHistoryList: View {
//    var callback: (ManagedViewAction) -> Void
    @EnvironmentObject var BEO: BoardEngineObject
    @State var screenHeight = UIScreen.main.bounds.height
    @State var screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    
    
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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(allToolActionsInCurrentActivity, id: \.self) { key in
                    HStack {
                        
                        HistoryItemView(action: key)
                            .onTapAnimation {
                                self.loadToolAction(viewId: key.viewId, actionId: key.id)
                            }
                        
                        BodyText(TimeProvider.convertTimestampToReadableDate(timestamp: key.dateCreated) ?? key.dateCreated)
                            
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(height: screenHeight * 0.75, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(getBackgroundColor(colorScheme))
                .shadow(radius: 5)
        )
        
    }
    
}

