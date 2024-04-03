//
//  TrainingEquipment.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/2/24.
//

import Foundation


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

    var description: String {
        return self.rawValue
    }
}


