//
//  HistoryEntryViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 22/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import AVFoundation

class HistoryEntryViewController: UIViewController {

    // MARK: - Properties
    
    var entry: Entry?
    
    // Text to speech
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    // MARK: Outlets
    
    @IBOutlet weak var readSwitch: UISwitch!
    @IBOutlet weak var painRank: UILabel!
    @IBOutlet weak var sleepRank: UILabel!
    @IBOutlet weak var functionalityRank: UILabel!
    @IBOutlet weak var textArea: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    // MARK: - Actions
    
    @IBAction func readItToMe(sender: UISwitch) {
        if (sender.on) {
            
            // Start narrating the text
            myUtterance = AVSpeechUtterance(string: textArea.text)
            myUtterance.rate = 0.3
            synth.speakUtterance(myUtterance)
            
        } else {
            
            // Stop after saying the next word
            synth.stopSpeakingAtBoundary(.Word)
        }
    }
    
    // MARK: - Configuration
    
    func configure() {
        Theme.setDateToNavigationTitle(vc: self, date: (self.entry?.date)!)
        self.configureActionButton()
        self.configureReadSwitch()
        self.painRank.text = "\((self.entry?.painRank)!)"
        self.sleepRank.text = "\((self.entry?.sleepRank)!)"
        self.functionalityRank.text = "\((self.entry?.functionalityRank)!)"
        self.textArea.text = self.entry?.text
        Theme.tabBarColor(self)

    }
    
    func configureReadSwitch() {
        self.readSwitch.setOn(false, animated: false)
        self.readSwitch.onTintColor = Theme.htGreen
    }
    
    func configureActionButton() {
        let action = UIBarButtonItem(
            barButtonSystemItem: .Action,
            target: self,
            action: Selector("shareHistoryEntry")
        )
        self.navigationItem.rightBarButtonItem = action
    }
    
    // MARK: - Segues
    
    /// If an entry exists get entry to send, prepare data and launch the activity view otherwise report the error
    func shareHistoryEntry() {
        
        // Check if the user have purchased the sharing option
        IAPHelper.sharingOptionGuard(self)
        
        if self.entry != nil {
            let dataToSend = Entry.prepareDataToShare(self.entry!)
            Theme.activityView(self, textToSend: dataToSend)
        } else {
            Theme.alertView(
                self,
                title: Constants.dataError,
                message: Constants.dataDoesNotExist
            )
        }
    }
}
