//
//  RanksViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 7/11/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import CoreData

class RanksViewController:  UIViewController,
                            NSFetchedResultsControllerDelegate
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
    
    @IBOutlet weak var painLevelValue: UILabel!
    @IBOutlet weak var sleepQualityValue: UILabel!
    @IBOutlet weak var functionalityValue: UILabel!
    @IBOutlet weak var painSlider: UISlider!
    @IBOutlet weak var sleepSlider: UISlider!
    @IBOutlet weak var functionalitySlider: UISlider!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.fetchedResultsController.delegate = nil
    }
    
    // MARK: - Actions
    
    @IBAction func painSlider(sender: UISlider) {
        self.painLevelValue.text = "\(Int(sender.value))"
        Theme.setSliderThumbImageReversed(sender)
    }
    
    @IBAction func sleepQualitySlider(sender: UISlider) {
        self.sleepQualityValue.text = "\(Int(sender.value))"
        Theme.setSliderThumbImage(sender)
    }
    
    @IBAction func functionalitySlider(sender: UISlider) {
        self.functionalityValue.text = "\(Int(sender.value))"
        Theme.setSliderThumbImage(sender)
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
        Theme.setDateToNavigationTitle(vc: self, date: Date.get())
        self.configureNavigation()
        self.configureSliderValues()
        self.configureSliderImages()
    }
    
    func configureNavigation() {
        let rightButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "segueToNextVC:"
        )
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    /// If the ranks are already set, display the stored settings
    func configureSliderValues() {
        if let entry = Entry.getEntryIfExists(frc: fetchedResultsController) {
            
            // Pain
            self.painSlider.value = Float((entry.painRank))
            self.painLevelValue.text = "\(Int(entry.painRank))"
            
            // Sleep quality
            self.sleepSlider.value = Float(entry.sleepRank)
            self.sleepQualityValue.text = "\(Int(entry.sleepRank))"
            
            // Functionality
            self.functionalitySlider.value = Float(entry.functionalityRank)
            self.functionalityValue.text = "\(Int(entry.functionalityRank))"
        }
    }
    
    /// Display the appropriate emoticon on the slider thumb
    func configureSliderImages() {
        Theme.setSliderThumbImageReversed(self.painSlider)
        Theme.setSliderThumbImage(self.functionalitySlider)
        Theme.setSliderThumbImage(self.sleepSlider)
    }
    
    // MARK: - Helpers

    func getPainRanks(completion: (Int, Int, Int) -> Void) {
        let painRank: Int = Int(self.painSlider.value)
        let sleepRank: Int = Int(self.sleepSlider.value)
        let functionalityRank = Int(functionalitySlider.value)
        completion(painRank, sleepRank, functionalityRank)
    }
    
    /// Saves the ranks either on an existing or a new entry
    func saveRanks() {
        self.getPainRanks() { painRank, sleepRank, functionalityRank in
            
            let entry = Entry.getEntryIfExists(frc: self.fetchedResultsController)
            if entry != nil {
                
                // If entry exists update with the rank values
                entry?.painRank = painRank
                entry?.sleepRank = sleepRank
                entry?.functionalityRank = functionalityRank
                
            } else {
                
                // If there is no entry, create a new one
                let dictionary = [
                    Entry.Keys.text : "",
                    Entry.Keys.painRank : painRank as AnyObject,
                    Entry.Keys.sleepRank : sleepRank as AnyObject,
                    Entry.Keys.functionalityRank : functionalityRank as AnyObject
                ]
                _ = Entry(dictionary: dictionary, context: self.sharedContext)
            }
            
            // Save the context
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // MARK: - Segues
    
    func segueToNextVC(rightButton : UIBarButtonItem) {
        
        // Update the ranks to Core Data
        self.saveRanks()
        
        // Get the stored entries for latter use
        Entry.getStoredEntries(vc: self, frc: fetchedResultsController)
        
        // Go to the monitor tab
        Theme.segueToTabBarController(self, tabItemIndex: Constants.monitorTab)
    }
    
}
