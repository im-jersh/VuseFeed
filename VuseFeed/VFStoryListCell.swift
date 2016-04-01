//
//  VFStoryListCell.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 3/31/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class VFStoryListCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
