//
//  ProgressViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import CoreData

class ProgressViewController:   UIViewController,
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
    
    // MARK: - Properties
    
    var viewShowing: Int = 0
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var painView: PainView!
    @IBOutlet weak var sleepView: SleepView!
    @IBOutlet weak var functionalityView: FunctionalityView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var segmentedOptions: UISegmentedControl!
    @IBOutlet weak var segmentedWeekMonth: UISegmentedControl!
    
    // Pain View Labels
    @IBOutlet weak var averagePain: UILabel!
    @IBOutlet weak var minPain: UILabel!
    @IBOutlet weak var maxPain: UILabel!
    
    // Sleep View Labels
    @IBOutlet weak var averageSleep: UILabel!
    @IBOutlet weak var minSleep: UILabel!
    @IBOutlet weak var maxSleep: UILabel!
    
    // Functionality View Labels
    @IBOutlet weak var averageFunctionality: UILabel!
    @IBOutlet weak var minFunctionality: UILabel!
    @IBOutlet weak var maxFunctionality: UILabel!
    
    // Progress View Labels
    @IBOutlet weak var averageProgress: UILabel!
    @IBOutlet weak var minProgress: UILabel!
    @IBOutlet weak var maxProgress: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.subscribeToOrientationChangeNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.fetchedResultsController.delegate = nil
        self.unsubscribeToOrientationChangeNotifications()
    }
    
    // MARK: - Actions
    
    /// Launch the activity view to share the entry
    @IBAction func action(sender: UIBarButtonItem) {
        
        // Check if the user have purchased the sharing option
        IAPHelper.sharingOptionGuard(self)
        
        // Send the entry if it exists, alert the user otherwise
        if let entry = Entry.getEntryIfExists(frc: self.fetchedResultsController) {
            let dataToSend = Entry.prepareDataToShare(entry)
            Theme.activityView(self, textToSend: dataToSend)
        } else {
            Theme.alertView(
                self,
                title: Constants.dataError,
                message: Constants.dataDoesNotExist
            )
        }
    }
    
    /// Transitions sequentialy between views by taping on the plot It also updates the segmented control accordingly
    @IBAction func tapTransition(sender: UITapGestureRecognizer) {
        
        // For all transitions originating from any view:
        // 1. Perform the transition
        // 2. Update the plot selector
        // 3. Update the global that holds which view is showing
        
        switch self.viewShowing {
        case Constants.painSelector:
            self.transition(fromView: self.painView, toView: self.sleepView)
            self.segmentedOptions.selectedSegmentIndex = Constants.sleepSelector
            self.viewShowing = Constants.sleepSelector
        case Constants.sleepSelector:
            self.transition(fromView: self.sleepView, toView: self.functionalityView)
            self.segmentedOptions.selectedSegmentIndex = Constants.functionalitySelector
            self.viewShowing = Constants.functionalitySelector
        case Constants.functionalitySelector:
            self.transition(fromView: self.functionalityView, toView: self.progressView)
            self.segmentedOptions.selectedSegmentIndex = Constants.progressSelector
            self.viewShowing = Constants.progressSelector
        default: // Progress view
            self.transition(fromView: self.progressView, toView: self.painView)
            self.segmentedOptions.selectedSegmentIndex = Constants.painSelector
            self.viewShowing = Constants.painSelector
        }
    }
    
    /// Manages transitions depending on the degment control selection
    @IBAction func segmentedControl(sender: UISegmentedControl) {
        
        // For all plot views:
        // 1. Handle all possible transitions landing to the view
        // 2. Update the global that holds which view is showing
        
        switch sender.selectedSegmentIndex {
        case Constants.painSelector:
            self.transition(fromView: self.functionalityView, toView: self.painView)
            self.transition(fromView: self.sleepView, toView: self.painView)
            self.transition(fromView: self.progressView, toView: self.painView)
            self.viewShowing = Constants.painSelector
        case Constants.sleepSelector:
            self.transition(fromView: self.painView, toView: self.sleepView)
            self.transition(fromView: self.functionalityView, toView: self.sleepView)
            self.transition(fromView: self.progressView, toView: self.sleepView)
            self.viewShowing = Constants.sleepSelector
        case Constants.functionalitySelector:
            self.transition(fromView: self.painView, toView: self.functionalityView)
            self.transition(fromView: self.sleepView, toView: self.functionalityView)
            self.transition(fromView: self.progressView, toView: self.functionalityView)
            self.viewShowing = Constants.functionalitySelector
        default: // Progress View
            self.transition(fromView: self.painView, toView: self.progressView)
            self.transition(fromView: self.sleepView, toView: self.progressView)
            self.transition(fromView: self.functionalityView, toView: self.progressView)
            self.viewShowing = Constants.progressSelector
        }
    }
    
    /// Controls the week or month plotting
    @IBAction func segmentedDaysToShow(sender: UISegmentedControl) {
        self.plotForWeekOrMonth(sender.selectedSegmentIndex)
    }
    
    // MARK: - Orientation Change Handling
    
    /// Handle orientation changes to reconfigure plot appearance
    func orientationDidChange(notification: NSNotification) {
        
        // Redraw the plot on any orientation change to avoid compression of the plot view from landscape to portrait
        self.plotForWeekOrMonth(self.segmentedWeekMonth.selectedSegmentIndex)
    }
    
    // MARK: - Notification subscriptions
    
    func subscribeToOrientationChangeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "orientationDidChange:",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil
        )
    }
    
    func unsubscribeToOrientationChangeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIDeviceOrientationDidChangeNotification,
            object: nil
        )
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
        Theme.navigationBar(self)
        Theme.tabBarColor(self)
        self.segmentedWeekMonth.tintColor = Theme.htSomon
        self.segmentedOptions.tintColor = Theme.htDarkGreen
        self.segmentedOptions.selectedSegmentIndex = Constants.painSelector
        self.configurePlots(Constants.daysInWeek)
    }
    
    func configurePlots(daysToShow: Int) {
        self.configurePainView(daysToShow)
        self.configureSleepView(daysToShow)
        self.configureFunctionalityView(daysToShow)
        self.configureProgressView(daysToShow)
    }
    
    // MARK: - Helpers
    
    /// Plot for week or month depending on user selection
    func plotForWeekOrMonth(selector: Int) {
        switch selector {
        case Constants.plotMonth:
            self.configurePlots(Constants.daysInMonth)
        default:
            self.configurePlots(Constants.daysInWeek)
        }
    }
    
    /// Control transition between plots
    func transition(fromView fromView: UIView, toView: UIView) {
        UIView.transitionFromView(fromView,
            toView: toView,
            duration: 1.0,
            options: [UIViewAnimationOptions.TransitionFlipFromLeft,
                UIViewAnimationOptions.ShowHideTransitionViews],
            completion: nil
        )
    }
}
