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
import GooglePlaces

class General: NSObject {
    
    static let shared = General()
    
    func avatarCached(userid: Int, completion:@escaping (UIImage) -> Void) {
        let realm = try! Realm()
        if let user = realm.filterUser(id: "\(userid)") {
            if let avatar = user.avatar?.userSmallAvatar {
                if let img = UIImage(data: avatar as Data) {
                    completion(img)
                } else {
                    let gender = Key.shared.gender == "male" ? "defaultMen" : "defaultWomen"
                    completion(UIImage(named: gender)!)
                }
            }
        }
    }
    
    func avatar(userid: Int, completion:@escaping (UIImage) -> Void) {
        
        if userid == 1 {
            guard let faeAvatar = Key.shared.faeAvatar else { return }
            completion(faeAvatar)
            return
        }
        
        if userid <= 0 {
            guard let defaultImage = Key.shared.defaultMale else { return }
            completion(defaultImage)
        }
        
        getAvatar(userID: userid, type: 2) { (status, etag, imageRawData) in
            guard imageRawData != nil else {
                print("[getAvatar] fail, imageRawData is nil")
                return
            }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            DispatchQueue.main.async(execute: {
                guard imageRawData != nil else { return }
                guard let imageToCache = UIImage(data: imageRawData!) else { return }
                faeImageCache.setObject(imageToCache, forKey: userid as AnyObject)
                completion(imageToCache)
            })
        }
    }
    
    func coverPhotoCached(userid: Int, completion:@escaping (UIImage) -> Void) {
        let realm = try! Realm()
        if let user = realm.filterUser(id: "\(userid)") {
            if let coverPhoto = user.avatar?.userCoverPhoto {
                if let img = UIImage(data: coverPhoto as Data) {
                    completion(img)
                } else {
                    guard let defaultCover = Key.shared.defaultCover else { return }
                    completion(defaultCover)
                }
            }
        }
    }
    
    func coverPhoto(userid: Int, completion:@escaping (UIImage) -> Void) {
        
        if userid <= 1 {
            guard let defaultCover = Key.shared.defaultCover else { return }
            completion(defaultCover)
            return
        }
        
        getCoverPhoto(userID: userid, type: 2) { (status, etag, imageRawData) in
            if status == 404 {
                guard let defaultCover = Key.shared.defaultCover else { return }
                completion(defaultCover)
            }
            guard imageRawData != nil else {
                print("[getCoverPhoto] fail, imageRawData is nil")
                return
            }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            DispatchQueue.main.async(execute: {
                guard imageRawData != nil else { return }
                guard let imageToCache = UIImage(data: imageRawData!) else { return }
                faeImageCache.setObject(imageToCache, forKey: "\(userid)_coverPhoto" as AnyObject)
                completion(imageToCache)
            })
        }
    }
    
    func getAddress(location: CLLocation, original: Bool = false, full: Bool = true, detach: Bool = false, completion: @escaping (AnyObject) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard error == nil else { joshprint("[CLGeocoder] error != nil", error?.localizedDescription ?? ""); return }
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
                var subLocality = ""
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
                if let s_l = first.subLocality {
                    subLocality = s_l
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
//                    address = subLocality + ", " + locality + ", " + administrativeArea + ", " + country
                    address = (subLocality == "" ? "" : subLocality + ", ") + (locality == "" ? "" : locality + ", ") + (administrativeArea == "" ? "" : administrativeArea + ", ") + country
                    if detach {
                        /*
                        if locality == administrativeArea {
                            address = subLocality + ", " + locality + "@" + ", " + country
                            completion(address as AnyObject)
                            return
                        }
                        if locality == country {
                            address = subLocality + ", " + locality + "@"
                            completion(address as AnyObject)
                            return
                        }
                        */
                        address = (subLocality == "" ? "" : subLocality + ", ") + locality + "@" + (administrativeArea == "" ? "" : administrativeArea + ", ") + country
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
                completion(status, JSON.null)
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                completion(status, JSON.null)
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                completion(status, JSON.null)
                return
            }
            completion(status, mapPlaceJSON)
        }
    }
    
    func downloadImageForView(place: PlacePin, url: String, imgPic: UIImageView, _ completion: (() -> ())? = nil) {
        
        func whenComplete() {
            imgPic.image = #imageLiteral(resourceName: "default_place")
            imgPic.backgroundColor = .white
            imgPic.contentMode = .scaleAspectFill
            completion?()
        }
        
        if url == "" {
            whenComplete()
        } else {
            imgPic.contentMode = .scaleAspectFill
            if let placeImgFromCache = placeInfoBarImageCache.object(forKey: url as AnyObject) as? UIImage {
                imgPic.image = placeImgFromCache
                imgPic.backgroundColor = UIColor._2499090()
                completion?()
            } else {
                downloadImage(URL: url) { (rawData) in
                    guard let data = rawData else { whenComplete(); return }
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let placeImg = UIImage(data: data) else { whenComplete(); return }
                        DispatchQueue.main.async {
                            imgPic.image = placeImg
                            imgPic.backgroundColor = UIColor._2499090()
                            placeInfoBarImageCache.setObject(placeImg, forKey: url as AnyObject)
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
    // GMSLookUpPlaceForCoordinate
    func lookUpForCoordinate(_ completion: @escaping (GMSPlace) -> ()) {
        if let placeId = Key.shared.selectedPrediction?.placeID {
            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (gmsPlace, error) in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                guard let place = gmsPlace else {
                    print("No place details for \(placeId)")
                    return
                }
                completion(place)
            })
        }
    }
}
