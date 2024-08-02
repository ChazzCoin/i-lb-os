//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/1/24.
//

import Foundation
import SwiftUI
import RealmSwift

// ViewModel for CoreEvent
class CoreEventObject: ObservableObject {
    // Observable properties for each attribute
    @Published var id: String
    @Published var orgId: String
    @Published var teamId: String
    @Published var sessionId: String
    @Published var createdBy: String
    @Published var name: String
    @Published var eventType: EventType
    @Published var opponent: String
    @Published var location: String
    @Published var startTime: String
    @Published var endTime: String
    @Published var startDate: String
    @Published var endDate: String
    @Published var descriptionText: String
    @Published var isReoccurring: Bool
    @Published var isDeleted: Bool

    // Realm instance
    private var realm: Realm

    // Default initializer for creating a new CoreEvent
    init() {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.orgId = ""
        self.teamId = ""
        self.sessionId = ""
        self.createdBy = ""
        self.name = ""
        self.eventType = .practice
        self.opponent = ""
        self.location = ""
        self.startTime = ""
        self.endTime = ""
        self.startDate = ""
        self.endDate = ""
        self.descriptionText = ""
        self.isReoccurring = false
        self.isDeleted = false
    }

    // Function to load an existing CoreEvent by ID
    func loadCoreEvent(byId eventId: String) {
        if let coreEvent = realm.object(ofType: CoreEvent.self, forPrimaryKey: eventId) {
            // Update properties with the values from Realm
            self.id = coreEvent.id
            self.orgId = coreEvent.orgId
            self.teamId = coreEvent.teamId
            self.sessionId = coreEvent.sessionId
            self.createdBy = coreEvent.createdBy
            self.name = coreEvent.name
            self.eventType = EventType(rawValue: coreEvent.eventType) ?? .practice
            self.opponent = coreEvent.opponent
            self.location = coreEvent.location
            self.startTime = coreEvent.startTime
            self.endTime = coreEvent.endTime
            self.startDate = coreEvent.startDate
            self.endDate = coreEvent.endDate
            self.descriptionText = coreEvent.descriptionText
            self.isReoccurring = coreEvent.isReoccurring
            self.isDeleted = coreEvent.isDeleted
        } else {
            print("CoreEvent with ID \(eventId) not found.")
        }
    }

    // Function to save changes back to Realm
    func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingCoreEvent = realm.object(ofType: CoreEvent.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingCoreEvent.orgId = self.orgId
                    existingCoreEvent.teamId = self.teamId
                    existingCoreEvent.sessionId = self.sessionId
                    existingCoreEvent.createdBy = self.createdBy
                    existingCoreEvent.name = self.name
                    existingCoreEvent.eventType = self.eventType.rawValue
                    existingCoreEvent.opponent = self.opponent
                    existingCoreEvent.location = self.location
                    existingCoreEvent.startTime = self.startTime
                    existingCoreEvent.endTime = self.endTime
                    existingCoreEvent.startDate = self.startDate
                    existingCoreEvent.endDate = self.endDate
                    existingCoreEvent.descriptionText = self.descriptionText
                    existingCoreEvent.isReoccurring = self.isReoccurring
                    existingCoreEvent.isDeleted = self.isDeleted
                } else {
                    // Create a new object if not found
                    let newCoreEvent = CoreEvent()
                    newCoreEvent.id = self.id
                    newCoreEvent.orgId = self.orgId
                    newCoreEvent.teamId = self.teamId
                    newCoreEvent.sessionId = self.sessionId
                    newCoreEvent.createdBy = self.createdBy
                    newCoreEvent.name = self.name
                    newCoreEvent.eventType = self.eventType.rawValue
                    newCoreEvent.opponent = self.opponent
                    newCoreEvent.location = self.location
                    newCoreEvent.startTime = self.startTime
                    newCoreEvent.endTime = self.endTime
                    newCoreEvent.startDate = self.startDate
                    newCoreEvent.endDate = self.endDate
                    newCoreEvent.descriptionText = self.descriptionText
                    newCoreEvent.isReoccurring = self.isReoccurring
                    newCoreEvent.isDeleted = self.isDeleted

                    realm.add(newCoreEvent)
                }
            }
        } catch let error {
            print("Failed to save CoreEvent: \(error.localizedDescription)")
        }
    }
}
