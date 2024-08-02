//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import SwiftUI


public protocol ObservablePanel: ObservableObject {
    init(title: String, subtitle: String)
}
public typealias ViewEngine = CoreName.ViewEngine
public typealias VEngine = CoreName.ViewEngine

public protocol ToolCategory: Identifiable, Hashable, CaseIterable where Self: RawRepresentable, Self.RawValue == String {
    var genre: String { get }
    var type: String { get }
    var name: String { get }
    var displayName: String { get }
    func BuildIcon() -> AnyView
    func Build(viewId: String, activityId: String) -> AnyView
    func toArray() -> [any ToolCategory]
}


public struct ToolListView: View {
    
    @AppStorage("currentActivityId") var currentActivityId: String = ""
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                HStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
    //                    .foregroundColor(getForegroundColor(colorScheme))
                        .padding()
                        .padding(.top)
                        .padding(.leading)
                        .onTapAnimation {
                            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "toolbox", viewAction: WindowAction.close))
                        }
                    Spacer()
                }.frame(height: 50)
                ToolList(title: "Smart Shapes", forEachContent: {
                    ForEach(ViewEngine.Tool.ShapeTool.allCases, id: \.self) { tool in
                        ToolListItem(currentActivityId, tool: tool)
                    }
                })
                ToolList(title: "General", forEachContent: {
                    ForEach(ViewEngine.Tool.GeneralTool.allCases, id: \.self) { tool in
                        ToolListItem(currentActivityId, tool: tool)
                    }
                })
                ToolList(title: "Soccer", forEachContent: {
                    ForEach(ViewEngine.Tool.SoccerTool.allCases, id: \.self) { tool in
                        ToolListItem(currentActivityId, tool: tool)
                    }
                })
                Spacer()
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.90, maxHeight: 300)
        .solBackground()
    }
}
@ViewBuilder
public func ToolListItem(_ activityId: String, tool: any ToolCategory) -> some View {
    VStack {
        tool.BuildIcon()
        Text(tool.displayName).font(.system(size: 8))
    }
    .onTapAnimation {
        print("On Tap! \(tool.name)")
        var tempId = ""
        FusedTools.fusedCreator(ManagedView.self) { r in
            let newTool = ManagedView()
            newTool.toolType = tool.type
            newTool.subToolType = tool.name
            newTool.sport = tool.genre
            newTool.boardId = activityId
            tempId = newTool.id
            return newTool
        }
        CodiChannel.TOOL_ON_CREATE.send(value: tempId)
    }
}
@ViewBuilder
public func ToolList<V:View>(title: String, @ViewBuilder forEachContent: () -> V) -> some View {
    LazyVStack {
        HStack {
            Text(title)
            Spacer().padding()
        }
        .padding(.leading)
        BorderedView(color: .AIMYellow) {
            ScrollView(.horizontal) {
                LazyHStack {
                    forEachContent()
                }
            }.frame(minHeight: 50)
        }
        .padding(.leading)
        .padding(.trailing)
    }
}

@available(*, deprecated, renamed: "ToolList", message: "Deprecated for ToolList")
public struct ToolPicker<Content: View>: View {
    public let content: Content
    @AppStorage("toolBarIsShowing") public var toolBarIsShowing: Bool = false
    @Environment(\.colorScheme) public var colorScheme
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public let soccerTools = SoccerToolProvider.allCases
    
    @State public var gps = GlobalPositioningSystem(CoreNameSpace.local)
    
    public var sWidth = UIScreen.main.bounds.width
    public var sHeight = UIScreen.main.bounds.height

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(getForegroundColor(colorScheme))
                    .padding()
                    .onTapAnimation {
                        self.toolBarIsShowing = false
                    }
                
                
                BorderedView(color: .red) {
                    content
                }
                
                BorderedView(color: .AIMYellow) {
                    ForEach(soccerTools, id: \.self) { tool in
                        ToolButtonIcon(icon: SoccerToolProvider(subType: tool))
                    }
                }
                
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 75)
        .solBackground()
        
    }
    
}






public struct LineIconView: View {
    public init(isBgColor: Bool) {
        self.isBgColor = isBgColor
    }
    @State public var isBgColor: Bool
    @Environment(\.colorScheme) public var colorScheme
    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting point of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.5)

                // End point of the line
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.5)

                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(isBgColor ? getBackgroundColor(colorScheme) : getForegroundColor(colorScheme), lineWidth: 2)
        }
        .rotationEffect(Angle(degrees: 45))
        .aspectRatio(1, contentMode: .fit)
    }
}

public struct DottedLineIconView: View {
    
    public init() {}
    @Environment(\.colorScheme) public var colorScheme

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting and end points of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.5)
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.5)

                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(getForegroundColor(colorScheme), style: StrokeStyle(lineWidth: 2, dash: [5]))
        }
        .rotationEffect(Angle(degrees: 45))
        .aspectRatio(1, contentMode: .fit)
    }

}


public struct CurvedLineIconView: View {
    public init() {}
    @Environment(\.colorScheme) public var colorScheme

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Starting point of the line
                let startPoint = CGPoint(x: width * 0.1, y: height * 0.9)

                // Control points for curve
                let control1 = CGPoint(x: width * 0.3, y: height * 0.1)
                let control2 = CGPoint(x: width * 0.7, y: height * 0.1)

                // End point of the line
                let endPoint = CGPoint(x: width * 0.9, y: height * 0.9)

                path.move(to: startPoint)
                path.addCurve(to: endPoint, control1: control1, control2: control2)
            }
            .stroke(getForegroundColor(colorScheme), lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
