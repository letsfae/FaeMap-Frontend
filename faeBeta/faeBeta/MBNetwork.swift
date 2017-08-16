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
                if mbPlaceData.class_1.contains("Drink") && testArrDrinks.count < 15 {
                    testArrDrinks.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Shopping") && testArrShopping.count < 15 {
                    testArrShopping.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Outdoors") && testArrOutdoors.count < 15 {
                    testArrOutdoors.append(mbPlaceData)
                }
                if mbPlaceData.class_1.contains("Recreation") && testArrRecreation.count < 15 {
                    testArrRecreation.append(mbPlaceData)
                }
                break
            case "people":
                
                let mbPeopleData = MBPeopleStruct(json: result)
                if mbPeopleData.userId == Key.shared.user_id {
                    continue
                }
                
                if selectedGender == "" || mbPeopleData.age == "" {
                    continue
                }
                
                if (mbPeopleData.dis > Double(disVal)!) || (selectedGender == "Female" && mbPeopleData.gender != "female") || (selectedGender == "Male" && mbPeopleData.gender != "male") || (Int(mbPeopleData.age)! < ageLBVal) || (Int(mbPeopleData.age)! > ageUBVal) {
                    continue
                }
                
                self.mbPeople.append(mbPeopleData)
                break
            default:
                break
            }
        }
    }
    
    func getMBPlaceInfo() {
        let mbPlacesList = FaeMap()
        mbPlacesList.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
        mbPlacesList.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
        mbPlacesList.whereKey("radius", value: "9999999")
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
            self.testArrDrinks.removeAll()
            self.testArrShopping.removeAll()
            self.testArrOutdoors.removeAll()
            self.testArrRecreation.removeAll()
            
            self.processMBInfo(results: placeInfoJsonArray, socialType: "place")
//            self.mbPlaces.sort { $0.dis < $1.dis }
            
            self.testArrPlaces.append(self.testArrPopular)
            self.testArrPlaces.append(self.testArrRecommend)
            self.testArrPlaces.append(self.testArrFood)
            self.testArrPlaces.append(self.testArrDrinks)
            self.testArrPlaces.append(self.testArrShopping)
            self.testArrPlaces.append(self.testArrOutdoors)
            self.testArrPlaces.append(self.testArrRecreation)
            
            self.tblMapBoard.reloadData()
        }
    }
    
    func getMBPeopleInfo(_ completion: ((Int) -> ())?) {
        let mbPeopleList = FaeMap()
        
        mbPeopleList.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
        mbPeopleList.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
        mbPeopleList.whereKey("radius", value: "9999999")
        mbPeopleList.whereKey("type", value: "user")
        mbPeopleList.getMapInformation { (status: Int, message: Any?) in
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
