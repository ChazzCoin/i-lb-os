//
//  ActivityPlanThumbView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

struct ActivityPlanThumbView: View {
    let activityPlan: ActivityPlan

    var body: some View {
        HStack(spacing: 16) {
            Image("soccer_one") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text("activityPlan.title")
                    .font(.headline)
                    .lineLimit(1)
                Text("activityPlan.subTitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
                Text("Date: \(activityPlan.dateOf)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Duration: \(activityPlan.duration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.frame(height: 110)

            Spacer()
        }
        .frame(height: 110)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}


struct ActivityPlanThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPlanThumbView(activityPlan: ActivityPlan())
    }
}
