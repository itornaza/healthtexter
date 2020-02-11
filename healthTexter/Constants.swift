//
//  Constants.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 2/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

final class Constants {
    
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
    static let voiceTitle: String =     "Dictation 🎙"
    static let voiceMessage: String =   "Tap the mic icon on the keyboard to dictate!"
    static let text: String =           ""
    static let initialText: String =    "Write about your day \n\n" +
                                        "- Were you in pain? \n\n" +
                                        "- Did you sleep well? \n\n" +
                                        "- Were you able to do your activities? \n\n" +
                                        "- Any events worth noting? \n\n" +
                                        "... Tap to start writing ..."
    
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
    static let dataLoadingError: String =   "Could not load stored data"
    static let dataDoesNotExist: String =   "No data exist"
    static let oops: String =               "Oooops!"
    static let noDataToSend: String =       "You have not selected any entries to share.\n\n" +
                                            "Click first on the select button to make your selections"
    
    // MARK: - In-App Purchases
    
    /**
     * Determines if the app is for free or under in-app purchases, check with itunesconnect app features in-app
     * purchases status
     */
    static let IAPIsEnabled: Bool = false
    
    static let maxFreeEntries: Int = 6
    static let IAPtitle: String =           "In-app purchases"
    static let IAPbuttonTitle: String =     "Go to preferences"
    static let sharingOptionMsg: String =   "In order to share your entries review the in-app purchases " +
                                            "in the preferences menu"
    static let unlimitedEntriesMsg: String = "You have reached your maximum free entries limit. " +
                                            "In order to write unlimited entries review the in-app purchases " +
                                            "in the preferences menu"
    
    // MARK: - Notifications
    
    // NSUserDefault key
    static let notificationTimePreference: String = "time_preference"
    static let daySwitchTimePreference: String =    "day_switch_preference"
    static let hasLaunchedOnce: String =            "HasLaunchedOnce"
    static let hasIntroducedMic: String =           "HasIntroducedMic"
    
    // Default time preference in hours
    static let ninteenHudredHours: TimeInterval = 19.0
    static let fourHudredHours: TimeInterval = 4.0
    static let maxSwitchDayDelay: TimeInterval = 4.0 * 3600
    
    // Messages
    static let notificationMsg_1: String =  "It's about time to write in your diary! 🙄"
    static let notificationMsg_2: String =  "Write in your diary and keep up with your progress! 😏"
    static let notificationMsg_3: String =  "Writing about your condition may contribute to your health! 😇"
    static let notificationMsg_14: String = "Hey there! either you are doing good or you have forgotten to write " +
                                            "in your diary for a while! 😉"
    static let notificationMsg_30: String = "Long time no see! Check back with your notes! ✍️"
}
