//
//  GlanceController.swift
//  VuseFeed Watch Extension
//
//  Created by Joshua O'Steen on 3/24/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    @IBOutlet var thumbnailImage: WKInterfaceImage!
    @IBOutlet var headlineLabel: WKInterfaceLabel!
    @IBOutlet var publicationDateLabel: WKInterfaceLabel!
    
    var story : Story? {
        didSet {
            self.configureGlance()
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Set the engine delegate
        VuseFeedEngine.delegate = self
        
        // Fetch the stories
        VuseFeedEngine.sharedEngine.fetchStoriesInstantly()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func configureGlance() {
        
        if let story = self.story {
            self.headlineLabel.setText(story.headline)
            self.publicationDateLabel.setText(NSDateFormatter.localizedStringFromDate(story.pubDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle))
            self.thumbnailImage.setRemoteImage(forStory: story)
        } else {
            self.headlineLabel.setText("It looks like there aren't any new stories right now. Check back again later!")
        }
        
    }

}

extension GlanceController : VuseFeedEngineDelegate {
    
    func engine(engine: VuseFeedEngine, didCompleteFetchWithStories stories: [Story]) {
        
        guard !stories.isEmpty else {
            self.story = nil
            return
        }
        
        // Sort the stories by publication date
        let sortedStories = stories.sort({ $0.epochDate > $1.epochDate })
        
        self.story = sortedStories.first
        
    }
    
}

extension WKInterfaceImage {
    
    func setRemoteImage(forStory story: Story) -> WKInterfaceImage {
        guard let url = story.thumbnailURL else {
            return self
        }
        
        // Set the default image
        self.setImage(UIImage(named: "placeholder")!)
        
        if SESSION {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                NSURLSession.sharedSession().dataTaskWithURL(url) { [unowned self](data: NSData?, response: NSURLResponse? , error: NSError?) in
                    
                    // Check for data
                    guard let data = data else {
                        // Check for error if there was no data
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        return
                    }
                    
                    // Create an image from the data
                    guard let image = UIImage(data: data) else {
                        return
                    }
                    
                    story.thumbnail = image
                    
                    // Set the newly downloaded image
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setImage(image)
                    })
                    
                    }.resume()
                
            }
            
        } else {
            if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.setImage(image)
                })
            }
        }
        
        
        return self

    }
    
}



















