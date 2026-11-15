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
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()

        // Flush the selected indices array for next use
        self.selectedIndicesArray = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Theme.tabBarColor(vc: self, color: Theme.historyColor)
        
        // Reload data to avoid the last selected cell to be highlighted
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.fetchedResultsController.delegate = nil
    }
    
    // MARK: - Actions
    
    /// Share the selected entries
    @IBAction func action(sender: UIBarButtonItem) {
        if Constants.IAPIsEnabled == true {
            // Check if the user have purchased the sharing option
            if IAPHelper.sharingOptionGuard(vc: self) == false {
                return
            }
        }
        
        // Local variables
        var entriesToShare = [Entry]()
        var textToSend = String()
        
        // Get the data
        for index in self.selectedIndicesArray {
            entriesToShare.append(self.fetchedResultsController.object(at: index as IndexPath) )
        }

        // If no entries are selected alert the user. Otherwise send the data
        if entriesToShare.count == 0 {
            Theme.alertView(
                vc: self,
                title: Constants.oops,
                message: Constants.noDataToSend
            )
        } else {
            for entry in entriesToShare {
                textToSend = textToSend + (Entry.prepareDataToShare(entry: entry))
            }
            Theme.activityView(vc: self, textToSend: textToSend)
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
        Theme.navigationBar(vc: self, backgroundColor: Theme.historyColor)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.title = "Select"
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.reloadData()
    }
    
    // MARK: - Segues
    
    func navigateToHistoryEntryViewController(indexPath: NSIndexPath) {
        OperationQueue.main.addOperation {
            Theme.configureBackButtonForNextVC(vc: self, label: "History")
            let progressVC = self.storyboard!.instantiateViewController(withIdentifier: "HistoryEntryViewController")
                as! HistoryEntryViewController
            
            // Send the entry to display
            progressVC.entry = self.fetchedResultsController.object(at: indexPath as IndexPath)
            
            // Retain the tab bar in the detail view
            self.navigationController?.pushViewController(progressVC, animated: false)
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    @available(iOS 2.0, *)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryViewCell
        
        // Show the little arrow on the right hand side of the row
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        // Find the model object that corresponds to that row
        let entry = self.fetchedResultsController.object(at: indexPath as IndexPath) 
        
        // Set the cell custom labels
        cell.date.text = Date.getFormatted(date: entry.date, formatString: Date.dateFormat4AllShort)
        cell.weekDay.text = Date.getFormatted(date: entry.date, formatString: Date.dateFormatDay)
        cell.painRank.text = "\(entry.painRank)"
        cell.functionalityRank.text = "\(entry.functionalityRank)"
        cell.sleepRank.text = "\(entry.sleepRank)"
        
        // Set the color of the left checkboxes in editing mode
        cell.tintColor = Theme.historyColor
        
        // return the cell
        return cell
    }
    
    /// If the table is in edit mode, do not segue. If in edit mode, get the selected entries indices
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            self.navigateToHistoryEntryViewController(indexPath: indexPath as NSIndexPath)
        } else {
            self.selectedIndicesArray.append(indexPath as NSIndexPath)
        }
    }
    
    /// Enables the checkboxes on the left of the table cells
    override func setEditing(_ editing: Bool, animated: Bool) {
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
