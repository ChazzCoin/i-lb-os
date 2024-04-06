//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension CGFloat {
    
    func bounded(byMin minValue: CGFloat, andMax maxValue: CGFloat) -> CGFloat {
        return Swift.max(Swift.min(self, maxValue), minValue)
    }
    
}
