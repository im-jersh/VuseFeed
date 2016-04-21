//
//  TestConnectivityInterfaceController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/19/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class TestConnectivityInterfaceController: WKInterfaceController {

    @IBOutlet var testButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.setupWatchConnectivity()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func testButtonWasTapped() {
        self.fetchStoriesInstantly()
    }
    
    
    
}

extension TestConnectivityInterfaceController : WCSessionDelegate {
    
    private func setupWatchConnectivity() {
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
                    guard let storyData = reply["watch_stories"] as? [[String : AnyObject]] else {
                        print("Could not extract the watch stories from the reply payload")
                        return
                    }
                    
                    // Convert the data to Stories
                    let stories = storyData.flatMap({ Story(withJSON: $0) })
                    print("There were \(stories.count) stories fetched")
                    
                    }, errorHandler: { (error : NSError) in
                        print("ERROR SENDING MESSAGE - CODE: \(error.code) - DESCRIPTION: \(error.localizedDescription)")
                })
                
            } else { self.showReachabilityError() }
            
        }
    }
    
    private func showReachabilityError() {
        let tryAgain = WKAlertAction(title: "Uh Oh", style: .Default, handler: { () -> Void in })
        let cancel = WKAlertAction(title: "Cancel", style: .Cancel, handler: { () -> Void in })
        self.presentAlertControllerWithTitle("Your iPhone is not reachable.", message: "Your stories cannot be loaded because your iPhone is not currently connected to your phone. Please ensure your iPhone is on and within range of your Watch.", preferredStyle: WKAlertControllerStyle.Alert, actions:[tryAgain, cancel])
    }
}
