//
//  OpenedPlaces.swift
//  faeBeta
//
//  Created by Yue on 4/14/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

extension OpenedPlace: Equatable {
    static func ==(lhs: OpenedPlace, rhs: OpenedPlace) -> Bool {
        return lhs.pinId == rhs.pinId
    }
}

struct OpenedPlace {
    
    var title: String
    var category: String
    var street: String
    var city: String
    var imageURL: String
    var position: CLLocationCoordinate2D
    var pinTime = ""
    var pinId = ""
    
    init(title: String, category: String, street: String, city: String, imageURL: String, position: CLLocationCoordinate2D) {
        self.title = title
        self.category = category
        self.street = street
        self.city = city
        self.imageURL = imageURL
        self.position = position
        self.pinTime = "\(street), \(city)"
        self.pinId = "\(title)\(street)"
    }
    
}

class OpenedPlaces {
    static var openedPlaces = [OpenedPlace]()
}
