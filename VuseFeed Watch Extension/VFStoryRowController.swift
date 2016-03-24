//
//  VFStoryRowController.swift
//  Watchable
//
//  Created by MU IT Program on 3/20/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit

class VFStoryRowController: NSObject {

    @IBOutlet var rowGroup: WKInterfaceGroup!
    @IBOutlet var thumbnailImage: WKInterfaceImage!
    @IBOutlet var movie: WKInterfaceMovie!
    @IBOutlet var headlineLabel: WKInterfaceLabel!
    @IBOutlet var authorLabel: WKInterfaceLabel!
    
    var story : Story?
    
}
