//
//  ActivityPlanThumbList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

struct ActivityPlanListView: View {
    @Binding var activityPlans: [ActivityPlan]
    @EnvironmentObject var BEO: BoardEngineObject
    var body: some View {
        
        if !activityPlans.isEmpty {
            List(activityPlans) { activityPlan in
                if !activityPlan.isInvalidated {
                    NavigationLink(destination: ActivityPlanView(boardId: activityPlan.id, sessionId: activityPlan.sessionId, isShowing: .constant(true)).environmentObject(self.BEO)) {
                        ActivityPlanThumbView(activityPlan: activityPlan)
                    }
                }   
            }
        } else {
            Text("No Activities Yet.")
        }
        
    }
}

//struct ActivityPlanListView_Preview: PreviewProvider {
//    static var previews: some View {
//        ActivityPlanListView(activityPlans: [ActivityPlan()])
//    }
//}
