import SwiftUI
import RealmSwift

// ViewModel for ActivityPlan
public class ActivityPlanObject: ObservableObject {
    
    @AppStorage("currentActivityId") var currentActivityId: String = ""
    
    // Observable properties for each attribute
    @Published public var id: String
    @Published public var dateCreated: String
    @Published public var dateUpdated: String
    @Published public var dateOf: String
    @Published public var title: String
    @Published public var subTitle: String
    @Published public var objectiveDetails: String
    @Published public var activityDetails: String
    @Published public var timePeriod: String
    @Published public var duration: String
    @Published public var ageLevel: String
    @Published public var category: String
    @Published public var tags: [String]
    @Published public var equipment: String
    @Published public var spaceDimensions: String
    @Published public var principles: String
    @Published public var keyQualities: String
    @Published public var coachingPoints: String
    @Published public var guidedAnswers: String
    @Published public var answers: String
    @Published public var numOfPlayers: Int
    @Published public var numOfGroups: Int
    @Published public var numPerGroup: Int
    @Published public var sessionId: String
    @Published public var orgId: String
    @Published public var teamId: String
    @Published public var ownerId: String
    @Published public var createdBy: String
    @Published public var isHost: Bool
    @Published public var isOpen: Bool
    @Published public var isLocal: Bool
    @Published public var isDeleted: Bool
    @Published public var orderIndex: Int
    @Published public var width: Int
    @Published public var height: Int
    @Published public var backgroundRed: Double
    @Published public var backgroundGreen: Double
    @Published public var backgroundBlue: Double
    @Published public var backgroundAlpha: Double
    @Published public var backgroundLineStroke: Double
    @Published public var backgroundRotation: Double
    @Published public var backgroundLineRed: Double
    @Published public var backgroundLineGreen: Double
    @Published public var backgroundLineBlue: Double
    @Published public var backgroundLineAlpha: Double
    @Published public var backgroundView: String
    
    // Optional List of ManagedView - Requires ManagedView Model
    @Published public var managedViews: [ManagedView]

    // Realm instance
    public var realm: Realm

    // Default initializer for creating a new ActivityPlan
    public init() {
        self.realm = try! Realm()
        
        // Initialize properties with default values
        self.id = UUID().uuidString
        self.dateCreated = getTimeStamp()
        self.dateUpdated = getTimeStamp()
        self.dateOf = getTimeStamp()
        self.title = ""
        self.subTitle = ""
        self.objectiveDetails = ""
        self.activityDetails = ""
        self.timePeriod = ""
        self.duration = ""
        self.ageLevel = ""
        self.category = ""
        self.tags = []
        self.equipment = ""
        self.spaceDimensions = ""
        self.principles = ""
        self.keyQualities = ""
        self.coachingPoints = ""
        self.guidedAnswers = ""
        self.answers = ""
        self.numOfPlayers = 0
        self.numOfGroups = 0
        self.numPerGroup = 0
        self.sessionId = ""
        self.orgId = ""
        self.teamId = ""
        self.ownerId = ""
        self.createdBy = ""
        self.isHost = false
        self.isOpen = false
        self.isLocal = true
        self.isDeleted = false
        self.orderIndex = 0
        self.width = 3000
        self.height = 4000
        self.backgroundRed = 0.2
        self.backgroundGreen = 0.78
        self.backgroundBlue = 0.34
        self.backgroundAlpha = 0.75
        self.backgroundLineStroke = 10
        self.backgroundRotation = -90
        self.backgroundLineRed = 255.0
        self.backgroundLineGreen = 255.0
        self.backgroundLineBlue = 255.0
        self.backgroundLineAlpha = 1.0
        self.backgroundView = "Sol"
        self.managedViews = []
    }

    public func isCurrentActivity() -> Bool {
        if self.currentActivityId == self.id {
            return true
        }
        return false
    }
    public func makeCurrentActivity() {
        if isCurrentActivity() { return }
        self.currentActivityId = self.id
    }
    
    // Function to load an existing ActivityPlan by ID
    public func loadActivityPlan(byId activityId: String) {
        if let activityPlan = realm.object(ofType: ActivityPlan.self, forPrimaryKey: activityId) {
            // Update properties with the values from Realm
            self.id = activityPlan.id
            self.dateCreated = activityPlan.dateCreated
            self.dateUpdated = activityPlan.dateUpdated
            self.dateOf = activityPlan.dateOf
            self.title = activityPlan.title
            self.subTitle = activityPlan.subTitle
            self.objectiveDetails = activityPlan.objectiveDetails
            self.activityDetails = activityPlan.activityDetails
            self.timePeriod = activityPlan.timePeriod
            self.duration = activityPlan.duration
            self.ageLevel = activityPlan.ageLevel
            self.category = activityPlan.category
            self.tags = Array(activityPlan.tags)
            self.equipment = activityPlan.equipment
            self.spaceDimensions = activityPlan.spaceDimensions
            self.principles = activityPlan.principles
            self.keyQualities = activityPlan.keyQualities
            self.coachingPoints = activityPlan.coachingPoints
            self.guidedAnswers = activityPlan.guidedAnswers
            self.answers = activityPlan.answers
            self.numOfPlayers = activityPlan.numOfPlayers
            self.numOfGroups = activityPlan.numOfGroups
            self.numPerGroup = activityPlan.numPerGroup
            self.sessionId = activityPlan.sessionId
            self.orgId = activityPlan.orgId
            self.teamId = activityPlan.teamId
            self.ownerId = activityPlan.ownerId
            self.createdBy = activityPlan.createdBy
            self.isHost = activityPlan.isHost
            self.isOpen = activityPlan.isOpen
            self.isLocal = activityPlan.isLocal
            self.isDeleted = activityPlan.isDeleted
            self.orderIndex = activityPlan.orderIndex
            self.width = activityPlan.width
            self.height = activityPlan.height
            self.backgroundRed = activityPlan.backgroundRed
            self.backgroundGreen = activityPlan.backgroundGreen
            self.backgroundBlue = activityPlan.backgroundBlue
            self.backgroundAlpha = activityPlan.backgroundAlpha
            self.backgroundLineStroke = activityPlan.backgroundLineStroke
            self.backgroundRotation = activityPlan.backgroundRotation
            self.backgroundLineRed = activityPlan.backgroundLineRed
            self.backgroundLineGreen = activityPlan.backgroundLineGreen
            self.backgroundLineBlue = activityPlan.backgroundLineBlue
            self.backgroundLineAlpha = activityPlan.backgroundLineAlpha
            self.backgroundView = activityPlan.backgroundView
            self.managedViews = Array(activityPlan.managedViews)
        } else {
            print("ActivityPlan with ID \(activityId) not found.")
        }
    }

    // Function to save changes back to Realm
    public func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingActivityPlan = realm.object(ofType: ActivityPlan.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingActivityPlan.dateUpdated = getTimeStamp()
                    existingActivityPlan.title = self.title
                    existingActivityPlan.subTitle = self.subTitle
                    existingActivityPlan.objectiveDetails = self.objectiveDetails
                    existingActivityPlan.activityDetails = self.activityDetails
                    existingActivityPlan.timePeriod = self.timePeriod
                    existingActivityPlan.duration = self.duration
                    existingActivityPlan.ageLevel = self.ageLevel
                    existingActivityPlan.category = self.category
                    existingActivityPlan.tags.removeAll()
                    existingActivityPlan.tags.append(objectsIn: self.tags)
                    existingActivityPlan.equipment = self.equipment
                    existingActivityPlan.spaceDimensions = self.spaceDimensions
                    existingActivityPlan.principles = self.principles
                    existingActivityPlan.keyQualities = self.keyQualities
                    existingActivityPlan.coachingPoints = self.coachingPoints
                    existingActivityPlan.guidedAnswers = self.guidedAnswers
                    existingActivityPlan.answers = self.answers
                    existingActivityPlan.numOfPlayers = self.numOfPlayers
                    existingActivityPlan.numOfGroups = self.numOfGroups
                    existingActivityPlan.numPerGroup = self.numPerGroup
                    existingActivityPlan.sessionId = self.sessionId
                    existingActivityPlan.orgId = self.orgId
                    existingActivityPlan.teamId = self.teamId
                    existingActivityPlan.ownerId = self.ownerId
                    existingActivityPlan.createdBy = self.createdBy
                    existingActivityPlan.isHost = self.isHost
                    existingActivityPlan.isOpen = self.isOpen
                    existingActivityPlan.isLocal = self.isLocal
                    existingActivityPlan.isDeleted = self.isDeleted
                    existingActivityPlan.orderIndex = self.orderIndex
                    existingActivityPlan.width = self.width
                    existingActivityPlan.height = self.height
                    existingActivityPlan.backgroundRed = self.backgroundRed
                    existingActivityPlan.backgroundGreen = self.backgroundGreen
                    existingActivityPlan.backgroundBlue = self.backgroundBlue
                    existingActivityPlan.backgroundAlpha = self.backgroundAlpha
                    existingActivityPlan.backgroundLineStroke = self.backgroundLineStroke
                    existingActivityPlan.backgroundRotation = self.backgroundRotation
                    existingActivityPlan.backgroundLineRed = self.backgroundLineRed
                    existingActivityPlan.backgroundLineGreen = self.backgroundLineGreen
                    existingActivityPlan.backgroundLineBlue = self.backgroundLineBlue
                    existingActivityPlan.backgroundLineAlpha = self.backgroundLineAlpha
                    existingActivityPlan.backgroundView = self.backgroundView
                    existingActivityPlan.managedViews.removeAll()
                    existingActivityPlan.managedViews.append(objectsIn: self.managedViews)
                } else {
                    // Create a new object if not found
                    let newActivityPlan = ActivityPlan()
                    newActivityPlan.id = self.id
                    newActivityPlan.dateCreated = self.dateCreated
                    newActivityPlan.dateUpdated = getTimeStamp()
                    newActivityPlan.dateOf = self.dateOf
                    newActivityPlan.title = self.title
                    newActivityPlan.subTitle = self.subTitle
                    newActivityPlan.objectiveDetails = self.objectiveDetails
                    newActivityPlan.activityDetails = self.activityDetails
                    newActivityPlan.timePeriod = self.timePeriod
                    newActivityPlan.duration = self.duration
                    newActivityPlan.ageLevel = self.ageLevel
                    newActivityPlan.category = self.category
                    newActivityPlan.tags.append(objectsIn: self.tags)
                    newActivityPlan.equipment = self.equipment
                    newActivityPlan.spaceDimensions = self.spaceDimensions
                    newActivityPlan.principles = self.principles
                    newActivityPlan.keyQualities = self.keyQualities
                    newActivityPlan.coachingPoints = self.coachingPoints
                    newActivityPlan.guidedAnswers = self.guidedAnswers
                    newActivityPlan.answers = self.answers
                    newActivityPlan.numOfPlayers = self.numOfPlayers
                    newActivityPlan.numOfGroups = self.numOfGroups
                    newActivityPlan.numPerGroup = self.numPerGroup
                    newActivityPlan.sessionId = self.sessionId
                    newActivityPlan.orgId = self.orgId
                    newActivityPlan.teamId = self.teamId
                    newActivityPlan.ownerId = self.ownerId
                    newActivityPlan.createdBy = self.createdBy
                    newActivityPlan.isHost = self.isHost
                    newActivityPlan.isOpen = self.isOpen
                    newActivityPlan.isLocal = self.isLocal
                    newActivityPlan.isDeleted = self.isDeleted
                    newActivityPlan.orderIndex = self.orderIndex
                    newActivityPlan.width = self.width
                    newActivityPlan.height = self.height
                    newActivityPlan.backgroundRed = self.backgroundRed
                    newActivityPlan.backgroundGreen = self.backgroundGreen
                    newActivityPlan.backgroundBlue = self.backgroundBlue
                    newActivityPlan.backgroundAlpha = self.backgroundAlpha
                    newActivityPlan.backgroundLineStroke = self.backgroundLineStroke
                    newActivityPlan.backgroundRotation = self.backgroundRotation
                    newActivityPlan.backgroundLineRed = self.backgroundLineRed
                    newActivityPlan.backgroundLineGreen = self.backgroundLineGreen
                    newActivityPlan.backgroundLineBlue = self.backgroundLineBlue
                    newActivityPlan.backgroundLineAlpha = self.backgroundLineAlpha
                    newActivityPlan.backgroundView = self.backgroundView
                    newActivityPlan.managedViews.append(objectsIn: self.managedViews)

                    realm.add(newActivityPlan)
                }
            }
        } catch let error {
            print("Failed to save ActivityPlan: \(error.localizedDescription)")
        }
    }
}
