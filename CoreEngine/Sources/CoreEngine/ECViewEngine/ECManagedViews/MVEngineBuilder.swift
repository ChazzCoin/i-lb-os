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
        public static func GenreBuilder(for genre: String, in type: String, as subtype: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> some View {
            switch genre {
                case "nav": EmptyText()
                case "tool": ViewEngine.ToolBuilder(in: type, as: subtype, viewId: viewId, activityId: activityId, bounds: bounds)
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
                case .pool(let poolTool): poolTool.Build(viewId: viewId, activityId: activityId)
                default: EmptyText()
            }
        }
        @ViewBuilder
        public static func ToolBuilder(in type: String, as subtype: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> some View {
            switch type {
            case "general": ViewEngine.Tool.GeneralTool.Build(name: subtype, viewId: viewId, activityId: activityId, bounds: bounds)
                case "shape": ViewEngine.Tool.ShapeTool.Build(name: subtype, viewId: viewId, activityId: activityId)
                case "soccer": ViewEngine.Tool.SoccerTool.Build(name: subtype, viewId: viewId, activityId: activityId, bounds: bounds)
                case "pool": ViewEngine.Tool.PoolBallTool.Build(name: subtype, viewId: viewId, activityId: activityId, bounds: bounds)
                case "tactic": ViewEngine.Tool.SmartTool.Build(name: subtype, viewId: viewId, activityId: activityId, bounds: bounds)
                default: EmptyText()
            }
        }
        
        public enum Tool {
            case general(GeneralTool)
            case shape(ShapeTool)
            case soccer(SoccerTool)
            case pool(PoolBallTool)
            
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
                // Player subtypes render as the redesign jersey disc (TASK-004);
                // equipment subtypes keep their asset images.
                static let playerSubtypes: Set<String> = [
                    "tools_soccer_jersey", "tools_soccer_dummy",
                    "tools_soccer_running", "tools_soccer_walking", "tools_soccer_steps"
                ]
                public func Build(viewId: String, activityId: String) -> AnyView {
                    SoccerTool.Build(name: self.name, viewId: viewId, activityId: activityId)
                }
                public static func Build(name: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> AnyView {
                    if playerSubtypes.contains(name) {
                        return AnyView(ManagedViewTool(viewId: viewId, activityId: activityId, bounds: bounds) {
                            SoccerPlayerToolView(viewId: viewId)
                        })
                    }
                    return AnyView(ManagedViewTool(viewId: viewId, activityId: activityId, bounds: bounds) {
                        Image(name).resizable()
                    })
                }
                public func toArray() -> [any ToolCategory] {
                    Array(SoccerTool.allCases)
                }
            }
            
            public enum PoolBallTool: String, ToolCategory {
                
                case solid1 = "1"
                case solid2 = "2"
                case solid3 = "3"
                case solid4 = "4"
                case solid5 = "5"
                case solid6 = "6"
                case solid7 = "7"
                case stripe9 = "9"
                case stripe10 = "10"
                case stripe11 = "11"
                case stripe12 = "12"
                case stripe13 = "13"
                case stripe14 = "14"
                case stripe15 = "15"
                case eightBall = "8"
                case que = "0"
                public var id: String { self.rawValue }
                public var name: String { rawValue }
                
                public var genre: String { "tool" }
                public var type: String { "pool" }
                
                public var displayName: String {
                    self.rawValue.split(separator: "_").map { "\($0)".capitalized }.joined(separator: " ").substring(from: 5)
                }
                public func BuildIcon() -> AnyView {
                    AnyView(PoolBallIcon(ballType: self))//.frame(width: 30, height: 30)
                }
                public func Build(viewId: String, activityId: String) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId) {
                        Image(self.name).resizable()
                    })
                }
                public static func Build(name: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId, bounds: bounds) {
                        Image(name).resizable()
                    })
                }
                public func toArray() -> [any ToolCategory] {
                    Array(PoolBallTool.allCases)
                }
                
                public var color: SwiftUI.Color {
                    switch self {
                        case .que: return .white
                        case .solid1, .stripe9:
                            return .yellow
                        case .solid2, .stripe10:
                            return .blue
                        case .solid3, .stripe11:
                            return .red
                        case .solid4, .stripe12:
                            return .purple
                        case .solid5, .stripe13:
                            return .orange
                        case .solid6, .stripe14:
                            return .green
                        case .solid7, .stripe15:
                            return .purple.opacity(0.75)
                        case .eightBall:
                            return .black
                    }
                }
                
                public var number: Int {
                    return Int(self.rawValue) ?? 0
                }
                
                public var stripeColor: SwiftUI.Color {
                    return self.number > 8 ? .white : .clear
                }
            }
            
            // Smart Tools (tactical) — Tier 1. All cases render through the one
            // `SmartToolManaged` dispatcher, which reads the concrete subToolType
            // from the tool's ManagedView and draws in absolute board space.
            public enum SmartTool: String, ToolCategory {
                case passArrow     = "tactic_pass_arrow"
                case runArrow      = "tactic_run_arrow"
                case dribbleArrow  = "tactic_dribble_arrow"
                case curveArrow    = "tactic_curve_arrow"
                case overlapRun    = "tactic_overlap_run"
                case zoneRect      = "tactic_zone_rect"
                case distanceTool  = "tactic_distance_tool"
                case offsideLine   = "tactic_offside_line"
                case angleTool     = "tactic_angle_tool"
                case spotlight     = "tactic_spotlight"
                case focusRing     = "tactic_focus_ring"
                case agilityLadder = "tactic_agility_ladder"
                case statBadge     = "tactic_stat_badge"

                public var id: String { rawValue }
                public var name: String { rawValue }
                public var genre: String { "tool" }
                public var type: String { "tactic" }

                public var displayName: String {
                    switch self {
                    case .passArrow:     return "Pass Arrow"
                    case .runArrow:      return "Run Arrow"
                    case .dribbleArrow:  return "Dribble"
                    case .curveArrow:    return "Curved Pass"
                    case .overlapRun:    return "Overlap Run"
                    case .zoneRect:      return "Zone"
                    case .distanceTool:  return "Distance"
                    case .offsideLine:   return "Offside Line"
                    case .angleTool:     return "Angle"
                    case .spotlight:     return "Spotlight"
                    case .focusRing:     return "Focus Ring"
                    case .agilityLadder: return "Ladder"
                    case .statBadge:     return "Stat Badge"
                    }
                }
                public var icon: String {
                    switch self {
                    case .passArrow:     return "arrow.up.right"
                    case .runArrow:      return "arrow.up.forward"
                    case .dribbleArrow:  return "scribble.variable"
                    case .curveArrow:    return "arrow.turn.up.right"
                    case .overlapRun:    return "arrow.uturn.up"
                    case .zoneRect:      return "rectangle.dashed"
                    case .distanceTool:  return "ruler"
                    case .offsideLine:   return "flag.checkered"
                    case .angleTool:     return "angle"
                    case .spotlight:     return "rays"
                    case .focusRing:     return "scope"
                    case .agilityLadder: return "ladder"
                    case .statBadge:     return "gauge"
                    }
                }
                public func BuildIcon() -> AnyView {
                    AnyView(Image(systemName: icon).font(.system(size: 18, weight: .medium)))
                }
                public func Build(viewId: String, activityId: String) -> AnyView {
                    AnyView(SmartToolManaged(viewId: viewId, activityId: activityId))
                }
                public static func Build(name: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> AnyView {
                    AnyView(SmartToolManaged(viewId: viewId, activityId: activityId))
                }
                public func toArray() -> [any ToolCategory] { Array(SmartTool.allCases) }
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
                case message = "message"
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
                public static func Build(name: String, viewId: String, activityId: String, bounds: CGRect?=nil) -> AnyView {
                    AnyView(ManagedViewTool(viewId: viewId, activityId: activityId, bounds: bounds) {
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
