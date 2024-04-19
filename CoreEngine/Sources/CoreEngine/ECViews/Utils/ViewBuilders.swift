//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/16/24.
//

import Foundation
import SwiftUI




public typealias V = ViewTools

public struct TimedView<Content: View>: View {
    @Binding public var isVisible: Bool
    public let viewBuilder: () -> Content
    public let seconds: TimeInterval

    public init(_ isVisible: Binding<Bool>, seconds: TimeInterval = 2.0, @ViewBuilder viewBuilder: @escaping () -> Content) {
        self._isVisible = isVisible
        self.viewBuilder = viewBuilder
        self.seconds = seconds
    }

    public var body: some View {
        GeometryReader { _ in
            if isVisible { viewBuilder() }
        }
        .onAppear {
            // Create a timer that toggles `isVisible` every `interval` seconds
            Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { timer in
                // Toggle the visibility state
                self.isVisible.toggle()
            }
        }
    }
}


public class ViewTools {
    
    
    
    // MARK: Helpers
    @ViewBuilder
    public static func IsVisible<Content: View>(_ isVisible: Binding<Bool>, @ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
        if isVisible.wrappedValue { viewBuilder() }
    }
    
    @ViewBuilder
    public static func Timer<Content: View>(_ isVisible: inout Binding<Bool>, @ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
        if isVisible.wrappedValue {
            viewBuilder()
                .onAppear() {
                    delayThenMain(5, mainBlock: {
                        
                    })
                }
        }
    }
    
    // MARK: Navigation
    @ViewBuilder
    public static func LinkTo<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) -> NavigationLink<EmptyView, Content> {
        NavigationLink(destination: { viewBuilder() } ) { EmptyView() }
    }
    
    // MARK: Geometery Readers
    @ViewBuilder
    public static func GeoBox<Content: View>(width: Double = .infinity, height: Double = .infinity, @ViewBuilder viewBuilder: @escaping (GeometryProxy) -> Content) -> some View {
        GeometryReader { geo in viewBuilder(geo) }.frame(maxWidth: width, maxHeight: height)
    }
    @ViewBuilder
    public static func GeoBox<Content: View>(width: Double = .infinity, height: Double = .infinity, @ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
        GeometryReader { geo in viewBuilder() }.frame(maxWidth: width, maxHeight: height)
    }
    @ViewBuilder
    public static func GeoBox<Content: View>(_ visibility: Binding<Bool>, width: Double = .infinity, height: Double = .infinity, @ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
        if visibility.wrappedValue { GeometryReader { geo in viewBuilder() }.frame(maxWidth: width, maxHeight: height) }
    }
    
}





