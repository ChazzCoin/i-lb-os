//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public typealias S = CoreName
public typealias SChannel = CoreName.Channels
public typealias SDateTime = CoreName.DateTime
public typealias SViews = CoreName.Views
public typealias SPanel = CoreName.Views.Panel
//public typealias SGenre = CoreName.Genre
public typealias SStatus = CoreName.Status
public typealias SState = CoreName.State
public typealias SUser = CoreName.User


public class CoreName {
    
    public class DateTime {
        
        public static let locale_en_US = "en_US"
        
        public enum amPM: String, CaseIterable {
            case am = "am"
            case pm = "pm"
            public var name: String { rawValue }
        }
        
        public enum HumanFormat: String, CaseIterable {
            case timestamp = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            case for_display_light = "MMM dd yyyy hh:mma"
            case for_display_full = "EEEE, MMM d, yyyy HH:mm:ss"
            public var name: String { rawValue }
        }
        
        public enum RawFormat: String, CaseIterable {
            case full_timezone = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            case full = "yyyy-MM-dd'T'HH:mm:ss"
            case month_day_year_hour_min_ap = "MMM dd yyyy hh:mma"
            case year_month_day_hour_min_sec = "yyyy-MM-dd HH:mm:ss"
            case day_month_day_year_hour_min_sec = "EEEE, MMM d, yyyy HH:mm:ss"
            case month_year = "MMMM yyyy"
            public var name: String { rawValue }
        }
        
    }
    
    public enum Window: String, CaseIterable {
        case master = "master"
        case home = "home"
        case chat = "chat"
        case profile = "profile"
        case dashboard = "dashboard"
        case settings = "settings"
        public var name: String { rawValue }
    }

//    public enum Genre: String, CaseIterable {
//        case soccer = "soccer"
//        case football = "football"
//        case basketball = "basketball"
//        case baseball = "baseball"
//        case iceHockey = "iceHockey"
//        case golf = "golf"
//        case tennis = "tennis"
//        case billiards = "billiards"
//        case signupProfile = "signup_profile"
//        case chat = "chat"
//        case nav = "nav"
//        public var name: String { rawValue }
//    }
    
    public enum EventType: String, CaseIterable {
        case practice = "Practice"
        case scrimmage = "Scrimmage"
        case game = "Game"
        case tournament = "Tournament"
        case teamMeeting = "Team Meeting"
        case trainingSession = "Training Session"
        case tryOut = "Try Out"
        case fundraiser = "Fundraiser"
        case communityEvent = "Community Event"
        public var name: String { rawValue }
    }
}


