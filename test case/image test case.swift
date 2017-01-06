//: Playground - noun: a place where people can play

import UIKit

// download self avatar // 头像
let stringHeaderURL = "https://api.letsfae.com/files/users/" + user_id.stringValue + "/avatar"
print(user_id)
headerImageView.sd_setImageWithURL(NSURL(string: stringHeaderURL))
// download cover page
if user_id != nil {
    let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/name_card_cover"
    print(stringHeaderURL)
    imageViewAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .RefreshCached)
}
// with default image
if user_id != nil {
    let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
    print(stringHeaderURL)
    imageViewAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .RefreshCached)
}

// upload self avatar
let avatar = FaeImage()
avatar.image = image
avatar.faeUploadImageInBackground { (code:Int, message:AnyObject?) in
    print(code)
    print(message)
    if code / 100 == 2 {//upload success
        self.imageViewAvatarMore.image = image
    } else {
        //failure, we need to hanld the error here
    }
}

