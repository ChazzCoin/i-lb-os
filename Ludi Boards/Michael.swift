//
//  File.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/6/24.
//

import Foundation
import SwiftUI

/*
 Rules
 1. Everything is an Object. Classes, are Objects.
    - Classes are the object.
    - Variables are the references or holders of Classes/Objects.
    - Functions are the manipulators of Classes/Objects.
 
 2. Naming Schemes..
    - Classes start with Capital Letters.
    - Variables and Functions start with Lowercase Letters.
    - Bool/Boolean variables are named as a question to make the code more human readable.
        ex: if redzoneToggleIsEnabled {
                // true!
            }
    - Plural and Singular. The 's' is important...
        "redzone" -> should represent a single Redzone object.
        "redzones" -> should represent a list [Redzone] of objects.
 
 3. {} vs () vs []
    { } = a block of code.
    () = a function.
    [] = a data structure (list or dictionary)
 
 
 
 */

// 'Primitive' Object Types
let theBoolean : Bool = true
let theString : String = ""
let theNoDecimalInteger : Int = 0
let theDecimalInteger : Double = 0.0

// Data Structures, as they call them.
// These hold Objects in a List or a Key/Value based Dictionary.
let theArrayOrList : [String] = []
let theDictionaryOrMap : [String : String] = [:]

// Basic Class

class MichaelBasicClass {
    
    // var = Mutable Variables (think of this as a unlocked variable to change later)
    // or this is a Read and Write variable.
    var mutableVariable : String = "You can change this string value later with var."
    
    // let = Non-Mutable Variables (think of this as a locked variable you can not change later)
    // or this is a Read Only Variable.
    let unmutableVariable : String = "You can NOT change this string value later with let."
    
    
    // Function 1. Takes no input, returns no output. It simply does some work.
    func noInputOrOutputFunction() {
        self.mutableVariable = "I am changing the String value of this variable."
    }
    
    // Function 2. Takes a single input variable that is of Type String. It then does its work, returning no output.
    func inputNoOutputFunction(inputVariable : String) {
        self.mutableVariable = inputVariable
    }
    
    // Function 3. Takes a single input of type String, does work, returns a value of type String.
    func inputAndOutputFunction(inputVariable : String) -> String {
        
        let finalString = "The Input String says: \(inputVariable)"
        
        return finalString
    }
    
}


class MichaelIsGoingAdvanced : MichaelBasicClass {
    
    let randomlyNamedVariable : String = "This class is a 'Child' class that 'inherits' every not private variable and function from its 'Parent' Class (aka, MichaelSucks)."
    
    // This is a 'computed' variable. 
    // Kind of like a function and a variable hybrid where its a 'variable' in how you use it... but when used, it will run the block of code, which
    var usingMichaelSucks : String {
        let finalOutput = "Fucking hell" + mutableVariable // <- im using the parent's variable here.
        return finalOutput
    }
    
    // This is a function, that takes another function as an Input, then will run the function within itself.
    // I only show this, because
    // 1. You are already doing this, unknowningly.
    // 2. This is an extremely powerful function and this example in no way shows its use cases.
    func aHigherOrderFunction(inputFunction : () -> Void) {
        inputFunction()
    }
    
}

// We're going deeper...

/*
 Threading 101
 
 Just follow me for a moment.
 
 1. A thread is a single order of operations.
    - Or. A thread is a single worker who can only do one job at a time.
    - Like a person who can build a single car at a time. If you need two cars at once, you need two threads, each one building a car at the same time.
    - One single thread can only build one car at one time. End of story.
    
 2. Code naturally runs from Top to Bottom. All code starts and runs on a 'Single Thread'.
    - This is called 'Synchronous' coding as the Thread starts at the top of a file or class/view, and runs down the lines of code. It will never go back up or skip around. Top. To. Bottom. Only.
    - Like a function, the code executes the first line in the function and goes down the lines in order, every single time. This is synchronous. (it never runs from bottom up..)

 2. The 'Main' Thread I always talk about, is a 'single' thread that can only do 1 job at a time.
    - The Main Thread is what starts and runs an app.
    - Anything you want to do in the background, like loading Redzones from Firebase into Realm, needs to be done on its own thread.
    - You create a new/second Thread and you tell it to do this Loading of the Redzones and then 'sync' it back into the Main Thread when ready.
        (this thread creation and switching is kind of built into Swift and is happening for you most of the time. This is way less friendly in android)
    - If you download a song from the internet, it might take a minute to download and finish. This means the single Thread running the download job can do nothing else.
    - SO. If you download a song on the Main Thread, the app can do nothing else. The user is locked from using the app under the Main Thread has finished the job (aka, downloading the song).
    - Because, threads can only do 1 job at a time.
 
 3. The idea that you start new threads and run jobs 'in the background' is called 'Asynchronous' or Multi-Threading.
 
 4. As an example, when you 'breakpoint' on a line of code, you are pausing a single thread. The thread running that line of code.
 */

// Main Thread example.

func threadingExampleFunction() {
    
    /*
     
        DispatchQueue -> is a 'thread manager' it creates, destroys and manages a threads job.
     
        Think about it like this, it is a Queue of Jobs that are being Dispatched to Threads to be run.
        
        DispatchQueue is also... yep, you guessed it, AN OBJECT!!!
     
     */
    
    
    // 1. main : you want to run a job on the 'main' thread.
    // 2. async : you can do async, or sync.
    //      - 'async' means, once the main thread is 'free' and not running a job, take this code and run it on the main thread. (i only use this)
    //      - 'sync' means, do not wait, stop whatever job is running on the main thread and immediately run this code, NOW! (don't use this, its dangerous)
    DispatchQueue.main.async {
        // This is where you'd update the UI/Screen.
        let aNewVariableOnMain = "doing some work on the main thread!!"
    }
    
    // 1. global(qos: .background) : long story short, you want to run this code/job on a background thread. Not the main thread.
    // This code will never 'sync' back in with the main thread, it just does its job silently in the background and dies.
    DispatchQueue.global(qos: .background).async {
        // This is where you'd download a song or do something that might take awhile.
        let aNewVariableInTheBackground = "doing some work in the background!!"
    }
    
    // Running a job in the background, then syncing back up with Main
    DispatchQueue.global(qos: .background).async {
        // We're in the background...
        let aNewVariableInTheBackground = "doing some work in the background!!"
        
        DispatchQueue.main.async {
            // Now we're on the main thread...
            let aNewVariableOnMain = "doing some work on the main thread after \(aNewVariableInTheBackground)"
        }
        
    }
    
}


/*
 The 'Real-Time' Parser
 
 Two Databases.
 
 1. Realm -> Data on the Device.
 2. Firebase -> Data in the Cloud.
 
 A. We call Firebase to get data.
 B. Firebase returns a 'snapshot' of the data that comes in the form of JSON/Dictionary.
 C. We need to take this snapshot data and 'parse' or convert the JSON/Dictionary into a Realm Object.
 D. We then take the new Realm Object and save it into Realm.
 
 Long story short, the parser will take a 'snapshot' and the Class/Object Type of the realm object 'Redzone.self' and convert the SnapShot into a RedZone.
 
 snapshot.toSectorObjects(Redzone.self) -> this Returns [Redzone] a list of redzones...
 
 I created an 'extension' that gives the snapshot object a new function to use called 'toSectorObjects' which you give it a Realm Object Type and itll convert the snapshot into a list of the Realm Type you give it.
 
 Realm has no idea what a snapshot is, or what a dictionary is.
 
 This is formally called 'Serialization / Deserialization'
 
 The base idea is, i have data of Type X and i need the data to be of Type Y... so you 'parse' the data into another type.
 */
