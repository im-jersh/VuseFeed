//
//  AVPlayerView.swift
//  Watchable
//
//  Created by Joshua O'Steen on 3/23/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AVPlayerView: UIImageView {

    var avPlayer : AVPlayer? {
        didSet {
            let playerLayer = AVPlayerLayer(player: self.avPlayer)
            playerLayer.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width * (9/16))
            self.layer.insertSublayer(playerLayer, atIndex: 0)
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

}
