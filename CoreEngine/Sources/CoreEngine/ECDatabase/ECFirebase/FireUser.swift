//
//  FireUser.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//

public func generateRandomUserId() -> String {
    let firstNames = [
        "Liam", "Olivia", "Noah", "Emma", "Ava", "Sophia", "Isabella",
        "Ethan", "Mia", "Mason", "Charlotte", "Amelia", "James",
        "Benjamin", "Lucas", "Harper", "Evelyn", "Henry", "Alexander"
    ]
    
    let randomFirst = firstNames.randomElement() ?? "John"
    let randomNumber = Int.random(in: 1000...9999) // 4-digit number
    
    return "\(randomFirst)-\(randomNumber)"
}

public func generateRandomName() -> String {
    let firstNames = [
        "Liam", "Olivia", "Noah", "Emma", "Ava", "Sophia", "Isabella",
        "Ethan", "Mia", "Mason", "Charlotte", "Amelia", "James",
        "Benjamin", "Lucas", "Harper", "Evelyn", "Henry", "Alexander"
    ]
    
    let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
        "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez",
        "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor"
    ]
    
    let randomFirst = firstNames.randomElement() ?? "John"
    let randomLast = lastNames.randomElement() ?? "Doe"
    
    return "\(randomFirst) \(randomLast)"
}

