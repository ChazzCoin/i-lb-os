//
//  RealmSOL.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/29/24.
//

import Foundation
import RealmSwift


enum SolFilter {
    case ID_EQUALS
    case ORG_ID_EQUALS
    case TEAM_ID_EQUALS
    case SESSION_ID_EQUALS
    case ACTIVITY_ID_EQUALS
    case USER_ID_EQUALS
    
    var query: String {
        switch self {
            case .ID_EQUALS: return "id == %@"
            case .ORG_ID_EQUALS: return "orgId == %@"
            case .TEAM_ID_EQUALS: return "teamId == %@"
            default: return ""
        }
    }
}


