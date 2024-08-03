//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/2/24.
//

import Foundation
import SwiftUI
import RealmSwift

// For Tools connecting to PlayerRefs
public class ManagedPlayerRefManager {
    public var realm: Realm = newRealm()

    public init() {}

    // 1. Attach/Save a new tool/player connection
    public func attachToolToPlayer(toolId: String, playerRefId: String) {
        realm.safeWrite { r in
            let connection = ManagedPlayerRef()
            connection.toolId = toolId
            connection.playerRefId = playerRefId
            r.create(ManagedPlayerRef.self, value: connection, update: .all)
        }
        print("Successfully attached tool \(toolId) to player \(playerRefId).")
    }

    // 2. Delete/Detach a tool/player connection
    public func detachToolFromPlayer(toolId: String, playerRefId: String) {
        if let connection = realm.objects(ManagedPlayerRef.self).filter("toolId == %@ AND playerRefId == %@", toolId, playerRefId).first {
            realm.safeWrite { r in
                r.delete(connection)
            }
            print("Successfully detached tool \(toolId) from player \(playerRefId).")
        } else {
            print("Connection not found for tool \(toolId) and player \(playerRefId).")
        }
    }

    // 3. Find/Get a connection based on player id
    public func findConnectionsByPlayerId(playerRefId: String) -> Results<ManagedPlayerRef> {
        return realm.objects(ManagedPlayerRef.self).filter("playerRefId == %@", playerRefId)
    }

    // 4. Find/Get a connection based on tool id
    public func findConnectionsByToolId(toolId: String) -> Results<ManagedPlayerRef> {
        return realm.objects(ManagedPlayerRef.self).filter("toolId == %@", toolId)
    }
}
