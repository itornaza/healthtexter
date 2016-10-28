//
//  HistoryViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    
    var selectedIndicesArray = [NSIndexPath]()
    
    // MARK: - Core Data Properties
    
    /// Shorhand for the managed object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Entry")
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
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()

        // Flush the selected indices array for next use
        self.selectedIndicesArray = []
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        Theme.tabBarColor(self, color: Theme.historyColor)
        
        // Reload data to avoid the last selected cell to be highlighted
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.fetchedResultsController.delegate = nil
    }
    
    // MARK: - Actions
    
    /// Share the selected entries
    @IBAction func action(sender: UIBarButtonItem) {
        // Check if the user have purchased the sharing option
        if IAPHelper.sharingOptionGuard(self) == false {
            return
        }
        
        // Local variables
        var entriesToShare = [Entry]()
        var textToSend = String()
        
        // Get the data
        for index in self.selectedIndicesArray {
            entriesToShare.append(self.fetchedResultsController.objectAtIndexPath(index) as! Entry)
        }

        // If no entries are selected alert the user. Otherwise send the data
        if entriesToShare.count == 0 {
            Theme.alertView(
                self,
                title: Constants.oops,
                message: Constants.noDataToSend
            )
        } else {
            for entry in entriesToShare {
                textToSend = textToSend + (Entry.prepareDataToShare(entry))
            }
            Theme.activityView(self, textToSend: textToSend)
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
    
    func configureUI(){
        Theme.navigationBar(self, backgroundColor: Theme.historyColor)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.title = "Select"
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.reloadData()
    }
    
    // MARK: - Segues
    
    func navigateToHistoryEntryViewController(indexPath: NSIndexPath) {
        OperationQueue.main.addOperation {
            Theme.configureBackButtonForNextVC(self, label: "History")
            let progressVC = self.storyboard!.instantiateViewController(withIdentifier: "HistoryEntryViewController")
                as! HistoryEntryViewController
            
            // Send the entry to display
            progressVC.entry = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Entry
            
            // Retain the tab bar in the detail view
            self.navigationController?.pushViewController(progressVC, animated: false)
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryViewCell
        
        // Show the little arrow on the right hand side of the row
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // Find the model object that corresponds to that row
        let entry = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
        
        // Set the cell custom labels
        cell.date.text = Date.getFormatted(entry.date, formatString: Date.dateFormat4AllShort)
        cell.weekDay.text = Date.getFormatted(entry.date, formatString: Date.dateFormatDay)
        cell.painRank.text = "\(entry.painRank)"
        cell.functionalityRank.text = "\(entry.functionalityRank)"
        cell.sleepRank.text = "\(entry.sleepRank)"
        
        // Set the color of the left checkboxes in editing mode
        cell.tintColor = Theme.historyColor
        
        // return the cell
        return cell
    }
    
    /// If the table is in edit mode, do not segue. If in edit mode, get the selected entries indices
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEditing == false {
            self.navigateToHistoryEntryViewController(indexPath)
        } else {
            self.selectedIndicesArray.append(indexPath)
        }
    }
    
    /// Enables the checkboxes on the left of the table cells
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(true, animated: true)
        
        // Branch on editing state
        if self.tableView.isEditing {
            
            // Switch to not editing mode
            self.tableView.setEditing(false, animated: true)
            self.tableView.isEditing = false
            self.editButtonItem.title = "Select"
            
            // Empty the selected entries
            self.selectedIndicesArray = []
            
        } else {
            
            // Switch to editing mode
            self.tableView.setEditing(true, animated: true)
            self.tableView.isEditing = true
            self.editButtonItem.title = "Done"
        }
    }
}
