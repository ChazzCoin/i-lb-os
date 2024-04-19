//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/16/24.
//

import Foundation
import SwiftUI


public struct HList<Content: View>: View {
    public let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var w: Double? = nil
    public var h: Double? = nil
    public init(@ViewBuilder content: () -> Content, width: Double, height: Double) {
        self.content = content()
        self.w = width
        self.h = height
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                content
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .solBackground()
    }
    
}

public struct VList<Content: View>: View {
    public let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var w: Double? = nil
    public var h: Double? = nil
    public init(@ViewBuilder content: () -> Content, width: Double, height: Double) {
        self.content = content()
        self.w = width
        self.h = height
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                content
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .solBackground()
    }
    
}
