//
//  TimeProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation


struct DateTimeTools {
    
    static func currentMonth() -> String {
        Calendar.current.monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    }
    static func currentYear() -> String {
        String(Calendar.current.component(.year, from: Date()))
    }
    static func currentYear() -> Int {
        Calendar.current.component(.year, from: Date())
    }

    static func currentTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Adjust format options as needed
        return formatter.string(from: Date())
    }
    
    // IN-TO Database
    static func parseToString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Adjust format options as needed
        return formatter.string(from: date)
    }
    
    // OUT-OF Database
    static func toDisplayText(fromTimestamp timestamp: Date) -> String {
        let temp = parseToString(date: timestamp)
        return toDisplayText(fromTimestamp: temp)
    }
    static func toDisplayText(fromTimestamp timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Match the format used to generate the timestamp
        
        if let date = isoFormatter.date(from: timestamp) {
            let readableFormatter = DateFormatter()
            readableFormatter.dateStyle = .long
//            readableFormatter.timeStyle = .short
            readableFormatter.locale = Locale.current // Adjust for the desired locale
            return readableFormatter.string(from: date)
        } else {
            return timestamp
        }
    }
    static func toMonthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
}


class TimeProvider {
    
    static func getCurrentTimestamp() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: currentDateTime)
    }
    
    static func getMonthDayYearTime() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy hh:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: currentDate)
    }
    
    static func convertTimestampToReadableDate(timestamp: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: timestamp) else {
            return nil
        }

        formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    static func compareTimestamps(timestamp1: String, timestamp2: String) -> ComparisonResult {
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
    
}

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


func getCurrentTimestamp() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: currentDateTime)
}

// Function to convert timestamp string to human-readable date
func convertTimestampToReadableDate(timestamp: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = formatter.date(from: timestamp) else {
        return nil
    }

    formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm:ss"
    return formatter.string(from: date)
}
