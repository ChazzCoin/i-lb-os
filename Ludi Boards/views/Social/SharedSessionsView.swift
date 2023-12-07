//
//  SharedSessionsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/6/23.
//

import Foundation
import SwiftUI

struct ShareThumbnailView: View {
    var share: Share

    var body: some View {
        Group {
            // Replace with an actual image or icon if available
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 4) {
                Text("From: \(share.hostUserName)")
                    .font(.headline)
                Text("Status: \(share.status)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                // Accept action
            }) {
                Text("Accept")
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
            }

            Button(action: {
                // Reject action
            }) {
                Text("Reject")
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}


struct SharedSessionsView: View {
    @State var sessions: [SessionPlan] = []

    var body: some View {
        
        Section(header: Text("Shared Sessions")) {
            List(sessions) { sessionPlan in
                NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)) {
                    SessionPlanThumbView(sessionPlan: sessionPlan)
                }
                Spacer()
                AcceptRejectButtons(session: sessionPlan)
            }
        }.clearSectionBackground()
        
    }
}

struct AcceptRejectButtons: View {
    @State var session: SessionPlan // Your session model

    var body: some View {
        HStack {
            Button(action: {
                // Accept action
            }) {
                Text("Accept")
                    .foregroundColor(.green)
            }

            Button(action: {
                // Reject action
            }) {
                Text("Reject")
                    .foregroundColor(.red)
            }
        }
    }
}

// Define your Session model and SessionThumbnailView here
