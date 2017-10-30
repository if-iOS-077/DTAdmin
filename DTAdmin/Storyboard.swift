//
//  Storyboard.swift
//  DTAdmin
//
//  Created by mac6 on 10/26/17.
//  Copyright © 2017 if-ios-077. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func stoyboard(by type: StoryboardType) -> UIStoryboard {
        return UIStoryboard.init(name: type.rawValue, bundle: nil)
    }
}

enum StoryboardType: String {
    case Subject = "Subjects"
    case TimeTable = "TimeTable"
    case Admin = "Admin"
}
