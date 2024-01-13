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
        
        VStack(alignment: .leading, spacing: 4) {
            Text(activityPlan?.title ?? "Unknown")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.blue) // Highlighted title color
                .lineLimit(1)

            HStack(spacing: 16) {
                // Image
                Image("soccer_one") // Replace with actual image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .background(Color.gray.opacity(0.3)) // Placeholder background
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2) // Adding border
                    )

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(activityPlan?.subTitle ?? "Unknown")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text("Date: \(activityPlan?.dateOf ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text("Duration: \(activityPlan?.duration ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
        }
        
        
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 8)
    }
}

struct ActivityPlanThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPlanThumbView(activityPlan: nil)
    }
}



struct ActivityPlanThumbView2: View {
    let activityPlan: ActivityPlan?

    var body: some View {
        
        VStack {
            Text(activityPlan?.title ?? "Unknown")
                .font(.headline)
                .lineLimit(1)
            HStack(spacing: 16) {
                Image("soccer_one") // Replace with actual image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    
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
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}



