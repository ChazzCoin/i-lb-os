//
//  RealmSOL.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/29/24.
//

import Foundation
import RealmSwift
import CoreEngine


extension Realm {
    
    // Get Players/Roster on Team
    func getRosterForTeamId(teamId: String) -> Results<PlayerRef> {
        self.objects(PlayerRef.self).filter("teamId == %@", teamId)
    }
    // Get Teams part of Organization
    func getTeamsForOrgId(orgId: String) -> Results<Team> {
        self.objects(Team.self).filter("orgId == %@", orgId)
    }
    
    // Get Activities part of Organization
    // Get Sessions part of Organization
    // Get Activities part of Team
    // Get Sessions part of Team
    // Get Events part of Organization
    // Get Events part of Team
    // Users part of Organization
    // Users part of Team
    
}

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


