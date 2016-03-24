//
//  WatchablePlayerController.swift
//  Watchable
//
//  Created by Joshua O'Steen on 3/2/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WatchablePlayerController: AVPlayerViewController {
    
    var videoURL : NSURL! {
        didSet {
            self.player = AVPlayer(URL: self.videoURL)
        }
    }
    
    override func viewDidLoad() {
        
        self.player = AVPlayer(URL: self.videoURL)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {

        //self.player?.play()
        
    }
    
    
    
    
}
