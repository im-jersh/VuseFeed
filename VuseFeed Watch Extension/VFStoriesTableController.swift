//
//  VFStoriesTableController.swift
//  Watchable
//
//  Created by MU IT Program on 3/20/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class VFStoriesTableController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    let jsonFileName = "Stories"
    var stories = [Story]()
    
    
    override func awakeWithContext(context: AnyObject?) {
        
        super.awakeWithContext(context)
        
        self.setupWatchConnectivity()
        self.fetchStoriesInstantly()
        
    }
    
    override func didAppear() {
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func loadTable(withStories stories: [Story]) {
        
        // Get the categories
        var categories = [Category]()
        for story in self.stories {
            if !categories.contains(story.category) {
                categories.append(story.category)
            }
        }
        
        // Add a refresh button
        self.table.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "vusefeedButton")
        if let refreshRow = self.table.rowControllerAtIndex(0) as? VFButtonRowController {
            refreshRow.button.setTitle("Refresh")
        }
        
        // Sort the categories
        categories = categories.sort({ $0.rawValue < $1.rawValue })
        for category in categories {
            self.addStoriesToTable(byCategory: category)
        }
        
        // Add a load more button
        let numRows = self.table.numberOfRows
        self.table.insertRowsAtIndexes(NSIndexSet(index: numRows), withRowType: "vusefeedButton")
        if let loadMoreRow = self.table.rowControllerAtIndex(numRows) as? VFButtonRowController {
            loadMoreRow.button.setTitle("Load More")
        }
        
        
        // Scroll to hide the refresh button
        self.table.scrollToRowAtIndex(2)
        
    }
    
    private func showReachabilityError() {
        let tryAgain = WKAlertAction(title: "Uh Oh", style: .Default, handler: { () -> Void in })
        let cancel = WKAlertAction(title: "Cancel", style: .Cancel, handler: { () -> Void in })
        self.presentAlertControllerWithTitle("Your iPhone is not reachable.", message: "Your stories cannot be loaded because your iPhone is not currently connected to your phone. Please ensure your iPhone is on and within range of your Watch.", preferredStyle: WKAlertControllerStyle.Alert, actions:[tryAgain, cancel])
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        // Get the row
        let row = self.table.rowControllerAtIndex(rowIndex)
        
        if let row = row as? VFStoryRowController {
            
            // Create and present a movie controller if this story has a video attached to us
            if let story = row.story, _ = story.watchVideoURL {
                //self.pushControllerWithName("movieController", context: story)
                let options = [WKMediaPlayerControllerOptionsAutoplayKey : true, WKMediaPlayerControllerOptionsLoopsKey : false]
                self.presentMediaPlayerControllerWithURL(story.watchVideoURL!, options: options, completion: { (didPlayToEnd, endTime, error) -> Void in
                    print("VIDEO DID END")
                })
            }
            
        }
        
    }
    
    func addStoriesToTable(byCategory category: Category) {
        
        // Get the number of rows in the table already
        let rows = self.table.numberOfRows
        
        // Insert the category header row
        let headerIndex = NSIndexSet(index: rows)
        self.table.insertRowsAtIndexes(headerIndex, withRowType: "categoryLabel")
        
        // Insert the story rows
        var storiesForCategory = [Story]()
        let _ = self.stories.map{ // get only the stories for this category
            if $0.category == category {
                storiesForCategory.append($0)
            }
        }
        storiesForCategory.sortInPlace{ $0.pubDateEpoch > $1.pubDateEpoch }
        
        let storyRows = NSIndexSet(indexesInRange: NSRange(location: rows + 1, length: storiesForCategory.count))
        self.table.insertRowsAtIndexes(storyRows, withRowType: "storyRow")
        
        // Configure the rows
        for i in rows..<self.table.numberOfRows {
            
            // Get the row
            let row = self.table.rowControllerAtIndex(i)
            
            // Configure the controller based on its type
            if let row = row as? VFHeaderRowController {
                
                // Change the background and set the category label
                row.rowGroup.setBackgroundColor(UIColor.colorForCategory(category))
                row.categoryLabel.setText(category.rawValue.capitalizedString)
                
            } else if let row = row as? VFStoryRowController {
                
                // Get the story for this row
                let story = storiesForCategory[i - rows - 1]
                
                // Attach the story to the row
                row.story = story
                
                // Set the thumbnail, headline, & author
                let rowColor = UIColor.colorForCategory(story.category)
                //row.thumbnailImage.setImage(UIImage(named: String(story.pubDateEpoch)))
                row.movie.setPosterImage(WKImage(image: UIImage(named: String(story.pubDateEpoch))!))
                if let _ = story.watchVideoURL {
                    row.movie.setMovieURL(story.watchVideoURL!)
                }
                row.movie.setLoops(false)
                row.rowGroup.setBackgroundColor(rowColor.colorWithAlphaComponent(0.20))
                row.headlineLabel.setText(story.headline)
                row.authorLabel.setText(story.author)
                
            }
            
            
        }
        
    }

}

extension VFStoriesTableController : WCSessionDelegate {
    
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
                    self.stories = storyData.flatMap({ Story(withJSON: $0) })
                    self.loadTable(withStories: self.stories)
                    
                    }, errorHandler: { (error : NSError) in
                        print("ERROR SENDING MESSAGE - CODE: \(error.code) - DESCRIPTION: \(error.localizedDescription)")
                })
                
            } else { self.showReachabilityError() }
            
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































