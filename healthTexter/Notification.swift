//
//  Notification.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 22/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class Notification {
    
    // MARK: - Class Methods
    
    class func configure() {
        self.cancelPrevious()
        self.scheduleNew()
    }
    
    /// Ask the user's permission to send notifications
    class func userConcent(application: UIApplication) {
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        )
    }
    
    /// Clean up previous notifications
    class func cancelPrevious() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    /// Schedules the actual notifications
    class func scheduleNew() {
        
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
        let tiArray: [NSTimeInterval] = Notification.configureTimeIntervals()
        
        // Configure the notifications
        self.configure(notification_1,  referenceDate: refDate, ti: tiArray[0], msg: Constants.notificationMsg_1)
        self.configure(notification_2,  referenceDate: refDate, ti: tiArray[1], msg: Constants.notificationMsg_2)
        self.configure(notification_3,  referenceDate: refDate, ti: tiArray[2], msg: Constants.notificationMsg_3)
        self.configure(notification_4,  referenceDate: refDate, ti: tiArray[3], msg: Constants.notificationMsg_1)
        self.configure(notification_5,  referenceDate: refDate, ti: tiArray[4], msg: Constants.notificationMsg_2)
        self.configure(notification_6,  referenceDate: refDate, ti: tiArray[5], msg: Constants.notificationMsg_3)
        self.configure(notification_7,  referenceDate: refDate, ti: tiArray[6], msg: Constants.notificationMsg_1)
        self.configure(notification_14, referenceDate: refDate, ti: tiArray[7], msg: Constants.notificationMsg_14)
        self.configure(notification_30, referenceDate: refDate, ti: tiArray[8], msg: Constants.notificationMsg_30)
    }
    
    /// Sets up the atributes of a notification
    class func configure(notification: UILocalNotification, referenceDate: NSDate, ti: NSTimeInterval, msg: String) {

        // Set up notification
        notification.alertBody = msg
        notification.alertAction = "Open"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = NSDate(timeInterval: ti, sinceDate: referenceDate)
        
        // Schedule notification
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /// Configure the time and dates that the notifications will show up
    class func configureTimeIntervals() -> [NSTimeInterval] {
        
        // The list here represents the number of days after today that the notifications will fire
        var tiArray: [NSTimeInterval] = [1, 2, 3, 4, 5, 6, 7, 14, 30]
        
        for ix in 0..<9 { 
            let numberOfDaysToShift: NSTimeInterval = tiArray[ix] - 1
            
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
