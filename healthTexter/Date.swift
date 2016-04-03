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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        
        // Return today in the desired format
        let today: NSDate = self.get()
        return dateFormatter.stringFromDate(today)
    }
    
    // Get a given date formated
    class func getFormatted(date: NSDate, formatString: String) -> String {
        
        // Set up the dateformatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        
        // Return the date in the desired format
        return dateFormatter.stringFromDate(date)
    }
    
    /// Get the current NSDate shifted on user preference
    class func get() -> NSDate {
        
        // Get the preference of the user as a delay (negative shift)
        let shiftInSeconds: NSTimeInterval = (self.shiftDirection * self.getDaySwitchPreference()!)

        // Add it to current date
        let today = NSDate().dateByAddingTimeInterval(shiftInSeconds)
        
        // Return the shifted version of today
        return today
    }
    
    /// Returns tomorrow 00:00:00 or 12:00AM (ie start of day). This date is not shifted as it does not refer to a diary entry but is used for a reference date to set up notifications
    class func getTomorrowMidnigh() -> NSDate {
        let now = NSDate()
        let tomorrowSameTime = now.dateByAddingTimeInterval(self.secondsInHour * 24)
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let tomorrowMidnight = cal.startOfDayForDate(tomorrowSameTime)
        return tomorrowMidnight
    }
    
    class func getTodayMidnight() -> NSDate {
        let now = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let todayMidnight = cal.startOfDayForDate(now)
        return todayMidnight
    }
    
    /// Get the hour and minute from a date
    class func getTimeComponents(date: NSDate) -> (NSTimeInterval, NSTimeInterval) {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: date)
        let hour = NSTimeInterval(comp.hour)
        let minute = NSTimeInterval(comp.minute)
        return (hour, minute)
    }
    
    /// Get the time in seconds from a date picker
    class func getTimeFromPickerInSeconds(sender: UIDatePicker) -> NSTimeInterval {
    
        // Get the time components
        var hour: NSTimeInterval = 0.0
        var min: NSTimeInterval = 0.0
        (hour, min) = self.getTimeComponents(sender.date)
        
        // Generate the prefered notification time in seconds
        let timeInSeconds: NSTimeInterval = (hour * 60 + min) * 60
        
        // Return the date picker time in seconds
        return timeInSeconds
    }
    
    // MARK: - NSUserDefaults Getters
    
    class func getTimePreference() -> NSTimeInterval? {
        return NSUserDefaults.standardUserDefaults().doubleForKey(Constants.notificationTimePreference) as NSTimeInterval
    }
    
    class func getDaySwitchPreference() -> NSTimeInterval? {
        return NSUserDefaults.standardUserDefaults().doubleForKey(Constants.daySwitchTimePreference) as NSTimeInterval
    }
    
    // MARK: - NSUserDefaults Setters
    
    /// Get the notification time preference in seconds and update the user defaults
    class func setTimePreference(ti: NSTimeInterval) {
        NSUserDefaults.standardUserDefaults().setDouble(ti, forKey: Constants.notificationTimePreference)
    }
    
    /// Get the day switch time preference in seconds and update the user defaults
    class func setDaySwitchPreference(ti: NSTimeInterval) {
        NSUserDefaults.standardUserDefaults().setDouble(ti, forKey: Constants.daySwitchTimePreference)
    }
    
    // MARK: - Methods
    
    /// Is this the first app launch or not?
    class func appHasLaunchedOnce() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(Constants.hasLaunchedOnce)
    }
    
    /// Set the user defaults on the first launch ever
    class func configureDefaults() {
        if self.appHasLaunchedOnce() == false {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.hasLaunchedOnce)
            NSUserDefaults.standardUserDefaults().synchronize()
            self.setTimePreference(Constants.ninteenHudredHours * self.secondsInHour)
            self.setDaySwitchPreference(Constants.fourHudredHours * self.secondsInHour)
        }
    }
}
