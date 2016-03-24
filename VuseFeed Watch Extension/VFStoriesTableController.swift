//
//  VFStoriesTableController.swift
//  Watchable
//
//  Created by MU IT Program on 3/20/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit
import Foundation

struct CategoryColor {
    var category : String
    
    init(withCategory category: String) {
        self.category = category
    }
    
    func colorForCategory() -> UIColor {
        switch self.category {
        case "Local" :
            return UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1) // orange
        case "World" :
            return UIColor(red: 32/255, green: 148/255, blue: 250/255, alpha: 1) // blue
        case "Entertainment" :
            return UIColor(red: 255/255, green: 230/255, blue: 32/255, alpha: 1) // yellow
        default :
            return UIColor(red: 242/255, green: 244/255, blue: 255/255, alpha: 1) // grey
        }
    }
}


class VFStoriesTableController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    let jsonFileName = "Stories"
    var stories = [Story]()
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Create stories from the file
        self.stories = self.loadStoriesFromJSON(self.jsonFileName)
        
        // Get the categories
        var categories = [String]()
        for story in self.stories {
            if !categories.contains(story.category) {
                categories.append(story.category)
            }
        }
        
        // Add a refresh button
        self.table.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "vusefeedButton")
        let refreshRow = self.table.rowControllerAtIndex(0) as! VFButtonRowController
        refreshRow.button.setTitle("Refresh")
        
        // Sort the categories
        categories = categories.sort()
        for category in categories {
            self.addStoriesToTable(byCategory: category)
        }
        
        // Add a load more button
        let numRows = self.table.numberOfRows
        self.table.insertRowsAtIndexes(NSIndexSet(index: numRows), withRowType: "vusefeedButton")
        let loadMoreRow = self.table.rowControllerAtIndex(numRows) as! VFButtonRowController
        loadMoreRow.button.setTitle("Load More")
        
        // Scroll to hide the refresh button
        self.table.scrollToRowAtIndex(2)
        
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
    
    // Load stories from JSON file
    func loadStoriesFromJSON(fileName: String) -> [Story] {
        
        // Get path of JSON file
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!
        
        // Extract the file data into memory
        let data = NSData(contentsOfFile: path)!
        
        // Create JSON object
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [[String: AnyObject]]
        
        // Iterate through the json and create story objects
        var stories = [Story]()
        for jsonStory in json! {
            stories.append(Story(withJSON: jsonStory))
        }
        
        return stories
    }
    
    func addStoriesToTable(byCategory category: String) {
        
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
                row.rowGroup.setBackgroundColor(CategoryColor(withCategory: category).colorForCategory())
                row.categoryLabel.setText(category.capitalizedString)
                
            } else if let row = row as? VFStoryRowController {
                
                // Get the story for this row
                let story = storiesForCategory[i - rows - 1]
                
                // Attach the story to the row
                row.story = story
                
                // Set the thumbnail, headline, & author
                let rowColor = CategoryColor.init(withCategory: story.category).colorForCategory()
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































