//
//  WatchableStory.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit

class WatchableStory: NSObject {

    private(set) var recordID : CKRecordID!
    private(set) var author : String!
    private(set) var category : String!
    private(set) var headline : String!
    private(set) var pubDate : NSDate!
    private(set) var printPubDate : String!
    private(set) var summary : String!
    private(set) var article : NSURL?
    private(set) var articleText : String!
    private(set) var mainVideo : NSURL!
    private(set) var watchVideo : NSURL!

    init(fromRecord record: CKRecord) {
        self.recordID = record.recordID
        guard let author = record["author"] as? String, headline = record["headline"] as? String, category = record["category"] as? String, pubDate = record["pubDate"] as? Double, summary = record["summary"] as? String, mainVideo = record["mainVideo"] as? String else {
            return
        }
        
        self.author = author
        self.category = category
        self.headline = headline
        self.summary = summary
        self.pubDate = NSDate(timeIntervalSince1970: pubDate)
        self.printPubDate = NSDateFormatter.localizedStringFromDate(self.pubDate, dateStyle: .FullStyle, timeStyle: .ShortStyle)
        
        guard let mainVideoURL = NSURL(string: mainVideo) else {
            return
        }
        
        self.mainVideo = mainVideoURL

    }
    
    func updateStory(withRecord record: CKRecord) -> Void {
        guard let article = record["article"] as? CKAsset, wVideo = record["watchVideo"] as? CKAsset else {
            return
        }
        
        self.article = article.fileURL
        self.watchVideo = wVideo.fileURL
        
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
