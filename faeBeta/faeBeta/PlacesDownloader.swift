//
//  PlacesDownloader.swift
//  faeBeta
//
//  Created by Yue Shen on 3/19/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

enum DownloadState {
    case new, loading, downloaded, failed
}

class PendingOperations {
    var state = DownloadState.new
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class PlacePinFetcher: Operation {
    //1
    private let cluster: CCHMapClusterController
    private let arrPlaceJSON: [JSON]
    private let idSet: Set<Int>
    var placePins = [FaePinAnnotation]()
    var ids = [Int]()
    
    //2
    init(cluster: CCHMapClusterController, arrPlaceJSON: [JSON], idSet: Set<Int>) {
        self.cluster = cluster
        self.arrPlaceJSON = arrPlaceJSON
        self.idSet = idSet
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        
        //5
        
        for placeJson in arrPlaceJSON {
            let placeData = PlacePin(json: placeJson)
            let place = FaePinAnnotation(type: .place, cluster: self.cluster, data: placeData)
            if !idSet.contains(placeJson["place_id"].intValue) {
                placePins.append(place)
                ids.append(placeJson["place_id"].intValue)
            }
        }

    }
}

class UserPinFetcher: Operation {
    //1
    private let cluster: CCHMapClusterController
    private let arrUserJSON: [JSON]
    private let idSet: Set<Int>
    private let originals: [FaePinAnnotation]
    var userPins = [FaePinAnnotation]()
    var ids = [Int]()
    
    //2
    init(cluster: CCHMapClusterController, arrJSON: [JSON], idSet: Set<Int>, originals: [FaePinAnnotation]) {
        self.cluster = cluster
        self.arrUserJSON = arrJSON
        self.idSet = idSet
        self.originals = originals
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        
        //5
        for userJson in arrUserJSON {
            let userData = UserPin(json: userJson)
            let user = FaePinAnnotation(type: .user, cluster: self.cluster, data: userData)
            if !idSet.contains(userJson["user_id"].intValue) {
                userPins.append(user)
                ids.append(userJson["user_id"].intValue)
            } else {
                guard let index = self.originals.index(of: user) else { continue }
                self.originals[index].positions = user.positions
            }
        }
    }
}
