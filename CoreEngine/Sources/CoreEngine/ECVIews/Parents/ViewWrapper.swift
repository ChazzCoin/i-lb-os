//
//  ViewWrapper.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

public struct ViewWrapper<Content: View>: Identifiable {
    public let id: UUID
    @ViewBuilder public let viewHolder: () -> Content

    public init(id: UUID = UUID(), @ViewBuilder viewHolder: @escaping () -> Content) {
        self.id = id
        self.viewHolder = viewHolder
    }
    
    public func view() -> () -> Content { return viewHolder }
}
