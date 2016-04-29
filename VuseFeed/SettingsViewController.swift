//
//  SettingsViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/26/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 2 : 1
    }

    
    override func viewWillAppear(animated: Bool) {
        
        //check NSUserDefaults for the night mode setting
        if flag {
            self.tableView.backgroundColor = UIColor.darkGrayColor()
            self.tableView.reloadData()
        }
        else {
            self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.tableView.reloadData()
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if flag {
            //change the background color of the header view when in night mode
            if let view = view as? UITableViewHeaderFooterView {
                view.backgroundView?.backgroundColor = UIColor.darkGrayColor()
                view.textLabel?.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            if let view = view as? UITableViewHeaderFooterView {
                view.backgroundView?.backgroundColor = UIColor.groupTableViewBackgroundColor()
                view.textLabel?.textColor = UIColor.darkGrayColor()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        if flag {
            //change the background color of the header view when in night mode
            if let view = view as? UITableViewHeaderFooterView {
                view.backgroundView?.backgroundColor = UIColor.darkGrayColor()
                view.textLabel?.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            if let view = view as? UITableViewHeaderFooterView {
                view.backgroundView?.backgroundColor = UIColor.groupTableViewBackgroundColor()
                view.textLabel?.textColor = UIColor.darkGrayColor()
            }
        }
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

extension SettingsViewController {
    
    //action to set NSUserDefaults to be able to determine whether the night mode switch is on or off
    @IBAction func nightModeSwitchWasTapped(sender: AnyObject) {
        
        if let nightModeSwitch = sender as? UISwitch {
            
            if nightModeSwitch.on {
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "nightMode")
                flag = true
                self.tableView.backgroundColor = UIColor.darkGrayColor()
                
                self.tableView.reloadData()
            }
            else {
                NSUserDefaults.standardUserDefaults().setValue(0, forKey: "nightMode")
                flag = false
                self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                self.tableView.reloadData()
            }
        }
        
    }
    
}
