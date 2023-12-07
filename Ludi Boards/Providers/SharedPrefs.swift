//
//  SharedPrefs.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation

class SharedPrefs: ObservableObject {
    static let shared = SharedPrefs()
    
    private let defaults = UserDefaults.standard

    private init() {}

    func save(_ key: String, value: String) { defaults.set(value, forKey: key) }

    func retrieve(_ key:String, defaultValue:String="") -> String {
        return defaults.string(forKey: key) ?? defaultValue
    }
    
    func saveUserId(userId:String) { defaults.set("currentUserId", forKey: userId) }
    func getUserId() -> String? { return defaults.string(forKey: "currentUserId") }
    func saveUserName(userName:String) { defaults.set("currentUserName", forKey: userName) }
    func getUserName() -> String? { return defaults.string(forKey: "currentUserName") }
    func clearUser() {
        saveUserId(userId: "")
        saveUserName(userName: "")
    }
}
