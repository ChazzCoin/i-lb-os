//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/20/24.
//

import Foundation
import SwiftUI

public typealias Icons = CoreName.Icons

public extension CoreName {
    
    class Icons {
        
        @ViewBuilder
        public static func SystemIcon(icon: CoreName.Icons.System) -> some View {
            Image(systemName: icon.name)
        }
        
        public enum System: String, CaseIterable {
            case airplane = "airplane"
            case alarm = "alarm"
            case arrowClockwise = "arrow.clockwise"
            case arrowCounterclockwise = "arrow.counterclockwise"
            case arrowDownDoc = "arrow.down.doc"
            case arrowLeft = "arrow.left"
            case arrowRight = "arrow.right"
            case arrowUp = "arrow.up"
            case bell = "bell"
            case bolt = "bolt"
            case book = "book"
            case bookmark = "bookmark"
            case calendar = "calendar"
            case camera = "camera"
            case car = "car"
            case cart = "cart"
            case checkmark = "checkmark"
            case chevronLeft = "chevron.left"
            case chevronRight = "chevron.right"
            case circle = "circle"
            case clock = "clock"
            case cloud = "cloud"
            case creditcard = "creditcard"
            case deleteLeft = "delete.left"
            case doc = "doc"
            case envelope = "envelope"
            case exclamationmark = "exclamationmark"
            case eye = "eye"
            case film = "film"
            case flame = "flame"
            case gear = "gear"
            case heart = "heart"
            case house = "house"
            case magnifyingglass = "magnifyingglass"
            case map = "map"
            case mic = "mic"
            case moon = "moon"
            case paperplane = "paperplane"
            case pencil = "pencil"
            case person = "person"
            case phone = "phone"
            case photo = "photo"
            case plus = "plus"
            case printer = "printer"
            case scissors = "scissors"
            case squareAndArrowUp = "square.and.arrow.up"
            case trash = "trash"
            case wifi = "wifi"
            case wrench = "wrench"
            case xmark = "xmark"
            case app = "app"
            case arrowUpBin = "arrow.up.bin"
            case arrowUpLeftAndArrowDownRight = "arrow.up.left.and.arrow.down.right"
            case at = "at"
            case battery100 = "battery.100"
            case bicycle = "bicycle"
            case binoculars = "binoculars"
            case boltShield = "bolt.shield"
            case bookClosed = "book.closed"
            case bookmarkCircle = "bookmark.circle"
            case briefcase = "briefcase"
            case bubbleMiddleBottom = "bubble.middle.bottom"
            case bubbleMiddleTop = "bubble.middle.top"
            case buildingColumns = "building.columns"
            case cameraRotate = "camera.rotate"
            case cameraShutterButton = "camera.shutter.button"
            case carFill = "car.fill"
            case cartFill = "cart.fill"
            case chartPie = "chart.pie"
            case checkmarkCircle = "checkmark.circle"
            case chevronDown = "chevron.down"
            case chevronUp = "chevron.up"
            case cloudDrizzle = "cloud.drizzle"
            case cloudFog = "cloud.fog"
            case cloudHail = "cloud.hail"
            case cloudHeavyrain = "cloud.heavyrain"
            case cloudMoon = "cloud.moon"
            case cloudRain = "cloud.rain"
            case cloudSnow = "cloud.snow"
            case cloudSun = "cloud.sun"
            case command = "command"
            case cpu = "cpu"
            case creditcardCircle = "creditcard.circle"
            case crop = "crop"
            case cube = "cube"
            case cursorArrowRays = "cursor.arrow.rays"
            case cursorArrow = "cursor.arrow"
            case desktopcomputer = "desktopcomputer"
            case dialMax = "dial.max"
            case dialMin = "dial.min"
            case display = "display"
            case dotRadiowavesLeftAndRight = "dot.radiowaves.left.and.right"
            case ear = "ear"
            public var name: String { rawValue }
        }
    }
    
}
