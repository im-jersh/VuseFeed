//
//  CloudKitManager.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation
import CloudKit

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
            newStories.append(WatchableStory(fromRecord: record))
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
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
    
    func updateCompleteStory(story: WatchableStory, completion: (WatchableStory) -> Void) {
        
        print("UPDATE BEGAN AT : \(NSDate())")
        
        // Download the complete record with the convenience API
        self.publicDatabase.fetchRecordWithID(story.recordID) { (record, error) in
         
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
    
//    private func getLastFetchTime() -> NSDate {
//        
//        // Get the last fetch date from user defaults
//        guard let lastFetchTime = NSUserDefaults.standardUserDefaults().objectForKey("lastFetchTime") as? NSDate else {
//            return self.calculateDateInPast(daysAgo: self.daysAgo)
//        }
//        
//        return lastFetchTime
//        
//    }
    
//    private func calculateDateInPast(daysAgo days: Int = 1) -> NSDate {
//        
//        // Date of daysAgo from now (negative number indicates time in the past)
//        let pastDate = NSDate().dateByAddingTimeInterval(Double(daysAgo * -86400)) // number of days multiplied by number of seconds in a day
//        
//        // Decompose the date into its components
//        let calendar = NSCalendar.currentCalendar()
//        var components = calendar.components(<#T##unitFlags: NSCalendarUnit##NSCalendarUnit#>, fromDate: <#T##NSDate#>)
//        
//    }
}




















