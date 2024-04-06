//
//  SessionPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import CoreEngine

struct SessionPlanView: View {
    @State var sessionId: String
    @Binding var isShowing: Bool
    @State var isMasterWindow: Bool
    
    @State var isEditMode: Bool = false
    
    // Session Details
    @State private var sport = "soccer"
    @State private var title = "SOL Session"
    
    @State private var scheduledDate: Date = Date()
    @State private var duration = ""
    
    @State private var sessionCategory = ""
    @State private var ageLevel = ""
    @State private var intensity = ""
    @State private var numOfPlayers = 0
    @State private var principles = ""
    
    @State var coachingPoints = ""
    @State var guidedAnswers = ""
    @State var keyQualities = ""
    
    @State var equipment = ""
    @State var spaceDimensions = ""
    
    @State private var description = ""
    @State private var objective = ""
    @State private var isLive = true
    
    @State private var ages = ["U7", "U8", "U9", "U10"]
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedResults(ActivityPlan.self) var allActivities
    var activities: Results<ActivityPlan> {
        return self.allActivities.filter("sessionId == %@ AND isDeleted != true", self.sessionId)
    }
    
    var isSharable: Bool {
        return self.BEO.isLoggedIn && !self.shareIds.contains(self.sessionId) && sessionId != "SOL-LIVE-DEMO"
    }
    
    @State private var showNewActivity = false
    @State private var showShareSheet = false
    
    @State private var shareIds: [String] = []
    
    @StateObject var sessionRealmObserver = RealmChangeListener()
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    @State private var isLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State var cancellables = Set<AnyCancellable>()
    
    @State var tabItems: [ActivityPlan] = []
    @State var currentTab: ActivityPlan = newActivityPlan()
    
    @State private var sheetTitle = ""
    @State private var sheetMessage = ""
    @State private var sheetIsShowing = false
    
    @State private var isExpanded = false
    
    @State private var reloadList = false
    func doReloadOfList() {
        reloadList = true
        reloadList = false
    }

    func runLoadingProcess() {
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

    var body: some View {
        
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
                        
            Section {
                
                HStack {
                    
                    Spacer()
                    
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
                            print("save button")
                            runLoading()
                            if self.sessionId == "new" {
                                saveNewSessionPlan()
                            } else {
                                updateSessionPlan()
                            }
                            isShowing = false
                        }
                    )
                    SOLCON(
                        icon: SolIcon.load,
                        onTap: {
                            runLoading()
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: ActivityChange(activityId: self.activities.first?.id ?? "nil"))
                            isCurrentPlan = true
                        }
                    ).solEnabled(isEnabled: !self.isCurrentPlan && self.sessionId != "new")
                    SOLCON(
                        icon: SolIcon.delete,
                        onTap: {
                            runLoading()
                            deleteSessionPlan()
                        }
                    ).solEnabled(isEnabled: self.sessionId != "new")
                    
                    Spacer().padding()
                    
                    SOLCON(
                        icon: SolIcon.add,
                        title: "Add Activity",
                        isConfirmEnabled: false,
                        onTap: {
                            showNewActivity = true
                        }
                    ).solEnabled(isEnabled: true)
                    
                    SolIconTextButton(
                        title: "Share Session",
                        systemName: SolIcon.share.icon, onTap: {
                            self.showShareSheet = true
                        }
                    ).solEnabled(isEnabled: self.isSharable && self.isLive)
                }
                
            }.clearSectionBackground()
        
            Section(header: AlignLeft { HeaderText("Details", color: getTextColorOnBackground(colorScheme)) }) {

                SwitchOnOff(title: "Is Edit Mode", status: $isEditMode)
                    .padding()
//                InputText(label: "Title", text: $title, isEdit: $isEditMode)
                    
                PickerDate(selection: $scheduledDate, isEdit: $isEditMode)
                PickerTimeDuration(selection: $duration, isEdit: $isEditMode)
                PickerIntensity(selection: $intensity, isEdit: $isEditMode)
                PickerAgeLevel(selection: $ageLevel, isEdit: $isEditMode)
                PickerNumberOfPlayers(selection: $numOfPlayers, isEdit: $isEditMode)
                PickerSessionCategory(selection: $sessionCategory, isEdit: $isEditMode)
                
                DisclosureGroup("More Attributes and Settings", isExpanded: $isExpanded) {
                    InputTextMultiLine("Coaching Points", text: $coachingPoints, color: .black, isEdit: $isEditMode)
                    InputTextMultiLine("Key Qualities", text: $keyQualities, color: .black, isEdit: $isEditMode)
                    InputTextMultiLine("Principles", text: $coachingPoints, color: .black, isEdit: $isEditMode)
                }
                .font(.system(size: 18, weight: .heavy))
                
                AdaptiveStack {
                    InputTextMultiLine("Description", text: $description, color: .black, isEdit: $isEditMode)
                        .padding()
                    InputTextMultiLine("Objective", text: $objective, color: .black, isEdit: $isEditMode)
                        .padding()
                }
                .frame(minHeight: isEditMode ? 150 : 35)
                .padding(.bottom)
                
            }
            
            Section(header: HeaderText("Activities: \(activities.count)", color: getTextColorOnBackground(colorScheme))) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        if !reloadList {
                            ForEach(activities, id: \.id) { item in
                                ExpandableFormView(incomingAP: .constant(item))
                            }
                        }
                    }
                }
            }
            
        }.clearSectionBackground()
        .onChange(of: self.BEO.currentSessionId) { _ in
            fetchSessionPlan()
        }
        .onChange(of: self.NavStack.isHidden) { _ in
            if !self.NavStack.isHidden {
                if self.NavStack.navStackCount >= 2 {
                    fetchSessionPlan()
                }
            }
        }
        .onAppear {
            self.NavStack.addToStack()
            if self.sessionId != "new" {
                fetchSessionPlan()
            }
            loadActivities()
            getShareIds()
        }
        .onDisappear() {
            self.NavStack.removeFromStack()
            self.sessionRealmObserver.stop()
            self.sessionNotificationToken = nil
        }
        .navigationBarTitle(isCurrentPlan ? "Current Session" : "Session Plan", displayMode: .inline)
        .navigationBarItems(leading: HStack {
            // Add buttons or icons here for minimize, maximize, close, etc.
            if self.NavStack.navStackCount >= 2 {
                
                Button(action: {
                    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "master", stateAction: "close", viewId: "self"))
                }) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
            }
        }, trailing: HStack {
            // Add buttons or icons here for minimize, maximize, close, etc.
            if self.NavStack.navStackCount >= 2 {
                
                if self.NavStack.keyboardIsShowing {
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
                
            }
            
//            Button(action: {
//                self.NavStack.toggleWindowSize(gps: self.gps)
//            }) {
//                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//            }
        })
        .alert(self.sheetTitle, isPresented: $sheetIsShowing) {
            Button("Cancel", role: .cancel) {
                sheetIsShowing = false
            }
            Button("OK", role: .none) {
                sheetIsShowing = false
            }
        } message: {
            Text(self.sheetMessage)
        }
        .sheet(isPresented: self.$showNewActivity) {
//            ActivityPlanView(boardId: "new", sessionId: sessionId, isShowing: $showNewActivity)
        }
        .sheet(isPresented: self.$showShareSheet) {
            AddBuddyView(isPresented: self.$showShareSheet, sessionId: self.$sessionId)
        }
        .refreshable {
            if self.sessionId != "new" {
                runLoadingProcess()
                fetchSessionPlan()
                loadActivities()
            }
        }
    }
    
    func getShareIds() {
        safeFirebaseUserId() { userId in
            if let umvs = self.allActivities.realm?.objects(UserToSession.self) {
                for i in umvs {
                    self.shareIds.append(i.sessionId)
                }
            }
        }
    }
    
    func deleteSessionPlan() {
        if let sess = self.BEO.realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            self.BEO.realmInstance.safeWrite { r in
                sess.isDeleted = true
            }
            // TODO: FIREBASE ONLY
            deleteSessionPlanFromFirebase(spId: self.sessionId)
        }
    }
    
    func deleteSessionPlanFromFirebase(spId: String) {
        firebaseDatabase { db in
            db.child(DatabasePaths.sessionPlan.rawValue)
                .child(spId)
                .removeValue()
        }
    }
    
    func saveNewSessionPlan() {
        // New Plan
        let newSP = SessionPlan()
        // TODO: FIX THIS!!!
        newSP.id = UUID().uuidString
        newSP.title = title
        newSP.sessionDetails = description
        newSP.objectiveDetails = objective
        newSP.isOpen = isLive
        newSP.ownerId = getFirebaseUserIdOrCurrentLocalId()
        // New Activity
        let newAP = ActivityPlan()
        newAP.sessionId = newSP.id
        newAP.ownerId = getFirebaseUserIdOrCurrentLocalId()
        newAP.title = "\(title) Activity"
        newAP.orderIndex = 0
        newAP.isLocal = isLive
        
        self.BEO.realmInstance.safeWrite { r in
            r.create(SessionPlan.self, value: newSP, update: .all)
            r.create(ActivityPlan.self, value: newAP, update: .all)
        }
        
        // TODO: Firebase
        newSP.fireSave(id: newSP.id)
        newAP.fireSave(id: newAP.id)
    }
    
    func updateSessionPlan() {
        if let sp = self.BEO.realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            self.BEO.realmInstance.safeWrite { r in
                // TODO: FIX THIS
                sp.ownerId = getFirebaseUserIdOrCurrentLocalId()
                sp.title = title
                sp.sessionDetails = description
                sp.objectiveDetails = objective
                sp.isLive = isLive
                sp.fireSave(id: sp.id)
            }
        }
    }
    
    func loadActivities() {
        var temp = false
        tabItems.removeAll()
        if self.sessionId == "new" { return }
        for act in allActivities {
            if act.sessionId != self.sessionId { continue }
            if !temp {
                self.currentTab = act
                temp = true
            }
            tabItems.append(act)
        }
    }
    
    func fetchSessionPlan() {
        print("BEO SessionId: \(self.BEO.currentSessionId)")
        if self.isMasterWindow {
            self.sessionId = self.BEO.currentSessionId
            self.isCurrentPlan = true
        } else if self.BEO.currentSessionId == self.sessionId {
            self.isCurrentPlan = true
        }
        
        fireGetSessionPlanAsync(sessionId: self.sessionId, realm: self.allActivities.realm?.thaw() ?? newRealm())
        fireGetActivitiesBySessionId(sessionId: self.sessionId, realm: self.allActivities.realm?.thaw() ?? newRealm())
        
        if let sp = self.allActivities.realm?.thaw().findByField(SessionPlan.self, value: self.sessionId) {
            self.sessionRealmObserver.observe(object: sp, onChange: { obj in
                title = sp.title
                description = sp.sessionDetails
                objective = sp.objectiveDetails
                isLive = sp.isLive
                if sp.ownerId != self.BEO.userId && sp.ownerId != CURRENT_USER_ID {
                    self.BEO.isShared = true
                }
            })
            
            title = sp.title
            description = sp.sessionDetails
            objective = sp.objectiveDetails
            isLive = sp.isLive
            if sp.ownerId != self.BEO.userId && sp.ownerId != CURRENT_USER_ID {
                self.BEO.isShared = true
            }
        }
        if self.sessionId == "SOL-LIVE-DEMO" {
            self.isLive = true
        }
    }
    
}

struct ClearBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.clear)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func clearSectionBackground() -> some View {
        self.modifier(ClearBackgroundModifier())
    }
}


