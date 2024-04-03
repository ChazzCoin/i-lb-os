//
//  TeamDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct ActivityDetailsView: View {
    
    var activityId: String
    @Binding var isShowing: Bool
    
    init(activityId: String, isShowing: Binding<Bool> = .constant(true)) {
        self.activityId = activityId
        self._isShowing = isShowing
    }
    
    @State var sport: String = ""
    
    @State var title = ""
    @State var subTitle = ""
    @State var date: Date = Date()
    @State var timePeriod = ""
    @State var duration = ""
    @State var ageLevel = ""
    @State var intensity = ""
    @State var numOfGroups = 0
    @State var numPerGroup = 0
    @State var numOfPlayers = 0
    @State var coachingPoints = ""
    @State var guidedAnswers = ""
    @State var keyQualities = ""
    @State var principles = ""
    @State var equipment = ""
    @State var spaceDimensions = ""
    @State var objectiveDetails = ""
    @State var activityDetails = ""

    @State var realmInstance = newRealm()
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var isEditMode: Bool = true
    
    func save() {
        if activityId == "new" {
            new()
        } else {
            update()
        }
    }
    func update() {
        if let activityPlan = realmInstance.findByField(ActivityPlan.self, value: activityId) {
            realmInstance.safeWrite { r in
                activityPlan.orderIndex = 0
                activityPlan.ownerId = getFirebaseUserIdOrCurrentLocalId()
                activityPlan.title = title
                activityPlan.subTitle = subTitle
                activityPlan.duration = duration
//                currentAp.dateOf = date
                activityPlan.ageLevel = ageLevel
                activityPlan.timePeriod = timePeriod
                activityPlan.activityDetails = activityDetails
                activityPlan.objectiveDetails = objectiveDetails
            }
        }
    }
    func new() {
        let newPlan = ActivityPlan()
        newPlan.orderIndex = 0
        newPlan.ownerId = getFirebaseUserIdOrCurrentLocalId()
        newPlan.title = title
        newPlan.subTitle = subTitle
        newPlan.duration = duration
        newPlan.ageLevel = ageLevel
        newPlan.timePeriod = timePeriod
        newPlan.activityDetails = activityDetails
        newPlan.objectiveDetails = objectiveDetails
       
        realmInstance.safeWrite { r in
            r.create(ActivityPlan.self, value: newPlan)
        }
    }
    
    func fetch() {
        if activityId == "new" {
            return
        }
        if let activityPlan = realmInstance.findByField(ActivityPlan.self, value: activityId) {
            self.title = activityPlan.title
            self.subTitle = activityPlan.subTitle
            self.activityDetails = activityPlan.activityDetails
            self.ageLevel = activityPlan.ageLevel
            self.timePeriod = activityPlan.timePeriod
            self.activityDetails = activityPlan.activityDetails
            self.objectiveDetails = activityPlan.objectiveDetails
            isEditMode = false
        }
        
    }
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Activity",
            headerBuilder: {
                HStack {
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
                            save()
                            isShowing = false
                        }
                    )
                    
                    SOLCON(
                        icon: SolIcon.delete,
                        onTap: {
                            // todo: delete
                            isShowing = false
                        }
                    )
                    
                    Spacer()
                    Text(isEditMode ? "Done" : "Edit")
                        .foregroundColor(.blue)
                        .onTapAnimation {
                            isEditMode.toggle()
                        }
                    Text("Back")
                        .foregroundColor(.blue)
                        .onTapAnimation {
                            isShowing = false
                        }
                    
                }
                
            },
            bodyBuilder: {
                Section("Activity Details") {
                    
                    SolTextField("Title", text: $title)
                    PickerTimeDuration(selection: $duration, isEdit: .constant(true))
                    PickerIntensity(selection: $intensity, isEdit: .constant(true))
                    PickerAgeLevel(selection: $ageLevel, isEdit: .constant(true))
                    PickerNumberOfPlayers(selection: $numOfPlayers, isEdit: .constant(true))
                    PickerGroupCount(selection: $numOfGroups, isEdit: .constant(true))
                    PickerNumPerGroup(selection: $numPerGroup, isEdit: .constant(true))
                    
                    DStack {
                        InputTextMultiLine("Description", text: $objectiveDetails, color: .black)
                            .frame(minHeight: 125)
                        InputTextMultiLine("Objective", text: $activityDetails, color: .black)
                            .frame(minHeight: 125)
                    }.padding(.bottom)
                    
                }
                
            },
            footerBuilder: {
                EmptyView()
            }).onAppear() {
                fetch()
            }
        
    }
}

#Preview {
    TeamDetailsView(teamId: "new")
}
