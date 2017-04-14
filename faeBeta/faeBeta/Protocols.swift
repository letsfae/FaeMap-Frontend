//
//  Protocols.swift
//  faeBeta
//
//  Created by Yue on 3/3/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol JSONDecodable {
    init(json: JSON) throws
}

extension Collection where Iterator.Element == JSON {
    func decode<T: JSONDecodable>() throws -> [T] {
        return try map{try T(json: $0)}
    }
}
