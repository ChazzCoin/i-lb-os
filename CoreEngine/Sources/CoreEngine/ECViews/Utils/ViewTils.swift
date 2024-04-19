//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation
import SwiftUI


public extension View {
    
    // MARK: -> Works!
    func measureSize(sizeResult: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.onAppear() {
                    print("Measured Size: \(geometry.size)")
                    sizeResult(geometry.size)
                }
            }
        )
    }
    func measure(_ geoResult: @escaping (GeometryProxy) -> Void) -> some View {
        background( GeometryReader { geometry in Color.clear.onAppear() { geoResult(geometry) } } )
    }

}
