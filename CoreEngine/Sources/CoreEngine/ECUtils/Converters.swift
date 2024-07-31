//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import CoreGraphics

public extension Int {
    func toFloat() -> Float { return Float(self) }
    func toDouble() -> Double { return Double(self) }
    func toCGFloat() -> CGFloat { return CGFloat(self) }
}
public extension Double {
    func toInt() -> Int { return Int(self) }
    func toFloat() -> Float { return Float(self) }
    func toCGFloat() -> CGFloat { return CGFloat(self) }
}
public extension Float {
    func toInt() -> Int { return Int(self) }
    func toDouble() -> Double { return Double(self) }
    func toCGFloat() -> CGFloat { return CGFloat(self) }
}
public extension CGFloat {
    func toInt() -> Int { return Int(self) }
    func toFloat() -> Float { return Float(self) }
    func toDouble() -> Double { return Double(self) }
}
