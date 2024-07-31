//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI



public class PanelViewFactory {
    
    public static func view(_ panel: CoreName.Views.Panel, title: String, subtitle: String) -> (any ObservablePanel)? {
        switch panel {
            case .mode: return PanelModeController(title: title, subTitle: subtitle)
            default: return nil
        }
    }
    
}

