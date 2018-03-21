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

class PlacesAdder: Operation {
    //1
    let cluster: CCHMapClusterController
    let arrPlaceJSON: [JSON]
    let idSet: Set<Int>
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
            let place = FaePinAnnotation(type: "place", cluster: self.cluster, data: placeData)
            if !idSet.contains(placeJson["place_id"].intValue) {
                placePins.append(place)
                ids.append(placeJson["place_id"].intValue)
            }
        }

    }
}
