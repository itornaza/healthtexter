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
    
    @IBAction func readItToMe(_ sender: UISwitch) {
        if (sender.isOn) {
            
            // Start narrating the text
            myUtterance = AVSpeechUtterance(string: textArea.text)
            myUtterance.rate = 0.3
            synth.speak(myUtterance)
            
        } else {
            
            // Stop after saying the next word
            synth.stopSpeaking(at: .word)
        }
    }
    
    
    // MARK: - Configuration
    
    func configure() {
        Theme.setDateToNavigationTitle(vc: self, date: (self.entry?.date)! as NSDate)
        self.configureActionButton()
        self.configureReadSwitch()
        self.painRank.text = "\((self.entry?.painRank)!)"
        self.sleepRank.text = "\((self.entry?.sleepRank)!)"
        self.functionalityRank.text = "\((self.entry?.functionalityRank)!)"
        self.textArea.text = self.entry?.text
        Theme.tabBarColor(vc: self, color: Theme.historyColor)

    }
    
    func configureReadSwitch() {
        self.readSwitch.setOn(false, animated: false)
        self.readSwitch.onTintColor = Theme.historyColor
    }
    
    func configureActionButton() {
        let action = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(HistoryEntryViewController.shareHistoryEntry)
        )
        self.navigationItem.rightBarButtonItem = action
    }
    
    // MARK: - Segues
    
    /// If an entry exists get entry to send, prepare data and launch the activity view otherwise report the error
    func shareHistoryEntry() {
        if Constants.IAPIsEnabled == true {
            // Check if the user have purchased the sharing option
            if IAPHelper.sharingOptionGuard(vc: self) == false {
                return
            }
        }
        
        if self.entry != nil {
            let dataToSend = Entry.prepareDataToShare(entry: self.entry!)
            Theme.activityView(vc: self, textToSend: dataToSend)
        } else {
            Theme.alertView(
                vc: self,
                title: Constants.dataError,
                message: Constants.dataDoesNotExist
            )
        }
    }
}
