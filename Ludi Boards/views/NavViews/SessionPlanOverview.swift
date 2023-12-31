//
//  SessionPlanOverview.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct SessionPlanOverview: View {
    @State var userId: String = "temp"
    @LiveSessionPlans(shared: false) var sessionPlans
    @LiveSessionPlans(shared: true) var sessionPlansShared
    @State var shares: [UserToSession] = []
    @State var sharedIds: [String] = []
    
    @State var sharedPrefs = SharedPrefs.shared
    let realmInstance = realm()
    
    @State private var liveDemoNotificationToken: NotificationToken? = nil
    
    @State private var isLoading: Bool = false
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var sessionSharesNotificationToken: NotificationToken? = nil
    @State private var sharesNotificationToken: NotificationToken? = nil
    @State private var showNewPlanSheet = false
    
    @State private var isLoggedIn = false

    var body: some View {
        Form {
            Section(header: Text("Manage")) {
                solButton(title: "New Session", action: {
                    print("New Session Button")
                    showNewPlanSheet = true
                })
            }.clearSectionBackground()
            Section(header: Text("Sessions")) {
                List($sessionPlans, id: \.self) { $sessionPlan in
                    NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)) {
                        SessionPlanThumbView(sessionPlan: sessionPlan)
                    }
                }
            }.clearSectionBackground()
            
//            Section(header: Text("Pending Shares")) {
//                List(shares) { share in
//                    ShareThumbnailView(share: share)
//                }
//            }.clearSectionBackground()
            if self.isLoggedIn {
                Section(header: Text("Shared Sessions")) {
                    List($sessionPlansShared, id: \.self) { $sessionPlan in
                        
                        NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)) {
                            SessionPlanThumbView(sessionPlan: sessionPlan)
                        }
    //                    Spacer()
    //                    AcceptRejectButtons(session: sessionPlan)
                    }
                }.clearSectionBackground()
            }
            

        }
        .onAppear() {
            _sessionPlans.start()
            if isLoggedIntoFirebase() {
                self.isLoggedIn = true
                _sessionPlansShared.start()
                getShareIds()
                return
            }
            
        }
        .loading(isShowing: $isLoading)
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
        }
        .refreshable {
            _sessionPlans.start()
            if isLoggedIntoFirebase() {
                self.isLoggedIn = true
                _sessionPlansShared.start()
                getShareIds()
                return
            }
        }
    }

    
    func getShareIds() {
        safeFirebaseUserId() { userId in
            let umvs = realmInstance.objects(UserToSession.self).filter("guestId == %@", userId)
            for i in umvs {
                sharedIds.append(i.sessionId)
            }
        }
    }
    
//    func observeSessions() {
//        fireGetLiveDemoAsync(realm: self.realmInstance)
//        let umvs = realmInstance.objects(SessionPlan.self)
//        sessionNotificationToken = umvs.observe { (changes: RealmCollectionChange) in
//            sessionPlansShared.removeAll()
//            switch changes {
//                case .initial(let results):
//                    print("Realm Listener: initial")
//                    for i in results {
//                        if i.ownerId == "SOL" {
//                            sessionPlansShared.safeAdd(i)
//                            continue
//                        }
//                        sessionPlans.safeAdd(i)
//                    }
//                    isLoading = false
//                case .update(let results, let de, _, _):
//                    print("Realm Listener: update")
//                    for i in results {
//                        if i.ownerId == "SOL" {
//                            sessionPlansShared.safeAdd(i)
//                            continue
//                        }
//                        sessionPlans.safeAdd(i)
//                    }
//                    for d in de {
//                        sessionPlans.remove(at: d)
//                    }
//                    isLoading = false
//                case .error(let error):
//                    print("Realm Listener: error")
//                    isLoading = false
//                    fatalError("\(error)")  // Handle errors appropriately in production code
//            }
//        }
//    }
//    
//    func observeSharedSessions() {
//        if let umvs = realmInstance.findAllNotByField(SessionPlan.self, field: "ownerId", value: self.userId) {
//            sessionSharesNotificationToken = umvs.observe { (changes: RealmCollectionChange) in
//                switch changes {
//                    case .initial(let results):
//                        for i in results {
//                            if i.ownerId == self.userId {
//                                continue
//                            }
//                            sessionPlansShared.safeAdd(i)
//                        }
//                    case .update(let results, let de, _, _):
//                        for i in results {
//                            if i.ownerId == self.userId {
//                                continue
//                            }
//                            sessionPlansShared.safeAdd(i)
//                        }
//                        for d in de {
//                            sessionPlansShared.remove(at: d)
//                        }
//                    case .error(let error):
//                        print("\(error)")  // Handle errors appropriately in production code
//                }
//            }
//        }
//        
//    }
    
}
