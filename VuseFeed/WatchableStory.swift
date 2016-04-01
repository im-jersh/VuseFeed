//
//  WatchableStory.swift
//  Watchable
//
//  Created by Joshua O'Steen on 2/22/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import UIKit
import CloudKit

enum Category : String {
    case World = "World"
    case US = "U.S."
    case Local = "Local"
    case Politics = "Politics"
    case SciTech = "Science & Technology"
    case Entertainment = "Entertainment"
    case Sports = "Sports"
    case Business = "Business"
    case Health = "Health"
    case Travel = "Travel"
    case Lifestyle = "Lifestyle"
    case Education = "Education"
    case Default = "Uncategorized"
}

extension UIColor {
    
    static func colorForCategory(category: Category) -> UIColor {
        switch category {
        case .World :
            return UIColor.flatPowderBlueColorDark()
        case .US :
            return UIColor.flatRedColor()
        case .Local :
            return UIColor.flatGreenColorDark()
        case .Politics :
            return UIColor.flatOrangeColor()
        case .SciTech :
            return UIColor.flatMintColor()
        case .Entertainment :
            return UIColor.flatYellowColor()
        case .Sports :
            return UIColor.flatSkyBlueColorDark()
        case .Business :
            return UIColor.flatTealColor()
        case .Health :
            return UIColor.flatPinkColor()
        case .Travel :
            return UIColor.flatMagentaColor()
        case .Lifestyle :
            return UIColor.flatLimeColor()
        case .Education :
            return UIColor.flatCoffeeColor()
        default:
            return UIColor.flatBlackColor()
        }
    }
    
}

class WatchableStory {

    private(set) var recordID : CKRecordID!
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

    init(fromRecord record: CKRecord) {
        
        self.recordID = record.recordID
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


















