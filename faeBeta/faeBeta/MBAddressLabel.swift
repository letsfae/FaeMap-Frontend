//
//  MBAddressLabel.swift
//  faeBeta
//
//  Created by Yue on 6/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GoogleMaps

let mbAddressCache = NSCache<AnyObject, AnyObject>()

class MBAddressLabel: UILabel {
    
    var pinId = -1
    var pinType = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAddress(position: CLLocationCoordinate2D, id: Int, type: String) {
        
        self.text = nil
        
        if let addressFromCache = mbAddressCache.object(forKey: id as AnyObject) as? String {
            self.text = addressFromCache
            return
        }
        
        self.getSocialPinAddress(position: position, id: id, type: type)
    }
    
    func getSocialPinAddress(position: CLLocationCoordinate2D, id: Int, type: String) {
        GMSGeocoder().reverseGeocodeCoordinate(position, completionHandler: {
            (response, _) -> Void in
            DispatchQueue.main.async(execute: {
                guard let fullAddress = response?.firstResult()?.lines else {
                    print("[getSocialPinAddress] fail")
                    return
                }
                
                var addressToCache = ""
                for line in fullAddress {
                    if line == "" {
                        continue
                    } else if fullAddress.index(of: line) == fullAddress.count - 1 {
                        addressToCache += line + ""
                    } else {
                        addressToCache += line + ", "
                    }
                }
                
                if "\(self.pinId)" + self.pinType == "\(id)" + type {
                    self.text = addressToCache
                }
                mbAddressCache.setObject(addressToCache as AnyObject, forKey: "\(id)" + type as AnyObject)
            })
        })
    }
}
