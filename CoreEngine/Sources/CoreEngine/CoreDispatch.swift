//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension DispatchQueue {
    
    
    static func executeAfter(seconds: TimeInterval, on queue: DispatchQueue = .main, action: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + seconds, execute: action)
    }
    
    func delay(_ delay: TimeInterval, execute: @escaping () -> Void) {
        let deadline = DispatchTime.now() + delay
        self.asyncAfter(deadline: deadline, execute: execute)
    }
    
    static func delayInBackground(_ delay: TimeInterval, backgroundBlock: @escaping () -> Void, mainBlock: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            backgroundBlock()

            DispatchQueue.main.async {
                mainBlock()
            }
        }
    }
}


public func delayThenMain(_ delay: TimeInterval, backgroundBlock: @escaping () -> Void, mainBlock: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
        backgroundBlock()

        DispatchQueue.main.async {
            mainBlock()
        }
    }
}

public func delayThenMain(_ delay: TimeInterval, mainBlock: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
        DispatchQueue.main.async {
            mainBlock()
        }
    }
}
