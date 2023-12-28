//
//  DispatchQueue.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation



extension DispatchQueue {

    /// Executes a closure after a specified number of seconds.
    /// - Parameters:
    ///   - delay: The delay in seconds before executing the closure.
    ///   - execute: The closure to execute after the delay.
    func delay(_ delay: TimeInterval, execute: @escaping () -> Void) {
        let deadline = DispatchTime.now() + delay
        self.asyncAfter(deadline: deadline, execute: execute)
    }
    
    func delayInBackground(_ delay: TimeInterval, backgroundBlock: @escaping () -> Void, mainBlock: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            backgroundBlock()

            DispatchQueue.main.async {
                mainBlock()
            }
        }
    }
}

//func delay(_ delay: TimeInterval, execute: @escaping () -> Void) {
//    let deadline = DispatchTime.now() + delay
//    DispatchQueue.asyncAfter(deadline: deadline, execute: execute)
//}
func delayThenMain(_ delay: TimeInterval, backgroundBlock: @escaping () -> Void, mainBlock: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
        backgroundBlock()

        DispatchQueue.main.async {
            mainBlock()
        }
    }
}

func delayThenMain(_ delay: TimeInterval, mainBlock: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
        DispatchQueue.main.async {
            mainBlock()
        }
    }
}
