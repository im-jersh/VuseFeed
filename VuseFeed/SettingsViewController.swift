//
//  SettingsViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/26/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var dailyRemindersLabel: UILabel!
    @IBOutlet weak var nightModeLabel: UILabel!
    @IBOutlet weak var popupBarLabel: UILabel!
    
    @IBOutlet weak var notificationsCell: UITableViewCell!
    @IBOutlet weak var dailyRemindersCell: UITableViewCell!
    @IBOutlet weak var nightModeCell: UITableViewCell!
    @IBOutlet weak var popupBarCell: UITableViewCell!
    
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var popupBarSwitch: UISwitch!
    
    var nightMode = false
    private var context : UInt8 = 37
    
    var labels : [UILabel]?
    var cells : [UIView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true

        // Handle night mode changes
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "night_mode", options: .New, context: &self.context)
        self.nightMode = NSUserDefaults.standardUserDefaults().boolForKey("night_mode")
        
        self.labels = [self.notificationsLabel, self.dailyRemindersLabel, self.nightModeLabel, self.popupBarLabel]
        self.cells = [self.notificationsCell, self.dailyRemindersCell, self.nightModeCell, self.popupBarCell]
        
        // Flip the switches to match the settings
        self.nightModeSwitch.on = self.nightMode
        self.popupBarSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("popup_bar")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.nightMode ? .LightContent : .Default
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
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func viewWillAppear(animated: Bool) {
        
        // Configure for night mode
        self.shouldSwitchToNightMode(self.nightMode)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = self.nightMode ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
        }
    
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = self.nightMode ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
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
            // Update the night mode settings and save
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defer { defaults.synchronize() }
            
            nightModeSwitch.on ? defaults.setBool(true, forKey: "night_mode") : defaults.setBool(false, forKey: "night_mode")
            
        }
        
    }
    
    func shouldSwitchToNightMode(nightMode: Bool) {
        
        defer { self.tableView.reloadData() }
        
        self.nightMode = nightMode
        
        if nightMode {
            
            self.tableView.backgroundColor = UIColor.darkGrayColor()
            self.navigationController?.navigationBar.barTintColor = VuseFeedEngine.globalTint
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            
            if let labels = self.labels, cell = self.cells {
                for label in labels { label.textColor = UIColor.lightTextColor() }
                for view in cell { view.backgroundColor = UIColor.clearColor() }
            }
            
        } else {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.tintColor = VuseFeedEngine.globalTint
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : VuseFeedEngine.globalTint]
            
            if let labels = self.labels, cells = self.cells {
                for label in labels { label.textColor = UIColor.darkTextColor(); label.backgroundColor = UIColor.clearColor() }
                for view in cells { view.backgroundColor = UIColor.lightTextColor() }
            }
        }
        
    }
    
}














