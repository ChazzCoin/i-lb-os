//
//  ActivityPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine

// ActivityPlan View
struct ActivityPlanBindingView: View {

    @Binding var inComingAP: ActivityPlan
    @Binding var sessionId: String
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var isLoading: Bool = false
    @State var realmInstance = realm()
    
    @State var confirmationPopupIsShowing = false
    
    @State var activityId = ""
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
    @State var backgroundView = ""
    
    @State private var refreshView = false
    @State private var showLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    @State private var colorOpacity = 1.0
    @State private var lineOpacity = 1.0
    @State private var lineStroke = 1.0
    @State private var lineColor = Color.clear
    @State private var bgColor = Color.clear
    @State private var fieldName = ""
    @State private var fieldRotation = 0.0
    
    @State var showShareSheet = false
    @State var cancellables = Set<AnyCancellable>()

    func resetView() {
        refreshView = true
        refreshView = false
    }
    
    var body: some View {
        
        VStack {
                     
            HStack {
                
                FieldOverlayView(width: 75, height: 75, background: {
                    Color.gray
                }, overlay: {
                    if let CurrentBoardBackground = self.BEO.boards.getAllMinis()[self.fieldName] {
                        CurrentBoardBackground()
                            .zIndex(2.0)
                            .environmentObject(self.BEO)
                    }
                })
                .frame(width: 50, height: 50)
                
                Spacer().padding()
                
                SOLCON(
                    icon: SolIcon.save,
                    onTap: {
                        addUpdateActivityPlan()
                    }
                )
//                SOLCON(
//                    icon: SolIcon.load,
//                    onTap: {
//                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: self.sessionId, activityId: self.activityId))
//                        self.isCurrentPlan = true
//                    }
//                ).solEnabled(isEnabled: !self.isCurrentPlan)
                SOLCON(
                    icon: SolIcon.delete,
                    onTap: {
                        deleteActivityPlan()
                    }
                )
            }
            
            Form {
                SolTextField("Title", text: $title)
                PickerTimeDuration(selection: $duration, isEdit: .constant(true))
                PickerIntensity(selection: $intensity, isEdit: .constant(true))
                PickerAgeLevel(selection: $ageLevel, isEdit: .constant(true))
                PickerNumberOfPlayers(selection: $numOfPlayers, isEdit: .constant(true))
                
                DStack {
                    PickerGroupCount(selection: $numOfGroups, isEdit: .constant(true))
                    PickerNumPerGroup(selection: $numPerGroup, isEdit: .constant(true))
                }
                
                DStack {
                    SolTextEditor("Description", text: $objectiveDetails, color: .black)
                        .frame(minHeight: 125)
                    SolTextEditor("Objective", text: $activityDetails, color: .black)
                        .frame(minHeight: 125)
                }.padding(.bottom)
            }
            
            
                        
        }
//        .frame(minHeight: 500)
//        .background(getBackgroundColor(colorScheme))
//        .cornerRadius(15)
//        .shadow(color: .gray, radius: 3, x: 0, y: 0)
//        .padding()
        .onChange(of: self.inComingAP) { newPlan in
            DispatchQueue.main.async {
                self.fetchActivityPlan(activityPlan: newPlan)
            }
        }
        .onAppear {
            self.fetchActivityPlan(activityPlan: self.inComingAP)
            self.BEO.windowIsOpen = true
        }

    }
    
    private func fetchActivityPlan(activityPlan: ActivityPlan) {
        
        self.activityId = activityPlan.id
        
        self.title = activityPlan.title
        self.subTitle = activityPlan.subTitle
//        self.date = activityPlan.dateOf
        self.activityDetails = activityPlan.activityDetails
        
        self.ageLevel = activityPlan.ageLevel
        self.timePeriod = activityPlan.timePeriod
        self.activityDetails = activityPlan.activityDetails
        self.objectiveDetails = activityPlan.objectiveDetails
        
        self.lineStroke = activityPlan.backgroundLineStroke
        self.lineOpacity = activityPlan.backgroundLineAlpha
        self.colorOpacity = activityPlan.backgroundAlpha
        self.fieldRotation = activityPlan.backgroundRotation
        self.fieldName = activityPlan.backgroundView
        if self.BEO.currentActivityId == self.activityId {
            self.isCurrentPlan = true
        } else {
            self.isCurrentPlan = false
        }
    }

    func startLoadingProcess() {
        isLoading = true
        // Simulate a network request or some processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCompletion = false
            }
        }
    }
    
    func addUpdateActivityPlan() {
        if self.activityId == "new" {
            saveNewActivityPlan()
        } else {
            updateCurrentActivityPlan()
        }
    }
    
    func updateCurrentActivityPlan() {
        
        if let currentAp = self.realmInstance.findByField(ActivityPlan.self, value: self.activityId) {
            self.realmInstance.safeWrite { _ in
                currentAp.sessionId = self.sessionId
                currentAp.orderIndex = 0
                
                currentAp.ownerId = getFirebaseUserIdOrCurrentLocalId()
                
                currentAp.title = title
                currentAp.subTitle = subTitle
                currentAp.duration = duration
//                currentAp.dateOf = date
                currentAp.ageLevel = ageLevel
                currentAp.timePeriod = timePeriod
                currentAp.activityDetails = activityDetails
                currentAp.objectiveDetails = objectiveDetails
                                
                // TODO: Firebase Users ONLY
                updateInFirebase(newAP: currentAp)
            }
        }
        
        
    }
    
    func saveNewActivityPlan() {
        // New Activity
        let newAP = ActivityPlan()
        
        newAP.sessionId = self.sessionId
        newAP.orderIndex = 0
        
        newAP.ownerId = getFirebaseUserId() ?? "SOL"
        
        newAP.title = title
        newAP.subTitle = subTitle
        newAP.duration = duration
//        newAP.dateOf = date
        newAP.ageLevel = ageLevel
        newAP.timePeriod = timePeriod
        newAP.activityDetails = activityDetails
        newAP.objectiveDetails = objectiveDetails
        
        newAP.backgroundView = fieldName
        newAP.backgroundRotation = fieldRotation
        newAP.backgroundLineStroke = lineStroke
        
        if let c = bgColor.toRGBA() {
            newAP.backgroundRed = c.red
            newAP.backgroundGreen = c.green
            newAP.backgroundBlue = c.blue
            newAP.backgroundAlpha = c.alpha
        }
        
        if let lc = lineColor.toRGBA() {
            newAP.backgroundLineRed = lc.red
            newAP.backgroundLineGreen = lc.green
            newAP.backgroundLineBlue = lc.blue
            newAP.backgroundLineAlpha = lc.alpha
        }
        
        realmInstance.safeWrite { r in
            r.create(ActivityPlan.self, value: newAP, update: .all)
        }
        // TODO: Firebase Users ONLY
        updateInFirebase(newAP: newAP)
        
    }
    
    func updateInFirebase(newAP: ActivityPlan) {
        // TODO: Firebase Users ONLY
        self.realmInstance.safeWrite { _ in
            newAP.ownerId = getFirebaseUserId() ?? "SOL"
        }
        firebaseDatabase { db in
            db.child(DatabasePaths.activityPlan.rawValue)
                .child(newAP.id)
                .setValue(newAP.toDict())
        }
    }
    
    func deleteActivityPlan() {
        
        if let currentAp = self.realmInstance.findByField(ActivityPlan.self, value: self.activityId) {
            realmInstance.safeWrite { r in
                currentAp.isDeleted = true
            }
        }
        
    }
    func deleteActivityPlanFromFirebase(apId: String) {
        firebaseDatabase { db in
            db.child(DatabasePaths.activityPlan.rawValue)
                .child(apId)
                .removeValue()
        }
    }

}

struct ActivityItemView: View {
    @Binding var item: ActivityPlan // Assuming Activity is your model
    @State private var isExpanded: Bool = false
    
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    
    @State private var scheduledDate: Date = Date()
    @State private var duration = ""
    
    var body: some View {
        VStack {
            
            if !isExpanded {
                
                HStack {
                    TextField("Title", text: .constant(item.title))
                    
                    SOLCON(
                        icon: SolIcon.load,
                        onTap: {
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: item.sessionId, activityId: item.id))
//                            self.isCurrentPlan = true
                        }
                    ).solEnabled(isEnabled: true)
                    
                    SwitchShowHide(status: $isExpanded)
                        .onChange(of: isExpanded, perform: { value in
                            withAnimation(.easeInOut) {
                                isExpanded.toggle()
                            }
                        })
                }.padding()
                
            } else {
                
                HStack {
                    TextField("Title", text: .constant(item.title))
                    
                    SOLCON(
                        icon: SolIcon.load,
                        onTap: {
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: item.sessionId, activityId: item.id))
//                            self.isCurrentPlan = true
                        }
                    ).solEnabled(isEnabled: true)
                    
                    SwitchShowHide(status: $isExpanded)
                        .onChange(of: isExpanded, perform: { value in
                            withAnimation(.easeInOut) {
                                isExpanded.toggle()
                            }
                        })
                }.padding()
//                ExpandableFormView()
//                ActivityPlanBindingView(inComingAP: .constant(item), sessionId: .constant(item.sessionId), isShowing: .constant(true))
//                    .environmentObject(self.BEO)
//                    .environmentObject(self.NavStack)
            }
//            Button(action: {
//                withAnimation(.easeInOut) {
//                    isExpanded.toggle()
//                }
//            }) {
//                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .foregroundColor(.blue)
//            }
        }
        .frame(height: isExpanded ? 600 : 100)
        .animation(.easeInOut, value: isExpanded)
    }
}


//                ActivityPlanBindingView(inComingAP: .constant(item), sessionId: .constant(item.sessionId), isShowing: .constant(true))
//                    .environmentObject(self.BEO)
//                    .environmentObject(self.NavStack)


struct ExpandableFormView: View {
    @Binding var incomingAP: ActivityPlan
    @State private var isExpanded = false
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
    @State private var objectiveDetails: String = ""
    @State private var activityDetails: String = ""

    var body: some View {
        Form {
            Section(header: Text(title)) {
                SolTextField("Title", text: $title)
                AdaptiveStack {
                    PickerTimeDuration(selection: $duration, isEdit: .constant(true))
                    PickerIntensity(selection: $intensity, isEdit: .constant(true))
                }
                
                DisclosureGroup("More Attributes and Settings", isExpanded: $isExpanded) {
                    
                    AdaptiveStack {
                        PickerAgeLevel(selection: $ageLevel, isEdit: .constant(true))
                        PickerNumberOfPlayers(selection: $numOfPlayers, isEdit: .constant(true))
                    }
                    
                    AdaptiveStack {
                        PickerGroupCount(selection: $numOfGroups, isEdit: .constant(true))
                        PickerNumPerGroup(selection: $numPerGroup, isEdit: .constant(true))
                    }

                    AdaptiveStack {
                        SolTextEditor("Description", text: $objectiveDetails, color: .black)
                            .frame(minHeight: 125)
                        SolTextEditor("Objective", text: $activityDetails, color: .black)
                            .frame(minHeight: 125)
                    }
                    .padding(.bottom)
                    .frame(minHeight: 150)
                    
                    Section {
                        
                        HStack {
                            Spacer()
                            FieldOverlayView(width: 75, height: 75, background: {
                                Color.gray
                            }, overlay: {
                                if let CurrentBoardBackground = Sports().getAllMinis()["Soccer Field 1"] {
                                    CurrentBoardBackground()
                                        .zIndex(2.0)
                                }
                            })
                            .frame(width: 50, height: 50)
                            Spacer()
                        }.frame(height: 200)
                        
                    }.clearSectionBackground()
                    
                    
                }
                
                HStack {
                    Spacer().padding()
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
//                            addUpdateActivityPlan()
                        }
                    )
                    SOLCON(
                        icon: SolIcon.delete,
                        onTap: {
//                            deleteActivityPlan()
                        }
                    )
                }
                
            }

            
        }
        .frame(minHeight: isExpanded ? 600 : 300)
        .onAppear() {
            fetchActivityPlan(activityPlan: incomingAP)
        }
    }
    
    private func fetchActivityPlan(activityPlan: ActivityPlan) {
        
//        self.activityId = activityPlan.id
        
        self.title = activityPlan.title
        self.subTitle = activityPlan.subTitle
//        self.date = activityPlan.dateOf
        self.activityDetails = activityPlan.activityDetails
        
        self.ageLevel = activityPlan.ageLevel
        self.timePeriod = activityPlan.timePeriod
        self.activityDetails = activityPlan.activityDetails
        self.objectiveDetails = activityPlan.objectiveDetails
        
//        self.lineStroke = activityPlan.backgroundLineStroke
//        self.lineOpacity = activityPlan.backgroundLineAlpha
//        self.colorOpacity = activityPlan.backgroundAlpha
//        self.fieldRotation = activityPlan.backgroundRotation
//        self.fieldName = activityPlan.backgroundView
//        if self.BEO.currentActivityId == self.activityId {
//            self.isCurrentPlan = true
//        } else {
//            self.isCurrentPlan = false
//        }
    }
}
