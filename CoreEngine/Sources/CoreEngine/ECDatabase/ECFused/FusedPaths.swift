//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import Realm


public enum DatabasePaths: String, CaseIterable {
    case users = "users"
    case rooms = "rooms"
    case managedViews = "managedViews"
    case chat = "chat"
    case organizations = "organizations"
    case teams = "teams"
    case players = "players"
    case notes = "notes"
    case events = "events"
    case sessionPlan = "sessionPlan"
    case activityPlan = "activityPlan"
    case userToSession = "userToSession"
    case userToActivity = "userToActivity"
    case userInRoom = "userInRoom"
    
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
            case is Room.Type:
                return .rooms
            case is UserInRoom.Type:
                return .userInRoom
            case is Organization.Type:
                return .organizations
            case is Team.Type:
                return .teams
            case is CoreEvent.Type:
                return .events
            case is UserToActivity.Type:
                return .userToActivity
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
                return CoreEvent.self
            case DatabasePaths.chat.rawValue:
                return Chat.self
            case DatabasePaths.userToActivity.rawValue:
                return UserToActivity.self
            case DatabasePaths.players.rawValue:
                return PlayerRef.self
            default:
                return nil
        }
    }

    

}
