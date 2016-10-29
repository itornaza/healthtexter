//
//  Notification.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 22/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/// The notification scheduler shall calculate notifications when the app resigns active state. The scheduler sets up notifications to fire the second day after the app has resigned the active state. In this way if a user uses the app every day will never get a notification and will not be annoyed. Daily notifications follow for every day for a week one at the 2 week mark and a last one at the month mark
final class Notification {
    
    private static let DEBUG: Bool = false
    
    // MARK: - Class Methods
    
    class func configure() {
        self.cancelPrevious()
        self.scheduleNew()
    }
    
    /// Ask the user's permission to send notifications
    class func userConcent(application: UIApplication) {
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        )
    }
    
    /// Clean up previous notifications
    private class func cancelPrevious() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    /// Schedules the actual notifications
    private class func scheduleNew() {
        // Set up the new notifications
        
        let refDate: NSDate = Date.getTomorrowMidnigh()
        
        // Declare the notifications
        let notification_1:  UILocalNotification = UILocalNotification()
        let notification_2:  UILocalNotification = UILocalNotification()
        let notification_3:  UILocalNotification = UILocalNotification()
        let notification_4:  UILocalNotification = UILocalNotification()
        let notification_5:  UILocalNotification = UILocalNotification()
        let notification_6:  UILocalNotification = UILocalNotification()
        let notification_7:  UILocalNotification = UILocalNotification()
        let notification_14: UILocalNotification = UILocalNotification()
        let notification_30: UILocalNotification = UILocalNotification()
        
        // Set up the time intervals
        let tiArray: [TimeInterval] = Notification.configureTimeIntervals()
        
        // Configure the notifications
        self.configure(notification: notification_1,  referenceDate: refDate, ti: tiArray[0], msg: Constants.notificationMsg_1)
        self.configure(notification: notification_2,  referenceDate: refDate, ti: tiArray[1], msg: Constants.notificationMsg_2)
        self.configure(notification: notification_3,  referenceDate: refDate, ti: tiArray[2], msg: Constants.notificationMsg_3)
        self.configure(notification: notification_4,  referenceDate: refDate, ti: tiArray[3], msg: Constants.notificationMsg_1)
        self.configure(notification: notification_5,  referenceDate: refDate, ti: tiArray[4], msg: Constants.notificationMsg_2)
        self.configure(notification: notification_6,  referenceDate: refDate, ti: tiArray[5], msg: Constants.notificationMsg_3)
        self.configure(notification: notification_7,  referenceDate: refDate, ti: tiArray[6], msg: Constants.notificationMsg_1)
        self.configure(notification: notification_14, referenceDate: refDate, ti: tiArray[7], msg: Constants.notificationMsg_14)
        self.configure(notification: notification_30, referenceDate: refDate, ti: tiArray[8], msg: Constants.notificationMsg_30)
    }
    
    /// Sets up the atributes of a notification
    private class func configure(notification: UILocalNotification, referenceDate: NSDate, ti: TimeInterval, msg: String) {
        // Set up notification
        notification.alertBody = msg
        notification.alertAction = "Open"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        notification.fireDate = NSDate(timeInterval: ti, sinceDate: referenceDate as Date) as Date
        
        // Schedule notification
        UIApplication.shared.scheduleLocalNotification(notification)
        if self.DEBUG { print(notification.fireDate) }
    }
    
    /// Configure the time and dates that the notifications will show up
    private class func configureTimeIntervals() -> [TimeInterval] {
        // The list here represents the number of days after today that the notifications will fire
        var tiArray: [TimeInterval] = [2, 3, 4, 5, 6, 7, 8, 15, 31]
        
        for ix in 0..<9 { 
            let numberOfDaysToShift: TimeInterval = tiArray[ix] - 1
            
            // Check if the user has ever set the defaults
            if let preference = Date.getTimePreference() {
                tiArray[ix] = (numberOfDaysToShift * Date.secondsInDay) + preference
            } else {
                tiArray[ix] = (numberOfDaysToShift * Date.secondsInDay) + Constants.ninteenHudredHours * Date.secondsInHour
            }
        }
        
        // Return the array with the configuref time intervals
        return tiArray
    }
}
