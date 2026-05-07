//
//  EventStream.swift
//  CoreEngine
//
//  Created by Charles Romeo on 2/4/26.
//
import RealmSwift
import Foundation

public class ManagedStream: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var createdDate: String = getTimeStamp()
    @Persisted public var updatedDate: String = getTimeStamp()
    @Persisted public var viewId = ""
    @Persisted public var roomId = ""
    @Persisted public var sessionId = ""
    @Persisted public var visibility: Bool = true
    @Persisted public var auth: String = ""
    @Persisted public var role: String = ""
    @Persisted public var model = ""
    @Persisted public var type = "" // duration in seconds
    @Persisted public var ownerId = "" // duration in seconds
    @Persisted public var updatedById = "" // duration in seconds
    @Persisted public var title = "" // duration in seconds
    @Persisted public var details = "" // duration in seconds
    @Persisted public var sequence: Int = 0
    @Persisted public var eventKind: String = ""
    @Persisted public var schemaVersion: Int = 0
    @Persisted public var payloadType: String = ""
    @Persisted public var chunkIndex: Int = 0
    @Persisted public var chunkCount: Int = 0
    @Persisted public var byteSize: Int = 0
    @Persisted public var data: String = ""
    
}
