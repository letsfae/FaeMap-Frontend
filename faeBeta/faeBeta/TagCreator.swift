//
//  TagCreator.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/25/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
class TagCreator: NSObject {
    class func uploadTags(_ tagNames: [String], completion: @escaping (_ tagIds: [NSNumber]) -> ()){
        var tagNames = tagNames
        var tagIds = [NSNumber]()
        func uploadTag(_ tagName: String, completion:@escaping (_ tagIds: [NSNumber]) -> ()){
            postToURL("tags", parameter: ["title": tagName], authentication: headerAuthentication()) { (status, message) in
                if(status / 100 == 2){
                    let result = JSON(message!)
                    let id = result["tag_id"].number
                    tagIds.append(id!)
                }
                
                if(tagNames.count != 0){
                    let name = tagNames.removeFirst()
                    uploadTag(name, completion: completion)
                }else{
                    completion(tagIds)
                }
            }
        }
        if(tagNames.count != 0){
            uploadTag(tagNames.removeFirst(), completion: completion)
        }else{
            completion(tagIds)
        }
    }
}
