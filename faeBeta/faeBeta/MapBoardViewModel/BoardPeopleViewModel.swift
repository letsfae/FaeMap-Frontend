//
//  MBPeopleViewModel.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class BoardPeopleViewModel {
    var location: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate {
        didSet {
            getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    var boolUserVisible: ((Bool) -> ())?
    var boolDataLoaded: ((Bool) -> ())?
    var peopleDataLoaded: (([BoardPeopleStruct]) -> ())?
    
    var visible: Bool = true {
        didSet {
            boolUserVisible?(visible)
        }
    }
    
    private var loaded: Bool = true {
        didSet {
            boolDataLoaded?(loaded)
        }
    }
    
    private var users: [BoardPeopleStruct] = [] {
        didSet {
            peopleDataLoaded?(users)
        }
    }
    
    var numberOfUsers: Int {
        return users.count
    }
    
    var hasUsers: Bool {
        return numberOfUsers > 0
    }
    
    var valDis: String = "23.0" {
        didSet {
            if oldValue != valDis {
                getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var valGender: String = "Both" {
        didSet {
            if oldValue != valGender {
                getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var valAgeLB: Int = 18 {
        didSet {
            if oldValue != valAgeLB {
                getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var valAgeUB: Int = 33 {
        didSet {
            if oldValue != valAgeUB {
                getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    var valAllAge: String = "" {
        didSet {
            if oldValue != valAllAge {
                getPeopleInfo(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    // MARK: - Methods
    private func people(at index: Int) -> BoardPeopleStruct? {
        guard index < users.count else { return nil }
        return users[index]
    }
    
    func viewModel(for index: Int) -> BoardOneUserViewModel? {
        guard let people = people(at: index) else { return nil }
        return BoardOneUserViewModel(people: people)
    }
    
    func getPeopleInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        loaded = false
        FaeMap.shared.whereKey("geo_latitude", value: "\(latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(longitude)")
        FaeMap.shared.whereKey("radius", value: "100000")   // 100km
        FaeMap.shared.whereKey("type", value: "user")
        FaeMap.shared.getMapInformation { [weak self] (status: Int, message: Any?) in
            self?.loaded = true
            
            if status / 100 != 2 || message == nil {
                print("[loadMBPeopleInfo] status/100 != 2")
                return
            }
            let peopleInfoJSON = JSON(message!)
            guard let peopleInfo = peopleInfoJSON.array else {
                print("[loadMBPeopleInfo] fail to parse mapboard people info")
                return
            }
            
            guard let `self` = self else { return }
            self.users = self.processPeopleInfo(results: peopleInfo, type: "people")
        }
    }
    
    fileprivate func processPeopleInfo(results: [JSON], type: String) -> [BoardPeopleStruct] {
        var users: [BoardPeopleStruct] = []
        
        for result in results {
            let peopleData = BoardPeopleStruct(json: result)
            if peopleData.userId == Key.shared.user_id {
                continue
            }
                
            if valGender == "" {
                continue
            }
            
            if (peopleData.distance > Double(valDis)!) {
                continue
            }
            
            if (valGender == "Female" && peopleData.gender != "female") || (valGender == "Male" && peopleData.gender != "male") {
                continue
            }
            
            if valAllAge == "All" {
                users.append(peopleData)
                continue
            }
            
            if peopleData.age == "" {
                continue
            }
            
            guard Int(peopleData.age) != nil else { continue }
                
            if ((Int(peopleData.age)! < valAgeLB) || (Int(peopleData.age)! > valAgeUB) && !(valAgeLB == 18 && valAgeUB == 55)) {
                continue
            }
            
            users.append(peopleData)
        }
        
        users.sort{ $0.distance < $1.distance }
        return users
    }
}
