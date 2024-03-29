//
//  AppDelegate.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 3/24/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("initial_install") {
            // Let's set up the app
            VuseFeedEngine.sharedEngine.configureApplication()
        }
        
        // Seed the CloudKit database
        CloudKitManager.sharedManager().seedCloudKit()
        
        // Set up WatchConnectivity
        self.setupWatchConnectivity()
        
        // Request notification permissions
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        //self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.osteen.VuseFeed" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("VuseFeed", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("VuseFeed.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
            
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        // Get the userInfo
        guard let userInfo = userActivity.userInfo else {
            return true
        }
        print(userInfo)
        
        // Get the root controller to restore the state
        guard let storyListController = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? WatchableTableViewController else {
            return true
        }
        
        storyListController.restoreUserActivityState(userActivity)
        
        return true
    }

}

extension AppDelegate : WCSessionDelegate {
    
    private func setupWatchConnectivity() {
        
        // Ensure the device supports connectivity
        if WCSession.isSupported() {
            // Set the delegate and activate the session
            WCSession.defaultSession().delegate = self
            WCSession.defaultSession().activateSession()
            
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        // If there was a date passed in
        if let _ = message["fetch_date"] as? NSDate {
            
            // Fetch the latest videos
            do {
                try CloudKitManager.sharedManager().fetchStories(forDevice: .Watch, withCompletion: { (stories) in
                    
                    guard !stories.isEmpty else {
                        // Return an empty dictionary
                        replyHandler(["error_message" : "There were no stories returned."])
                        return
                    }
                    
                    // Extract each object's data for transport
                    let rawStoryData = stories.flatMap({ $0.convertToRawData() })

                    let replyDictionary = ["watch_stories" : rawStoryData]
                    
                    // Send the reply
                    replyHandler(replyDictionary)
                    
                })
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }

    }
    
    
    
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        
        // Check for a recordName
        if let recordName = userInfo["recordName"] as? String {
            CloudKitManager.sharedManager().saveBookmarkFromWatch(withRecordName: recordName)
        }
        
    }
    
}




















