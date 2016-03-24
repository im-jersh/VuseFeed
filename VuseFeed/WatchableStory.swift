//
//  WatchableStory.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit

class WatchableStory {

    private(set) var recordID : CKRecordID!
    private(set) var author : String!
    private(set) var category : String!
    private(set) var headline : String!
    private(set) var pubDate : NSDate!
    private(set) var printPubDate : String!
    private(set) var summary : String!
    private(set) var article : NSURL?
    private(set) var articleText : String!
    private(set) var mainVideo : NSURL?
    private(set) var watchVideo : NSURL?
    
    private(set) var thumbnailImageString : String?
    private(set) var thumbnailImageURL : NSURL? {
        get {
            return NSURL(string: thumbnailImageString!)
        }
        set {
            
        }
    }

    init(fromRecord record: CKRecord) {
        
        self.recordID = record.recordID
        guard let author = record["author"] as? String, headline = record["headline"] as? String, category = record["category"] as? String, pubDate = record["publicationDate"] as? Double, summary = record["summary"] as? String else {
            return
        }
        
        self.author = author
        self.category = category
        self.headline = headline
        self.summary = summary
        self.pubDate = NSDate(timeIntervalSince1970: pubDate)
        self.printPubDate = NSDateFormatter.localizedStringFromDate(self.pubDate, dateStyle: .FullStyle, timeStyle: .ShortStyle)
        
        if let mainVideo = record["mainVideo"] as? String, mainVideoURL = NSURL(string: mainVideo) {
            self.mainVideo = mainVideoURL
        }
        
        // There must either be a url or an asset for the story's thumbnail, but not both
        if let videoThumbnailString = record["videoThumbnailString"] as? String {
            self.thumbnailImageString = videoThumbnailString
        } else if let thumbnailAsset = record["videoThumbnail"] as? CKAsset {
            self.thumbnailImageString = thumbnailAsset.fileURL.absoluteString
        }

    }
    
    func updateStory(withRecord record: CKRecord) -> Void {
        guard let article = record["article"] as? CKAsset else {
            return
        }
        
        self.article = article.fileURL
        
        if let wVideo = record["watchVideo"] as? CKAsset {
            self.watchVideo = wVideo.fileURL
        }
        
        // Extract text from file
        do {
            if let articlePath = self.article!.path {
                self.articleText = try NSString(contentsOfFile: articlePath, encoding: NSUTF8StringEncoding) as String
            }
        } catch let error as NSError {
            print(error)
        }

        
        return
    }

    
}
