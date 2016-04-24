//
//  VFStoryDetailController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/23/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit
import Foundation


class VFStoryDetailController: WKInterfaceController {
    
    @IBOutlet var moviePlayer: WKInterfaceMovie!
    @IBOutlet var headlineLabel: WKInterfaceLabel!
    @IBOutlet var authorLabel: WKInterfaceLabel!
    @IBOutlet var summaryLabel: WKInterfaceLabel!
    
    var story : Story?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let story = context as? Story, _ = story.watchVideoURL else {
            self.popController()
            return
        }
        
        self.story = story
        self.moviePlayer.setLoops(false)
        self.moviePlayer.setMovieURL(story.watchVideoURL!)
        
        if let _ = story.thumbnail {
            let image = WKImage(image: story.thumbnail!)
            self.moviePlayer.setPosterImage(image)
        }
        
        self.headlineLabel.setText(story.headline)
        self.authorLabel.setText(story.author)
        self.summaryLabel.setText(story.summary)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
