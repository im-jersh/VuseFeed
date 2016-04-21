//
//  Category+Extensions.swift
//  VuseFeed
//
//  Created by Joshua O'Steen on 4/14/16.
//  Copyright © 2016 Joshua O'Steen. All rights reserved.
//

import Foundation
import UIKit


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
        case .Business :
            return UIColor(red: 155.0/255.0, green: 171.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        case .Education :
            return UIColor(red: 47.0/255.0, green: 128.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        case .Entertainment :
            return UIColor(red: 158.0/255.0, green: 87.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        case .Health :
            return UIColor(red: 247.0/255.0, green: 121.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        case .Lifestyle :
            return UIColor(red: 233.0/255.0, green: 71.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        case .Local :
            return UIColor(red: 231.0/255.0, green: 125.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        case .Politics :
            return UIColor(red: 255.0/255.0, green: 205.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        case .SciTech :
            return UIColor(red: 162.0/255.0, green: 200.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        case .Sports :
            return UIColor(red: 23.0/255.0, green: 176.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        case .Travel :
            return UIColor(red: 5.0/255.0, green: 190.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        case .US :
            return UIColor(red: 59.0/255.0, green: 112.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        case .World :
            return UIColor(red: 142.0/255.0, green: 114.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        default:
            return UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        }
    }
    
}