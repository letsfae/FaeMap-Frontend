//
//  MBNetwork.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/5/18.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON

extension MapBoardViewController {
    
//    func getMBSocialInfo(socialType: String) {
//        let mbSocialList = FaeMap()
//        mbSocialList.whereKey("geo_latitude", value: "\(currentLatitude)")
//        mbSocialList.whereKey("geo_longitude", value: "\(currentLongitude)")
//        mbSocialList.whereKey("radius", value: "9999999")
//        mbSocialList.whereKey("type", value: "\(socialType)")
//        mbSocialList.whereKey("in_duration", value: "false")
//        mbSocialList.whereKey("max_count", value: "100")
//        mbSocialList.getMapInformation { (status: Int, message: Any?) in
//            
//            if status / 100 != 2 || message == nil {
//                print("[loadMBSocialInfo] status/100 != 2")
//                
//                return
//            }
//            let socialInfoJSON = JSON(message!)
//            guard let socialInfoJsonArray = socialInfoJSON.array else {
//                print("[loadMBSocialInfo] fail to parse mapboard social info")
//                
//                return
//            }
//            if socialInfoJsonArray.count <= 0 {
//                
//                print("[loadMBSocialInfo] array is nil")
//                return
//            }
//            
//            self.processMBInfo(results: socialInfoJsonArray, socialType: socialType)
    
//            self.mbComments.sort { $0.pinId > $1.pinId }
//            self.mbStories.sort { $0.pinId > $1.pinId }
            
            // if mbComments > 0  =>  恒成立？
//            for i in 0..<self.mbComments.count {
//                let pos = self.mbComments[i].position
//                self.getSocialPinAddress(position: pos, socialType: "comment", index: i)
//            }
//            
//            for i in 0..<self.mbStories.count {
//                let pos = self.mbStories[i].position
//                self.getSocialPinAddress(position: pos, socialType: "media", index: i)
//            }
            
            //            self.tableMapBoard.reloadData()
//        }
//    }
    
    fileprivate func processMBInfo(results: [JSON], socialType: String) {
        for result in results {
            switch socialType {
//            case "comment":
//                let mbCommentData = MBSocialStruct(json: result)
//                if self.mbComments.contains(mbCommentData) {
//                    continue
//                } else {
//                    self.mbComments.append(mbCommentData)
//                }
//                break
//            case "media":
//                let mbStoryData = MBSocialStruct(json: result)
//                if self.mbStories.contains(mbStoryData) {
//                    continue
//                } else {
//                    self.mbStories.append(mbStoryData)
//                }
//                break
            case "place":
                let mbPlaceData = PlacePin(json: result)
//                if self.mbPlaces.contains(mbPlaceData) {
//                    continue
//                } else {
//                    self.mbPlaces.append(mbPlaceData)
//                }
//                if mbPlaceData.class_2_icon_id != 0 {
                    self.mbPlaces.append(mbPlaceData)
//                }
                
                if mbPlaceData.class_1.contains("Arts") && testArrPopular.count < 15 {
                    testArrPopular.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Education") && testArrRecommend.count < 15{
                    testArrRecommend.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Food") && testArrFood.count < 15 {
                    testArrFood.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Shopping") && testArrShopping.count < 15 {
                    testArrShopping.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Outdoors") && testArrOutdoors.count < 15 {
                    testArrOutdoors.append(mbPlaceData)
                }
            case "people":
                
                let mbPeopleData = MBPeopleStruct(json: result, centerLoc: self.chosenLoc)
                if mbPeopleData.userId == Key.shared.user_id {
                    continue
                }
                
                if selectedGender == "" {
                    continue
                }
                if (mbPeopleData.dis > Double(disVal)!) {
                    continue
                }
                if (selectedGender == "Female" && mbPeopleData.gender != "female") || (selectedGender == "Male" && mbPeopleData.gender != "male") {
                    continue
                }
                
                if lblAgeVal.text == "All" {
                    self.mbPeople.append(mbPeopleData)
                    continue
                }
                
                if mbPeopleData.age == "" {
                    continue
                }
                
                if ((Int(mbPeopleData.age)! < ageLBVal) || (Int(mbPeopleData.age)! > ageUBVal) && !(ageLBVal == 18 && ageUBVal == 55)) {
                    continue
                }
                
                self.mbPeople.append(mbPeopleData)
            default: break
            }
        }
    }
    
    func getMBPlaceInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let mbPlacesList = FaeMap()
        mbPlacesList.whereKey("geo_latitude", value: "\(latitude)")
        mbPlacesList.whereKey("geo_longitude", value: "\(longitude)")
        mbPlacesList.whereKey("radius", value: "9999999999")
        mbPlacesList.whereKey("type", value: "place")
        mbPlacesList.whereKey("max_count", value: "1000")
        mbPlacesList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMBPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMBPlaceInfo] fail to parse mapboard place info")
                return
            }
            if placeInfoJsonArray.count <= 0 {
                print("[loadMBPlaceInfo] array is nil")
                return
            }
            
            self.mbPlaces.removeAll()
            self.testArrPlaces.removeAll()
            
            self.testArrPopular.removeAll()
            self.testArrRecommend.removeAll()
            self.testArrFood.removeAll()
            self.testArrShopping.removeAll()
            self.testArrOutdoors.removeAll()
            
            self.processMBInfo(results: placeInfoJsonArray, socialType: "place")
//            self.mbPlaces.sort { $0.dis < $1.dis }
            
            self.testArrPlaces.append(self.testArrPopular)
            self.testArrPlaces.append(self.testArrRecommend)
            self.testArrPlaces.append(self.testArrFood)
            self.testArrPlaces.append(self.testArrShopping)
            self.testArrPlaces.append(self.testArrOutdoors)
            
            self.arrAllPlaces = self.mbPlaces
            self.tblMapBoard.reloadData()
        }
    }
    
    func getMBPeopleInfo(_ completion: ((Int) -> ())?) {
        var location: CLLocationCoordinate2D!
        if let loc = chosenLoc {
            location = loc
        } else {
            location = LocManager.shared.curtLoc.coordinate
        }
        FaeMap.shared.whereKey("geo_latitude", value: "\(location.latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(location.longitude)")
        FaeMap.shared.whereKey("radius", value: "99999999999")
        FaeMap.shared.whereKey("type", value: "user")
        FaeMap.shared.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMBPeopleInfo] status/100 != 2")
                return
            }
            let peopleInfoJSON = JSON(message!)
            guard let peopleInfoJsonArray = peopleInfoJSON.array else {
                print("[loadMBPeopleInfo] fail to parse mapboard people info")
                return
            }
            if peopleInfoJsonArray.count <= 0 {
                print("[loadMBPeopleInfo] array is nil")
                return
            }
            
            self.mbPeople.removeAll()
            self.processMBInfo(results: peopleInfoJsonArray, socialType: "people")
            
            self.mbPeople.sort{ $0.dis < $1.dis }
//            print(self.mbPeople)
//            self.tblMapBoard.reloadData()
            completion?(self.mbPeople.count)
        }
    }
}
