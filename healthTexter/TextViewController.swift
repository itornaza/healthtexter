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

class TextViewController:   UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Core Data Properties
    
    /// Shorhand for the managed object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // See this page for conversion to swift 3.0
    // http://stackoverflow.com/questions/39816877/lazy-var-nsfetchedresultscontroller-producing-error-in-swift-3-0
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Entry.Keys.date, ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchedResultsController
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var remainingChars: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        
        if Constants.IAPIsEnabled == true {
            // Get the current number of entries and check against the unlimited entries In-App Purchase rules
            let numberOfEntries = Entry.getStoredEntriesCount(frc: self.fetchedResultsController)
            if IAPHelper.unlimitedEntriesGuard(vc: self, entries: numberOfEntries) == false {
                return
            }
        }
        
        self.subscribeToKeyboardNotifications()
        
        // Promt used to record instead of typing
        if Theme.hasIntroducedMic() == false {
            Theme.alertView(vc: self, title: Constants.voiceTitle, message: Constants.voiceMessage)
            Theme.configureMicIntro()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.fetchedResultsController.delegate = nil
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Keyboard functions
    
    func keyboardWillShow(notification: NSNotification) {
        self.textArea.contentInset.bottom = getKeyboardHeight(notification: notification)
    }
    
    /// Reset the text area to it's original state
    func keyboardWillHide(notification: NSNotification) {
        self.textArea.contentInset.bottom = 0.0
    }
    
    /// Get keyboard height from the notification service
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
        return (keyboardSize! as AnyObject).cgRectValue.height
    }
    
    // MARK: - Notification subscriptions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TextViewController.keyboardWillShow(notification:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TextViewController.keyboardWillHide(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
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
            self.remainingChars.textColor = UIColor.orange
        } else if numberOfChars <= Constants.redCharsLimit {
            self.remainingChars.textColor = UIColor.red
        } else {
            self.remainingChars.textColor = UIColor.black
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
        Theme.navigationBar(vc: self, backgroundColor: Theme.writeColor)
        Theme.setDateToNavigationTitle(vc: self, date: Date.get() as NSDate)
        Theme.hideTabBar(vc: self)
        self.configureTextArea()
    }
    
    /// If the entry is new display the defaults if not display the users text
    func configureTextArea() {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the back button for the next view controller to show
        Theme.configureBackButtonForNextVC(vc: self, label: "Back")
        
        // Check if the text is empty or default
        let isEmptyText: Bool = (self.textArea.text == "" || self.textArea.text == Constants.initialText)
        
        // Check if the user selected the home button
        let navigationButton = sender as! UIBarButtonItem
        let homeButtonTouched = navigationButton.tag == 0 ? true : false
        
        // If the text is empty or default and the user opts for Home, and there is no saved entry: do not save an entry, otherwise do!
        // The getEntryIfExists is computationaly expensive this is why it is done inline as the final check. If any of the previous tests is false, then this check does not need to be performed at all
        if (isEmptyText == true &&
            homeButtonTouched == true &&
            Entry.getEntryIfExists(frc: self.fetchedResultsController) == nil
        ) == false {
            
            // Update Core Data
            self.saveEntry()
            
            // Get the new Core Data for next use
            Entry.getStoredEntries(vc: self, frc: fetchedResultsController)
        }
    }
}

extension TextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.setRemainingCharacters()
    }
    
    /// Limit to a maximum number of characters
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= Constants.maxChars
    }
    
    /// Clear the default text on tap in odrer to let the user write immediately
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.initialText {
            textView.text = nil
            self.setRemainingCharacters()
        }
    }
    
    /// If the user has left the textView empty, store the default text
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.initialText
        }
    }
}
