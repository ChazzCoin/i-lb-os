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

struct SessionPlanView: View {
    @State var sessionId: String
    @Binding var isShowing: Bool
    @State var isMasterWindow: Bool
    @State private var sport = "soccer"
    @State private var title = "SOL Session"
    @State private var description = ""
    @State private var objective = ""
    @State private var isLive = true
    
//    var tabbedActivity: ActivityPlan = ActivityPlan()
    
//    @StateObject var keyboardResponder = KeyboardResponder()
    
    @ObservedResults(ActivityPlan.self) var allActivities
    var activities: Results<ActivityPlan> {
        return self.allActivities.filter("sessionId == %@", self.sessionId)
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
    @State var currentTab: ActivityPlan = ActivityPlan()
    
    @State var actionHasBeenMade = false
    

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
            
            DStack {
                
                solConfirmButton(
                    title: "Save Session",
                    message: "Are you sure you want to save this session?",
                    action: {
                        if self.actionHasBeenMade {return}
                        self.actionHasBeenMade = true
                        print("save button")
                        runLoading()
                        if self.sessionId == "new" {
                            saveNewSessionPlan()
                        } else {
                            updateSessionPlan()
                        }
                        isShowing = false
                    })
                
                if self.sessionId == "new" {
                    
                    solButton(title: "Cancel", action: {
                        if self.actionHasBeenMade {return}
                        self.actionHasBeenMade = true
                        self.isShowing = false
                    }, isEnabled: self.isShowing)
                    
                } else {
                    
                    if !self.shareIds.contains(self.sessionId) && sessionId != "SOL-LIVE-DEMO" && sessionId != "SOL"  {
                        solConfirmButton(
                            title: "Delete Session",
                            message: "Are you sure you want to delete this session?",
                            action: {
                                if self.actionHasBeenMade {return}
                                self.actionHasBeenMade = true
                                runLoading()
                                deleteSessionPlan()
                            }
                        )
                    }
                    
                }
                
                if self.sessionId != "new" {
                    solConfirmButton(
                        title: "Load Session",
                        message: "Would you like to load this plan onto the board?",
                        action: {
                            if self.actionHasBeenMade {return}
                            self.actionHasBeenMade = true
                            runLoading()
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: sessionId, activityId: self.activities.first?.id ?? "nil"))
                            isCurrentPlan = true
                        },
                        isEnabled: !self.isCurrentPlan)
                }
                
            }
            
            Section {
                
                DStack {
                    Toggle("Is Live", isOn: $isLive)
                        .opacity(1.0)
                        .disabled(!self.isSharable)
                        .onChange(of: isLive) { newValue in
                            if let s = self.BEO.realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
                                self.BEO.realmInstance.safeWrite { r in
                                    s.isLive = self.isLive
                                    s.fireSave(id: s.id)
                                }
                            }
                        }
                    
                    solButton(title: "Share Session", action: {
                        self.showShareSheet = true
                    }, isEnabled: self.isSharable && self.isLive)
                    
                }
                
                
            }
            
            
            Section(header: Text("Details")) {
                SolTextField("Title", text: $title)
                
                DStack {
                    SolTextEditor("Description", text: $description)
                        .frame(minHeight: 100)
                    
                    SolTextEditor("Objective", text: $objective)
                        .frame(minHeight: 100)
                }
                
            }.clearSectionBackground()

            Section(header: Text("Activities")) {    
                
                if self.sessionId != "new" {
                    solButton(title: "New Activity", action: {
                        print("New Activity Button")
                        showNewActivity = true
                    })
                }
                
                HStack {
                    ForEach(tabItems, id: \.id) { item in
                        Text("Title: \(item.id)")
                            .padding()
                            .background(self.currentTab.id == item.id ? Color.primaryBackground : Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .animation(.easeInOut, value: self.currentTab)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.currentTab = item
                                }
                            }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
                .shadow(color: .gray, radius: 10, x: 0, y: 0)

                VStack {
                    ActivityPlanView(activityPlan: self.$currentTab, isShowing: .constant(true))
                        .environmentObject(self.BEO)
                        .environmentObject(self.NavStack)
                }
                .frame(minHeight: 500)
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(15)
                .shadow(color: .gray, radius: 10, x: 0, y: 0)
                
                
            }.clearSectionBackground()
            
            
        }
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
        .onChange(of: self.actionHasBeenMade) { _ in
            if !self.actionHasBeenMade { return }
            DispatchQueue.executeAfter(seconds: 3, action: {
                self.actionHasBeenMade = false
            })
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
        .navigationBarItems(trailing: HStack {
            // Add buttons or icons here for minimize, maximize, close, etc.
            if self.NavStack.navStackCount >= 2 {
                
                Button(action: {
                    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "master", stateAction: "close", viewId: "self"))
                }) {
                    Image(systemName: "arrow.down.to.line.alt")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
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
        })
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
            }
        }
    }
    
    func getShareIds() {
        safeFirebaseUserId() { userId in
            if let umvs = self.allActivities.realm?.objects(UserToSession.self).filter("guestId == %@", userId) {
                for i in umvs {
                    self.shareIds.append(i.sessionId)
                }
            }
        }
    }
    
    func deleteSessionPlan() {
        if let sess = self.allActivities.realm?.findByField(SessionPlan.self, value: self.sessionId) {
            self.allActivities.realm?.safeWrite { r in
                r.delete(sess)
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
        newSP.id = UUID().uuidString
        newSP.title = title
        newSP.sessionDetails = description
        newSP.objectiveDetails = objective
        newSP.isOpen = isLive
        newSP.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
        // New Activity
        let newAP = ActivityPlan()
        newAP.sessionId = newSP.id
        newAP.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
        newAP.title = "\(title) Activity"
        newAP.orderIndex = 0
        newAP.isLocal = isLive
        
        self.allActivities.realm?.safeWrite { r in
            r.create(SessionPlan.self, value: newSP, update: .all)
            r.create(ActivityPlan.self, value: newAP, update: .all)
        }
        
        // TODO: Firebase
        newSP.fireSave(id: newSP.id)
        newAP.fireSave(id: newAP.id)
    }
    
    func updateSessionPlan() {
        if let sp = self.allActivities.realm?.thaw().findByField(SessionPlan.self, value: self.sessionId) {
            self.allActivities.realm?.thaw().safeWrite { r in
                sp.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
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
        
        fireGetSessionPlanAsync(sessionId: self.sessionId, realm: self.allActivities.realm?.thaw())
        fireGetActivitiesBySessionId(sessionId: self.sessionId, realm: self.allActivities.realm?.thaw())
        
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


struct InputFieldA: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField("", text: $value, onEditingChanged: { _ in onValueChange(value) })
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct InputTextEditorA: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextEditor(text: $value)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onAppear {
                    onValueChange(value)
                }
        }
    }
}




//struct BoardSessionDetailsForm_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true)
//    }
//}

