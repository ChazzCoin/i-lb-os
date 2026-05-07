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


public extension CoreName {
    
    enum FusedPaths: String, CaseIterable {
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
        case friendRequests = "friendRequests"
    }
    
}


public enum DatabasePaths: String, CaseIterable {
    case users = "users"
    case rooms = "rooms"
    case messages = "messages"
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
    case friendRequests = "friendRequests"
    case participants = "participants"
    case managed_stream = "managed_stream"
    
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
            case is ChatMessage.Type:
                return .chat
            case is ChatMessage.Type:
                return .messages
            case is CoreUser.Type:
                return .users
            case is Room.Type:
                return .rooms
            case is Presence.Type:
                return .userInRoom
            case is Organization.Type:
                return .organizations
            case is Team.Type:
                return .teams
            case is CoreEvent.Type:
                return .events
            case is UserToActivity.Type:
                return .userToActivity
            case is FriendRequest.Type:
                return .friendRequests
            case is InteractionParticipant.Type:
                return .participants
            case is ManagedStream.Type:
                return .managed_stream
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
                return Presence.self
            case DatabasePaths.users.rawValue:
                return CoreUser.self
            case DatabasePaths.organizations.rawValue:
                return Organization.self
            case DatabasePaths.teams.rawValue:
                return Team.self
            case DatabasePaths.events.rawValue:
                return CoreEvent.self
            case DatabasePaths.chat.rawValue:
                return ChatMessage.self
            case DatabasePaths.userToActivity.rawValue:
                return UserToActivity.self
            case DatabasePaths.players.rawValue:
                return PlayerRef.self
            case DatabasePaths.friendRequests.rawValue:
                return FriendRequest.self
            case DatabasePaths.participants.rawValue:
                return InteractionParticipant.self
            case DatabasePaths.managed_stream.rawValue:
                return ManagedStream.self
            default:
                return nil
        }
    }

    

}
