//
//  ActivityPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

// ActivityPlan View
struct ActivityPlanView: View {
    @Binding var activityPlan: ActivityPlan
    var isEditMode: Bool

    var body: some View {
        if isEditMode {
//            TextField("Activity Name", text: $activityPlan.name)
            // Add other editable fields here
        } else {
//            Text(activityPlan.name)
            // Display other non-editable info here
        }
    }
}

