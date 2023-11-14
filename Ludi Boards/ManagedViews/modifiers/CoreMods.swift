//
//  CoreMods.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

extension View {
    func dragger() -> some View {
        self.modifier(lbDragger())
    }
    
    func enableMVT(viewId: String="") -> some View {
        self.modifier(enableManagedViewTool(viewId: ""))
    }
}
