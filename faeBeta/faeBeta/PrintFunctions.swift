//
//  PrintFunctions.swift
//  faeBeta
//
//  Created by Yue on 7/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

var joshDebug: Bool = true
var vickyDebug: Bool = false
var felixDebug: Bool = false

func joshprint(_ items: Any...) {
    if joshDebug {
        print(items)
    }
}

func vickyprint(_ items: Any...) {
    if vickyDebug {
        print(items)
    }
}

func felixprint(_ items: Any...) {
    if felixDebug {
        print(items)
    }
}
