//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI
import Combine

public extension Dictionary where Key == String, Value == Any {
    
    func encodeToString() -> String {
        var encodedItems = [String: String]()
        for (key, value) in self {
            if let stringValue = value as? String { encodedItems[key] = "s:\(stringValue)"}
            else if let intValue = value as? Int { encodedItems[key] = "i:\(intValue)" }
            else if let doubleValue = value as? Double { encodedItems[key] = "d:\(doubleValue)" }
            else if let fValue = value as? Float { encodedItems[key] = "f:\(fValue)" }
            else if let bValue = value as? Bool { encodedItems[key] = "b:\(bValue)" }
        }
        let data = try? JSONSerialization.data(withJSONObject: encodedItems, options: [])
        return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
    }
    
}

public extension String {
    
    func decodeToDictionary() -> [String: Any] {
        guard let data = self.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
            return [:]
        }

        var decodedItems: [String: Any] = [:]
        for (key, value) in dict {
            let components = value.split(separator: ":", maxSplits: 1)
            guard components.count == 2 else { continue }
            let type = components[0]
            let value = components[1]

            switch type {
                case "s": decodedItems[key] = String(value)
                case "i": if let intValue = Int(value) { decodedItems[key] = intValue }
                case "d": if let doubleValue = Double(value) { decodedItems[key] = doubleValue }
                case "f": if let floatValue = Float(value) { decodedItems[key] = floatValue }
                case "b": decodedItems[key] = value == "true" ? true : false
                default: continue
            }
        }
        return decodedItems
    }
    
}

public extension CoreTools {
    
    static func encodeToString(dictionary: [String: Any]) -> String {
        return dictionary.encodeToString()
    }

    static func decodeToDictionary(dictionaryString: String) -> [String: Any] {
        return dictionaryString.decodeToDictionary()
    }

}

