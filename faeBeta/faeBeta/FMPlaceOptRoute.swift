//
//  FMPlaceOptRoute.swift
//  faeBeta
//
//  Created by Yue Shen on 8/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class RouteAddress: NSObject {
    var name: String
    var coordinate: CLLocationCoordinate2D
    init(name: String, coordinate: CLLocationCoordinate2D = LocManager.shared.curtLoc.coordinate) {
        self.name = name
        self.coordinate = coordinate
    }
}
