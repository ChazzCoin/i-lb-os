//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI


@ViewBuilder
public func ZStackReader<Content: View>(@ViewBuilder viewBuilder: @escaping (GeometryProxy) -> Content) -> some View {
    ZStack {
        GeometryReader { geo in
            viewBuilder(geo)
        }
    }
}
@ViewBuilder
public func VStackReader<Content: View>(@ViewBuilder viewBuilder: @escaping (GeometryProxy) -> Content) -> some View {
    VStack {
        GeometryReader { geo in
            viewBuilder(geo)
        }
    }
}

//@available(iOS 16.0, *)
//public extension Layout {
//    
//    func childWidth() {
//        self.onPreferenceChange(WidthPreferenceKey.self) { width in print(width) }
//    }
//}

@ViewBuilder
public func HScroll<Content: View>(@ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
    ScrollView(.horizontal) { HStack { viewBuilder() } }
}
@ViewBuilder
public func VScroll<Content: View>(@ViewBuilder viewBuilder: @escaping () -> Content) -> some View {
    ScrollView(.vertical) { VStack { viewBuilder() } }
}



