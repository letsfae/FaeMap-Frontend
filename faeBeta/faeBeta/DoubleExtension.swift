//
//  DoubleExtension.swift
//  faeBeta
//
//  Created by Yue on 4/4/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random number Double
     
     - parameter min: Double
     - parameter max: Double
     
     - returns: Double
     */
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
    
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
