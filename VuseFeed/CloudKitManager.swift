//
//  CloudKitManager.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class CloudKitManager {
    
    // The number of days to set the current date back
    private let daysAgo : Int = 7;
    
    // Singleton
    private static let sharedInstance = CloudKitManager()
    private init() { }
    
    // Default container and public database
    private let defaultContainer = CKContainer.defaultContainer()
    private var publicDatabase : CKDatabase {
        return self.defaultContainer.publicCloudDatabase
    }
    
    class func sharedManager() -> CloudKitManager {
        return self.sharedInstance
    }
    
    
    
    // Fetch all story records
    func fetchAllTestStories(withCompletion completion: ([WatchableStory]!) -> Void) {
        
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Create the predicate and sort descriptor
        let predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        // Create the query
        let query = CKQuery(recordType: "Story", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        // Create the query operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["author", "category", "headline", "mainVideo", "publicationDate", "summary", "videoThumbnailString", "watchVideo", "videoThumbnail"]
        //operation.resultsLimit = 50
        
        var newStories = [WatchableStory]()
        
        // Set the per record completion block
        operation.recordFetchedBlock = { (record) in
            //print(record)
            newStories.append(WatchableStory(fromRecord: record))
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            // Unset the activity indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    print("FETCH COMPLETE AT : \(NSDate())")
                    completion(newStories)
                }
            }
        }
        
        print("FETCH BEGAN AT : \(NSDate())")
        self.publicDatabase.addOperation(operation)
    }
    
    func fetchStories(withCompletion completion: ([WatchableStory]!) -> Void) throws {
    
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Create the predicate and sort descriptor
        var predicate : NSPredicate
        do {
            predicate = try self.constructCategoriesFetchPredicate()
        } catch let error as NSError {
            throw error
        }
        
        let sortDescriptor = NSSortDescriptor(key: "publicationDate", ascending: false)
        
        // Create the query
        let query = CKQuery(recordType: "Story", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        // Create the query operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["author", "category", "headline", "mainVideo", "publicationDate", "summary", "videoThumbnailString", "watchVideo", "videoThumbnail"] // all fields except the watch video asset
        
        var newStories = [WatchableStory]()
        
        // Per record completion block
        operation.recordFetchedBlock = { (record) in
            newStories.append(WatchableStory(fromRecord: record))
        }
        
        // Query completion block
        operation.queryCompletionBlock = { (curser, error) in
         
            // Unset the activity indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error == nil {
                // Save the latest fetch date
                self.setLastFetchTime()
                
                // Dispatch the results to the UI for display
                dispatch_async(dispatch_get_main_queue()) {
                    print("FETCH COMPLETE AT : \(NSDate())")
                    completion(newStories)
                }
            }
            
        }
        
        // Start the query
        print("FETCH BEGAN AT : \(NSDate())")
        self.publicDatabase.addOperation(operation)
    }
    
    func updateCompleteStory(story: WatchableStory, completion: (WatchableStory) -> Void) {
        
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Download the complete record with the convenience API
        self.publicDatabase.fetchRecordWithID(story.recordID) { (record, error) in
            // Unset the activity indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
         
            if error == nil {
                if let record = record {
                    // Update the story
                    story.updateStory(withRecord: record)
                    
                    // Dispatch the updates to the UI thread
                    dispatch_async(dispatch_get_main_queue()) {
                        print("UPDATE COMPLETE AT : \(NSDate())")
                        completion(story)
                    }
                }
            }
        }
    }
    
    // Helper function
    private func setLastFetchTime() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastFetchTime")
    }
    
    private func getLastFetchTime() -> NSDate {
        
        // Get the last fetch date from user defaults
        guard let lastFetchTime = NSUserDefaults.standardUserDefaults().objectForKey("lastFetchTime") as? NSDate else {
            return self.calculateDateInPast()
        }
        
        return lastFetchTime
    }
    
    private func calculateDateInPast(hoursAgo hours: Int = 36) -> NSDate {
        
        // Calculate the number of seconds in the past
        let seconds = Double(60 * 60 * hours)
        
        // Date of hoursAgo from now (negative number indicates time in the past)
        return NSDate().dateByAddingTimeInterval(-(seconds))
    }
    
    private func constructCategoriesFetchPredicate() throws -> NSPredicate {
        
        // Fetch the categories from CoreData
        var fetchedEntities = [NSManagedObject]()
        do {
            // We guarantee in the category selection controller that there will be at least on entity returned
            fetchedEntities = try VuseFeedEngine.fetchAllCategories()
            
            // Form the two predicates
            let datePredicate = NSPredicate(format: "%K >= %lf", "publicationDate",self.calculateDateInPast().timeIntervalSince1970)
            
            let categories = fetchedEntities.flatMap{ $0.valueForKey("category") }
            let categoryPredicate = NSPredicate(format: "%K IN %@", "category", categories)
            
            // Return a compound `AND` predicate
            return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, categoryPredicate])
        } catch let error as NSError {
            throw error
        }
        
    }
    
}




















