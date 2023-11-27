//
//  TimeProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation


func getTimeStamp() -> String {
    let current = Locale(identifier: "en_US")
    let dateFormatter = DateFormatter()

    do {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: Date())
    } catch {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = current
        return dateFormatter.string(from: Date())
    }
}

func compareTimestamps(timestamp1: String, timestamp2: String) -> ComparisonResult {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.timeZone = TimeZone.current

    guard let date1 = dateFormatter.date(from: timestamp1),
          let date2 = dateFormatter.date(from: timestamp2) else {
        return .orderedSame
    }

    return date1.compare(date2)
}
