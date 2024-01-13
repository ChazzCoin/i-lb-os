//
//  ActivityPlanThumbList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct ActivityPlanListView: View {
    @State var sessionId: String
    @EnvironmentObject var BEO: BoardEngineObject
    var body: some View {
        
        if let acts = self.BEO.realmInstance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionId) {
            List(acts) { activityPlan in
                if !activityPlan.isInvalidated && !activityPlan.isDeleted {
                    NavigationLink(destination: ActivityPlanView(boardId: activityPlan.id, sessionId: activityPlan.sessionId, isShowing: .constant(true)).environmentObject(self.BEO)) {
                        ActivityPlanThumbView(activityPlan: activityPlan)
                    }
                }
            }
        }
        
    }
}

