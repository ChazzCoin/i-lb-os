//
//  Extensions.swift
//  CoreEngine
//
//  Created by Charles Romeo on 2/4/26.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
