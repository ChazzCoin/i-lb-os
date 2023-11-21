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
    var boardId: String
    
    @State private var activityPlan = ActivityPlan() // Use StateObject for lifecycle management

        private func fetchSessionPlan() {
            // Fetch board details and update state variables
            // Populate the activityPlan object with fetched data
        }

        var body: some View {
            Form {
                // Details Section
                Section(header: Text("Activity Details")) {
                    TextField("Title", text: $activityPlan.title)
                    TextField("Sub Title", text: $activityPlan.subTitle)
                    TextField("Date", text: $activityPlan.dateOf)
                    TextField("Time Period", text: $activityPlan.timePeriod)
                    TextField("Duration", text: $activityPlan.duration)
                    TextField("Age Level", text: $activityPlan.ageLevel)
                }

                // Description Section
                Section(header: Text("Description")) {
                    TextEditor(text: $activityPlan.objectiveDetails)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }

                // Objective Section
                Section(header: Text("Objective")) {
                    TextEditor(text: $activityPlan.activityDetails)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }

                // Save Button Section
                Section {
                    Button("Save", action: {
                        // Implement the save action
                    })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }.clearSectionBackground()
            }

            .onAppear {
                fetchSessionPlan()
            }
            .navigationBarTitle("Activity Plan", displayMode: .inline)
        }
}




struct ActivityDetailsForm_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPlanView(boardId: "123")
    }
}
