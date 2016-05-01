//
//  BookmarkTableViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/10/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit
import LNPopupController
import CoreData
import DZNEmptyDataSet


class BookmarkTableViewController: WatchableTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reuseIdentifier = "BookmarkStoryCell"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func fetchStories() {
        
        // Fetch the stories from CloudKit and reload the table view when the results are returned
        do {
            try CloudKitManager.sharedManager().fetchStories(forDevice: .Phone, fromDatabase: CloudKitManager.sharedManager().privateDatabase, withCompletion: { (fetchedStories) in
                
                // Cast the result
                guard let fetchedStories = fetchedStories as? [WatchableStory] else {
                    print("Unable to cast result as WatchableStory array")
                    return
                }
                
                // Get the various DISTINCT category types for the section headers sorted alphabetically
                let categorySet = Set<Category>(fetchedStories.map{ $0.category })
                self.storySections = Array<Category>(categorySet).sort{ $0.rawValue < $1.rawValue }
                
                // Sort the fetched stories by category and then by publication date
                self.stories = fetchedStories.sort{
                    return ($0.category.rawValue == $1.category.rawValue) ? ($0.epochDate > $1.epochDate) : ($0.category.rawValue < $1.category.rawValue)
                }
                
            })

        } catch _ as NSError {
            // TODO: Handle exception
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get the stories corresponding to the section that this indexPath is in
        guard let category = self.storySections?[indexPath.section] else {
            return
        }
        
        // Filter the stories
        guard let filteredStories = self.stories?.filter({ $0.category.rawValue == category.rawValue }) else {
            return
        }
        
        if let popupController = self.storyboard?.instantiateViewControllerWithIdentifier("bookmarkViewController") as? BookmarkDetailViewController {
            popupController.story = filteredStories[indexPath.row]
            popupController.popupItem.title = popupController.story.headline
            popupController.popupItem.subtitle = popupController.story.summary
            popupController.delegate = self
            
            self.navigationController?.presentPopupBarWithContentViewController(popupController, openPopup: true, animated: true, completion: nil)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO:
            if let story = self.stories?.removeAtIndex(indexPath.row) {
                CloudKitManager.sharedManager().deleteStoryFromPrivateDatabase(story, withCompletionHandler: { (success) in
                    
                })
                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            
            // Delete story from user's private database
        }
    }
    
}


extension BookmarkTableViewController {

    
    override func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "You haven't saved any bookmarks yet!"
        
        let foregroundColor = self.nightMode ? UIColor.whiteColor() : UIColor.darkGrayColor()
        
        let attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName : foregroundColor]
        
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    
    override func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "When you see a story that you would like to come back to later, be sure to tap the bookmark icon and the story will be saved here. \n\nIf you believe this to be an error, tap the refresh button to load your bookmarks again."
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(14.0), NSForegroundColorAttributeName : UIColor.lightGrayColor(), NSParagraphStyleAttributeName : paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    
    override func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        
        self.fetchStories()
        
    }
    
}
































