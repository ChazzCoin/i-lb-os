//
//  Song.swift
//  Wrlds
//
//  Created by Charles Romeo on 1/10/24.
//

import Foundation
import RealmSwift

class Song: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var title = ""
    @Persisted var artist = ""
    @Persisted var duration = 0 // duration in seconds
    @Persisted var releaseDate: String = getTimeStamp()
    @Persisted var downloadUrl: String = ""

}
