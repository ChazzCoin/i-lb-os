//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/1/24.
//

import Foundation
import SwiftUI
import RealmSwift

// ViewModel for Team
public class TeamObject: ObservableObject {
    // Observable properties for each attribute
    @Published public var id: String
    @Published public var orgId: String
    @Published public var name: String
    @Published public var coachName: String
    @Published public var sportType: String
    @Published public var logoUrl: String?
    @Published public var foundedYear: String
    @Published public var homeCity: String
    @Published public var stadiumName: String
    @Published public var roster: [String]
    @Published public var coach: String
    @Published public var manager: String
    @Published public var league: String
    @Published public var achievements: [String]
    @Published public var officialWebsite: String?
    @Published public var socialMediaLinks: [String]
    @Published public var isDeleted: Bool

    // Realm instance
    public var realm: Realm

    // Default initializer for creating a new Team
    public init() {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.orgId = ""
        self.name = ""
        self.coachName = ""
        self.sportType = ""
        self.logoUrl = nil
        self.foundedYear = "2020"
        self.homeCity = ""
        self.stadiumName = ""
        self.roster = []
        self.coach = ""
        self.manager = ""
        self.league = ""
        self.achievements = []
        self.officialWebsite = nil
        self.socialMediaLinks = []
        self.isDeleted = false
    }

    // Function to load an existing Team by ID
    public func loadTeam(byId teamId: String) {
        if let team = realm.object(ofType: Team.self, forPrimaryKey: teamId) {
            // Update properties with the values from Realm
            self.id = team.id
            self.orgId = team.orgId
            self.name = team.name
            self.coachName = team.coachName
            self.sportType = team.sportType
            self.logoUrl = team.logoUrl
            self.foundedYear = team.foundedYear
            self.homeCity = team.homeCity
            self.stadiumName = team.stadiumName
            self.roster = Array(team.roster)
            self.coach = team.coach
            self.manager = team.manager
            self.league = team.league
            self.achievements = Array(team.achievements)
            self.officialWebsite = team.officialWebsite
            self.socialMediaLinks = Array(team.socialMediaLinks)
            self.isDeleted = team.isDeleted
        } else {
            print("Team with ID \(teamId) not found.")
        }
    }

    // Function to save changes back to Realm
    public func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingTeam = realm.object(ofType: Team.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingTeam.orgId = self.orgId
                    existingTeam.name = self.name
                    existingTeam.coachName = self.coachName
                    existingTeam.sportType = self.sportType
                    existingTeam.logoUrl = self.logoUrl
                    existingTeam.foundedYear = self.foundedYear
                    existingTeam.homeCity = self.homeCity
                    existingTeam.stadiumName = self.stadiumName
                    existingTeam.roster.removeAll()
                    existingTeam.roster.append(objectsIn: self.roster)
                    existingTeam.coach = self.coach
                    existingTeam.manager = self.manager
                    existingTeam.league = self.league
                    existingTeam.achievements.removeAll()
                    existingTeam.achievements.append(objectsIn: self.achievements)
                    existingTeam.officialWebsite = self.officialWebsite
                    existingTeam.socialMediaLinks.removeAll()
                    existingTeam.socialMediaLinks.append(objectsIn: self.socialMediaLinks)
                    existingTeam.isDeleted = self.isDeleted
                } else {
                    // Create a new object if not found
                    let newTeam = Team()
                    newTeam.id = self.id
                    newTeam.orgId = self.orgId
                    newTeam.name = self.name
                    newTeam.coachName = self.coachName
                    newTeam.sportType = self.sportType
                    newTeam.logoUrl = self.logoUrl
                    newTeam.foundedYear = self.foundedYear
                    newTeam.homeCity = self.homeCity
                    newTeam.stadiumName = self.stadiumName
                    newTeam.roster.append(objectsIn: self.roster)
                    newTeam.coach = self.coach
                    newTeam.manager = self.manager
                    newTeam.league = self.league
                    newTeam.achievements.append(objectsIn: self.achievements)
                    newTeam.officialWebsite = self.officialWebsite
                    newTeam.socialMediaLinks.append(objectsIn: self.socialMediaLinks)
                    newTeam.isDeleted = self.isDeleted

                    realm.add(newTeam)
                }
            }
        } catch let error {
            print("Failed to save Team: \(error.localizedDescription)")
        }
    }
}
