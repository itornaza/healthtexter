//
//  Constants.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 2/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    // MARK: - Device resolution
    
    static let iPhone5ScreenHeight: CGFloat = 568.0
    
    // MARK: - Tab bar
    
    // Index values for each of the tabs
    static let textTab: Int = 0
    static let monitorTab: Int = 1
    static let historyTab: Int = 2
    static let preferencesTab: Int = 3
    
    // MARK: - User input defaults
    
    // Ranks
    static let painRank: Int = 0
    static let sleepRank: Int = 0
    static let functionalityRank: Int = 0
    static let defaultRank: Int = 5
    
    // TextView
    static let maxChars: Int = 500
    static let orangeCharsLimit: Int = 30
    static let redCharsLimit: Int = 10
    static let voiceTitle: String =     "Voice Recording 🎙"
    static let voiceMessage: String =   "Tap the mic icon on the keyboard to dictate!"
    static let text: String =           ""
    static let initialText: String =    "Write about your day \n\n" +
                                        "- Were you able to do your activities? \n\n" +
                                        "- Were you in pain? \n\n" +
                                        "- Did you sleep well? \n\n" +
                                        "- Any events worth noting?"
    
    // MARK: - Plotting
    
    // Rank plot segment selectors
    static let painSelector:Int = 0
    static let sleepSelector: Int = 1
    static let functionalitySelector: Int = 2
    static let progressSelector: Int = 3
    
    // Week/Month segment selector
    static let plotWeek: Int = 0
    static let plotMonth: Int = 1
    
    // Number of days in week and month
    static let daysInWeek: Int = 7
    static let daysInMonth: Int = 30
    
    // MARK: - Errors and Alerts
    
    static let dataError: String =          "Data error"
    static let dataLoadingError: String =   "Could not load the stored data"
    static let dataDoesNotExist: String =   "No data exist"
    static let oops: String =               "Oooops!"
    static let noDataToSend: String =       "You have not selected any entries to share.\n\n" +
                                            "Click first on the select button to make your selections"
    
    // MARK: - In-App Purchases
    
    static let maxFreeEntries: Int = 6
    static let IAPtitle: String =           "In-App Purchases"
    static let IAPbuttonTitle: String =     "Go to preferences"
    static let sharingOptionMsg: String =   "In order to share your entries review the In-App Purchases " +
                                            "in the Preferences menu"
    static let unlimitedEntriesMsg: String = "You have reached your maximum entries limit. " +
                                            "In order to have unlimited entries review the In-App Purchases " +
                                            "in the Preferences menu"
    
    // MARK: - Notifications
    
    // NSUserDefault key
    static let notificationTimePreference: String = "time_preference"
    static let daySwitchTimePreference: String =    "day_switch_preference"
    static let hasLaunchedOnce: String =            "HasLaunchedOnce"
    static let hasIntroducedMic: String =           "HasIntroducedMic"
    
    // Default time preference in hours
    static let ninteenHudredHours: NSTimeInterval = 19.0
    static let fourHudredHours: NSTimeInterval = 4.0
    static let maxSwitchDayDelay: NSTimeInterval = 4.0 * 3600
    
    // Messages
    static let notificationMsg_1: String =  "It's about time to write in your patient diary! 🙄"
    static let notificationMsg_2: String =  "Write in your diary and keep up with your progress! 😏"
    static let notificationMsg_3: String =  "Writing about your condition contributes to your health! 😇"
    static let notificationMsg_14: String = "Hey there! either you are fine or you have forgotten to write " +
                                            "in your diary for a while! 😉"
    static let notificationMsg_30: String = "Long time no see! Check back with your notes! ✍️"
}
