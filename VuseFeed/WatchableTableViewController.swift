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
import CoreData


class WatchableTableViewController: UITableViewController {
    
    @IBOutlet weak var categoriesButton: UIBarButtonItem!
    @IBOutlet weak var bookmarksButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var nightMode = false
    private var context : UInt8 = 37
    
    var reuseIdentifier = "WatchableStoryCell"
    var stories : [WatchableStory]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var storySections : [Category]?
    
    lazy var moc : NSManagedObjectContext = {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchStories()
        
        // Dynamic cell height based on content
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200.0
        
        // Make the popupcontroller bar title bold
        LNPopupBar.appearanceWhenContainedInInstancesOfClasses([UINavigationController.self]).titleTextAttributes = [ NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0)]
        
        // Add an action to the refresh control
        self.refreshControl?.addTarget(self, action: #selector(WatchableTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Observe for night mode changes
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "night_mode", options: .New, context: &self.context)
        self.nightMode = NSUserDefaults.standardUserDefaults().boolForKey("night_mode")
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.shouldSwitchToNightMode(self.nightMode)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.nightMode ? .LightContent : .Default
    }
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        
        self.navigationController?.popToViewController(self, animated: true)
        
        let handoff = Handoff()
        switch activity.activityType {
        case Handoff.ActivityTypes.ViewStory.rawValue :
            
            // Get the record name from the activity's userInfo
            guard let recordName = activity.userInfo?[handoff.activityKey] as? String else {
                print("Error extracting record name")
                return
            }
            
            // Fetch the record
            CloudKitManager.sharedManager().fetchStory(withRecordName: recordName, withCompletionHandler: { (story: Story?) in
                
                guard let story = story as? WatchableStory else {
                    return
                }
                
                if let popupController = self.storyboard?.instantiateViewControllerWithIdentifier("storyDetailController") as? StoryDetailViewController {
                    popupController.story = story
                    popupController.popupItem.title = popupController.story.headline
                    popupController.popupItem.subtitle = popupController.story.summary
                    popupController.delegate = self
                    
                    self.navigationController?.presentPopupBarWithContentViewController(popupController, openPopup: true, animated: true, completion: nil)
                }
                
            })
            
            break
        default :
            break
        }
        
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &self.context {
            // Switch to night mode
            self.shouldSwitchToNightMode(NSUserDefaults.standardUserDefaults().boolForKey("night_mode"))
        }
    }
    
    deinit {
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "night_mode")
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
            
            cell.headlineLabel.textColor = self.nightMode ? UIColor.whiteColor() : UIColor.darkTextColor()
            cell.backgroundColor = self.nightMode ? UIColor.clearColor() : UIColor.whiteColor()
            cell.headlineLabel.text = story.headline
            cell.authorLabel.text = story.author
            cell.pubDateLabel.text = NSDateFormatter.localizedStringFromDate(story.pubDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            if let imageURL = story.thumbnailURL {
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
            popupController.delegate = self
            
            self.navigationController?.presentPopupBarWithContentViewController(popupController, openPopup: true, animated: true, completion: nil)
            
            //set content insets for the scroll view
            self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 84.0, 0.0)
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
            
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
    
// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier, destVC = segue.destinationViewController as? StoryDetailViewController where identifier == "presentStoryDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow, story = self.stories?[indexPath.row] {
                // Set the destination story to the selected cell's story
                destVC.story = story
            }
            
        }
        
    }

}


extension WatchableTableViewController {
    
    //func to create and show the UIActivityController for the share menu
    func showShareMenu(forStory story: WatchableStory) {
        
        //create share sheet
        let shareMenu = UIActivityViewController(activityItems: [story.headline], applicationActivities: nil)
        presentViewController(shareMenu, animated: true, completion: nil)
    }
    
    func presentAlertWithMessage(message: String) {
        
        let alert = UIAlertController(title: "Uh Oh", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Got It", style: .Default, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func fetchStories() {
        
        self.refreshControl?.beginRefreshing()
        
        // Fetch the stories from CloudKit and reload the table view when the results are returned
        do {
            try CloudKitManager.sharedManager().fetchStories(forDevice: .Phone, withCompletion: { (fetchedStories) in
                
                defer {
                    self.refreshControl?.endRefreshing()
                }
                
                guard let fetchedStories = fetchedStories as? [WatchableStory] else {
                    print("Unable to cast result")
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.fetchStories()
    }
    
    func shouldSwitchToNightMode(nightMode: Bool) {
        
        defer { self.tableView.reloadData() }
        
        self.nightMode = nightMode
        
        if nightMode {
            self.tableView.backgroundColor = UIColor.darkGrayColor()
            self.navigationController?.navigationBar.barTintColor = VuseFeedEngine.globalTint
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            self.refreshControl?.tintColor = UIColor.whiteColor()
            self.navigationController?.toolbar.barTintColor = VuseFeedEngine.globalTint
            self.navigationController?.toolbar.tintColor = UIColor.whiteColor()
        } else {
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.tintColor = VuseFeedEngine.globalTint
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : VuseFeedEngine.globalTint]
            self.refreshControl?.tintColor = VuseFeedEngine.globalTint
            self.navigationController?.toolbar.barTintColor = UIColor.whiteColor()
            self.navigationController?.toolbar.tintColor = VuseFeedEngine.globalTint
        }
        
    }

    @IBAction func categoriesTapped(sender: AnyObject) {
        print("categories tapped")
    }
    
    @IBAction func bookmarksTapped(sender: AnyObject) {
        
        
    }
    
    @IBAction func settingsTapped(sender: AnyObject) {
        print("settings tapped")
    }
    
    @IBAction func unwindToNewsfeed(segue: UIStoryboardSegue){
        
        // Check the segue identifier
        if segue.identifier == "unwindFromCategories" {
            
            // Check if there are any changes to the managed object context
            if self.moc.hasChanges {
                // Save the changed
                do {
                    try self.moc.save()
                    CloudKitManager.sharedManager().updateSubscription(forCategories: Array(VuseFeedEngine.sharedEngine.subscriptions))
                } catch {
                    // TODO: Handle exceptions
                }
                
                // Empty the table view
                self.stories?.removeAll()
                self.storySections?.removeAll()
                self.tableView.reloadData()
                self.fetchStories()
            }
            
        }
        
        if segue.identifier == "unwindFromBookmarks" {
            
        }
        
    }
    
}

extension WatchableTableViewController : StoryDetailDelegate {
    
    func storyDetail(storyDetail: StoryDetailViewController, actionWasTappedForStory story: WatchableStory) {
        
        //create an action sheet when the button is tapped
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        //add the share and bookmark acions to the menu
        actionMenu.addAction(UIAlertAction(title: "Share", style: .Default, handler: { (action) in
            self.showShareMenu(forStory: story)
        }))
        
        actionMenu.addAction(UIAlertAction(title: "Bookmark", style: .Default, handler: { (action) in
            
            CloudKitManager.sharedManager().saveStoryToPrivateDatabase(story) { (success, message) in
                if !success {
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.presentAlertWithMessage(message!)
                    })
                }
            }
            
        }))
        
        actionMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(actionMenu, animated: true, completion: nil)

    }
    
}























