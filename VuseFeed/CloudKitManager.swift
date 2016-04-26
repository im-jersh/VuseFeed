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

enum Device {
    case Phone, Watch
}

class CloudKitManager {
    
    // The number of days to set the current date back
    private let daysAgo : Int = 7;
    
    // Singleton
    private static let sharedInstance = CloudKitManager()
    private init() { }
    
    // Default container and public database
    private let defaultContainer = CKContainer.defaultContainer()
    var publicDatabase : CKDatabase {
        return self.defaultContainer.publicCloudDatabase
    }
    var privateDatabase : CKDatabase {
        return self.defaultContainer.privateCloudDatabase
    }
    
    class func sharedManager() -> CloudKitManager {
        return self.sharedInstance
    }
    
    
    // Check if there are records; upload all stories if not.
    func seedCloudKit() {
        
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Check if there are any records
        let predicate = NSPredicate(format: "%K >= %lf", "publicationDate", self.calculateDateInPast())
        let query = CKQuery(recordType: "Story", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "publicationDate", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["publicationDate"]
        operation.resultsLimit = 1
        
        var seedRequired = false
        operation.recordFetchedBlock = { (record) in
            // There was at least 1 story
            seedRequired = true
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            guard !seedRequired else {
                return
            }
            
            print("SEEDING CLOUDKIT.....")
            
            // Fetch all the records
            let truePred = NSPredicate(value: true)
            let allRecordsQuery = CKQuery(recordType: "Story", predicate: truePred)
            
            self.publicDatabase.performQuery(allRecordsQuery, inZoneWithID: nil, completionHandler: { (records: [CKRecord]?, error: NSError?) in
                
                guard let records = records where error == nil else {
                    print("ERROR FETCHING ALL RECORDS")
                    return
                }
                
                // Get the recordIDs of the returned records
                let deleteRecordIDs = records.flatMap({ $0.recordID })
                
                // Parse the stories.json file into CKRecords
                let storyRecords = self.parseStoriesFromFile()
                let videoRecords = self.parseStoriesFromFile("videos")
                
                // Save the new records and delete the old records
                self.saveRecords(storyRecords + videoRecords, andDeleteRecords: deleteRecordIDs)
                
            })
            
        }

        self.publicDatabase.addOperation(operation)
    }
    
    // Loads the story data from JSON file and creates CKRecords from that data
    private func parseStoriesFromFile(filename: String = "stories") -> [CKRecord] {
        
        // Get path of JSON file
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json")!
        
        // Extract the file data into memory
        let data = NSData(contentsOfFile: path)!
        
        // Create JSON object
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [[String: AnyObject]]
        
        //print(json)
        
        // Iterate through the json and create story objects
        var storyRecords = [CKRecord]()
        for (index, jsonStory) in json!.shuffle().enumerate() {
            
            // extract the json data for each story
            guard let author = jsonStory["AUTHOR"] as? String, category = jsonStory["CATEGORY"] as? String, summary = jsonStory["SUMMARY"] as? String, headline = jsonStory["HEADLINE"] as? String, imageLink = jsonStory["IMAGE_LINK"] as? String, article = jsonStory["ARTICLE"] as? NSString else {
                continue
            }
            
            // Create a file in the tmp directory for the article asset
            let tempFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent("\(headline.hashValue).txt")
            do {
                try article.writeToURL(tempFileURL, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                print(error.localizedDescription)
                continue
            }
            
            // Create the asset
            let articleAsset = CKAsset(fileURL: tempFileURL)
            
            // Create a story record
            let storyRecord = CKRecord(recordType: "Story")
            storyRecord.setValue(articleAsset, forKey: "article")
            storyRecord.setValue(author, forKey: "author")
            storyRecord.setValue(category, forKey: "category")
            storyRecord.setValue(summary, forKey: "summary")
            storyRecord.setValue(headline, forKey: "headline")
            storyRecord.setValue(imageLink, forKey: "videoThumbnailString")
            
            // Extract any video data if present
            if let videoURL = jsonStory["VIDEO"] as? String {
                storyRecord.setValue(videoURL, forKey: "mainVideo")
            }
            
            if let watchURL = jsonStory["WATCH"] as? String {
                storyRecord.setValue(watchURL, forKey: "watchVideo")
            }
            
            // Save the date
            let nowDouble = NSDate().timeIntervalSince1970
            let multiplier = Double(index * 5000)
            let dateDouble = Double(nowDouble - multiplier)
            storyRecord.setValue(dateDouble, forKey: "publicationDate")
            
            // Append the record for saving
            storyRecords.append(storyRecord)
        }
        
        print("\(storyRecords.count) CKRECORDS TO SAVE")
        
        return storyRecords
    }
    
    // Saves a batch of records to a CloudKit datase
    func saveRecords(saveRecords: [CKRecord]?,andDeleteRecords deleteRecords: [CKRecordID]?, toDatabase database: CKDatabase = CKContainer.defaultContainer().publicCloudDatabase) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Create the save operation
        let saveOperation = CKModifyRecordsOperation(recordsToSave: saveRecords, recordIDsToDelete: deleteRecords)
        saveOperation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecords, error) in
            print("\(savedRecords?.count ?? 0) CKRECORDS WERE SAVED AND \(deleteRecords?.count ?? 0) WERE DELETED")
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            // Update the UI
            dispatch_async(dispatch_get_main_queue()) {
                // Get the delegate and the root nagivation controller
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let rootNavigationController = delegate.window?.rootViewController as? UINavigationController
                
                // Get the newsfeed and fetch the newly uploaded records.
                if let newsFeed = rootNavigationController?.viewControllers.first as? WatchableTableViewController {
                    newsFeed.fetchStories()
                }
            }
        }
        
        // Run the operation
        self.publicDatabase.addOperation(saveOperation)
        
    }
    
    // Fetch all stories by category that were published within the last 36hrs
    func fetchStories(forDevice device: Device,fromDatabase database: CKDatabase = CKContainer.defaultContainer().publicCloudDatabase, withCompletion completion: ([Story]!) -> Void) throws {
    
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Create the predicate and sort descriptor
        var predicate : NSPredicate
        do {
            predicate = try self.constructCategoriesFetchPredicate(forDevice: device)
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
            if let story = WatchableStory(fromRecord: record) {
                newStories.append(story)
            }
        }
        
        // Query completion block
        operation.queryCompletionBlock = { (curser, error) in
         
            // Unset the activity indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error == nil {
                // Save the latest fetch date
                self.setLastFetchTime(forDevice: device)
                
                // If the data is for the Watch, convert the stories to the appropriate object
                if device == .Watch {
                    let watchStories = newStories.flatMap({ $0 as Story })
                    completion(watchStories)
                }
                
                // Dispatch the results to the UI for display
                dispatch_async(dispatch_get_main_queue()) {
                    print("FETCH COMPLETE AT : \(NSDate())")
                    completion(newStories)
                }
            }
        }
        
        // Start the query
        print("FETCH BEGAN AT : \(NSDate())")
        database.addOperation(operation)
    }
    
    // Update the story with it's assets
    func updateCompleteStory(story: WatchableStory, fromDatabase database: CKDatabase = CKContainer.defaultContainer().publicCloudDatabase, completion: (WatchableStory) -> Void) {
        
        // Set the network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Download the complete record with the convenience API
        database.fetchRecordWithID(story.cloudKitRecord.recordID) { (record, error) in
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
    
    // Save the record to the user's private database
    func saveStoryToPrivateDatabase(story: WatchableStory, withCompletionHandler completion: (success : Bool, message: String?) -> Void) {
        
        // Let's first make sure we have a complete record first
        if story.article == nil {
            self.updateCompleteStory(story) { [unowned self] (updatedStory) in
                self.saveStoryToPrivateDatabase(updatedStory, withCompletionHandler: completion)
            }
        }
        
        // Once we have a complete record, we need to create a copy of it in order to save a record with a unique recordID
        guard let recordCopy = story.createDuplicateCloudKitRecord() else {
            completion(success: false, message: "We weren't able to save your bookmarked story.")
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("SAVING BOOKMARK...")
        
        self.privateDatabase.saveRecord(recordCopy) { (record, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error != nil {
                    print(error?.localizedDescription)
                    
                    // If the error code was 14, then the bookmark has already been saved to the user's private database before
                    if error!.code == 14 {
                        completion(success: false, message: "It looks like you've already bookmarked this story.")
                    } else {
                        completion(success: false, message: "We weren't able to save your bookmarked story.")
                    }
                    
                } else {
                    print("BOOKMARK SAVED!")
                    completion(success: true, message: nil)
                }
            })
        }
        
    }
    
    // Deletes the record from the user's private database
    func deleteStoryFromPrivateDatabase(story: WatchableStory, withCompletionHandler completion: (success : Bool) -> Void) {
        print("DELETING RECORD...")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let record = story.cloudKitRecord
        
        self.privateDatabase.deleteRecordWithID(record.recordID) { (recordID, error) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error != nil {
                    completion(success: false)
                } else {
                    print("RECORD DELETED!")
                    completion(success: true)
                }
            })
        }
    }
    
    func saveStoryToPublicDatabase(story: WatchableStory) {
        
        
        
    }
    
    // Fetch a single record by its record name
    func fetchStory(withRecordName recordName: String, withCompletionHandler completion: (Story?) -> Void) {
        
        // Create the recordID from the recordName
        let recordID = CKRecordID(recordName: recordName)
        
        // Fetch the record
        self.publicDatabase.fetchRecordWithID(recordID) { (record: CKRecord?, error: NSError?) in
            
            guard let record = record where error == nil else {
                print("Error fetching record with ID: \(recordID.recordName)")
                return
            }
            
            // Make a Story from the record
            let story = WatchableStory(fromRecord: record)
            //story?.updateStory(withRecord: record)
            
            completion(story)
            
        }
        
    }
    
    // Deletes a batch of stories from the supplied database
    func deleteRecords(withIDs IDs: [CKRecordID], fromDatabase database: CKDatabase = CKContainer.defaultContainer().publicCloudDatabase) {
        
        
    }
    
}

extension CloudKitManager {
    
    private func setLastFetchTime(forDevice device: Device) {
        
        let key = device == .Phone ? "last_phone_fetch_time" : "last_watch_fetch_time"
        
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: key)
    }
    
    private func getLastFetchTime(forDevice device: Device) -> NSDate {
        
        let key = device == .Phone ? "last_phone_fetch_time" : "last_watch_fetch_time"
        
        // Get the last fetch date from user defaults
        guard let lastFetchTime = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSDate else {
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
    
    private func constructCategoriesFetchPredicate(forDevice device: Device) throws -> NSPredicate {
        
        // Fetch the categories from CoreData
        var fetchedEntities = [NSManagedObject]()
        do {
            // We guarantee in the category selection controller that there will be at least on entity returned
            fetchedEntities = try VuseFeedEngine.fetchAllCategories()
            
            // Form the two predicates
            let datePredicate = NSPredicate(format: "%K >= %lf", "publicationDate",self.calculateDateInPast().timeIntervalSince1970)
            
            let categories = fetchedEntities.flatMap{ $0.valueForKey("category") }
            let categoryPredicate = NSPredicate(format: "%K IN %@", "category", categories)
            
            _ = NSPredicate(format: "watchVideo != %@", nil as COpaquePointer)
            
            // Return a compound `AND` predicate
            if device == .Watch { return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, categoryPredicate]) }
            else { return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, categoryPredicate]) }
            
        } catch let error as NSError {
            throw error
        }
        
    }
    
}

extension CollectionType {
    
    // Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
    
}

extension MutableCollectionType where Index == Int {
    
    // Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }

}
































