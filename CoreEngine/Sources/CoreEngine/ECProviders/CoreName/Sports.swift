//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public extension CoreName {
    
    class Soccer {
        
        public enum Position: String, CaseIterable {
            case goalkeeper = "goalkeeper"
            case rightFullback = "rightFullback"
            case leftFullback = "leftFullback"
            case centerBack = "centerBack"
            case rightCenterBack = "rightCenterBack"
            case leftCenterBack = "leftCenterBack"
            case defensiveMidfield = "defensiveMidfield"
            case rightMidfield = "rightMidfield"
            case leftMidfield = "leftMidfield"
            case attackingMidfield = "attackingMidfield"
            case forward = "forward"
            
            public var positionNumber: Int {
                switch self {
                    case .goalkeeper: return 1
                    case .rightFullback: return 2
                    case .leftFullback: return 3
                    case .centerBack: return 4
                    case .rightCenterBack: return 5
                    case .leftCenterBack: return 6
                    case .defensiveMidfield: return 7
                    case .rightMidfield: return 8
                    case .leftMidfield: return 9
                    case .attackingMidfield: return 10
                    case .forward: return 11
                }
            }
        }
    }
    
    enum SessionCategory: String, CaseIterable {
        case warmUp = "Warm-Up"
        case preGame = "Pre-Game"
        case scrimmage = "Scrimmage"
        case formationTraining = "Formation Training"
        case defensiveDrills = "Defensive Drills"
        case offensiveDrills = "Offensive Drills"
        case technicalSkills = "Technical Skills"
        case tacticalTraining = "Tactical Training"
        case strengthAndConditioning = "Strength and Conditioning"
        case coolDown = "Cool Down"
        case teamMeeting = "Team Meeting"
        case strategySession = "Strategy Session"
        case individualSkills = "Individual Skills"
        case recoverySession = "Recovery Session"
        case mentalPreparation = "Mental Preparation"
        case goalkeeperTraining = "Goalkeeper Training"
        case plyometrics = "Plyometrics"
        case speedAndAgility = "Speed and Agility"
        case enduranceTraining = "Endurance Training"
        case flexibilitySession = "Flexibility Session"
        case nutritionEducation = "Nutrition Education"
        case injuryPrevention = "Injury Prevention"
        case videoAnalysis = "Video Analysis"
        case postGameAnalysis = "Post-Game Analysis"
        case communityEngagement = "Community Engagement"
        case youthDevelopment = "Youth Development"
        case equipmentPreparation = "Equipment Preparation"
    }
    
    enum ActivityCategory: String, CaseIterable {
        case oneVOneAttacking = "1v1 Attacking"
        case oneVOneDefending = "1v1 Defending"
        case passingAccuracy = "Passing Accuracy"
        case dribblingSkills = "Dribbling Skills"
        case shootingAccuracy = "Shooting Accuracy"
        case goalkeepingSkills = "Goalkeeping Skills"
        case headingDrills = "Heading Drills"
        case freeKickPractice = "Free Kick Practice"
        case cornerKickStrategies = "Corner Kick Strategies"
        case throwInTechniques = "Throw In Techniques"
        case speedLadders = "Speed Ladders"
        case agilityCones = "Agility Cones"
        case enduranceRuns = "Endurance Runs"
        case strengthCircuits = "Strength Circuits"
        case flexibilityYoga = "Flexibility Yoga"
        case tacticalPositioning = "Tactical Positioning"
        case ballControl = "Ball Control"
        case reactionTimeDrills = "Reaction Time Drills"
        case mentalToughness = "Mental Toughness"
        case teamPlaySimulation = "Team Play Simulation"
        case crossFitChallenges = "CrossFit Challenges"
        case plyometricHops = "Plyometric Hops"
        case balanceBoard = "Balance Board"
        case coordinationDrills = "Coordination Drills"
        case nutritionalPlanning = "Nutritional Planning"
        case injuryRehabilitation = "Injury Rehabilitation"
    }
    
    enum TrainingEquipment: String, CaseIterable {
        case balls = "Balls"
        case protectiveGear = "Protective Gear"
        case footwear = "Footwear"
        case net = "Net"
        case racket = "Racket"
        case bat = "Bat"
        case gloves = "Gloves"
        case helmet = "Helmet"
        case waterBottle = "Water Bottle"
        case trainingCones = "Training Cones"
        case goal = "Goal"
        case stopwatch = "Stopwatch"
        case whistle = "Whistle"
        case uniform = "Uniform"
        case agilityLadder = "Agility Ladder"
        case cones = "Cones"
        case hurdle = "Hurdle"
        case resistanceBands = "Resistance Bands"
        case medicineBall = "Medicine Ball"
        case kettlebell = "Kettlebell"
        case dumbbells = "Dumbbells"
        case jumpRope = "Jump Rope"
        case plyometricBoxes = "Plyometric Boxes"
        case stabilityBall = "Stability Ball"
        case yogaMat = "Yoga Mat"
        case foamRoller = "Foam Roller"
        case speedChute = "Speed Chute"
        case balanceBoard = "Balance Board"
        case weightedVest = "Weighted Vest"
        case sandbags = "Sandbags"
        case parallettes = "Parallettes"
        case pullUpBar = "Pull-Up Bar"
        case gripStrengthener = "Grip Strengthener"
        case ankleWeights = "Ankle Weights"
        case heartRateMonitor = "Heart Rate Monitor"
        case agilityRings = "Agility Rings"
        case battlingRopes = "Battling Ropes"
        case bosuBall = "Bosu Ball"
        case suspensionTrainer = "Suspension Trainer"
        case speedLadder = "Speed Ladder"
        case trainingSled = "Training Sled"
        case trainingMask = "Training Mask"
        public var description: String { return self.rawValue }
    }

    enum AgeLevel: String, CaseIterable, Identifiable {
        case Youth = "Youth"
        case U6 = "U6"
        case U8 = "U8"
        case U10 = "U10"
        case U12 = "U12"
        case U14 = "U14"
        case U16 = "U16"
        case U18 = "U18"
        case U21 = "U21"
        case Adult = "Adult"
        case Professional = "Professional"
        public var id: String { self.rawValue }
    }
    enum TimeDuration: Int, CaseIterable, Identifiable {
        case one = 1
        case five = 5
        case ten = 10
        case fifteen = 15
        case thirty = 30
        case fortyFive = 45
        case sixty = 60
        case ninety = 90
        public var id: Int { self.rawValue }
        public var description: String {
            "\(self.rawValue) Minutes"
        }
    }
    enum IntensityLevel: String, CaseIterable, Identifiable {
        case Cool = "Cool Down"
        case Warm = "Warm Up"
        case Low = "Low"
        case Medium = "Medium"
        case High = "High"
        case Max = "Max"
        public var id: String { self.rawValue }
    }
    enum DominateFoot: String, CaseIterable, Identifiable {
        case Right = "Right"
        case Left = "Left"
        case Both = "Both"
        case None = "None"
        public var id: String { self.rawValue }
    }
    enum DominateHand: String, CaseIterable, Identifiable {
        case Right = "Right"
        case Left = "Left"
        case Both = "Both"
        case None = "None"
        public var id: String { self.rawValue }
    }
    enum Gender: String, CaseIterable, Identifiable {
        case Male = "Male"
        case Female = "Female"
        case None = "None"
        public var id: String { self.rawValue }
    }

}
