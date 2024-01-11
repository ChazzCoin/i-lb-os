//
//  FireCore.swift
//
//  Created by Charles Romeo on 11/13/23.
//  Copyright © 2023 Ludi Software. All rights reserved.
//

import Foundation
import RealmSwift


enum DatabasePaths: String {
    case sports = "sports"
    case users = "users"
    case admin = "admin"
    case coaches = "coaches"
    case parents = "parents"
    case players = "players"
    case reviews = "reviews"
    case services = "services"
    case organizations = "organizations"
    case teams = "teams"
    case notes = "notes"
    case chat = "chat"
    case evaluations = "evaluations"
    case rosters = "rosters"
    case tryouts = "tryouts"
    case reviewTemplates = "review_templates"
    case redzones = "redzones"
    case events = "events"
    case sessionPlan = "sessionPlan"
    case activityPlan = "activityPlan"
    case boardSession = "boardSession"
    case managedViews = "managedViews"
    case stopWatch = "stopWatch"
    case timer = "timer"
    case userToSession = "userToSession"
    case userToActivity = "userToActivity"
    case connections = "connections"
    case rooms = "rooms"
    
    // Function to map object type to DatabasePaths
    static func path(forObjectType objectType: Object.Type) -> DatabasePaths? {
        switch objectType {
            case is SessionPlan.Type:
                return .sessionPlan
            case is ActivityPlan.Type:
                return .activityPlan
            case is ManagedView.Type:
                return .managedViews
            case is UserToSession.Type:
                return .userToSession
            case is Chat.Type:
                return .chat
            case is UserToSession.Type:
                return .userToSession
            case is SolUser.Type:
                return .users
            case is Connection.Type:
                return .connections
            case is Room.Type:
                return .rooms
            default:
                return nil
        }
    }
    
}

//func coreFirebaseUser() -> FirebaseAuth.User? {
//    return Auth.auth().currentUser
//}
//
//func coreFirebaseUserUid() -> String? {
//    return Auth.auth().currentUser?.uid
//}
//
//func coreFireLogoutAsync(context: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
//    let authUI = FUIAuth.defaultAuthUI()
//    try? authUI?.signOut()
//}

/** Firebase Database */

