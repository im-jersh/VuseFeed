//
//  StoryDetailViewController.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/23/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import LNPopupController

protocol StoryDetailDelegate {
    func storyDetail(storyDetail: StoryDetailViewController, actionWasTappedForStory story: WatchableStory)
}

class StoryDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var authorDateStackView: UIStackView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var videoPlayerView: AVPlayerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet var miniPlayerPlay: UIBarButtonItem!
    @IBOutlet var miniPlayerPause: UIBarButtonItem!
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoControlContainerBlurView: UIVisualEffectView!
    
    var delegate : StoryDetailDelegate?
    
    var popupPlayButton : UIButton?
    
    var story : WatchableStory!
    
    var avPlayer : AVPlayer?
    var isPlaying : Bool = false {
        willSet {
            if newValue { // play
                self.playButton.selected = !self.playButton.selected
                self.popupItem.leftBarButtonItems = [self.miniPlayerPause]
                self.avPlayer?.play()
                self.hideControlsAfterVideoPlays()
            } else { // pause
                self.playButton.selected = !self.playButton.selected
                self.popupItem.leftBarButtonItems = [self.miniPlayerPlay]
                self.avPlayer?.pause()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update to the full story if we haven't already
        if self.story.article == nil {
            CloudKitManager.sharedManager().updateCompleteStory(self.story) { updatedStory in
                self.story = updatedStory
                self.configure()
            }
        }
        
        self.configure()
        self.configureVideoPlayer()
        self.scrollView.scrollsToTop = true
        
        //set content insets for the scroll view
        self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        
        self.shouldSwitchToNightMode(NSUserDefaults.standardUserDefaults().boolForKey("night_mode"))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.configure()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return NSUserDefaults.standardUserDefaults().boolForKey("night_mode") ? .LightContent : .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        self.headlineLabel.text = self.story.headline
        self.authorLabel.text = self.story.author
        self.summaryLabel.text = self.story.summary
        self.dateLabel.text = self.story.printPubDate
        
        if let _ = self.story.article {
            self.articleLabel.text = self.story.articleText
        }
        
        // Create the popupItem bar button items
        self.popupItem.leftBarButtonItems = [self.miniPlayerPlay]
        self.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "miniPlayerAction"), style: .Plain, target: self, action: #selector(StoryDetailViewController.actionButtonTapped))]
        
        self.view.setNeedsLayout()
    
    }
    
    func configureVideoPlayer() {
        // If this story has a video, setup the player
        if let videoURL = self.story.mainVideo {
            self.avPlayer = AVPlayer(URL: videoURL)
            self.videoPlayerView.avPlayer = self.avPlayer
        } else if let imageURL = self.story.thumbnailURL, data = NSData(contentsOfURL: imageURL), image = UIImage(data: data) {
            self.videoPlayerView.image = image
            self.videoControlContainerBlurView.hidden = true
        }
    }
    
    func shouldSwitchToNightMode(nightMode: Bool) {
        
        if nightMode {
            self.view.backgroundColor = UIColor.darkGrayColor()
            self.contentView.backgroundColor = UIColor.darkGrayColor()
            self.headlineLabel.textColor = UIColor.whiteColor()
            self.authorLabel.textColor = UIColor.lightGrayColor()
            self.summaryLabel.textColor = UIColor.lightGrayColor()
            self.dateLabel.textColor = UIColor.lightGrayColor()
            self.articleLabel.textColor = UIColor.whiteColor()
            self.toolbar.barTintColor = VuseFeedEngine.globalTint
            self.toolbar.tintColor = UIColor.whiteColor()
        }
        
    }
    
    private func setImage(image: UIImage, asBackgroundFor view: UIView) {
        self.thumbnailImageView.image = image
        self.thumbnailImageView.frame = view.bounds
        view.addSubview(self.thumbnailImageView)
        self.videoControlContainerBlurView.hidden = true
    }
    
    private func hideControlsAfterVideoPlays() {
        
        // Create a timer that hides the controls once fired
        let timer = NSTimer.init(timeInterval: 2.0, target: self, selector: #selector(StoryDetailViewController.hideControlsAfterTimer(_:)), userInfo: nil, repeats: false)
        
        // Add it to the run loop
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    @objc private func hideControlsAfterTimer(timer : NSTimer) {
        
        // Invalidate the timer
        timer.invalidate()
        
        // Hide the controls
        self.videoControlContainerBlurView.hidden = true
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        
        if self.avPlayer?.status == .ReadyToPlay {
            self.isPlaying = !self.isPlaying
        }
        
    }
    
    func actionButtonTapped() {
        
        self.delegate?.storyDetail(self, actionWasTappedForStory: self.story)
        
    }
    
    @IBAction func bookmarkButtonWasTapped(sender: AnyObject) {
        
        CloudKitManager.sharedManager().saveStoryToPrivateDatabase(self.story) { (success, message) in
            if !success {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.presentAlertWithMessage(message!)
                })
            }
        }
        
    }
    
    @IBAction func mediaViewWasTapped(sender: AnyObject) {
        
        // The gesture should only effect a video player, not an image
        if let _ = self.story.mainVideo {
            self.videoControlContainerBlurView.hidden = !self.videoControlContainerBlurView.hidden
        }
    }
    
    @IBAction func shareButtonWasTapped(sender: AnyObject) {
        showShareMenu()
    }
    
    //func to create and show the UIActivityController for the share menu
    func showShareMenu() {
       
        //create share sheet
        let shareMenu = UIActivityViewController(activityItems: [story.headline], applicationActivities: nil)
        presentViewController(shareMenu, animated: true, completion: nil)
    }

    func presentAlertWithMessage(message: String) {
        
        let alert = UIAlertController(title: "Uh Oh", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Got It", style: .Default, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension StoryDetailViewController : UIScrollViewDelegate {
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true
    }
    
}







































