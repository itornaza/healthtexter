//
//  TextViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AVFoundation

class TextViewController:   UIViewController,
                            NSFetchedResultsControllerDelegate,
                            UITextViewDelegate
{
    
    // MARK: - Core Data Properties
    
    /// Shorhand for the managed object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Entry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Entry.Keys.date, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var remainingChars: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        
        // Get the current number of entries and check against the unlimited entries In-App Purchase rules
        let numberOfEntries = Entry.getStoredEntriesCount(self.fetchedResultsController)
        IAPHelper.unlimitedEntriesGuard(self, entries: numberOfEntries)
        
        self.subscribeToKeyboardNotifications()
        
        // Promt used to record instead of typing
        if (Theme.hasIntroducedMic() == false) {
            Theme.alertView(self, title: Constants.voiceTitle, message: Constants.voiceMessage)
            Theme.configureMicIntro()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.fetchedResultsController.delegate = nil
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Keyboard functions
    
    func keyboardWillShow(notification: NSNotification) {
        self.textArea.contentInset.bottom = getKeyboardHeight(notification)
    }
    
    /// Reset the text area to it's original state
    func keyboardWillHide(notification: NSNotification) {
        self.textArea.contentInset.bottom = 0.0
    }
    
    /// Get keyboard height from the notification service
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
        return keyboardSize!.CGRectValue.height
    }
    
    // MARK: - Notification subscriptions
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TextViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TextViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Text View delegate
    
    func textViewDidChange(textView: UITextView) {
        self.setRemainingCharacters()
    }
    
    /// Limit to a maximum number of characters
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= Constants.maxChars
    }
    
    /// Clear the default text on tap in odrer to let the user write immediately
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == Constants.initialText {
            textView.text = nil
            self.setRemainingCharacters()
        }
    }
    
    /// If the user has left the textView empty, store the default text
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.initialText
        }
    }
    
    // MARK: - Helpers
    
    /// Get any text that the user has entered and not the default textArea text
    func getUserText() -> String {
        if textArea.text == Constants.initialText {
            return ""
        } else {
            return textArea.text
        }
    }
    
    /// Save the entry to Core Data
    func saveEntry() {
        let text = getUserText()
        let entry = Entry.getEntryIfExists(frc: self.fetchedResultsController)
        
        // Create a new entry or update the existing one
        if entry == nil {
            _ = Entry(text: text, context: self.sharedContext)
        } else {
            entry?.text = text
        }
        
        // Save the context
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    /// Update the remaining characters
    func setRemainingCharacters() {
        
        // Get the number of characters that remain until text area is full
        let numberOfChars: Int = Constants.maxChars - self.textArea.text.characters.count
        
        // Update the number of characters as the user types
        self.remainingChars.text = "\(numberOfChars)"

        // Progressively alert the user on the remaining characters from black to orange to red
        if (numberOfChars > Constants.redCharsLimit) && (numberOfChars <= Constants.orangeCharsLimit) {
            self.remainingChars.textColor = UIColor.orangeColor()
        } else if numberOfChars <= Constants.redCharsLimit {
            self.remainingChars.textColor = UIColor.redColor()
        } else {
            self.remainingChars.textColor = UIColor.blackColor()
        }
    }
    
    // MARK: - Configuration
    
    func configure() {
        self.configureCoreData()
        self.configureUI()
    }
    
    func configureCoreData() {
        fetchedResultsController.delegate = self
        Entry.getStoredEntries(vc: self, frc: fetchedResultsController)
    }
    
    func configureUI() {
        Theme.navigationBar(self, backgroundColor: Theme.writeColor)
        Theme.setDateToNavigationTitle(vc: self, date: Date.get())
        Theme.hideTabBar(self)
        self.configureTextArea()
    }
    
    /// If the entry is new display the defaults if not display the users text
    func configureTextArea() {
        
        // Set the delegate
        self.textArea.delegate = self
        
        // Set the text inside the text area
        if let entry = Entry.getEntryIfExists(frc: fetchedResultsController) {
            if entry.text == "" {
                textArea.text = Constants.initialText
            } else {
                textArea.text = entry.text
            }
        } else {
            textArea.text = Constants.initialText
        }
        
        // Calculate the remaining chars after presenting the default text
        self.setRemainingCharacters()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Configure the back button for the next view controller to show
        Theme.configureBackButtonForNextVC(self, label: "Back")
        
        // Update Core Data
        self.saveEntry()
        
        // Get the new Core Data for next use
        Entry.getStoredEntries(vc: self, frc: fetchedResultsController)
    }
    
}
