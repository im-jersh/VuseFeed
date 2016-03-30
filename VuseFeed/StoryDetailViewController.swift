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
    
    @IBOutlet var miniPlayerPlay: UIBarButtonItem!
    @IBOutlet var miniPlayerPause: UIBarButtonItem!
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoControlContainerBlurView: UIVisualEffectView!
    
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
        self.scrollView.contentSize.height = 1000
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configure() {
        self.headlineLabel.text = self.story.headline
        self.authorLabel.text = self.story.author
        self.summaryLabel.text = self.story.summary
        self.dateLabel.text = self.story.printPubDate
        
        if let _ = self.story.article {
            self.articleLabel.text = self.story.articleText
        }
        
        // Create the popupItem bar button items
        self.popupItem.leftBarButtonItems = [self.miniPlayerPlay]
        self.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "miniPlayerAction"), style: .Plain, target: self, action: "actionButtonTapped:")]
        
        self.view.setNeedsLayout()
    
    }
    
    private func configureVideoPlayer() {
        // If this story has a video, setup the player
        if let videoURL = self.story.mainVideo {
            self.avPlayer = AVPlayer(URL: videoURL)
            self.videoPlayerView.avPlayer = self.avPlayer
        } else if let imageURL = self.story.thumbnailImageURL, data = NSData(contentsOfURL: imageURL), image = UIImage(data: data) {
            self.videoPlayerView.image = image
            self.videoControlContainerBlurView.hidden = true
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
        print("ACTION BUTTON TAPPED")
    }

    @IBAction func mediaViewWasTapped(sender: AnyObject) {
        
        // The gesture should only effect a video player, not an image
        if let _ = self.story.mainVideo {
            self.videoControlContainerBlurView.hidden = !self.videoControlContainerBlurView.hidden
        }
    }
    
}







































