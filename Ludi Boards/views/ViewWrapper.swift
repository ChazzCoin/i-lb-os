//
//  ViewWrapper.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

// Define a wrapper for your view closures
struct ViewWrapper: Identifiable {
    let id: UUID
    let viewClosure: () -> AnyView

    init(id: UUID = UUID(), viewClosure: @escaping () -> AnyView) {
        self.id = id
        self.viewClosure = viewClosure
    }

    func view() -> AnyView {
        viewClosure()
    }
}
