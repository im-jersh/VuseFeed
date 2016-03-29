//
//  WatchableTableViewController.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit
import LNPopupController

class WatchableTableViewController: UITableViewController {
    
    @IBOutlet weak var categoriesButton: UIBarButtonItem!
    @IBOutlet weak var bookmarksButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let reuseIdentifier = "WatchableStoryCell"
    var stories : [WatchableStory]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch the stories from CloudKit and reload the table view when the results are returned
        CloudKitManager.sharedManager().fetchAllTestStories() { (fetchedStories: [WatchableStory]!) in
            self.stories = fetchedStories
        }
        
        self.tableView.estimatedRowHeight = 120.0
        //self.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.stories?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath)

        let story = self.stories?[indexPath.row]
        
        cell.textLabel?.text = story?.headline
        cell.detailTextLabel?.text = story?.author
        

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let popupController = self.storyboard?.instantiateViewControllerWithIdentifier("storyDetailController") as? StoryDetailViewController {
            popupController.story = self.stories![indexPath.row]
            popupController.popupItem.title = popupController.story.headline
            popupController.popupItem.subtitle = popupController.story.summary
            
            self.navigationController?.presentPopupBarWithContentViewController(popupController, openPopup: true, animated: true, completion: nil)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier, destVC = segue.destinationViewController as? StoryDetailViewController where identifier == "presentStoryDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow, story = self.stories?[indexPath.row] {
                // Set the destination story to the selected cell's story
                destVC.story = story
            }
            
        }
        
        //let viewController = segue.destinationViewController as! CategoriesViewController
        
    }

    @IBAction func categoriesTapped(sender: AnyObject) {
        print("categories tapped")
    }
    @IBAction func bookmarksTapped(sender: AnyObject) {
        print("bookmarks tapped")
    }
    @IBAction func settingsTapped(sender: AnyObject) {
        print("settings tapped")
    }

    @IBAction func unwindToNewsfeed(segue: UIStoryboardSegue){
        
    }
}
