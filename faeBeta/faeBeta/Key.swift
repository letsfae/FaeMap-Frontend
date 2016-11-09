//
//  Key.swift
//  faeBeta
//
//  Created by blesssecret on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class Key: NSObject {// singlton class

    let imageDefaultCover = UIImage(named: "defaultCover")
    let imageDefaultMale = UIImage(named: "defaultMan")
    let imageDefaultFemale = UIImage(named: "defaultWomen")
    
    class var sharedInstance: Key {
        struct Static {
            static let instance = Key()
        }
        return Static.instance
    }
/*
    static let sharedInstance = Key()
    private init(){

    }*/
}
