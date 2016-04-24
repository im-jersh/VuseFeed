//
//  VuseFeedEngine.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/1/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation
import CoreData
import WatchConnectivity
import UIKit

protocol VuseFeedEngineDelegate {
    func engine(engine: VuseFeedEngine, didCompleteFetchWithStories stories: [Story])
}

class VuseFeedEngine : NSObject {
    
    // Singleton
    static let sharedEngine = VuseFeedEngine()
    private override init() { }
    
    static var watchStories : [Story]? {
        didSet {
            VuseFeedEngine.delegate?.engine(VuseFeedEngine.sharedEngine, didCompleteFetchWithStories: VuseFeedEngine.watchStories!)
        }
    }
    
    static var delegate : VuseFeedEngineDelegate?
    
    
#if os(iOS)
    // All the strings for the categories
    let allCategorieStrings = Set(["World","U.S.","Local","Politics","Science & Technology","Entertainment","Sports","Business","Health","Travel","Lifestyle","Education"])
    
    // All the possible Category enum values
    private(set) lazy var allCategories : Set<Category> = {
       return Set(self.allCategorieStrings.flatMap{ Category(rawValue: $0) })
    }()
    
    
    lazy var moc : NSManagedObjectContext = {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }()
    
    class func fetchAllCategories() throws -> [NSManagedObject] {
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = delegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        do {
            // We guarantee in the category selection controller that there will be at least on entity returned
            let fetchedEntities = try moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return fetchedEntities
        } catch let error as NSError {
            throw error
        }
        
    }
    
    // The selected Categories to show in the news feed
    private(set) lazy var newsFeedCategories : Set<Category> = {
        // Fetch the entities
        let fetchRequest = NSFetchRequest(entityName: "Category")
        do {
            let fetchedEntities = try self.moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            // Map the entities to Categories
            let categories = fetchedEntities.flatMap{ Category(rawValue: $0.valueForKey("category") as! String) }
            return Set(categories) // return a Set
        } catch {
            // TODO: Handle exception
        }
        
        return Set<Category>() // return empty Set
    }()

    func addCategory(category: Category) {
        // Add to the category set
        self.newsFeedCategories.insert(category)
        
        // Check to see if entity already exists
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "category", category.rawValue)
        let error : NSErrorPointer = nil
        if self.moc.countForFetchRequest(fetchRequest, error: error) == 1 { return } // Entity already exists; return
        
        // Save new record
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: self.moc)
        newEntity.setValue(category.rawValue, forKey: "category")
        
    }
    
    func removeCategory(category: Category) {
        // Remove from the category set
        self.newsFeedCategories.remove(category)
        
        // Delete entity from CoreData
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "category", category.rawValue)
        
        do {
            let fetchedEntities = try self.moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if let entityToDelete = fetchedEntities.first {
                self.moc.deleteObject(entityToDelete)
            }
        } catch {
            // TODO: Handle exception
        }
        
        // TODO: Unsubscribe CloudKit Notifications for this category
    }
    
#endif
    
}

extension VuseFeedEngine : WCSessionDelegate {
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session  = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    func fetchStoriesInstantly() {
        
        // Fetch the stories
        if WCSession.isSupported() {
            
            let session = WCSession.defaultSession()
            if session.reachable {
                let message = ["fetch_date" : NSDate()]
                
                // Send the request
                session.sendMessage(message, replyHandler: { (reply : [String : AnyObject]) in
                    
                    // Check for any errors
                    if let errorString = reply["error_message"] as? String {
                        print(errorString)
                        return
                    }
                    
                    // Extract the story data
                    guard let storyData = reply["watch_stories"] as? [NSData] else {
                        print("Could not extract the watch stories from the reply payload")
                        return
                    }
                    
                    // Convert the data to Stories
                    VuseFeedEngine.watchStories = storyData.flatMap({ Story(withData: $0) })
                    
                    }, errorHandler: { (error : NSError) in
                        print("ERROR SENDING MESSAGE - CODE: \(error.code) - DESCRIPTION: \(error.localizedDescription)")
                })
                
            } else {
                //self.showReachabilityError()
            }
            
        }
        
        
    }
    
    //    func fetchStoriesAndWait() {
    //
    //        if WCSession.isSupported() {
    //            let message = ["fetch_date" : NSDate()]
    //
    //            WCSession.defaultSession().transferUserInfo(message)
    //
    //        }
    //
    //    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        if let stories = userInfo["watch_stories"] {
            print(stories)
        }
    }

    
    
}