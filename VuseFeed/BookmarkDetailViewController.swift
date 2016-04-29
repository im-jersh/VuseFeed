//
//  BookmarkDetailViewController.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/10/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit

class BookmarkDetailViewController: StoryDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Update to the full story if we haven't already
        if self.story.article == nil {
            CloudKitManager.sharedManager().updateCompleteStory(self.story, fromDatabase: CloudKitManager.sharedManager().privateDatabase) { (updatedStory) in
                self.story = updatedStory
                super.configure()
            }
        }
        
        super.configure()
        super.configureVideoPlayer()
        self.scrollView.scrollsToTop = true
        
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
