//
//  PrintFunctions.swift
//  faeBeta
//
//  Created by Yue on 7/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

func joshPrint(_ items: Any...) {
    if Key.shared.joshDebug {
        print(items)
    }
}

func vickyPrint(_ items: Any...) {
    if Key.shared.vickyDebug {
        print(items)
    }
}
