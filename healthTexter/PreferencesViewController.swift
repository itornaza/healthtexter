//
//  PreferencesViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 22/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import UIKit
import StoreKit

class PreferencesViewController:    UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource
{
    // MARK: - Properties
    
    // IAP products
    var products = [SKProduct]()
    
    /// Show proper and localized currency for the In-App Purchases
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    var refreshControl: UIRefreshControl!
    
    // MARK: - Outlets
    
    @IBOutlet weak var timePreferencesTitleLabel: UILabel!
    @IBOutlet weak var inAppPurchasesTitleLabel: UILabel!
    @IBOutlet weak var datePickerLabel: UILabel!
    @IBOutlet weak var switchDayPickerLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var switchDayPicker: UIDatePicker!
    @IBOutlet weak var iapTableView: UITableView!
    @IBOutlet weak var restoreLabel: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.subscribeToIAPNotifications()
    }
    
    /// Distructor
    deinit {
        self.unsubscribeFromIAPNotifications()
    }

    // MARK: - Actions
    
    /// Update the notification preference in user defaults
    @IBAction func datePickerChange(sender: UIDatePicker) {
        Date.setTimePreference(Date.getTimeFromPickerInSeconds(sender))
    }
    
    /// Update the day change time in user defaults
    @IBAction func switchDayPickerChange(sender: UIDatePicker) {
        Date.setDaySwitchPreference(Date.getTimeFromPickerInSeconds(sender))
    }
    
    /// Restore purchases to this device
    @IBAction func restoreTouchUp(sender: UIButton) {
        IAPProducts.store.restoreCompletedTransactions()
    }
    
    // MARK: - In-App Purchases Methods
    
    /// Subscribe to a notification that fires when a product is purchased. Removed on the deinit
    func subscribeToIAPNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(PreferencesViewController.productPurchased(_:)),
            name: IAPHelperProductPurchasedNotification,
            object: nil
        )
    }
    
    func unsubscribeFromIAPNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// Reload the Inn-App Purchase table with the available app products
    func reloadIAP() {
        
        // Flush any current products from the iapTableView
        self.products = []
        self.iapTableView.reloadData()
        
        // Fetch the current products from iTunes Connect
        IAPProducts.store.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products
                self.iapTableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Purchase the product
    func buyButtonTapped(button: UIButton) {
        let product = products[button.tag]
        IAPProducts.store.purchaseProduct(product)
    }
    
    /// When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(notification: NSNotification) {
        let productIdentifier = notification.object as! String
        for (index, product) in products.enumerate() {
            if product.productIdentifier == productIdentifier {
                iapTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                break
            }
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCellWithIdentifier("iapCell")! as UITableViewCell
        
        // Find the model object that corresponds to that row
        let product = products[indexPath.row]
        
        // Branch on the purchase status of the product
        if IAPProducts.store.isProductPurchased(product.productIdentifier) {
        
            // Item is purchased, show a checkmark
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.accessoryView = nil
            cell.detailTextLabel?.text = ""
            
        } else if IAPHelper.canMakePayments() {
            
            // Configure price locales
            self.priceFormatter.locale = product.priceLocale
            
            // Set up buy button for the row
            let buyButton = self.createBuyButtonForRow(indexPath.row)
            
            // Display buy button into the row for user to purchase
            cell.detailTextLabel?.text = priceFormatter.stringFromNumber(product.price)
            cell.accessoryType = .None
            cell.accessoryView = buyButton
            
        } else {
            
            // Display in the row that item is not available
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.accessoryView = nil
            cell.detailTextLabel?.text = "Not available"
            
        }
        
        // Set the cell custom labels
        cell.textLabel?.textColor = UIColor.grayColor()
        cell.textLabel?.text = product.localizedTitle
        
        // Set the color of the left checkboxes in editing mode
        cell.tintColor = Theme.htGreen
        
        // return the cell
        return cell
    }
    
    /// Create a buy button for each of the iapTableViewCells given their index
    func createBuyButtonForRow(buttonTag: Int) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 72, height: 37))
        button.setTitleColor(view.tintColor, forState: .Normal)
        button.setTitle("Buy", forState: .Normal)
        button.tag = buttonTag
        button.addTarget(self, action: #selector(
            PreferencesViewController.buyButtonTapped(_:)), forControlEvents: .TouchUpInside
        )
        return button
    }
    
    /// Add refresh control for the iapTableView
    func configureRefreshControl() {
        
        // Set up a refresh control, call reload to start things up
        self.refreshControl = UIRefreshControl()
        
        // Add the refreshControl to the iapTableView
        self.iapTableView.addSubview(self.refreshControl)
        
        // Configure the refreshControl
        self.refreshControl?.addTarget(self, action: #selector(
            PreferencesViewController.reloadIAP), forControlEvents: .ValueChanged
        )
        self.reloadIAP()
        self.refreshControl?.beginRefreshing()  // endRefreshing in the reloadIAP method
    }
    
    // MARK: - Configuration
    
    func configure() {
        self.configureRefreshControl()
        self.configureUI()
    }
    
    /// Configure Navigation and DatePickers
    func configureUI() {
        Theme.navigationBar(self, backgroundColor: Theme.preferencesColor)
        Theme.tabBarColor(self, color: Theme.preferencesColor)
        Theme.configureHookLabels(self.datePickerLabel)
        Theme.configureHookLabels(self.switchDayPickerLabel)
        self.timePreferencesTitleLabel.textColor = Theme.preferencesColor
        self.inAppPurchasesTitleLabel.textColor = Theme.preferencesColor
        self.restoreLabel.tintColor = Theme.preferencesColor
        self.configureDatePicker()
        self.configureSwitchDayPicker()
    }
    
    func configureDatePicker() {
        if let preference = Date.getTimePreference() {
            self.datePicker.date = NSDate(timeInterval: preference, sinceDate: Date.getTodayMidnight())
        }
    }
    
    func configureSwitchDayPicker() {
        if let preference = Date.getDaySwitchPreference() {
            self.switchDayPicker.date = NSDate(timeInterval: preference, sinceDate: Date.getTodayMidnight())
            self.switchDayPicker.maximumDate = NSDate(
                timeInterval: Constants.maxSwitchDayDelay, sinceDate: Date.getTodayMidnight()
            )
        }
    }
}
