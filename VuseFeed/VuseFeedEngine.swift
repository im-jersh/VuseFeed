//
//  VuseFeedEngine.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/1/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation

class VuseFeedEngine {
    
    // Singleton
    static let sharedEngine = VuseFeedEngine()
    private init() { }
    
    // All the strings for the categories
    let allCategorieStrings = Set(["World","U.S.","Local","Politics","Science & Technology","Entertainment","Sports","Business","Health","Travel","Lifestyle","Education"])
    
    // All the possible Category enum values
    private(set) lazy var allCategories : Set<Category> = {
       return Set(self.allCategorieStrings.flatMap{ Category(rawValue: $0) })
    }()
    
    // The selected Categories to show in the news feed
    lazy var newsFeedCategories : Set<Category> = {
       return self.allCategories
    }()
    
}