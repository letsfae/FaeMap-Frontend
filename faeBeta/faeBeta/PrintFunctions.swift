//
//  PrintFunctions.swift
//  faeBeta
//
//  Created by Yue on 7/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

func joshprint(_ items: Any...) {
    if Key.shared.joshDebug {
        print(items)
    }
}

func vickyprint(_ items: Any...) {
    if Key.shared.vickyDebug {
        print(items)
    }
}

func felixprint(_ items: Any...) {
    if Key.shared.felixDebug {
        print(items)
    }
}
