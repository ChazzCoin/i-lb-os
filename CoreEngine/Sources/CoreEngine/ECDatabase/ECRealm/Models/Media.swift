//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import RealmSwift

public class Media: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var viewId = ""
    @Persisted public var boardId = ""
    @Persisted public var title = ""
    @Persisted public var artist = ""
    @Persisted public var duration = 0 // duration in seconds
    @Persisted public var releaseDate: String = getTimeStamp()
    @Persisted public var downloadUrl: String = ""

}
