//
//  FaeAvatarGetter.swift
//  faeBeta
//
//  Created by Yue on 5/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class General: NSObject {
    
    static let shared = General()
    
    func avatar(userid: Int, completion:@escaping (UIImage) -> Void) {
        
        if userid == 1 {
            guard let faeAvatar = Key.shared.imageFaeAvatar else { return }
            completion(faeAvatar)
            return
        }
        
        if userid <= 0 {
            guard let defaultImage = Key.shared.imageDefaultMale else { return }
            completion(defaultImage)
        }
        
        /*let realm = try! Realm()
        if let userAvatar = realm.objects(UserAvatar.self).filter("user_id == %@", "\(userid)").first {
            if let dataAvatar = userAvatar.userSmallAvatar {
                let imageFromRealm = UIImage(data: dataAvatar as Data)
                completion(imageFromRealm!)
            }
        }*/
        
        /*if let imageFromCache = faeImageCache.object(forKey: userid as AnyObject) as? UIImage {
//            joshprint("[getAvatar - \(userid)] already in cache")
            completion(imageFromCache)
            return
        }*/
        
        getAvatar(userID: userid, type: 2) { (status, etag, imageRawData) in
            guard imageRawData != nil else {
                print("[getAvatar] fail, imageRawData is nil")
                return
            }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            DispatchQueue.main.async(execute: {
                guard let imageToCache = UIImage.sd_image(with: imageRawData) else { return }
                faeImageCache.setObject(imageToCache, forKey: userid as AnyObject)
                completion(imageToCache)
            })
        }
    }
    
    func getAddress(location: CLLocation, original: Bool = false, full: Bool = true, detach: Bool = false, completion: @escaping (AnyObject) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard error == nil else { joshprint("[CLGeocoder] error != nil"); return }
                guard let results = placemarks else { joshprint("[CLGeocoder] results = placemarks"); return }
                guard results.count > 0 else { joshprint("[CLGeocoder] results.count <= 0"); return }
                guard let first = results.first else { joshprint("[CLGeocoder] first != results.first"); return }
                if original {
                    completion(first as AnyObject)
                    return
                }
                var name = ""
                var subThoroughfare = ""
                var thoroughfare = ""
                var locality = ""
                var administrativeArea = ""
                var postalCode = ""
                var country = ""
                
                if let n = first.name {
                    name = n
                }
                if let s = first.subThoroughfare {
                    subThoroughfare = s
                }
                if let t = first.thoroughfare {
                    thoroughfare = t
                }
                if let l = first.locality {
                    locality = l
                }
                if let a = first.administrativeArea {
                    administrativeArea = a
                }
                if let s = first.postalCode {
                    postalCode = s
                }
                if let c = first.country {
                    country = c
                }
                
                var address = ""
                
                if full == false {
                    address = locality + ", " + administrativeArea + ", " + country
                    if detach {
                        if locality == administrativeArea {
                            address = locality + "@" + ", " + country
                        }
                        if locality == country {
                            address = locality + "@"
                        }
                        address = locality + "@" + administrativeArea + ", " + country
                        completion(address as AnyObject)
                    } else {
                        completion(address as AnyObject)
                    }
                    return
                }
                
                if name == subThoroughfare + " " + thoroughfare {
                    address = name + ", " + locality + ", " + administrativeArea + postalCode + ", " + country
                } else {
                    address = name + ", " + subThoroughfare + " " + thoroughfare + ", " + locality + ", " + administrativeArea + postalCode + ", " + country
                }
                
                completion(address as AnyObject)
            }
        })
    }
    
    func getLocation(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            CLGeocoder().geocodeAddressString(address, in: nil) { (placemarks, error) in
                guard error == nil else { joshprint("[CLGeocoder] error != nil"); return }
                guard let results = placemarks else { joshprint("[CLGeocoder] results = placemarks"); return }
                guard results.count > 0 else { joshprint("[CLGeocoder] results.count <= 0"); return }
                guard let first = results.first else { joshprint("[CLGeocoder] first != results.first"); return }
                completion(first.location?.coordinate)
            }
        }
    }
    
    func getPlacePins(coordinate: CLLocationCoordinate2D, radius: Int, count: Int, completion: @escaping (Int, JSON) -> Void) {
        let getPlaces = FaeMap()
        getPlaces.whereKey("geo_latitude", value: "\(coordinate.latitude)")
        getPlaces.whereKey("geo_longitude", value: "\(coordinate.longitude)")
        getPlaces.whereKey("radius", value: "99999999")
        getPlaces.whereKey("type", value: "place")
        getPlaces.whereKey("max_count", value: "\(count)")
        getPlaces.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                completion(status, JSON())
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                completion(status, JSON())
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                completion(status, JSON())
                return
            }
            completion(status, mapPlaceJSON)
        }
    }
}
