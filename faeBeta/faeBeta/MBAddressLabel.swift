//
//  MBAddressLabel.swift
//  faeBeta
//
//  Created by Yue on 6/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

/*
import UIKit
import CoreLocation

let mbAddressCache = NSCache<AnyObject, AnyObject>()

class MBAddressLabel: UILabel {
    
    var pinId = -1
    var pinType = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func loadAddress(position: CLLocationCoordinate2D, id: Int, type: String) {
        
        self.text = nil

        if let addressFromCache = mbAddressCache.object(forKey: "\(id)" + type as AnyObject) as? String {
            self.text = addressFromCache
            return
        }

        self.getSocialPinAddress(position: position, id: id, type: type)
    }
    
    public func getSocialPinAddress(position: CLLocationCoordinate2D, id: Int, type: String) {
        
        let location = CLLocation(latitude: position.latitude, longitude: position.longitude)
        General.shared.getAddress(location: location) { (address) in
            guard let addr = address as? String else { return }
            DispatchQueue.main.async {
                if "\(self.pinId)" + self.pinType == "\(id)" + type {
                    self.text = addr
                }
            }
            mbAddressCache.setObject(address, forKey: "\(id)" + type as AnyObject)
        }
    }
}
*/
