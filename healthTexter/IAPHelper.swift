//
//  IAPHelper.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 4/3/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import StoreKit

/// Notification generated when a product is purchased
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Completion handler called when products are fetched
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()

// MARK: - IAPHelper Class

/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased, purchase products, and restore purchases. Uses NSUserDefaults to cache if a product has been purchased.
public class IAPHelper : NSObject  {
    
    // MARK: Private Properties
    
    // Used to keep track of the possible products and which ones have been purchased.
    private let productIdentifiers: Set<String>
    private var purchasedProductIdentifiers = Set<String>()
    
    // Used by SKProductsRequestDelegate
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
    
    // MARK: Constructor
    
    /// Initialize by mannualy providing the product identifiers
    public init(productIdentifiers: Set<String>) {
        self.productIdentifiers = productIdentifiers
        for productIdentifier in productIdentifiers {
            if NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier) {
                self.purchasedProductIdentifiers.insert(productIdentifier)
                print("Already purchased: \(productIdentifier)") // TODO: Remove after testing
            }
            else {
                print("Not purchased: \(productIdentifier)") // TODO: Remove after testing
            }
        }
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    // MARK: Methods
    
    /// Get the list of SKProducts from the Apple server
    public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
        self.completionHandler = handler
        
        // Keep a strong reference to the request
        self.productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    /// Initiates purchase of a product
    public func purchaseProduct(product: SKProduct) {
        print("Buying \(product.productIdentifier)...") // TODO: Remove after testing
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    /// Given the product identifier, returns true if that product has been purchased
    public func isProductPurchased(productIdentifier: String) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    /// If the state of whether purchases have been made is lost  (e.g. the user deletes and reinstalls the app) this will recover the purchases
    public func restoreCompletedTransactions() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    // MARK: Class Methods
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// MARK: - SKProductsRequestDelegates Extension

/// Get a list of products, their titles, descriptions, and prices from the Apple server
extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Loaded list of products...") // TODO: Remove after testing
        let products = response.products
        completionHandler?(success: true, products: products)
        clearRequest()
        
        // debug printing
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)") // TODO: Remove after testing
        }
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products.") // TODO: Remove after testing
        print("Error: \(error)") // TODO: Remove after testing
        clearRequest()
    }
    
    private func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver Extension

extension IAPHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly. For each transaction act accordingly, save in the purchased cache, issue notifications, mark the transaction as complete
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .Purchased:
                completeTransaction(transaction)
                break
            case .Failed:
                failedTransaction(transaction)
                break
            case .Restored:
                restoreTransaction(transaction)
                break
            case .Deferred:
                break
            case .Purchasing:
                break
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        print("completeTransaction...") // TODO: Remove after testing
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.originalTransaction!.payment.productIdentifier
        print("restoreTransaction... \(productIdentifier)") // TODO: Remove after testing
        provideContentForProductIdentifier(productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    private func provideContentForProductIdentifier(productIdentifier: String) {
        purchasedProductIdentifiers.insert(productIdentifier)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(
            IAPHelperProductPurchasedNotification,
            object: productIdentifier
        )
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("failedTransaction...") // TODO: Remove after testing
        if transaction.error!.code != SKErrorPaymentCancelled {
            print("Transaction error: \(transaction.error!.localizedDescription)") // TODO: Remove after testing
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}

// MARK: - Guards Extension

/// Handles the user access to features that are subject to in-app purchases
extension IAPHelper {
    
    /// Alert Controller used from the IAP Guard class methods
    class func IAPAlertController(vc: UIViewController, title: String, message: String) {
        
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // When the user clicks the action button segue to the Preferences View Controller. Where the user can perform the In-App Purchase
        let okAction = UIAlertAction(title: Constants.IAPbuttonTitle , style: UIAlertActionStyle.Default) { UIAlertAction in
            Theme.segueToTabBarController(vc, tabItemIndex: Constants.preferencesTab)
        }
        
        // Add the action to the alert controller
        alertController.addAction(okAction)
        
        alertController.view.tintColor = Theme.htSomon
        
        // Present the controller on the main queue
        NSOperationQueue.mainQueue().addOperationWithBlock {
            vc.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /// If the user reaches the maximum entries and have not purchased the Unlimited entries take her to the Preferences View Controller
    class func unlimitedEntriesGuard(vc: UIViewController, entries: Int) {
        let grantAccess: Bool = IAPProducts.store.isProductPurchased(IAPProducts.UnlimitedEnties)
        let reachedEntriesLimit: Bool = entries >= Constants.maxFreeEntries ? true : false
        
        if !grantAccess && reachedEntriesLimit {
            let title: String = Constants.IAPtitle
            let message: String = Constants.unlimitedEntriesMsg
            self.IAPAlertController(vc, title: title, message: message)
        }
    }
    
    /// If the sharing option is not yet purchased segue to the Preferences View Controller
    class func sharingOptionGuard(vc: UIViewController) {
        let grantAccess = IAPProducts.store.isProductPurchased(IAPProducts.SharingOption)
        print(IAPProducts.SharingOption)
        
        if !grantAccess {
            let title: String = Constants.IAPtitle
            let message: String = Constants.sharingOptionMsg
            self.IAPAlertController(vc, title: title, message: message)
        }
    }
}
