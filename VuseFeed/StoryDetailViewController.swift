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
    
    @IBOutlet var miniPlayerPlay: UIBarButtonItem!
    @IBOutlet var miniPlayerPause: UIBarButtonItem!
    
    
    var popupPlayButton : UIButton?
    
    var story : WatchableStory!
    
    var avPlayer : AVPlayer?
    var isPlaying : Bool = false {
        willSet {
            if newValue {
                self.playButton.selected = !self.playButton.selected
                self.popupItem.leftBarButtonItems = [self.miniPlayerPause]
                self.avPlayer?.play()
            } else {
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
        self.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "miniPlayerAction"), style: .Plain, target: self, action: #selector(StoryDetailViewController.actionButtonTapped))]
        
        self.view.setNeedsLayout()
    
    }
    
    private func configureVideoPlayer() {
        self.avPlayer = AVPlayer(URL: self.story.mainVideo)
        self.videoPlayerView.avPlayer = self.avPlayer
    }

    
    @IBAction func playButtonTapped(sender: AnyObject) {
        
        if self.avPlayer?.status == .ReadyToPlay {
            self.isPlaying = !self.isPlaying
        }
        
    }
    
    func actionButtonTapped() {
        print("ACTION BUTTON TAPPED")
    }

}