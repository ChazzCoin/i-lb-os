//
//  CanvasObject.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/26/26.
//
import Foundation
import SwiftUI

public class CoreCanvasControl: ObservableObject {
    
    public init() {}
    
    @AppStorage("showMenuBar", store: UserDefaults(suiteName: "worlds")) public var showMenuBar: Bool = true
    @AppStorage("toolBarPickerWindowIsVisible", store: UserDefaults(suiteName: "worlds")) public var toolBarPickerWindowIsVisible: Bool = false
    @AppStorage("boardSettingsWindowIsVisible", store: UserDefaults(suiteName: "worlds")) public var boardSettingsWindowIsVisible: Bool = false
    @AppStorage("mvSettingsWindowIsVisible", store: UserDefaults(suiteName: "worlds")) public var mvSettingsWindowIsVisible: Bool = false
    
    @AppLifecycle(.appDidEnterBackground) public var appDidEnterBackground: Bool
    @AppStorage("gesturesAreLocked", store: UserDefaults(suiteName: "worlds")) public var gesturesAreLocked: Bool = false
    @AppStorageCGFloat("canvasWidth") public var canvasWidth: CGFloat = 8000.0
    @AppStorageCGFloat("canvasHeight") public var canvasHeight: CGFloat = 8000.0
    @AppStorageCGPoint("canvasOffset") public var canvasOffset = CGPoint(x: 6000, y: 6000)
    @AppStorageCGFloat("canvasScale") public var canvasScale: CGFloat = 0.1
    @AppStorageCGFloat("canvasRotation") public var canvasRotation: CGFloat = 0.0
    @GestureState public var gestureScale: CGFloat = 1.0
    @AppStorageCGFloat("lastScaleValue") public var lastScaleValue: CGFloat = 1.0
    @AppStorageAngle("angle") public var angle: Angle = .zero
    @AppStorageAngle("lastAngle") public var lastAngle: Angle = .zero
    
    @AppStorageCGPoint("dropPosition") public var dropPosition = CGPoint.zero
    @AppStorageDictionary("coordinates") public var coordinates: [String: Any]
    
    @AppStorageCGPoint("translation") public var translation: CGPoint = CGPoint(x: 6000, y: 6000)
    @AppStorageCGPoint("lastOffset") public var lastOffset = CGPoint(x: 6000, y: 6000)
    @AppStorage("isDragging", store: UserDefaults(suiteName: "worlds")) public var isDragging: Bool = false
    @AppStorageCGPoint("position") public var position = CGPoint(x: 0, y: 0)
    
    @AppStorage("masterResetCanvas") public var masterResetCanvas: Bool = false
    public func masterResetTheCanvas() {
        self.masterResetCanvas = true
        self.masterResetCanvas = false
    }
    
    public var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
}
