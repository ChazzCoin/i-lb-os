//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift

public enum DatabasePaths: String {
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
    case userInRoom = "userInRoom"
//    case rooms = "rooms"
//    case rooms = "rooms"
//    case rooms = "rooms"
    
    // Function to map object type to DatabasePaths
    public static func path(forObjectType objectType: Object.Type) -> DatabasePaths? {
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
            case is CoreUser.Type:
                return .users
            case is UserToSession.Type:
                return .userToSession
            case is Room.Type:
                return .rooms
            case is UserInRoom.Type:
                return .rooms
            default:
                return nil
        }
    }
    
    public static func objectType(path: String) -> Object.Type? {
        switch path {
            case DatabasePaths.sessionPlan.rawValue:
                    return SessionPlan.self
            case DatabasePaths.activityPlan.rawValue:
                return ActivityPlan.self
            case DatabasePaths.managedViews.rawValue:
                return ManagedView.self
            case DatabasePaths.userToSession.rawValue:
                return UserToSession.self
            case DatabasePaths.rooms.rawValue:
                return Room.self
            case DatabasePaths.userInRoom.rawValue:
                return UserInRoom.self
            case DatabasePaths.users.rawValue:
                return CoreUser.self
            case DatabasePaths.organizations.rawValue:
                return Organization.self
            case DatabasePaths.teams.rawValue:
                return Team.self
            case DatabasePaths.events.rawValue:
                return Event.self
            case DatabasePaths.chat.rawValue:
                return Chat.self
            default:
                return nil
        }
    }
    
    var ref: DatabaseReference {
        return Database.database().reference().child(self.rawValue)
    }
    
    public static func reference(path: String) -> DatabaseReference? {
        return Database.database().reference().child(path)
    }
}
