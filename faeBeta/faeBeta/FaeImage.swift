//
//  FaeImage.swift
//  faeBeta
//
//  Created by blesssecret on 6/13/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SDWebImage

typealias ImageView = UIImageView

public typealias IndicatorView = UIActivityIndicatorView

func compressImage(_ image: UIImage, max_image_bytes: Int = 1024) -> Data {
//    let max_image_bytes = 1024    // 0.1 MB for the image
    let dates = UIImageJPEGRepresentation(image, 1)
    let formatted_datas = Int((dates?.count)!)//4752033
    if formatted_datas > max_image_bytes {
        let image_before_compression = image
        let compress_ratio = CGFloat(max_image_bytes / formatted_datas)
        
        let compressed_img = UIImageJPEGRepresentation(image_before_compression, compress_ratio)
        
        return compressed_img!
    } else {
        return dates!
    }
}
class FaeImage: NSObject {

    var image: UIImage!
    var type: String!
    
    func faeUploadFile(_ completion: @escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400, "Error: Need to save image first" as AnyObject?)
        } else if type == nil {
            completion(-400, "Error: Need to specify file type first" as AnyObject?)
        } else {
            let file = compressImage(image)
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                postFileToURL("files", parameter: ["file": file as AnyObject, "type": self.type as AnyObject], authentication: headerAuthentication(), completion: { (code: Int, message: Any?) in
                    completion(code, message)
                })
            })
        }
    }

    func faeUploadProfilePic(_ completion: @escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400, "you need to save image first" as AnyObject?)
        } else {
            let file = compressImage(image)
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                postImageToURL("files/users/avatar", parameter: ["avatar": file as AnyObject], authentication: headerAuthentication(), completion: { (code: Int, message: Any?) in
                    completion(code, message)
                })
            })
        }
    }
    
    func faeUploadCoverImageInBackground(_ completion:@escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400,"you need to save image first" as AnyObject?)
        } else {
            let file = compressImage(image)
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)

            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                postCoverImageToURL("files/users/name_card_cover", parameter: ["name_card_cover":file as AnyObject], authentication: headerAuthentication(), completion: { (code: Int, message: Any?) in
                    completion(code, message)
                })
            })
        }
    }
}
