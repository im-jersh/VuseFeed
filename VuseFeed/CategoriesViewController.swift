//
//  CategoriesViewController.swift
//  VuseFeed
//
//  Created by MU IT Program on 3/29/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet weak var categoriesTable: UITableView!
    
    var categories : [(category: String,isChecked: Bool)] = [("World", false), ("Sports",false), ("US News",false), ("Tech",false), ("Finance",false), ("Health",false), ("a",false), ("b",false), ("c",false), ("d",false), ("e",false),("World", false), ("Sports",false), ("US News",false), ("Tech",false), ("Finance",false), ("Health",false), ("a",false), ("b",false), ("c",false), ("d",false), ("e",false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


extension CategoriesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.categoriesTable.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) 
    
        cell.textLabel?.text = categories[indexPath.row].category
        
        
        if  categories[indexPath.row].isChecked == false {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
        }
        
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                categories[indexPath.row].isChecked = false
            } else {
                cell.accessoryType = .Checkmark
                categories[indexPath.row].isChecked = true
            }
        }
        
        self.categoriesTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}