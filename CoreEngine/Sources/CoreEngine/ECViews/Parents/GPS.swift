//
//  GlobalPositioning.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import Combine

public extension View {
    
    func position(using gps: GlobalPositioningSystem, at area: ScreenArea, with geo: GeometryProxy?, safePadding: Bool = false) -> some View {
        guard let g = geo else {
            let coordinate = gps.getCoordinate(for: area)
            return self.position(x: coordinate.x, y: coordinate.y)//.animation(.easeInOut, value: coordinate)
        }
        let coordinate = gps.getGlobalCoordinate(for: area, geo: g, safePadding: safePadding)
        return self.position(x: coordinate.x, y: coordinate.y)//.animation(.easeInOut, value: coordinate)
    }
    
    func position(using gps: GlobalPositioningSystem, at area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> some View {
        let coordinate = gps.getCoordinate(for: area, offsetX: offsetX, offsetY: offsetY)
        return self.position(x: coordinate.x, y: coordinate.y).animation(.easeInOut, value: coordinate)
    }

    // Method to set the offset of the view based on a specified ScreenArea
    func offset(using gps: GlobalPositioningSystem, for area: ScreenArea) -> some View {
        let offsetSize = gps.getOffset(for: area)
        return self.offset(x: offsetSize.width, y: offsetSize.height)
    }
    
    func moveTo(using gps: GlobalPositioningSystem, from startArea: ScreenArea, to endArea: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0, animation: Animation = .spring()) -> some View {
        self.position(
                x: gps.getCoordinate(for: endArea, offsetX: offsetX, offsetY: offsetY).x,
                y: gps.getCoordinate(for: endArea, offsetX: offsetX, offsetY: offsetY).y
            ).animation(animation, value: gps.getCoordinate(for: startArea))
    }
}

public enum ScreenArea : String, CaseIterable {
    case center = "center"
    case topRight = "topRight"
    case topLeft = "topLeft"
    case bottomRight = "bottomRight"
    case bottomLeft = "bottomLeft"
    case bottomCenter = "bottomCenter"
    case topCenter = "topCenter"
    case centerRight = "centerRight"
    case centerLeft = "centerLeft"
    public var name: String { rawValue }
}

public enum CoreNameSpace: String, CaseIterable {
    case global = "global"
    case canvas = "canvas"
    case board = "board"
    case local = "local"
    public var name: String { rawValue }
}

public struct GlobalPositioningZStack<Content: View>: View {
    let content: (GlobalPositioningSystem) -> Content
    @State var gps: GlobalPositioningSystem

    public init(coordinateSpace: String, @ViewBuilder content: @escaping (GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace)
    }
    public init(coordinateSpace: CoreNameSpace, @ViewBuilder content: @escaping (GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace)
    }
    public init(coordinateSpace: String, width: CGFloat, height: CGFloat, @ViewBuilder content: @escaping (GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace, customWidth: width, customHeight: height)
    }
    
    public var body: some View {
        ZStack {
            content(gps)
                .measure { g in
                    
                }
        }
        .coordinateSpace(name: gps.coordinateSpace)
        .frame(width: gps.effectiveSize.width, height: gps.effectiveSize.height)
//        .ignoresSafeArea(.all)
        .background(Color.clear)
    }
}

public struct GlobalPositioningReader<Content: View>: View {
    let content: (GeometryProxy, GlobalPositioningSystem) -> Content
    @State var gps: GlobalPositioningSystem

    public init(coordinateSpace: String, @ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace)
    }
    
    public init(coordinateSpace: CoreNameSpace, @ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace)
    }

    public init(coordinateSpace: String, width: CGFloat, height: CGFloat, @ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace, customWidth: width, customHeight: height)
    }
    public init(coordinateSpace: CoreNameSpace, width: CGFloat, height: CGFloat, @ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
        self.gps = GlobalPositioningSystem(coordinateSpace, customWidth: width, customHeight: height)
    }
    public var body: some View {
        GeometryReader { geo in
            content(geo, gps)
        }
        .coordinateSpace(name: gps.coordinateSpace)
        .frame(width: gps.effectiveSize.width, height: gps.effectiveSize.height)
        .ignoresSafeArea(.all)
        .background(Color.clear)
    }
}

public class GlobalPositioningSystem: ObservableObject {
    // Properties to store screen size, safe area insets, and optional custom dimensions
    @Published public var coordinateSpace: String
    @Published public var screenPaddingX: CGFloat = 0
    @Published public var screenPaddingY: CGFloat = 0
    @Published public var paddingAmount: CGFloat = 50
    @Published public var parentSize: CGSize?
    @Published public var screenSize: CGSize = UIScreen.main.bounds.size
    @Published public var safeAreaInsets: EdgeInsets = EdgeInsets()
    @Published public var safeAreaEmpty: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    @Published public var enablePadding: Bool = true

    // Initialization
    public init(_ coordinateSpace: String, customWidth: CGFloat? = nil, customHeight: CGFloat? = nil) {
        self.coordinateSpace = coordinateSpace
        if let width = customWidth, let height = customHeight {
            self.parentSize = CGSize(width: width, height: height)
        }
        updateScreenSizeAndInsets()
        BroadcastTools.addObserver(self, triggerFunction: #selector(updateScreenSizeAndInsets), notification: UIDevice.orientationDidChangeNotification)
    }
    public init(_ coordinateSpace: CoreNameSpace, customWidth: CGFloat? = nil, customHeight: CGFloat? = nil) {
        self.coordinateSpace = coordinateSpace.name
        if let width = customWidth, let height = customHeight {
            self.parentSize = CGSize(width: width, height: height)
        }
        updateScreenSizeAndInsets()
        BroadcastTools.addObserver(self, triggerFunction: #selector(updateScreenSizeAndInsets), notification: UIDevice.orientationDidChangeNotification)
    }
    @objc public func updateScreenSizeAndInsets() {
        if !self.enablePadding {
            
            return
        }
        main {
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }
            if let temp = scene as? UIWindowScene {
                if let w = temp.windows.first {
                    DispatchQueue.main.async {
                        self.screenSize = w.frame.size
                        let uiInsets = w.safeAreaInsets
                        self.safeAreaInsets = EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
                    }
                }
            }
        }
    }

    public var effectiveSize: CGSize { parentSize ?? screenSize }
    public var effectivePadding: EdgeInsets { enablePadding ? safeAreaInsets : safeAreaEmpty }
    public var effectivePad: CGFloat { enablePadding ? paddingAmount : 0.0 }
    
    public func resetPaddingToZero() {  self.safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) }
    public func setSafePadding(isOn: Bool) {
        if isOn == enablePadding { return }
        self.enablePadding = isOn
        if self.enablePadding {
            BroadcastTools.addObserver(self, triggerFunction: #selector(updateScreenSizeAndInsets), notification: UIDevice.orientationDidChangeNotification)
        } else {
            BroadcastTools.removeObserver(self)
        }
    }
    

//    @available(*, deprecated, renamed: "getGlobalCoordinate", message: "getGlobalCoordinate")
    public func getCoordinate(for area: ScreenArea, safePadding: Bool = true) -> CGPoint {
        let size = effectiveSize
        self.setSafePadding(isOn: safePadding)
        switch area {
            case .center: return CGPoint(x: size.width / 2, y: size.height / 2)
            case .topRight: return CGPoint(x: size.width - effectivePadding.trailing - screenPaddingX, y: effectivePadding.top + screenPaddingY)
            case .topLeft: return CGPoint(x: effectivePadding.leading + screenPaddingX, y: effectivePadding.top + screenPaddingY)
            case .bottomRight: return CGPoint(x: size.width - effectivePadding.trailing - screenPaddingX, y: size.height - effectivePadding.bottom - screenPaddingY)
            case .bottomLeft: return CGPoint(x: effectivePadding.leading + screenPaddingX, y: size.height - effectivePadding.bottom - screenPaddingY)
            case .bottomCenter: return CGPoint(x: size.width / 2, y: size.height - effectivePadding.bottom - screenPaddingY)
            case .topCenter: return CGPoint(x: size.width / 2, y: effectivePadding.top + screenPaddingY)
            case .centerRight: return CGPoint(x: (size.width / 2) - effectivePadding.trailing, y: size.height / 2)
            case .centerLeft: return CGPoint(x: (size.width / 2) + effectivePadding.leading, y: size.height / 2)
        }
    }
    
    @available(*, deprecated, renamed: "getGlobalCoordinate", message: "getGlobalCoordinate")
    public func getCoordinate(for area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0, safePadding: Bool = true) -> CGPoint {
        let size = effectiveSize
        self.setSafePadding(isOn: safePadding)
        switch area {
            case .center: return CGPoint(x: (size.width / 2) + offsetX, y: (size.height / 2) + offsetY)
            case .topRight: return CGPoint(x: size.width - effectivePadding.trailing - screenPaddingX - offsetX, y: effectivePadding.top + screenPaddingY + offsetY)
            case .topLeft: return CGPoint(x: effectivePadding.leading + offsetX, y: effectivePadding.top + screenPaddingY + offsetY)
            case .bottomRight: return CGPoint(x: size.width - effectivePadding.trailing - screenPaddingX - offsetX, y: size.height - effectivePadding.bottom - screenPaddingY - offsetY)
            case .bottomLeft: return CGPoint(x: effectivePadding.leading + offsetX, y: size.height - effectivePadding.bottom - offsetY)
            case .bottomCenter: return CGPoint(x: (size.width / 2) + offsetX, y: size.height - effectivePadding.bottom - offsetY)
            case .topCenter: return CGPoint(x: (size.width / 2) + offsetX, y: effectivePadding.top + screenPaddingY + offsetY)
            case .centerRight: return CGPoint(x: size.width - effectivePadding.trailing - screenPaddingX - offsetX, y: (size.height / 2) + offsetY)
            case .centerLeft: return CGPoint(x: effectivePadding.leading + offsetX, y: (size.height / 2) + offsetY)
        }
    }

    @available(*, deprecated, renamed: "getGlobalCoordinate", message: "getGlobalCoordinate")
    public func getOffset(for area: ScreenArea) -> CGSize {
        let size = effectiveSize
        switch area {
            case .center: return CGSize(width: size.width / 2, height: size.height / 2)
            case .topRight: return CGSize(width: size.width - effectivePadding.trailing, height: effectivePadding.top)
            case .topLeft: return CGSize(width: effectivePadding.leading, height: effectivePadding.top)
            case .bottomRight: return CGSize(width: size.width - effectivePadding.trailing, height: size.height - effectivePadding.bottom)
            case .bottomLeft: return CGSize(width: effectivePadding.leading, height: size.height - effectivePadding.bottom)
            case .bottomCenter: return CGSize(width: size.width / 2, height: size.height - effectivePadding.bottom)
            case .topCenter: return CGSize(width: size.width / 2, height: effectivePadding.top)
            case .centerRight: return CGSize(width: size.width - effectivePadding.trailing, height: size.height / 2)
            case .centerLeft: return CGSize(width: effectivePadding.leading, height: size.height / 2)
        }
    }
    
    // MARK: -> DON'T TOUCH
    public func getGlobalCoordinate(for area: ScreenArea, geo: GeometryProxy, safePadding: Bool = true) -> CGPoint {
        self.setSafePadding(isOn: safePadding)
        let baseX = calculateX(for: area, childWidth: geo.size.width)
        let baseY = calculateY(for: area, childHeight: geo.size.height)
        let adjustedX = min(max(baseX, effectivePad), effectiveSize.width - effectivePad)
        let adjustedY = min(max(baseY, effectivePad), effectiveSize.height - effectivePad)
        return CGPoint(x: adjustedX, y: adjustedY)
    }

    public func getGlobalCoordinate(for area: ScreenArea, childWidth: CGFloat, childHeight: CGFloat, safePadding: Bool = true) -> CGPoint {
        self.setSafePadding(isOn: safePadding)
        let baseX = calculateX(for: area, childWidth: childWidth)
        let baseY = calculateY(for: area, childHeight: childHeight)
        let adjustedX = min(max(baseX, effectivePad), effectiveSize.width - effectivePad)
        let adjustedY = min(max(baseY, effectivePad), effectiveSize.height - effectivePad)
        return CGPoint(x: adjustedX, y: adjustedY)
    }
    // MARK: -> DON'T TOUCH
    private func calculateX(for area: ScreenArea, childWidth: CGFloat) -> CGFloat {
        switch area {
            case .center, .topCenter, .bottomCenter: return (screenSize.width / 2)
            case .topRight, .bottomRight, .centerRight: return (screenSize.width - childWidth / 2)
            case .topLeft, .bottomLeft, .centerLeft: return (childWidth / 2)
        }
    }
    // MARK: -> DON'T TOUCH
    private func calculateY(for area: ScreenArea, childHeight: CGFloat) -> CGFloat {
        switch area {
            case .center, .centerRight, .centerLeft: return (screenSize.height / 2)
            case .bottomRight, .bottomLeft, .bottomCenter: return (screenSize.height - childHeight / 2)
            case .topRight, .topLeft, .topCenter: return (childHeight / 2)
        }
    }
}
