//
//  PreferencesViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 22/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import UIKit
import StoreKit

class PreferencesViewController: UIViewController {
    
    // MARK: - Properties
    
    // IAP products
    var products = [SKProduct]()
    
    /// Show proper and localized currency for the In-App Purchases
    lazy var priceFormatter: NumberFormatter = {
        let pf = NumberFormatter()
        pf.formatterBehavior = .behavior10_4
        pf.numberStyle = .currency
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Theme.tabBarColor(vc: self, color: Theme.preferencesColor)
    }
    
    /// Destructor
    deinit {
        self.unsubscribeFromIAPNotifications()
    }

    // MARK: - Actions
    
    /// Update the notification preference in user defaults
    @IBAction func datePickerChange(sender: UIDatePicker) {
        Date.setTimePreference(ti: Date.getTimeFromPickerInSeconds(sender: sender))
    }
    
    /// Update the day change time in user defaults
    @IBAction func switchDayPickerChange(sender: UIDatePicker) {
        Date.setDaySwitchPreference(ti: Date.getTimeFromPickerInSeconds(sender: sender))
    }
    
    /// Restore purchases to this device
    @IBAction func restoreTouchUp(sender: UIButton) {
        IAPProducts.store.restoreCompletedTransactions()
    }
    
    // MARK: - In-App Purchases Notifications
    
    /// Subscribe to a notification that fires when a product is purchased. Removed on the deinit
    func subscribeToIAPNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PreferencesViewController.productPurchased(notification:)),
            name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification),
            object: nil
        )
    }
    
    func unsubscribeFromIAPNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configuration
    
    func configure() {
        self.configureRefreshControl()
        self.configureUI()
    }
    
    /// Configure Navigation and DatePickers
    func configureUI() {
        Theme.navigationBar(vc: self, backgroundColor: Theme.preferencesColor)
        Theme.configureHookLabels(label: self.datePickerLabel)
        Theme.configureHookLabels(label: self.switchDayPickerLabel)
        self.timePreferencesTitleLabel.textColor = Theme.preferencesColor
        self.inAppPurchasesTitleLabel.textColor = Theme.preferencesColor
        self.restoreLabel.tintColor = Theme.preferencesColor
        self.configureDatePicker()
        self.configureSwitchDayPicker()
    }
    
    func configureDatePicker() {
        if let preference = Date.getTimePreference() {
            self.datePicker.date = NSDate(timeInterval: preference, sinceDate: Date.getTodayMidnight() as Date) as Date
        }
    }
    
    func configureSwitchDayPicker() {
        if let preference = Date.getDaySwitchPreference() {
            self.switchDayPicker.date = NSDate(timeInterval: preference, sinceDate: Date.getTodayMidnight() as Date) as Date
            self.switchDayPicker.maximumDate = NSDate(
                timeInterval: Constants.maxSwitchDayDelay, sinceDate: Date.getTodayMidnight() as Date
            ) as Date
        }
    }
}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table, using the reuse identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "iapCell")! as UITableViewCell
        
        // Find the model object that corresponds to that row
        let product = products[indexPath.row]
        
        // Branch on the purchase status of the product
        if IAPProducts.store.isProductPurchased(productIdentifier: product.productIdentifier) {
            
            // Item is purchased, show a checkmark
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.accessoryView = nil
            cell.detailTextLabel?.text = ""
            
        } else if IAPHelper.canMakePayments() {
            
            // Configure price locales
            self.priceFormatter.locale = product.priceLocale
            
            // Set up buy button for the row
            let buyButton = self.createBuyButtonForRow(buttonTag: indexPath.row)
            
            // Display buy button into the row for user to purchase
            cell.detailTextLabel?.text = priceFormatter.string(from: product.price)
            cell.accessoryType = .none
            cell.accessoryView = buyButton
            
        } else {
            
            // Display in the row that item is not available
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.accessoryView = nil
            cell.detailTextLabel?.text = "Not available"
            
        }
        
        // Set the cell custom labels
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.text = product.localizedTitle
        
        // Set the color of the left checkboxes in editing mode
        cell.tintColor = Theme.preferencesColor
        
        // return the cell
        return cell
    }
    
    /// Create a buy button for each of the iapTableViewCells given their index
    func createBuyButtonForRow(buttonTag: Int) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 72, height: 37))
        button.setTitleColor(view.tintColor, for: .normal)
        button.setTitle("Buy", for: .normal)
        button.tag = buttonTag
        button.addTarget(self, action: #selector(
            PreferencesViewController.buyButtonTapped(button:)), for: .touchUpInside
        )
        return button
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
        IAPProducts.store.purchaseProduct(product: product)
    }
    
    /// When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(notification: NSNotification) {
        let productIdentifier = notification.object as! String
        for (index, product) in products.enumerated() {
            if product.productIdentifier == productIdentifier {
                iapTableView.reloadRows(at: [NSIndexPath(row: index, section: 0) as IndexPath], with: .fade)
                break
            }
        }
    }
    
    /// Add refresh control for the iapTableView
    func configureRefreshControl() {
        // Set up a refresh control, call reload to start things up
        self.refreshControl = UIRefreshControl()
        
        // Add the refreshControl to the iapTableView
        self.iapTableView.addSubview(self.refreshControl)
        
        // Configure the refreshControl
        self.refreshControl?.addTarget(self, action: #selector(
            PreferencesViewController.reloadIAP), for: .valueChanged
        )
        self.reloadIAP()
        self.refreshControl?.beginRefreshing()  // endRefreshing in the reloadIAP method
    }
}
