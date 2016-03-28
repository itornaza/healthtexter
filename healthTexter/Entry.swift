//
//  Entry.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 9/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Entry: NSManagedObject {

    // MARK: - Properties

    struct Keys {
        static let date: String = "date"
        static let text: String = "text"
        static let painRank: String = "pain_rank"
        static let sleepRank: String = "sleep_rank"
        static let functionalityRank: String = "functionality_rank"
    }
    
    // MARK: - Core Data Attributes
    
    @NSManaged var date: NSDate
    @NSManaged var text: String
    
    // The next 3 ranks are defined as Int64 in xcdatamodeld file. In order to run to iPhones 4, 4s, 5 and 5s, and be represented as Int32, we have to use NSNumber for their definition. From there we get their intValue when needed
    @NSManaged var painRank: NSNumber
    @NSManaged var sleepRank: NSNumber
    @NSManaged var functionalityRank: NSNumber
    
    // MARK: - Constructors
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// Default constructor if all of the properties are known beforehand
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity from the Virtual_Tourist.xcdatamodeld
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
        
        // Insert the new Entry into the Core Data Stack
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Initialize the properties from a dictionary
        self.date = Date.get()
        self.text = dictionary[Keys.text] as! String
        self.painRank = dictionary[Keys.painRank] as! Int
        self.sleepRank = dictionary[Keys.sleepRank] as! Int
        self.functionalityRank = dictionary[Keys.functionalityRank] as! Int
    }
    
    /// Default constructor with only requiring the text area
    init(text: String, context: NSManagedObjectContext) {
        
        // Get the entity from the Virtual_Tourist.xcdatamodeld
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
        
        // Insert the new Entry into the Core Data Stack
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Initialize the Entity with the date and text
        self.date = Date.get()
        self.text = text
        
        // Set the ranks to a sentinel to indicate that they are not yet set
        self.painRank = Constants.defaultRank
        self.sleepRank = Constants.defaultRank
        self.functionalityRank = Constants.defaultRank
    }
    
    // MARK: - Class Methods
    
    /// Check if there is already an entry for today and return it
    class func getEntryIfExists(frc frc: NSFetchedResultsController) -> Entry? {
        let storedEntries = frc.fetchedObjects as! [Entry]
        let date_1 = Date.getFormatted(Date.get(), formatString: Date.dateFormatISO)
        for entry in storedEntries {
            let date_2 = Date.getFormatted(entry.date, formatString: Date.dateFormatISO)
            if  date_1 == date_2 {
                return entry
            }
        }
        return nil
    }
    
    /// Get all the entries stored in Core Data. Use self for the originator view controller
    class func getStoredEntries(vc vc: UIViewController, frc: NSFetchedResultsController) {
        // Get the entries or display error
        do {
            try frc.performFetch()
        } catch {
            Theme.alertView(
                vc,
                title: Constants.dataError,
                message: Constants.dataLoadingError
            )
        }
    }
    
    /// Get the current number of entries
    class func getStoredEntriesCount(frc: NSFetchedResultsController) -> Int {
        let sectionInfo = frc.sections![0]
        let numberOfEntries = sectionInfo.numberOfObjects
        return numberOfEntries
    }
    
    /// Format data of an entry in a string for the user to share
    class func prepareDataToShare(entry: Entry) -> String {
        return  "Date: \(Date.getFormatted(entry.date, formatString: Date.dateFormat) )\n" +
                "Pain: \(entry.painRank)\n" +
                "Sleep: \(entry.sleepRank)\n" +
                "Functionality: \(entry.functionalityRank)\n\n" +
                "\(entry.text)\n" +
                "\n---------\n\n"
    }
}
