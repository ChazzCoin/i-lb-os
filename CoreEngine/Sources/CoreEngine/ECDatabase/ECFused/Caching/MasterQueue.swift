//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/11/24.
//

import Foundation



public class MasterFusedQueue {
    
    public static func initializeQueues() {
        CoreUserQueue.initializeDatabaseQueue()
    }
    
    public static func runAllQueues() {
        if UserTools.userIsVerifiedForFirebaseRequest() {
            CoreUserQueue.processFullQueue()
        }
        
    }
    
    
}

