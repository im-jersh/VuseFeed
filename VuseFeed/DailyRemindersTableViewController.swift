//
//  DailyRemindersTableViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/30/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class DailyRemindersTableViewController: UITableViewController {
    
    var reminders = [UILocalNotification]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all the scheduled daily reminders
        if let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            self.reminders = localNotifications.filter({ (notification) -> Bool in
                if let userInfo = notification.userInfo, type = userInfo["notification_type"] as? String {
                    return type == "daily_reminder"
                }
                return false
            })
        }
        
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        let notification = self.reminders[indexPath.row]
        
        // Get the time from the date
        guard let fireDate = notification.fireDate else {
            return cell
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mma"
        
        cell.textLabel?.text = formatter.stringFromDate(fireDate)
        
        return cell
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


}
