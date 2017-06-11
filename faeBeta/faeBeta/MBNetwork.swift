//
//  MBNetwork.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/5/18.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps
import GooglePlaces

extension MapBoardViewController {
    
    func getMBSocialInfo(socialType: String) {
        let mbSocialList = FaeMap()
        mbSocialList.whereKey("geo_latitude", value: "\(currentLatitude)")
        mbSocialList.whereKey("geo_longitude", value: "\(currentLongitude)")
        mbSocialList.whereKey("radius", value: "9999999")
        mbSocialList.whereKey("type", value: "\(socialType)")
        mbSocialList.whereKey("in_duration", value: "false")
        mbSocialList.whereKey("max_count", value: "100")
        mbSocialList.getMapInformation { (status: Int, message: Any?) in
            
            if status / 100 != 2 || message == nil {
                print("[loadMBSocialInfo] status/100 != 2")
                
                return
            }
            let socialInfoJSON = JSON(message!)
            guard let socialInfoJsonArray = socialInfoJSON.array else {
                print("[loadMBSocialInfo] fail to parse mapboard social info")
                
                return
            }
            if socialInfoJsonArray.count <= 0 {
                
                print("[loadMBSocialInfo] array is nil")
                return
            }
            
            self.processMBInfo(results: socialInfoJsonArray, socialType: socialType)
            
            self.mbComments.sort { $0.pinId > $1.pinId }
            self.mbStories.sort { $0.pinId > $1.pinId }
            
            // if mbComments > 0  =>  恒成立？
            for i in 0..<self.mbComments.count {
                let pos = self.mbComments[i].position
                self.getSocialPinAddress(position: pos, socialType: "comment", index: i)
            }
            
            for i in 0..<self.mbStories.count {
                let pos = self.mbStories[i].position
                self.getSocialPinAddress(position: pos, socialType: "media", index: i)
            }
            
            //            self.tableMapBoard.reloadData()
        }
    }
    
    fileprivate func processMBInfo(results: [JSON], socialType: String) {
        for result in results {
            switch socialType {
            case "comment":
                let mbCommentData = MBSocialStruct(json: result)
                if self.mbComments.contains(mbCommentData) {
                    continue
                } else {
                    self.mbComments.append(mbCommentData)
                }
                break
            case "media":
                let mbStoryData = MBSocialStruct(json: result)
                if self.mbStories.contains(mbStoryData) {
                    continue
                } else {
                    self.mbStories.append(mbStoryData)
                }
                break
            case "place":
                let mbPlaceData = MBPlacesStruct(json: result)
                if self.mbPlaces.contains(mbPlaceData) {
                    continue
                } else {
                    self.mbPlaces.append(mbPlaceData)
                }
                break
            case "Peple":
                let mbPeopleData = MBPeopleStruct(json: result)
                if self.mbPeople.contains(mbPeopleData) {
                    continue
                } else {
                    self.mbPeople.append(mbPeopleData)
                }
                break
            default:
                break
            }
        }
    }
    
    fileprivate func getSocialPinAddress(position: CLLocationCoordinate2D, socialType: String, index: Int) {
        GMSGeocoder().reverseGeocodeCoordinate(position, completionHandler: {
            (response, _) -> Void in
            
            if let fullAddress = response?.firstResult()?.lines {
                var address: String = ""
                for line in fullAddress {
                    if line == "" {
                        continue
                    } else if fullAddress.index(of: line) == fullAddress.count - 1 {
                        address += line + ""
                    } else {
                        address += line + ", "
                    }
                }
                
                if socialType == "comment" {
                    self.mbComments[index].address = address
                } else if socialType == "media" {
                    self.mbStories[index].address = address
                    
                    //                    print("\(index) \(position) \(address)")
                }
            }
        })
        
        /*
        CLGeocoder().reverseGeocodeLocation(position, completionHandler: {
            (placemarks, error) -> Void in
            var placemark:CLPlacemark!
            var address: String = ""
         
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
         
                if placemark.subThoroughfare != nil {
                    address += "\(placemark.subThoroughfare!)"
                }
                if placemark.thoroughfare != nil {
                    address += ", \(placemark.thoroughfare!)"
                }
                if placemark.locality != nil {
                    address += ", \(placemark.locality!)"
                }
                if placemark.administrativeArea != nil {
                    address += ", \(placemark.administrativeArea!)"
                }
                if placemark.country != nil {
                    address += ", \(placemark.country!)"
                }
                if placemark.postalCode != nil {
                    address += ", \(placemark.postalCode!)"
                }
//                address = "\(placemark.subThoroughfare!), \(placemark.thoroughfare!), \(placemark.postalCode!), \(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
         
                if socialType == "comment" {
                    self.mbComments[index].address = address
                } else if socialType == "media" {
                    self.mbStories[index].address = address
                }
            }
        })
        */
    }
    
    func getMBPlaceInfo() {
        let mbPlacesList = FaeMap()
        mbPlacesList.whereKey("geo_latitude", value: "\(currentLatitude)")
        mbPlacesList.whereKey("geo_longitude", value: "\(currentLongitude)")
        mbPlacesList.whereKey("radius", value: "9999999")
        mbPlacesList.whereKey("type", value: "place")
        mbPlacesList.whereKey("in_duration", value: "false")
        mbPlacesList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMBPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMBPlaceInfo] fail to parse mapboard social info")
                return
            }
            if placeInfoJsonArray.count <= 0 {
                print("[loadMBPlaceInfo] array is nil")
                return
            }
            
            self.processMBInfo(results: placeInfoJsonArray, socialType: "place")
            
            self.mbPlaces.sort { $0.dis < $1.dis }
            //            self.mbPlaces = self.mbPlaces.sorted(by: { $0.dis < $1.dis })
        }
    }
    
    func getMBPeopleInfo() {
        let mbPeopleList = FaeMap()
        mbPeopleList.whereKey("geo_latitude", value: "\(currentLatitude)")
        mbPeopleList.whereKey("geo_longitude", value: "\(currentLongitude)")
        mbPeopleList.whereKey("radius", value: "9999999")
        mbPeopleList.whereKey("type", value: "user")
        mbPeopleList.whereKey("in_duration", value: "false")
        mbPeopleList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMBPeopleInfo] status/100 != 2")
                return
            }
            let peopleInfoJSON = JSON(message!)
            guard let peopleInfoJsonArray = peopleInfoJSON.array else {
                print("[loadMBPeopleInfo] fail to parse mapboard social info")
                return
            }
            if peopleInfoJsonArray.count <= 0 {
                print("[loadMBPeopleInfo] array is nil")
                return
            }
            
            print(peopleInfoJsonArray)
            self.processMBInfo(results: peopleInfoJsonArray, socialType: "people")
            //            self.mbPeople.sort{ $0.dis < $1.dis }
        }
    }
}
