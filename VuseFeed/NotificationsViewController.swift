//
//  NotificationsViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/26/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var notificationsTable: UITableView!
    
    // Show only the categories that are currently in the news feed
    let newsFeedCategories = Array(VuseFeedEngine.sharedEngine.newsFeedCategories).sort({ $0.rawValue < $1.rawValue })
    let currentSubscriptions = VuseFeedEngine.sharedEngine.subscriptions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Save the moc
        do {
            try VuseFeedEngine.sharedEngine.moc.save()
            // Update the cloudkit subscription
            CloudKitManager.sharedManager().updateSubscription(forCategories: Array(VuseFeedEngine.sharedEngine.subscriptions))
        } catch {
            print("UNABLE TO SAVE SUBSCRIPTIONS")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension NotificationsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsFeedCategories.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "News Feed Notifications"
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Only categories that are currently filling your news feed will appear here. When on, you will receive push notifications when new stories are published to the selected category."
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create a cell and configure it
        guard let cell = self.notificationsTable.dequeueReusableCellWithIdentifier(CategoryNotificationCell.cellIdentifier, forIndexPath: indexPath) as? CategoryNotificationCell else {
            return UITableViewCell()
        }
        
        let category = self.newsFeedCategories[indexPath.row]
        
        cell.categoryLabel.text = category.rawValue
        cell.categoryLabel.font = UIFont(descriptor: (cell.textLabel?.font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold))!, size: (cell.textLabel?.font.pointSize)!)
        cell.categoryLabel.textColor = UIColor.colorForCategory(category)
        cell.subscriptionSwitch.on = VuseFeedEngine.sharedEngine.subscriptions.contains(category)
        cell.subscriptionSwitch.tag = indexPath.row
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = self.notificationsTable.cellForRowAtIndexPath(indexPath) as? CategoryNotificationCell {
            cell.subscriptionSwitch.setOn(!cell.subscriptionSwitch.on, animated: true)
            self.subscriptionSwitchWasTapped(cell.subscriptionSwitch)
        }
        
        self.notificationsTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension NotificationsViewController {
    
    @IBAction func subscriptionSwitchWasTapped(sender: AnyObject) {
        
        if let subscriptionSwitch = sender as? UISwitch {
            
            if subscriptionSwitch.on {
                // Create a subscription for the category
                VuseFeedEngine.sharedEngine.createSubscription(forCategory: self.newsFeedCategories[subscriptionSwitch.tag])
            } else {
                // Delete the subscription for the category
                VuseFeedEngine.sharedEngine.deleteSubscription(forCategory: self.newsFeedCategories[subscriptionSwitch.tag])
            }
            
        }
        
    }
    
}
































