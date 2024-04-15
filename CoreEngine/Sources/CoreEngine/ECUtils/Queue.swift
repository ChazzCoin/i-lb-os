//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation


public struct CoreQueue<T> {
    public var elements: [T] = []

    public mutating func enqueue(_ element: T) {
        elements.append(element)
    }

    public mutating func dequeue() -> T? {
        guard !elements.isEmpty else { return nil }
        return elements.removeFirst()
    }

    public func peek() -> T? {
        return elements.first
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public var count: Int {
        return elements.count
    }
}
