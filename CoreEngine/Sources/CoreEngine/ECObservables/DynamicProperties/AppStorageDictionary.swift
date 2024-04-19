//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper
public struct AppStorageDictionaryString: DynamicProperty {
    private var key: String
    private var defaultValue: [String: String]
    @AppStorage private var storedData: String

    public init(_ key: String) {
        self.defaultValue = [:]
        self.key = key
        _storedData = AppStorage(wrappedValue: "{}", key)
        if self.wrappedValue.isEmpty && !defaultValue.isEmpty {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: [String: String] {
        get {
            guard let data = storedData.data(using: .utf8) else { return defaultValue }
            return (try? JSONDecoder().decode([String: String].self, from: data)) ?? defaultValue
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            storedData = String(data: data, encoding: .utf8) ?? "{}"
        }
    }

    public var projectedValue: AppStorageDictionaryString {
        return self
    }
    
    mutating public func update() { _storedData.update() }
}

@propertyWrapper
public struct AppStorageDictionary: DynamicProperty {
    public var key: String
    public var defaultValue: [String: Any]
    @AppStorage public var storedData: String

    public init(_ key: String) {
        self.defaultValue = [:]
        self.key = key
        _storedData = AppStorage(wrappedValue: "{}", key)
        if self.wrappedValue.isEmpty && !defaultValue.isEmpty {
            self.wrappedValue = defaultValue
        }
    }

    public var wrappedValue: [String: Any] {
        get { storedData.decodeToDictionary() }
        set { storedData = newValue.encodeToString() }
    }

    public var projectedValue: AppStorageDictionary {
        return self
    }
    
    mutating public func update() { _storedData.update() }
}

