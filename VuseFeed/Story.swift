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
    let category : Category
    let pubDate : NSDate
    let pubDateEpoch : Double
    let watchVideoURL : NSURL?
    
    var rawData : [String : AnyObject] {
        get {
            return ["author" : self.author, "headline" : self.headline, "category" : self.category.rawValue, "pubDateEpoch" : self.pubDateEpoch, "watchVideoURL" : self.watchVideoURL!.absoluteString]
        }
    }
    
    init(withJSON json: [String : AnyObject]) {
        
        self.author = json["author"] as! String
        self.headline = json["headline"] as! String
        self.category = Category(rawValue: json["category"] as! String)!
        self.pubDateEpoch = json["pubDateEpoch"] as! Double
        self.pubDate = NSDate(timeIntervalSince1970: self.pubDateEpoch)
        
        guard let watchVideoString = json["watchVideoURL"] as? String, watchVideoURL = NSURL(string: watchVideoString) else {
            self.watchVideoURL = nil
            return
        }
        
        self.watchVideoURL = watchVideoURL
        
    }
    
    init?(withAuthor author: String, headline: String, category: Category, pubDate: NSDate, epochDate: Double, watchVideoURL: NSURL?) {
        
        guard let watchVideoURL = watchVideoURL else {
            return nil
        }
        
        self.author = author
        self.headline = headline
        self.category = category
        self.pubDateEpoch = epochDate
        self.pubDate = pubDate
        self.watchVideoURL = watchVideoURL
        
    }
    
    
    
}