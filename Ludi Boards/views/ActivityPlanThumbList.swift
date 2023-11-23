//
//  ActivityPlanThumbList.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

struct ActivityPlanListView: View {
    let activityPlans: [ActivityPlan]

    var body: some View {
        List(activityPlans) { activityPlan in
            NavigationLink(destination: ActivityPlanView(boardId: "boardEngine-1")) {
                ActivityPlanThumbView(activityPlan: activityPlan)
            }

            
        }
    }
}

struct ActivityPlanListView_Preview: PreviewProvider {
    static var previews: some View {
        ActivityPlanListView(activityPlans: [ActivityPlan()])
    }
}
