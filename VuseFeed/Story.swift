//
//  Story.swift
//  Watchable
//
//  Created by Joshua O'Steen on 3/16/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation

class Story {
    
    let author : String
    let headline : String
    let category : String
    let pubDate : NSDate
    let pubDateEpoch : Double
    let watchVideoURL : NSURL?
    
    init(withJSON json: [String : AnyObject]) {
        
        self.author = json["author"] as! String
        self.headline = json["headline"] as! String
        self.category = json["category"] as! String
        self.pubDateEpoch = json["pubDate"] as! Double
        self.pubDate = NSDate(timeIntervalSince1970: self.pubDateEpoch)
        
        guard let watchVideoString = json["watchVideo"] as? String, watchVideoURL = NSURL(string: watchVideoString) else {
            self.watchVideoURL = nil
            return
        }
        
        self.watchVideoURL = watchVideoURL
        
    }
    
}