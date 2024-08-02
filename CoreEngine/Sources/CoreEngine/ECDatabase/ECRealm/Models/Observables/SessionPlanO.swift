//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/1/24.
//

import Foundation
import SwiftUI
import RealmSwift


// ViewModel for SessionPlan
class SessionPlanObject: ObservableObject {
    // Observable properties for each attribute
    @Published var id: String
    @Published var dateCreated: String
    @Published var dateUpdated: String
    @Published var dateOf: String
    
    @Published var title: String
    @Published var subTitle: String
    @Published var objectiveDetails: String
    @Published var sessionDetails: String
    @Published var timePeriod: String
    @Published var duration: String
    @Published var ageLevel: String
    @Published var intensity: String
    @Published var keyQualities: String
    @Published var numOfPlayers: Int
    @Published var principles: String
    @Published var goal: String
    @Published var stages: String
    @Published var category: String
    @Published var tags: [String]
    
    @Published var ownerId: String
    @Published var orgId: String
    @Published var teamId: String
    @Published var createdBy: String
    
    @Published var isHost: Bool
    @Published var isOpen: Bool
    @Published var isLive: Bool
    @Published var isDeleted: Bool

    // Realm instance
    private var realm: Realm

    // Default initializer for creating a new SessionPlan
    init() {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.dateCreated = getTimeStamp()
        self.dateUpdated = getTimeStamp()
        self.dateOf = getTimeStamp()
        
        self.title = "Session: \(TimeProvider.getMonthDayYearTime())"
        self.subTitle = ""
        self.objectiveDetails = ""
        self.sessionDetails = ""
        self.timePeriod = ""
        self.duration = ""
        self.ageLevel = ""
        self.intensity = ""
        self.keyQualities = ""
        self.numOfPlayers = 0
        self.principles = ""
        self.goal = ""
        self.stages = ""
        self.category = ""
        self.tags = []
        
        self.ownerId = ""
        self.orgId = ""
        self.teamId = ""
        self.createdBy = ""
        
        self.isHost = false
        self.isOpen = false
        self.isLive = false
        self.isDeleted = false
    }

    // Function to load an existing SessionPlan by ID
    func loadSessionPlan(byId sessionId: String) {
        if let sessionPlan = realm.object(ofType: SessionPlan.self, forPrimaryKey: sessionId) {
            // Update properties with the values from Realm
            self.id = sessionPlan.id
            self.dateCreated = sessionPlan.dateCreated
            self.dateUpdated = sessionPlan.dateUpdated
            self.dateOf = sessionPlan.dateOf
            self.title = sessionPlan.title
            self.subTitle = sessionPlan.subTitle
            self.objectiveDetails = sessionPlan.objectiveDetails
            self.sessionDetails = sessionPlan.sessionDetails
            self.timePeriod = sessionPlan.timePeriod
            self.duration = sessionPlan.duration
            self.ageLevel = sessionPlan.ageLevel
            self.intensity = sessionPlan.intensity
            self.keyQualities = sessionPlan.keyQualities
            self.numOfPlayers = sessionPlan.numOfPlayers
            self.principles = sessionPlan.principles
            self.goal = sessionPlan.goal
            self.stages = sessionPlan.stages
            self.category = sessionPlan.category
            self.tags = Array(sessionPlan.tags)
            self.ownerId = sessionPlan.ownerId
            self.orgId = sessionPlan.orgId
            self.teamId = sessionPlan.teamId
            self.createdBy = sessionPlan.createdBy
            self.isHost = sessionPlan.isHost
            self.isOpen = sessionPlan.isOpen
            self.isLive = sessionPlan.isLive
            self.isDeleted = sessionPlan.isDeleted
        } else {
            print("SessionPlan with ID \(sessionId) not found.")
        }
    }

    // Function to save changes back to Realm
    func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingSessionPlan = realm.object(ofType: SessionPlan.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingSessionPlan.dateUpdated = getTimeStamp()
                    existingSessionPlan.title = self.title
                    existingSessionPlan.subTitle = self.subTitle
                    existingSessionPlan.objectiveDetails = self.objectiveDetails
                    existingSessionPlan.sessionDetails = self.sessionDetails
                    existingSessionPlan.timePeriod = self.timePeriod
                    existingSessionPlan.duration = self.duration
                    existingSessionPlan.ageLevel = self.ageLevel
                    existingSessionPlan.intensity = self.intensity
                    existingSessionPlan.keyQualities = self.keyQualities
                    existingSessionPlan.numOfPlayers = self.numOfPlayers
                    existingSessionPlan.principles = self.principles
                    existingSessionPlan.goal = self.goal
                    existingSessionPlan.stages = self.stages
                    existingSessionPlan.category = self.category
                    existingSessionPlan.tags.removeAll()
                    existingSessionPlan.tags.append(objectsIn: self.tags)
                    existingSessionPlan.ownerId = self.ownerId
                    existingSessionPlan.orgId = self.orgId
                    existingSessionPlan.teamId = self.teamId
                    existingSessionPlan.createdBy = self.createdBy
                    existingSessionPlan.isHost = self.isHost
                    existingSessionPlan.isOpen = self.isOpen
                    existingSessionPlan.isLive = self.isLive
                    existingSessionPlan.isDeleted = self.isDeleted
                } else {
                    // Create a new object if not found
                    let newSessionPlan = SessionPlan()
                    newSessionPlan.id = self.id
                    newSessionPlan.dateCreated = self.dateCreated
                    newSessionPlan.dateUpdated = getTimeStamp()
                    newSessionPlan.dateOf = self.dateOf
                    newSessionPlan.title = self.title
                    newSessionPlan.subTitle = self.subTitle
                    newSessionPlan.objectiveDetails = self.objectiveDetails
                    newSessionPlan.sessionDetails = self.sessionDetails
                    newSessionPlan.timePeriod = self.timePeriod
                    newSessionPlan.duration = self.duration
                    newSessionPlan.ageLevel = self.ageLevel
                    newSessionPlan.intensity = self.intensity
                    newSessionPlan.keyQualities = self.keyQualities
                    newSessionPlan.numOfPlayers = self.numOfPlayers
                    newSessionPlan.principles = self.principles
                    newSessionPlan.goal = self.goal
                    newSessionPlan.stages = self.stages
                    newSessionPlan.category = self.category
                    newSessionPlan.tags.append(objectsIn: self.tags)
                    newSessionPlan.ownerId = self.ownerId
                    newSessionPlan.orgId = self.orgId
                    newSessionPlan.teamId = self.teamId
                    newSessionPlan.createdBy = self.createdBy
                    newSessionPlan.isHost = self.isHost
                    newSessionPlan.isOpen = self.isOpen
                    newSessionPlan.isLive = self.isLive
                    newSessionPlan.isDeleted = self.isDeleted

                    realm.add(newSessionPlan)
                }
            }
        } catch let error {
            print("Failed to save SessionPlan: \(error.localizedDescription)")
        }
    }
}
