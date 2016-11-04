//
//  ScreenFacotr.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

var screenWidth : CGFloat {
get{
    return UIScreen.mainScreen().bounds.width
}
}

var screenHeight : CGFloat {
get{
    return UIScreen.mainScreen().bounds.height
}
}

var screenWidthFactor : CGFloat {
get{
    return UIScreen.mainScreen().bounds.width / 414
}
}

var screenHeightFactor : CGFloat {
get{
    return UIScreen.mainScreen().bounds.height / 736
}
}
