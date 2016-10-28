//
//  IAPProducts.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 5/3/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation

// Using enum as a simple namespace. (It has no cases so you can't instantiate it.)
public enum IAPProducts {
    
    // Prefix with the App Bundle ID
    private static let Prefix = "gr.polarbear.healthTexter."
    
    // Supported Product Identifiers defined in itunesconnect
    public static let SharingOption = Prefix + "sharingOption"
    public static let UnlimitedEnties = Prefix + "unlimitedEntries"
    
    // All of the products assembled into a set of product identifiers.
    private static let productIdentifiers: Set<String> = [
        IAPProducts.SharingOption,
        IAPProducts.UnlimitedEnties
    ]
    
    // Static instance of IAPHelper that for all in-app products
    public static let store = IAPHelper(productIdentifiers: IAPProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
