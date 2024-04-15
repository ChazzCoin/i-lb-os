//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/14/24.
//

import Foundation
import SwiftUI




@propertyWrapper
public struct AppStorageList {
    public var key: String
    public var defaultValue: [String]
    @AppStorage public var storedData: String

    public init(wrappedValue: [String], key: String) {
        self.defaultValue = wrappedValue
        self.key = key
        _storedData = AppStorage(wrappedValue: "", key)
        // Initialize the storage with the default value if it's not already set.
        if self.wrappedValue.isEmpty && !defaultValue.isEmpty {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: [String] {
        get {
//            (try? JSONDecoder().decode([String].self, from: Data(storedData.utf8))) ?? []
            storedData.toList()
        }
        set {
            storedData = newValue.toString()
        }
    }
    
    // Optionally, you can provide a 'projectedValue' if you need direct access to more complex behavior or additional data.
    public var projectedValue: AppStorageList {
        return self
    }
}


