//
//  Extensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation


extension DispatchQueue {
    static func executeAfter(seconds: TimeInterval, on queue: DispatchQueue = .main, action: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + seconds, execute: action)
    }
}
