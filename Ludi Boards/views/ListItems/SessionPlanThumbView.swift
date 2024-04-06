//
//  ActivityPlanThumbView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI
import CoreEngine

struct SessionPlanThumbView: View {
    @State var sessionPlan: SessionPlan
//    @EnvironmentObject var NavStack: NavStackWindowObservable

    var body: some View {
        HStack(spacing: 16) {
            // Image Styling
            Image("tools_soccer_thumb_field") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 75, height: 75)
                .background(Color.gray.opacity(0.3)) // Placeholder background
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2) // Adding a subtle border
                )

            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(sessionPlan.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primaryBackground) // Highlighted title color
                    .lineLimit(1)

                Text(sessionPlan.subTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(sessionPlan.id)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 8)
        .navigationBarTitle("SOL Sessions", displayMode: .inline)
    }
}


//struct SessionPlanThumbView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPlanThumbView(sessionPlan: SessionPlan())
//    }
//}

struct SessionPlanListView: View {
    @State var sessionPlans: [SessionPlan] = []
    let realmInstance = realm()

    var body: some View {
        List(sessionPlans) { sessionPlan in
            if !sessionPlan.isInvalidated {
                SessionPlanThumbView(sessionPlan: sessionPlan)
            }
        }.onAppear() {
            let results = realmInstance.objects(SessionPlan.self)
            if results.isEmpty {return}
            sessionPlans.removeAll()
            for i in results {
                sessionPlans.append(i)
            }
        }
        .onDisappear() {
            sessionPlans.removeAll()
        }
    }
}

//struct SessionPlanListView_Preview: PreviewProvider {
//    static var previews: some View {
//        SessionPlanListView(sessionPlans: [SessionPlan(), SessionPlan()])
//    }
//}
