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


class BookmarkTableViewController: WatchableTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

// MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.storySections?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Filter the stories by the category represented by the section
        guard let category = self.storySections?[section] else {
            return 0
        }
        
        return self.stories?.filter{ $0.category.rawValue == category.rawValue }.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        guard let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier) as? VFStoryListCell else {
            return tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath)
        }
        
        // Get the stories corresponding to the section that this indexPath is in
        guard let category = self.storySections?[indexPath.section] else {
            return cell
        }
        
        let filteredStories = self.stories?.filter{ $0.category.rawValue == category.rawValue }
        
        // Extract the story from the filtered set
        if let story = filteredStories?[indexPath.row] {
            
            cell.headlineLabel.text = story.headline
            cell.authorLabel.text = story.author
            cell.pubDateLabel.text = NSDateFormatter.localizedStringFromDate(story.pubDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            if let imageURL = story.thumbnailImageURL {
                cell.thumbnailImage.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "placeholder"))
            }
            
            return cell
        }
        
        return cell
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
        
        if let popupController = self.storyboard?.instantiateViewControllerWithIdentifier("storyDetailController") as? StoryDetailViewController {
            popupController.story = filteredStories[indexPath.row]
            popupController.popupItem.title = popupController.story.headline
            popupController.popupItem.subtitle = popupController.story.summary
            
            self.navigationController?.presentPopupBarWithContentViewController(popupController, openPopup: true, animated: true, completion: nil)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.storySections?[section].rawValue ?? "Category"
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create the view
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 24.0))
        
        guard let category = self.storySections?[section] else {
            return nil
        }
        
        header.backgroundColor = UIColor.colorForCategory(category)
        
        // Create the Label
        let label = UILabel(frame: CGRect(x: 15.0, y: 1.0, width: self.view.frame.width - 15.0, height: 24.0))
        label.text = self.storySections?[section].rawValue ?? "Category"
        
        // Add the label to the view
        header.addSubview(label)
        
        return header
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
