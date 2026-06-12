//
//  WindowID.swift
//  CoreEngine
//
//  A normalized identifier for pooled NavStack / NodeStack windows.
//  Lowercases exactly once, at construction, so casing mismatches
//  ("mvSettings" vs "mvsettings") can never produce a silent no-op
//  window lookup. This is the single normalization point for window
//  identity — controllers key their pools by WindowID, never by raw
//  String.
//

import Foundation

public struct WindowID: Hashable, Equatable, CustomStringConvertible, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(_ value: String) { self.rawValue = value.lowercased() }
    public init(stringLiteral value: String) { self.rawValue = value.lowercased() }

    public var description: String { rawValue }
}

public extension String {
    /// Convenience: `"chat".windowID`. Lowercases at construction.
    var windowID: WindowID { WindowID(self) }
}
