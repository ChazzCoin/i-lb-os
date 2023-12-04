//
//  ActivityPlanThumbView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

struct ActivityPlanThumbView: View {
    let activityPlan: ActivityPlan?

    var body: some View {
        HStack(spacing: 16) {
            Image("soccer_one") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 75, height: 75)
                .cornerRadius(10)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(activityPlan?.title ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                Text(activityPlan?.subTitle ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("Date: \(activityPlan?.dateOf ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Duration: \(activityPlan?.duration ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
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
