//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation


public struct CoreQueue<T> {
    public var elements: [T] = []

    // MARK: FIFO
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

    // MARK: LIFO (stack) — used by NavStack/NodeStack back navigation.
    // The newest entry is the top of the stack: push appends, pop and
    // top operate on the last element. goBack() relies on this; treating
    // the back stack as FIFO (dequeue/peek) silently inverts navigation.
    public mutating func push(_ element: T) {
        elements.append(element)
    }

    public mutating func pop() -> T? {
        guard !elements.isEmpty else { return nil }
        return elements.removeLast()
    }

    public var top: T? {
        return elements.last
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public var count: Int {
        return elements.count
    }
}
