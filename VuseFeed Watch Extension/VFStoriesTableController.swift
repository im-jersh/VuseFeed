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
    
    enum InterfaceState {
        case Loading, Results, NoResults
    }

    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var loadingGroup: WKInterfaceGroup!
    
    let jsonFileName = "Stories"
    var stories : [Story]? {
        didSet {
            if self.stories!.isEmpty { self.interfaceState = .NoResults }
            else {
                self.interfaceState = .Results
                self.loadTable(withStories: self.stories!)
            }
            
        }
    }
    
    var interfaceState = InterfaceState.Loading {
        didSet {
            self.loadingGroup.setHidden(true)
            self.table.setHidden(true)
            
            switch self.interfaceState {
            case .Loading :
                self.loadingGroup.setHidden(false)
                break
            case .Results :
                self.table.setHidden(false)
                break
            case .NoResults :
                
                break
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        
        super.awakeWithContext(context)
        
        VuseFeedEngine.delegate = self
        if let watchStories = VuseFeedEngine.watchStories {
            self.stories = watchStories
        }
        
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
        for story in self.stories! {
            if !categories.contains(story.category) {
                categories.append(story.category)
            }
        }
        
        // Sort the categories and add them to the table 
        categories = categories.sort({ $0.rawValue < $1.rawValue })
        for category in categories {
            self.addStoriesToTable(byCategory: category)
        }
        
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
            self.pushControllerWithName("StoryDetail", context: row.story)
        }
        
    }
    
    func addStoriesToTable(byCategory category: Category) {
        
        // Get the number of rows in the table already
        let rows = self.table.numberOfRows
        
        // Insert the category header row
        let headerIndex = NSIndexSet(index: rows)
        self.table.insertRowsAtIndexes(headerIndex, withRowType: "categoryLabel")
        if let headerRow = self.table.rowControllerAtIndex(rows) as? VFHeaderRowController {
            // Change the background and set the category label
            headerRow.rowGroup.setBackgroundColor(UIColor.colorForCategory(category))
            headerRow.categoryLabel.setText(category.rawValue.capitalizedString)
        }
        
        // Insert the story rows
        var storiesForCategory = [Story]()
        let _ = self.stories!.map{ // Get only the stories for this category
            if $0.category == category {
                storiesForCategory.append($0)
            }
        }
        storiesForCategory.sortInPlace{ $0.epochDate > $1.epochDate } // Sort them by publication date
        
        let storyRows = NSIndexSet(indexesInRange: NSRange(location: rows + 1, length: storiesForCategory.count))
        self.table.insertRowsAtIndexes(storyRows, withRowType: "storyRow")
        
        // Configure the rows
        for i in (rows+1)..<self.table.numberOfRows {
            
            // Get the row
            let row = self.table.rowControllerAtIndex(i)
            
            if let row = row as? VFStoryRowController {
                // Get the story for this row
                let story = storiesForCategory[i - rows - 1]
                
                // Attach the story to the row
                row.story = story
                
                // Set the thumbnail, headline, & author
                let rowColor = UIColor.colorForCategory(story.category)
                row.movie.setPosterImage(WKImage(image: story.thumbnail!))
                if let _ = story.watchVideoURL {
                    row.movie.setMovieURL(story.watchVideoURL!)
                }
                row.movie.setLoops(false)
                row.rowGroup.setBackgroundColor(rowColor.colorWithAlphaComponent(0.20))
                row.headlineLabel.setText(story.headline)
                
            }
        }
        
    }

}

extension VFStoriesTableController : VuseFeedEngineDelegate {
    
    func engine(engine: VuseFeedEngine, didCompleteFetchWithStories stories: [Story]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.stories = stories
        })
    }
    
}





























