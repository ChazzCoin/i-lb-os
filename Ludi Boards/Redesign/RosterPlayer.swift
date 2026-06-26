//
//  RosterPlayer.swift
//  Ludi Boards — tactical board redesign (RD-5 / TASK-011)
//
//  The deferred roster model: a squad of players per board/team. Placing a
//  player on the board creates a soccer-jersey `ManagedView` that denormalises
//  the player's number/team onto the tool (so the disc renders without a
//  cross-module lookup) and keeps `playerId` for the Properties linked-player.
//

import Foundation
import RealmSwift

public class RosterPlayer: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var boardId: String = ""
    @Persisted public var teamSide: String = "home"   // "home" / "away"
    @Persisted public var number: Int = 0
    @Persisted public var name: String = ""
    @Persisted public var position: String = ""
    @Persisted public var orderIndex: Int = 0
}
