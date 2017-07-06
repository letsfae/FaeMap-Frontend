//
//  MoodAvatarImages.swift
//  faeBeta
//
//  Created by Yue on 7/4/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

struct Mood {
    static let avatars: [UIImage?] = {
        var array = [UIImage?]()
        for i in 1...36 {
            let image = UIImage(named: "mapAvatar_\(i)")
            array.append(image)
            
        }
        return array
    }()
}
