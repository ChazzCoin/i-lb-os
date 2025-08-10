//
//  BinauralSound.swift
//  CoreEngine
//
//  Created by Charles Romeo on 8/8/25.
//

import Foundation
import RealmSwift
import FirebaseDatabase

public class BinauralSound: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = "Alicia"
    
    // Core Sound Parameters
    @Persisted public var roomId: String = ""
    @Persisted public var duration: Double = 600.0
    @Persisted public var sampleRate: Double = 43200.0
    @Persisted public var freqLeft: Double = 60.0
    @Persisted public var freqRight: Double = 100.0
    @Persisted public var fadeTime: Double = 3.0
    @Persisted public var modFreq: Double = 0.1
    @Persisted public var modDepth: Double = 0.3
    @Persisted public var overtoneLevel: Double = 0.10
    @Persisted public var overtoneMultiplier: Double = 2.0
    
    @Persisted public var users: Int = 0
    @Persisted public var usersReady: Int = 0
    @Persisted public var status: String = "paused"
    @Persisted public var lastUpdatedBy: String = ""
    
    // Metadata
    @Persisted public var name: String = "Untitled Preset"
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    
}


public extension BinauralSound {
    func toFirebaseDict() -> [String: Any] {
        [
            "id": id,
            "roomId": roomId,
            "name": name,
            "duration": duration,
            "sampleRate": sampleRate,
            "freqLeft": freqLeft,
            "freqRight": freqRight,
            "fadeTime": fadeTime,
            "modFreq": modFreq,
            "modDepth": modDepth,
            "overtoneLevel": overtoneLevel,
            "overtoneMultiplier": overtoneMultiplier,
            "users": users,
            "usersReady": usersReady,
            "lastUpdatedBy": lastUpdatedBy,
            "status": status,
            "dateCreated": getTimeStamp(),
            "dateUpdated": getTimeStamp()
        ]
    }
}

public extension BinauralSound {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "roomId": roomId,
            "name": name,
            "duration": duration,
            "sampleRate": sampleRate,
            "freqLeft": freqLeft,
            "freqRight": freqRight,
            "fadeTime": fadeTime,
            "modFreq": modFreq,
            "modDepth": modDepth,
            "overtoneLevel": overtoneLevel,
            "overtoneMultiplier": overtoneMultiplier,
            "users": users,
            "usersReady": usersReady,
            "status": status,
            "lastUpdatedBy": lastUpdatedBy,
            "dateCreated": getTimeStamp(),
            "dateUpdated": getTimeStamp()
        ]
    }
}

public func toBinauralSound(from dictionary: [String: Any]) -> BinauralSound {
    let sound = BinauralSound()
    sound.id = dictionary["id"] as? String ?? UUID().uuidString
    sound.roomId = dictionary["roomId"] as? String ?? ""
    sound.name = dictionary["name"] as? String ?? "Untitled Preset"
    sound.duration = dictionary["duration"] as? Double ?? 600.0
    sound.sampleRate = dictionary["sampleRate"] as? Double ?? 43200.0
    sound.freqLeft = dictionary["freqLeft"] as? Double ?? 60.0
    sound.freqRight = dictionary["freqRight"] as? Double ?? 100.0
    sound.fadeTime = dictionary["fadeTime"] as? Double ?? 3.0
    sound.modFreq = dictionary["modFreq"] as? Double ?? 0.1
    sound.modDepth = dictionary["modDepth"] as? Double ?? 0.3
    sound.overtoneLevel = dictionary["overtoneLevel"] as? Double ?? 0.10
    sound.overtoneMultiplier = dictionary["overtoneMultiplier"] as? Double ?? 2.0
    sound.users = dictionary["users"] as? Int ?? 0
    sound.usersReady = dictionary["usersReady"] as? Int ?? 0
    sound.status = dictionary["status"] as? String ?? "paused"
    sound.lastUpdatedBy = dictionary["lastUpdatedBy"] as? String ?? ""
    
    if let createdTimestamp = dictionary["dateCreated"] as? String {
        sound.dateCreated = createdTimestamp
    }
    if let updatedTimestamp = dictionary["dateUpdated"] as? String {
        sound.dateUpdated = updatedTimestamp
    }
    
    return sound
}
