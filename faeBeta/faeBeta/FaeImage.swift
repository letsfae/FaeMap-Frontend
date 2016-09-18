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
/*
 let max_image_bytes = 1024    // 0.1 MB for the image
let datas = UIImageJPEGRepresentation(self.imageViewCover.image, 1)
let formatted_datas = Int(datas.length)

println("\(formatted_datas)")

/* resize the image if the image is larger than 0.8MB */

if (formatted_datas > self.max_image_bytes){
    // image too large
    println("Compress Image to JPEG")
    
    let image_before_compression = self.imageViewCover.image
    let compress_ratio = CGFloat(self.max_image_bytes / formatted_datas)
    
    let compressed_img = UIImageJPEGRepresentation(image_before_compression, compress_ratio)
    
    println("\(Int(compressed_img.length))")
    
    let file = PFFile (data: compressed_img, contentType: "JPEG")
    let str : String!
    file.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        self.userCurrent["faceURL"] = file.url
        self.userCurrent.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in println("Object has been saved.")}
    }
    
} else {
    
    let file = PFFile (data: datas, contentType: "JPEG")
    let str : String!
    file.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        self.userCurrent["faceURL"] = file.url
        self.userCurrent.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in println("Object has been saved.")}
    }
}*/

func compressImage(image:UIImage)->NSData{
    let max_image_bytes = 1024    // 0.1 MB for the image
    let dates = UIImageJPEGRepresentation(image, 1)
    let formatted_datas = Int((dates?.length)!)//4752033
    if formatted_datas > max_image_bytes {
        let image_before_compression = image
        let compress_ratio = CGFloat(max_image_bytes / formatted_datas)
        
        let compressed_img = UIImageJPEGRepresentation(image_before_compression, compress_ratio)
        
//        print("\(Int(compressed_img.!length))")
        print(compressed_img?.length)//245357
        return compressed_img!
    }
    else{
        return dates!
    }
}
class FaeImage : NSObject{ // it is ok to upload
//    var keyValue = [String:AnyObject]()
    var image : UIImage!
//    var imageView: UIImageView!

    func faeUploadImageInBackground(completion:(Int,AnyObject?)->Void){
        if image == nil {
            completion(-400,"you need to save image first")
        }
        else{
            let file = compressImage(image)
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                postImageToURL("files/users/avatar", parameter: ["avatar":file], authentication: headerAuthentication(), completion: { (code:Int, message:AnyObject?) in
                    completion(code,message)
                })
            })
        }
    }
    
}

extension UIImageView {
    func faeSetSelfAvatar(placeHolder:UIImage)->Void{
        self.image = placeHolder
//        self.sd_setImageWithURL(NSURL(string: "https://api.letsfae.com/files/avatar/23"))
 
        getImageFromURL("files/users/21/avatar/", authentication: headerAuthentication(), completion: {(status:Int, image:AnyObject?) in
            if status / 100 == 2 {
//                self.image = image as! UIImage
//                self.image = UIImage(data: image as! NSData)
                self.image = image as? UIImage
            }
        })
//        SDWebImageDownloader *manager = [SDWebImageManager sharedManager].imageDownloader;
//        [manager setValue:username forHTTPHeaderField:@"X-Oauth-Username"];
        
    }
    func faeSetImage(url:NSURL,placeHolder:UIImage)->Void{
    }
}

/*
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}*/

/*
class FaeImage: NSObject {
    var imageData = UIImage()
    func saveAvatarInBackGround(completion:(Int,AnyObject?)->Void){
        
    }
    func getAvatarByURL(url:NSURL,completion:(Int,AnyObject?)->Void){
        
    }
}*/
