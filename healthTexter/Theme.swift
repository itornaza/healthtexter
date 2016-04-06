//
//  Theme.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 7/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class Theme {
    
    // MARK: - Properties
    
    // Identifiers
    static let tabBarId: String = "TabBarController"
    
    // Colors
    static let htDarkGreen = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    static let htRankPain = UIColor(red: 255.0/255.0, green: 42.0/255.0, blue: 26.0/255.0, alpha: 1.0)
    static let htRankSleep = UIColor(red: 16.0/255.0, green: 63.0/255.0, blue: 251.0/255.0, alpha: 1.0)
    static let htRankFunctionality = UIColor(red: 1.0/255.0, green: 145.0/255.0, blue: 146.0/255.0, alpha: 1.0)
    
    // Designer's Palette
    static let writeColor = UIColor(red: 88.0/255.0, green: 187.0/255.0, blue: 184.0/255.0, alpha: 1.0)
    static let monitorColor = UIColor(red: 207.0/255.0, green: 81.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    static let historyColor = UIColor(red: 237.0/255.0, green: 146.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    static let preferencesColor = UIColor(red: 123.0/255.0, green: 102.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    
    // Colors Used for prototyping
    static let htGreen = UIColor(red: 152.0/255.0, green: 218.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    static let htSomon = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    
    // MARK: - Labels
    
    /// Configure the labels to resize fonts and wrap on a second line
    class func configureHookLabels(label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 2
    }
    
    // MARK: - Navigation
    
    /// Navigation bar look and feel
    class func navigationBar(vc: UIViewController, backgroundColor: UIColor) {
        vc.navigationController?.navigationBar.barTintColor = backgroundColor
        vc.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        vc.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    /// Set the navigation title to the date provided
    class func setDateToNavigationTitle(vc vc: UIViewController, date: NSDate) {
        vc.navigationItem.title = Date.getFormatted(date, formatString: Date.dateFormat4All)
    }
    
    /// Back button
    class func configureBackButtonForNextVC(vc: UIViewController, label: String) {
        let backItem = UIBarButtonItem()
        backItem.title = label
        vc.navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - Tab bar
    
    /// Hide Tab bar
    class func hideTabBar(vc: UIViewController) {
        vc.tabBarController?.tabBar.hidden = true
    }
    
    /// Set the tab bar color scheme
    class func tabBarColor(vc: UIViewController, color: UIColor) {
        // Tab bar color itself
        vc.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        
        // Color of the selected tab bar item
        vc.tabBarController?.tabBar.tintColor = color
    }
    
    // MARK: - Sliders
    
    /// Set the slider thumb with an emoticon of the same value
    class func setSliderThumbImage(sender: UISlider) {
        if Int(sender.value) >= 0 && Int(sender.value) <= 10 {
            let imageName = "emoticon_" + "\(Int(sender.value))" + ".png"
            sender.setThumbImage(UIImage(named: imageName), forState: UIControlState.Normal)
        } else {
            sender.setThumbImage(UIImage(named: "emoticon_5.png"), forState: UIControlState.Normal)
        }
    }
    
    /// Set the slider thumb with an emoticon of the reverse value to use with only the pain scale
    class func setSliderThumbImageReversed(sender: UISlider) {
        if Int(sender.value) >= 0 && Int(sender.value) <= 10 {
            let imageName = "emoticon_" + "\(10 - Int(sender.value))" + ".png"
            sender.setThumbImage(UIImage(named: imageName), forState: UIControlState.Normal)
        } else {
            sender.setThumbImage(UIImage(named: "emoticon_5.png"), forState: UIControlState.Normal)
        }
    }
    
    // MARK: - NSUserDefaults Utility Methods
    
    class func hasIntroducedMic() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(Constants.hasIntroducedMic)
    }
    
    class func configureMicIntro() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.hasIntroducedMic)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: - Alerts and activities
    
    /// Alert
    class func alertView(vc: UIViewController, title: String, message: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(dismiss)
            vc.presentViewController(alertController, animated: true, completion: nil)
            alertController.view.tintColor = Theme.htDarkGreen
        }
    }
    
    /// Activity View Controller to share entries
    class func activityView(vc: UIViewController, textToSend: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            // Get the activity view controller and pass it the text to send
            let activityViewController = UIActivityViewController(
                activityItems: [textToSend],
                applicationActivities: nil
            )
            
            // Present the ActivityViewController
            vc.presentViewController(activityViewController, animated: true, completion: nil)
            
            // Control flow when the activity controller exits
            activityViewController.completionWithItemsHandler = {
                (s: String?, ok: Bool, items: [AnyObject]?, err:NSError?) -> Void in
                if ok {
                    vc.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Segues
    
    /// Segue to tab bar
    class func segueToTabBarController(vc: UIViewController, tabItemIndex: Int) {
        let tabBarController = vc.storyboard!.instantiateViewControllerWithIdentifier(tabBarId)
            as! UITabBarController
        tabBarController.selectedIndex = tabItemIndex
        vc.presentViewController(tabBarController, animated: false, completion: nil)
    }
}
