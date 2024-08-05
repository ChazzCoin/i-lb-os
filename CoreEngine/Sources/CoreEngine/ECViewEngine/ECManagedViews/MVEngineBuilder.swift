//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/26/24.
//

import Foundation
import SwiftUI


public extension CoreName {
    
    class ViewEngine {
        
    // MARK: TOP GENRE LEVEL
        
        @ViewBuilder
        public static func GenreBuilder(for genre: Genre, viewId: String, activityId: String) -> some View {
            switch genre {
                case .nav(let navType):
                    buildNavView(navType)
                case .tool(let toolType):
                    buildToolView(toolType, viewId: viewId, activityId: activityId)
            }
        }
        
        @ViewBuilder
        public static func GenreBuilder(for genre: String, in type: String, as subtype: String, viewId: String, activityId: String) -> some View {
            switch genre {
                case "nav": EmptyText()
                case "tool": ViewEngine.ToolBuilder(in: type, as: subtype, viewId: viewId, activityId: activityId)
                default: EmptyText()
            }
        }
        
        public enum Genre {
            case nav(Nav)
            case tool(Tool)
            
           
        }
        
        // MARK: NAV LEVEL
        
        @ViewBuilder
        public static func buildNavView(_ navType: Nav) -> some View {
            switch navType {
                case .main(let mainType):
                    switch mainType {
                        case .chat: ChatView()
                    }
                case .sidebar(let sidebarType):
                    switch sidebarType {
                        case .buddyList: EmptyText()
                    }
                }
        }
        
        @ViewBuilder
        public static func NavBuilder(in type: String, as subtype: String) -> some View {
            switch type {
                case "main": EmptyText() // Main Builder
                case "sidebar": EmptyText() // Sidebar Builder
                default: EmptyText()
            }
        }
        
        public enum Nav {
            case main(Main)
            case sidebar(Sidebar)
            
            public enum Main {
                case chat
            }
            
            public enum Sidebar {
                case buddyList
            }
        }
        
        // MARK: TOOL LEVEL
        
        @ViewBuilder
        public static func buildToolView(_ toolType: Tool, viewId: String, activityId: String) -> some View {
            switch toolType {
                case .soccer(let soccerTool): soccerTool.Build(viewId: viewId, activityId: activityId)
                default: EmptyText()
            }
        }
        @ViewBuilder
        public static func ToolBuilder(in type: String, as subtype: String, viewId: String, activityId: String) -> some View {
            switch type {
                case "general": ViewEngine.Tool.GeneralTool.Build(name: subtype, viewId: viewId, activityId: activityId)
                case "shape": ViewEngine.Tool.ShapeTool.Build(name: subtype, viewId: viewId, activityId: activityId)
                case "soccer": ViewEngine.Tool.SoccerTool.Build(name: subtype, viewId: viewId, activityId: activityId)
                default: EmptyText()
            }
        }
        
        public enum Tool {
            case general(GeneralTool)
            case shape(ShapeTool)
            case soccer(SoccerTool)
            
//            @ViewBuilder
//            public static func BuildTool(subtype: String) -> some View {
//                Image(subtype).resizable()
//            }
//            
//            public func allSubcategories() -> [any ToolCategory] {
//                switch self {
//                    case .general: return GeneralTool.allCases as [any ToolCategory]
//                    case .shape: return ShapeTool.allCases as [any ToolCategory]
//                    case .soccer: return SoccerTool.allCases as [any ToolCategory]
//                }
//            }
//            
            // TOOLS
            
            public enum ShapeTool: String, ToolCategory {
                
                case line_straight = "line_straight"
                case line_dotted = "line_dotted"
                case line_curved = "line_curved"
                case circle = "circle"
                case square = "square"
                case triangle = "triangle"

                public var id: String { self.rawValue }
                public var name: String { rawValue }
                
                public var genre: String { "tool" }
                public var type: String { "shape" }
                
                public var displayName: String {
                    self.rawValue.capitalizedFirst
                }
                public func BuildIcon() -> AnyView {
                    switch self {
                        case .line_straight: AnyView(LineIconView(isBgColor: false).frame(width: 50, height: 50))
                        case .line_dotted: AnyView(DottedLineIconView().frame(width: 50, height: 50))
                        case .line_curved: AnyView(CurvedLineIconView().frame(width: 50, height: 50))
                        case .circle: AnyView(Circle().frame(width: 35, height: 35))
                        case .square: AnyView(Rectangle().frame(width: 35, height: 35))
                        case .triangle: AnyView(Triangle().frame(width: 35, height: 35))
                    }
                }
                public func Build(viewId: String, activityId: String) -> AnyView {
                    switch self {
                        case .line_straight: AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
                        case .line_dotted: AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
                        case .line_curved: AnyView(CurvedLineDrawingManaged(viewId: viewId, activityId: activityId))
                        case .circle: AnyView(CircleShapeManagedView(viewId: viewId, activityId: activityId))
                        case .square: AnyView(ShapeToolManaged(viewId: viewId, activityId: activityId, isQuad: true))
                        case .triangle: AnyView(ShapeToolManaged(viewId: viewId, activityId: activityId, isTriple: true))
                    }
                }
                public static func Build(name: String, viewId: String, activityId: String) -> AnyView {
                    switch name {
                        case ShapeTool.line_straight.name: AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
                        case ShapeTool.line_dotted.name: AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
                        case ShapeTool.line_curved.name: AnyView(CurvedLineDrawingManaged(viewId: viewId, activityId: activityId))
                        case ShapeTool.circle.name: AnyView(CircleShapeManagedView(viewId: viewId, activityId: activityId))
                        case ShapeTool.square.name: AnyView(ShapeToolManaged(viewId: viewId, activityId: activityId, isQuad: true))
                        case ShapeTool.triangle.name: AnyView(ShapeToolManaged(viewId: viewId, activityId: activityId, isTriple: true))
                        default: AnyView(EmptyText())
                    }
                    
                }
                public func toArray() -> [any ToolCategory] {
                    Array(ShapeTool.allCases)
                }
            }
           
            public enum SoccerTool: String, ToolCategory {
                
                case dummy = "tools_soccer_dummy"
                case jersey = "tools_soccer_jersey"
                case steps = "tools_soccer_steps"
                case walking = "tools_soccer_walking"
                case running = "tools_soccer_running"
                case goal = "tools_soccer_goal"
                case flagPole = "tools_soccer_flag"
                case tallCone = "tools_soccer_tall_cone"
                case shortCone = "tools_soccer_mat" // Check if this is correct as it seems like it should be shortCone
                case ladder = "tools_soccer_ladder"
                case soccerBall = "tools_soccer_soccer_ball"
                case curvedLine = "tools_soccer_curved_line"
                case dottedLine = "tools_soccer_dotted_line"
                public var id: String { self.rawValue }
                public var name: String { rawValue }
                
                public var genre: String { "tool" }
                public var type: String { "soccer" }
                
                public var displayName: String {
                    self.rawValue.split(separator: "_").map { "\($0)".capitalized }.joined(separator: " ").substring(from: 5)
                }
                public func BuildIcon() -> AnyView {
                    AnyView(Image(self.name).resizable().frame(width: 30, height: 30))
                }
                public func Build(viewId: String, activityId: String) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId) {
                        Image(self.name).resizable()
                    })
                }
                public static func Build(name: String, viewId: String, activityId: String) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId) {
                        Image(name).resizable()
                    })
                }
                public func toArray() -> [any ToolCategory] {
                    Array(SoccerTool.allCases)
                }
            }
            
            public enum GeneralTool: String, ToolCategory {
                
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
                
                public var genre: String { "tool" }
                public var type: String { "general" }
                
                public var id: String { rawValue }
                public var name: String { rawValue }
                public var displayName: String {
                    self.rawValue.split(separator: "_").map { "\($0)".capitalized }.joined(separator: " ")
                }
                public func BuildIcon() -> AnyView {
                    AnyView(Image(systemName: self.name).resizable().frame(width: 30, height: 30))
                }
                public func Build(viewId: String, activityId: String) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId) {
                        Image(systemName: self.name).resizable()
                    })
                }
                public static func Build(name: String, viewId: String, activityId: String) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId) {
                        Image(systemName: name).resizable()
                    })
                }
                public func toArray() -> [any ToolCategory] {
                    Array(GeneralTool.allCases)
                }
            }
        }
        
    }
    
    
}
