 //
//  Story.swift
//  Watchable
//
//  Created by Joshua O'Steen on 3/16/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation
import UIKit

class Story {
    
    let recordName : String
    
    let author : String
    let headline : String
    let category : Category
    let summary : String
    
    let pubDate : NSDate
    let epochDate : Double
    
    var watchVideoURL : NSURL?
    
    var thumbnailString : String?
    var thumbnailURL : NSURL? {
        get {
            if let _ = self.thumbnailString { return NSURL(string: thumbnailString!) }
            else { return nil }
        }
    }
    var thumbnail : UIImage?
    
    
    init(recordName: String, author: String, headline: String, category: Category, summary: String, epochDate: Double) {
        self.recordName = recordName
        self.author = author
        self.headline = headline
        self.category = category
        self.summary = summary
        self.epochDate = epochDate
        self.pubDate = NSDate(timeIntervalSince1970: self.epochDate)
    }
    
    init(withJSON json: [String : AnyObject]) {
        
        self.recordName = json["recordName"] as! String
        self.author = json["author"] as! String
        self.headline = json["headline"] as! String
        self.category = Category(rawValue: json["category"] as! String)!
        self.summary = json["summary"] as! String
        self.epochDate = json["pubDateEpoch"] as! Double
        self.pubDate = NSDate(timeIntervalSince1970: self.epochDate)
        
        if let watchVideoString = json["watchVideoURL"] as? String, watchVideoURL = NSURL(string: watchVideoString), urlString = json["thumbnailURL"] as? String {
            self.watchVideoURL = watchVideoURL
            self.thumbnailString = urlString
            self.thumbnail = self.downloadImage(withURL: self.thumbnailURL)
        }
        
    }
    
    convenience init?(withData data: NSData) {
        
        // Extract the dictionary from the data
        guard let jsonData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
            return nil
        }
        
        guard let json = jsonData else {
            return nil
        }
        
        self.init(withJSON: json)
        
        guard let _ = self.watchVideoURL else {
            return nil
        }
    }
    
    func convertToRawData() -> NSData? {
        
        // Create the dictionary of required data
        var dict : [String : AnyObject] = [
            "recordName" : self.recordName,
            "author" : self.author,
            "headline" : self.headline,
            "category" : self.category.rawValue,
            "summary" : self.summary,
            "pubDateEpoch" : self.epochDate
        ]
        
        // Add any optional data
        if let watchURL = self.watchVideoURL?.absoluteString {
            dict.updateValue(watchURL, forKey: "watchVideoURL")
        }
        
        if let thumbnail = self.thumbnailString {
            dict.updateValue(thumbnail, forKey: "thumbnailURL")
        }
        
        // Convert the dictionary to raw data
        return try? NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
    }
    
    private func downloadImage(withURL url: NSURL?) -> UIImage {
        
        // Make sure the url is valid
        guard let url = url else {
            // Return the placeholder
            return UIImage(named: "placeholder")!
        }
        
        guard let data = NSData(contentsOfURL: url), image = UIImage(data: data) else {
            return UIImage(named: "placeholder")!
        }
        
        return image
        
    }
    
    func downloadWatchVideo() {
        
        // Get the data
        guard let url = self.watchVideoURL, data = NSData(contentsOfURL: url) else {
            return
        }
        
        // Save the data to the file system
        let tempFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent("\(self.recordName).mp4")
        if data.writeToURL(tempFileURL, atomically: true) {
            self.watchVideoURL = tempFileURL
            print("FINISHED DOWNLOADING: \(tempFileURL.absoluteString)")
        }
        
    }
    
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 