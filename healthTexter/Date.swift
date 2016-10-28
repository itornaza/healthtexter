//
//  Date.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 2/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class Date {
    
    // MARK: - Properties
    
    static let dateDebug: String            = "yyyy-MM-dd, HH:mm:ss"
    static let notificationTime: String     = "HH.mm"
    static let dateFormat: String           = "E, dd/MM/yyyy"
    static let dateFormatShort: String      = "dd/MM/yyyy"
    static let dateFormat4All: String       = "E, dd MMM yyyy"
    static let dateFormat4AllShort: String  = "dd MMM yyyy"
    static let dateFormatDay: String        = "E"
    static let dateFormatISO: String        = "yyyy-MM-dd"
    static let dateFormatPlot: String       = "d/M"
    static let secondsInHour: Double        =  3600.0
    static let secondsInDay: Double         =  86400.0
    static let shiftDirection: Double       = -1.0
    
    // MARK: - Getters
    
    /// Get the current date formatted
    class func getFormatted(formatString: String) -> String {
        // Set up the dateformatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        
        // Return today in the desired format
        let today: NSDate = self.get()
        return dateFormatter.stringFromDate(today as Date)
    }
    
    // Get a given date formated
    class func getFormatted(date: NSDate, formatString: String) -> String {
        // Set up the dateformatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        
        // Return the date in the desired format
        return dateFormatter.stringFromDate(date as Date)
    }
    
    /// Get the current NSDate shifted on user preference
    class func get() -> NSDate {
        // Get the preference of the user as a delay (negative shift)
        let shiftInSeconds: TimeInterval = (self.shiftDirection * self.getDaySwitchPreference()!)

        // Add it to current date
        let today = NSDate().addingTimeInterval(shiftInSeconds)
        
        // Return the shifted version of today
        return today
    }
    
    /// Returns tomorrow 00:00:00 or 12:00AM (ie start of day). This date is not shifted as it does not refer to a diary entry but is used for a reference date to set up notifications
    class func getTomorrowMidnigh() -> NSDate {
        let now = NSDate()
        let tomorrowSameTime = now.addingTimeInterval(self.secondsInHour * 24)
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let tomorrowMidnight = cal.startOfDayForDate(tomorrowSameTime as Date)
        return tomorrowMidnight
    }
    
    class func getTodayMidnight() -> NSDate {
        let now = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let todayMidnight = cal.startOfDayForDate(now as Date)
        return todayMidnight
    }
    
    /// Get the hour and minute from a date
    class func getTimeComponents(date: NSDate) -> (TimeInterval, TimeInterval) {
        let calendar = NSCalendar.current
        let comp = calendar.components([.Hour, .Minute], fromDate: date)
        let hour = TimeInterval(comp.hour)
        let minute = TimeInterval(comp.minute)
        return (hour, minute)
    }
    
    /// Get the time in seconds from a date picker
    class func getTimeFromPickerInSeconds(sender: UIDatePicker) -> TimeInterval {
        // Get the time components
        var hour: TimeInterval = 0.0
        var min: TimeInterval = 0.0
        (hour, min) = self.getTimeComponents(sender.date)
        
        // Generate the prefered notification time in seconds
        let timeInSeconds: TimeInterval = (hour * 60 + min) * 60
        
        // Return the date picker time in seconds
        return timeInSeconds
    }
    
    // MARK: - NSUserDefaults Getters
    
    class func getTimePreference() -> TimeInterval? {
        return UserDefaults.standard.double(forKey: Constants.notificationTimePreference) as TimeInterval
    }
    
    class func getDaySwitchPreference() -> TimeInterval? {
        return UserDefaults.standard.double(forKey: Constants.daySwitchTimePreference) as TimeInterval
    }
    
    // MARK: - NSUserDefaults Setters
    
    /// Get the notification time preference in seconds and update the user defaults
    class func setTimePreference(ti: TimeInterval) {
        UserDefaults.standard.set(ti, forKey: Constants.notificationTimePreference)
    }
    
    /// Get the day switch time preference in seconds and update the user defaults
    class func setDaySwitchPreference(ti: TimeInterval) {
        UserDefaults.standard.set(ti, forKey: Constants.daySwitchTimePreference)
    }
    
    // MARK: - Methods
    
    /// Is this the first app launch or not?
    class func appHasLaunchedOnce() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.hasLaunchedOnce)
    }
    
    /// Set the user defaults on the first launch ever
    class func configureDefaults() {
        if self.appHasLaunchedOnce() == false {
            UserDefaults.standard.set(true, forKey: Constants.hasLaunchedOnce)
            UserDefaults.standard.synchronize()
            self.setTimePreference(Constants.ninteenHudredHours * self.secondsInHour)
            self.setDaySwitchPreference(Constants.fourHudredHours * self.secondsInHour)
        }
    }
}
