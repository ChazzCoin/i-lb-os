//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/7/24.
//

import Foundation
import SwiftUI


extension View {
    
    func enableManagedViewBasic(viewId: String, activityId: String="") -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, activityId: activityId))
    }
    
    func enableDynaView(viewId: String, activityId: String="") -> some View {
        self.modifier(enableDynaNavStackModifier(viewId: viewId, activityId: activityId))
    }
}
