//
//  OShape.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct OShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addEllipse(in: rect)

        return path
    }
}
