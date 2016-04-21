//
//  WatchableStory.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit

public class WatchableStory {

    private(set) var cloudKitRecord : CKRecord
    private(set) var author : String!
    private(set) var category : Category!
    private(set) var headline : String!
    private(set) var epochDate : Double!
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
    private(set) var thumbnailAsset : CKAsset?

    init(fromRecord record: CKRecord) {
        
        self.cloudKitRecord = record
        guard let author = record["author"] as? String, headline = record["headline"] as? String, categoryString = record["category"] as? String, pubDate = record["publicationDate"] as? Double, summary = record["summary"] as? String, category = Category(rawValue: categoryString) else {
            return
        }
        
        self.author = author
        self.category = category
        self.headline = headline
        self.summary = summary
        self.epochDate = pubDate
        self.pubDate = NSDate(timeIntervalSince1970: pubDate)
        self.printPubDate = NSDateFormatter.localizedStringFromDate(self.pubDate, dateStyle: .FullStyle, timeStyle: .ShortStyle)
        
        if let mainVideo = record["mainVideo"] as? String, mainVideoURL = NSURL(string: mainVideo) {
            self.mainVideo = mainVideoURL
        }
        
        // There must either be a url or an asset for the story's thumbnail, but not both
        if let videoThumbnailString = record["videoThumbnailString"] as? String {
            self.thumbnailImageString = videoThumbnailString
        } else if let thumbnailAsset = record["videoThumbnail"] as? CKAsset {
            self.thumbnailAsset = thumbnailAsset
            self.thumbnailImageString = thumbnailAsset.fileURL.absoluteString
        }
        
        if let watchVideo = record["watchVideo"] as? String, watchVideoURL = NSURL(string: watchVideo) {
            self.watchVideo = watchVideoURL
        }

    }
    
    func updateStory(withRecord record: CKRecord) -> Void {
        guard let article = record["article"] as? CKAsset else {
            return
        }
        
        self.cloudKitRecord = record
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
    
    func createDuplicateCloudKitRecord() -> CKRecord? {
        
        // Create a recordID from the story's headline hash
        var headlineHash = String(self.headline.hashValue)
        
        // Make sure the hash doesn't exceed 255 characters
        if headlineHash.characters.count > 255 {
            // Only use the first 255 characters
            let range = headlineHash.startIndex..<headlineHash.startIndex.advancedBy(255)
            headlineHash = headlineHash[range]
        }
        print(headlineHash)
        
        // Create the recordID
        let recordID = CKRecordID(recordName: headlineHash)
        let recordCopy = CKRecord(recordType: "Story", recordID: recordID)
        
        recordCopy.setValue(self.author, forKey: "author")
        recordCopy.setValue(self.category.rawValue, forKey: "category")
        recordCopy.setValue(self.headline, forKey: "headline")
        recordCopy.setValue(self.epochDate, forKey: "publicationDate")
        recordCopy.setValue(self.summary, forKey: "summary")
        
        
        guard let articleURL = self.article else {
            return nil
        }
        
        let articleAsset = CKAsset(fileURL: articleURL)
        recordCopy.setObject(articleAsset, forKey: "article")
        
        if let mainVideoURL = self.mainVideo?.path {
            recordCopy.setValue(mainVideoURL, forKey: "mainVideo")
        }
        
        if let watchVideoURL = self.watchVideo?.path {
            recordCopy.setValue(watchVideoURL, forKey: "watchVideo")
        }
        
        // If there's an asset, use it; otherwise, we are guaranteed an thumbnail URL
        if let thumbnailAsset = self.thumbnailAsset {
            recordCopy.setObject(thumbnailAsset, forKey: "videoThumbnail")
        } else if let thumbnailURLString = self.thumbnailImageString {
            recordCopy.setValue(thumbnailURLString, forKey: "videoThumbnailString")
        } else {
            return nil
        }
        
        
        return recordCopy
    }

    
}


















