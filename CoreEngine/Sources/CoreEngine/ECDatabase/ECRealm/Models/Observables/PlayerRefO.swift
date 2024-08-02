//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/1/24.
//

import Foundation
import SwiftUI
import RealmSwift

// ViewModel for PlayerRef
public class PlayerRefObject: ObservableObject {
    // Observable properties for each attribute
    @Published public var id: String
    @Published public var ownerId: String
    @Published public var orgId: String
    @Published public var teamId: String
    @Published public var userId: String
    @Published public var sessionId: String
    @Published public var activityId: String
    @Published public var toolId: String
    @Published public var name: String
    @Published public var position: String
    @Published public var number: Int
    @Published public var tag: Int
    @Published public var foot: String
    @Published public var hand: String
    @Published public var age: String
    @Published public var year: String
    @Published public var gender: String
    @Published public var imgUrl: String
    @Published public var height: String
    @Published public var weight: String
    @Published public var isDeleted: Bool

    // Realm instance
    public var realm: Realm

    // Default initializer for creating a new PlayerRef
    public init() {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.ownerId = ""
        self.orgId = ""
        self.teamId = ""
        self.userId = ""
        self.sessionId = ""
        self.activityId = ""
        self.toolId = ""
        self.name = ""
        self.position = ""
        self.number = 0
        self.tag = 0
        self.foot = ""
        self.hand = ""
        self.age = ""
        self.year = ""
        self.gender = ""
        self.imgUrl = ""
        self.height = ""
        self.weight = ""
        self.isDeleted = false
    }

    // Function to load an existing PlayerRef by ID
    public func loadPlayerRef(byId playerId: String) {
        if let playerRef = realm.object(ofType: PlayerRef.self, forPrimaryKey: playerId) {
            // Update properties with the values from Realm
            self.id = playerRef.id
            self.ownerId = playerRef.ownerId
            self.orgId = playerRef.orgId
            self.teamId = playerRef.teamId
            self.userId = playerRef.userId
            self.sessionId = playerRef.sessionId
            self.activityId = playerRef.activityId
            self.toolId = playerRef.toolId
            self.name = playerRef.name
            self.position = playerRef.position
            self.number = playerRef.number
            self.tag = playerRef.tag
            self.foot = playerRef.foot
            self.hand = playerRef.hand
            self.age = playerRef.age
            self.year = playerRef.year
            self.gender = playerRef.gender
            self.imgUrl = playerRef.imgUrl
            self.height = playerRef.height
            self.weight = playerRef.weight
            self.isDeleted = playerRef.isDeleted
        } else {
            print("PlayerRef with ID \(playerId) not found.")
        }
    }

    // Function to save changes back to Realm
    public func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingPlayerRef = realm.object(ofType: PlayerRef.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingPlayerRef.ownerId = self.ownerId
                    existingPlayerRef.orgId = self.orgId
                    existingPlayerRef.teamId = self.teamId
                    existingPlayerRef.userId = self.userId
                    existingPlayerRef.sessionId = self.sessionId
                    existingPlayerRef.activityId = self.activityId
                    existingPlayerRef.toolId = self.toolId
                    existingPlayerRef.name = self.name
                    existingPlayerRef.position = self.position
                    existingPlayerRef.number = self.number
                    existingPlayerRef.tag = self.tag
                    existingPlayerRef.foot = self.foot
                    existingPlayerRef.hand = self.hand
                    existingPlayerRef.age = self.age
                    existingPlayerRef.year = self.year
                    existingPlayerRef.gender = self.gender
                    existingPlayerRef.imgUrl = self.imgUrl
                    existingPlayerRef.height = self.height
                    existingPlayerRef.weight = self.weight
                    existingPlayerRef.isDeleted = self.isDeleted
                } else {
                    // Create a new object if not found
                    let newPlayerRef = PlayerRef()
                    newPlayerRef.id = self.id
                    newPlayerRef.ownerId = self.ownerId
                    newPlayerRef.orgId = self.orgId
                    newPlayerRef.teamId = self.teamId
                    newPlayerRef.userId = self.userId
                    newPlayerRef.sessionId = self.sessionId
                    newPlayerRef.activityId = self.activityId
                    newPlayerRef.toolId = self.toolId
                    newPlayerRef.name = self.name
                    newPlayerRef.position = self.position
                    newPlayerRef.number = self.number
                    newPlayerRef.tag = self.tag
                    newPlayerRef.foot = self.foot
                    newPlayerRef.hand = self.hand
                    newPlayerRef.age = self.age
                    newPlayerRef.year = self.year
                    newPlayerRef.gender = self.gender
                    newPlayerRef.imgUrl = self.imgUrl
                    newPlayerRef.height = self.height
                    newPlayerRef.weight = self.weight
                    newPlayerRef.isDeleted = self.isDeleted

                    realm.add(newPlayerRef)
                }
            }
        } catch let error {
            print("Failed to save PlayerRef: \(error.localizedDescription)")
        }
    }
}
