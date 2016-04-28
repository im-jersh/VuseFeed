//
//  CategoryNotificationCell.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/27/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class CategoryNotificationCell: UITableViewCell {
    
    static let cellIdentifier = "notificationCell"

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subscriptionSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
