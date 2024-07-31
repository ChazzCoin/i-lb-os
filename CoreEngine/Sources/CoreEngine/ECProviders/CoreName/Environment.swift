//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/20/24.
//

import Foundation

public typealias CN = CoreName
public typealias Env = CoreName.Environments

public extension CoreName {

    enum Environments: String, CaseIterable {
        case colorScheme = "colorScheme"
        case locale = "locale"
        case calendar = "calendar"
        case timeZone = "timeZone"
        case layoutDirection = "layoutDirection"
        case sizeCategory = "sizeCategory"
        case presentationMode = "presentationMode"
        case managedObjectContext = "managedObjectContext"
        case isEnabled = "isEnabled"
        case isVisible = "isVisible"
        case displayScale = "displayScale"
        case pixelLength = "pixelLength"
        case imageScale = "imageScale"
        case font = "font"
        case multilineTextAlignment = "multilineTextAlignment"
        case truncationMode = "truncationMode"
        case lineSpacing = "lineSpacing"
        case allowsTightening = "allowsTightening"
        case lineLimit = "lineLimit"
        case minimumScaleFactor = "minimumScaleFactor"
        case undoManager = "undoManager"
        case accessibilityDifferentiateWithoutColor = "accessibilityDifferentiateWithoutColor"
        case accessibilityReduceTransparency = "accessibilityReduceTransparency"
        case accessibilityReduceMotion = "accessibilityReduceMotion"
        case accessibilityInvertColors = "accessibilityInvertColors"
        case accessibilityOnOffLabels = "accessibilityOnOffLabels"
        case accessibilityEnabled = "accessibilityEnabled"
        case accessibilityShowButtonShapes = "accessibilityShowButtonShapes"
        case dynamicTypeSize = "dynamicTypeSize"
        case accessibleNavigation = "accessibleNavigation"
        public var name: String { rawValue }
    }

}
