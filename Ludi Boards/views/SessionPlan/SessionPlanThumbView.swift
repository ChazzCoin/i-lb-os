//
//  ActivityPlanThumbView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/22/23.
//

import Foundation
import SwiftUI

struct SessionPlanThumbView: View {
    let sessionPlan: SessionPlan

    var body: some View {
        HStack(spacing: 16) {
            Image("soccer_one") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(sessionPlan.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(sessionPlan.subTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
                Text(sessionPlan.sessionDetails)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(sessionPlan.objectiveDetails)
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
        .onTapAnimation {
            CodiChannel.SESSION_ON_ID_CHANGE.send(value: sessionPlan.id)
        }
        .navigationBarTitle("SOL Sessions", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                print("Minimize")
                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: MenuBarProvider.boardCreate.tool.title, stateAction: "close"))
            }) {
                Image(systemName: "minus")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        })
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
            NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id)) {
                SessionPlanThumbView(sessionPlan: sessionPlan)
            }
        }.onAppear() {
            let results = realmInstance.objects(SessionPlan.self)
            sessionPlans.removeAll()
            for i in results {
                sessionPlans.append(i)
            }
        }
    }
}

struct SessionPlanListView_Preview: PreviewProvider {
    static var previews: some View {
        SessionPlanListView(sessionPlans: [SessionPlan(), SessionPlan()])
    }
}
