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
    
    // Array of all categories sorted alphabetically
    var categories = Array(VuseFeedEngine.sharedEngine.allCategories).sort({ $0.rawValue < $1.rawValue })
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        // Create the cell and get it's corresponding category
        let cell = self.categoriesTable.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
        let category = self.categories[indexPath.row]
        
        cell.textLabel?.font = UIFont(descriptor: (cell.textLabel?.font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold))!, size: (cell.textLabel?.font.pointSize)!)
        cell.textLabel?.text = category.rawValue
        cell.textLabel?.textColor = UIColor.colorForCategory(category)

        // If the category is in the newsFeedCategories set, checkmark it; otherwise, don't
        cell.accessoryType = VuseFeedEngine.sharedEngine.newsFeedCategories.contains(category) ? .Checkmark : .None
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select the categories that you wish to see in your news feed."
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Deselecting a category will disable any notifications for that category"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // If the category is not checkmarked, checkmark it and add it to the newsFeedCategories
        // Otherwise, uncheck it and remove it from the set
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let category = self.categories[indexPath.row]
            
            if cell.accessoryType == .None {
                VuseFeedEngine.sharedEngine.addCategory(category)
                cell.accessoryType = .Checkmark
            } else if cell.accessoryType == .Checkmark {
                VuseFeedEngine.sharedEngine.removeCategory(category)
                cell.accessoryType = .None
            }
            
        }
        
        self.categoriesTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}


extension CategoriesViewController {
    
    @IBAction func selectAllCategoriesWasTapped(sender: AnyObject) {
        
        // Get all the cells
        let cells = self.categoriesTable.visibleCells
        
        // Iterate through each cell and checkmark it if it isn't checkmarked already
        for cell in cells {
            if cell.accessoryType == .None {
                if let indexPath = self.categoriesTable.indexPathForCell(cell){
                    cell.accessoryType = .Checkmark
                    VuseFeedEngine.sharedEngine.addCategory(self.categories[indexPath.row])
                }
            }
        }
        
    }
    
}





















