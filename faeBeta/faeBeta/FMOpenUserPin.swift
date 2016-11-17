//
//  OpenUserPinView.swift
//  faeBeta
//
//  Created by Yanxiang Wang on 16/7/26.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    
    func loadNamecard() {
        self.view.backgroundColor = UIColor.white
        
        uiviewDialog = UIView(frame: CGRect(x: (screenWidth-maxLength)/2, y: 140*screenWidthFactor, width: maxLength,height: 302))
        uiviewDialog.backgroundColor = UIColor(patternImage: UIImage(named: "map_userpin_dialog")!)
        uiviewDialog.layer.zPosition = 20
        
        uiviewCard = UIView(frame: CGRect(x: 0, y: 0,width: maxLength,height: 200))
        uiviewCard.backgroundColor = UIColor.clear
        uiviewCard.isHidden = true
        uiviewDialog.addSubview(uiviewCard)
        
        //avatar
        imageviewNamecardAvatar = UIImageView(frame: CGRect(x: (maxLength-70)/2, y: 90, width: 70, height: 70))
        imageviewNamecardAvatar.image = UIImage(named: "myAvatorLin")
        imageviewNamecardAvatar.layer.cornerRadius = 35
        imageviewNamecardAvatar.clipsToBounds = true
        imageviewNamecardAvatar.layer.borderColor = UIColor.white.cgColor
        imageviewNamecardAvatar.layer.borderWidth = 5
        imageviewNamecardAvatar.contentMode = .scaleAspectFill
        
        //background
        imageviewUserPinBackground = UIImageView(frame: CGRect(x: (maxLength - 268)/2, y: 20, width: 268, height: 126))
        imageviewUserPinBackground.image = UIImage(named: "map_userpin_background")
        imageviewUserPinBackground.clipsToBounds = false
        imageviewUserPinBackground.contentMode = .scaleAspectFill
        
        //button more
        buttonMore = UIButton(frame: CGRect(x: (maxLength-72), y: 40/736*screenHeight, width: 37, height: 17))
        
        buttonMore.setImage(UIImage(named: "map_namecard_dots"), for: UIControlState())
        
        //buttonMore.backgroundColor = UIColor.blackColor()
        buttonMore.addTarget(self, action: #selector(FaeMapViewController.buttonMoreAction(_:)), for: .touchUpInside)
        
        //load function view
        loadFunctionview()
        
        //label name
        labelNamecardName = UILabel(frame: CGRect(x: (maxLength-180)/2, y: 166, width: 180, height: 27))
        labelNamecardName.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNamecardName.textColor = UIColor.darkGray
        labelNamecardName.textAlignment = .center
        labelNamecardName.text = "LinLInLiN"
        
        //label description
        labelNamecardDescription = UILabel(frame: CGRect(x: (maxLength-294)/2, y: 100, width: 294, height: 44))
        labelNamecardDescription.numberOfLines = 2
        labelNamecardDescription.font = UIFont(name: "AvenirNext-Medium", size: 15.0)
        labelNamecardDescription.textColor = UIColor.lightGray
        labelNamecardDescription.textAlignment = .center
        labelNamecardDescription.text = "hahahaaahahah\nahaahahahahahahahe\nhahahhahahahahahahahahahahah"
        
        //line
        viewLine2 = UIView(frame: CGRect(x: (maxLength-268)/2, y: 80, width: 268, height: 1))
        viewLine2.backgroundColor = UIColor.lightGray
        //viewLine2.hidden = true
        viewLine = UIView(frame: CGRect(x: (maxLength-252)/2, y: 210, width: 252, height: 1))
        viewLine.backgroundColor = UIColor.lightGray
        
        //gender
        imageViewGender = UIImageView(frame: CGRect(x: 37, y: 40, width: 50, height: 19))
        imageViewGender.image = UIImage(named: "map_userpin_male")
        //imageViewGender.hidden = true
        uiviewCard.addSubview(imageViewGender)
        
        //age
        labelNamecardAge = UILabel(frame: CGRect(x: 27, y: 1, width: 16, height: 18))
        labelNamecardAge.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelNamecardAge.textColor = UIColor.white
        imageViewGender.addSubview(labelNamecardAge)
        
        //load button
        buttonChat = UIButton(frame: CGRect(x:(maxLength-190)/2, y: 230, width: 190, height: 39))
        buttonChat.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        buttonChat.layer.cornerRadius = 19
        buttonChat.setTitle("Chat", for: UIControlState())
        buttonChat.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        buttonChat.addTarget(self, action: #selector(FaeMapViewController.buttonChatAction(_:)), for: .touchUpInside)
        
        loadTags()
        //uiviewTag.hidden = true
        
        
        uiviewCard.addSubview(buttonMore)
        uiviewDialog.addSubview(labelNamecardName)
        uiviewCard.addSubview(labelNamecardDescription)
        uiviewCard.addSubview(viewLine2)
        uiviewDialog.addSubview(viewLine)
        
        uiviewDialog.addSubview(imageviewUserPinBackground)
        
        uiviewDialog.addSubview(buttonChat)
        
        self.view.addSubview(uiviewDialog)
        self.uiviewDialog.addSubview(imageviewNamecardAvatar)
        
        uiviewDialog.alpha = 0.0
        
        //        print("get name card")
        /*
        let user1 = FaeUser()
        user1.getNamecardOfSpecificUser(String(4)){(status:Int, message: Any?) in
            print(status)
            print("gets name")
            if(status / 100 == 2){
                print(message)
            }
        }
         */
        //        user1.getSelfNamecard{(status:Int, message: Any?) in
        //            if(status / 100 == 2){
        //                print("gets self name")
        //                print(message)
        //            }
        //        }
        //        user1.getAllTags{(status:Int, message: Any?) in
        //            if(status / 100 == 2){
        //                print("gets all tags")
        //                print(message)
        //            }
        //        }
        //
//        user1.getSelfProfile{(status:Int, message: Any?) in
//            if(status / 100 == 2){
//                print("gets self profile")
//                print(status)
//                print(message)
//            }
//        }
        //
        //        user1.getOthersProfile(String(1)){(status:Int, message: Any?) in
        //            print(status)
        //            print("gets others profile")
        //            if(status / 100 == 2){
        //                print(message)
        //            }
        //        }
        //
        //        user1.whereKey("nick_name", value: "heheda")
        //        user1.whereKey("short_intro", value: "hansome boy")
        //        user1.whereKey("tag_ids", value: "4;5;6")
        //        user1.updateNameCard{(status:Int, message: Any?) in
        //            if(status / 100 == 2){
        //                print("update name card")
        //                print(status)
        //                print(message)
        //            }
        //        }
        
        
        
    }
    
    func showOpenUserPinAnimation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        UIView.animate(withDuration: 0.2, animations: ({
            self.uiviewDialog.alpha = 1.0
        }))
        openUserPinActive = true
        let camera = GMSCameraPosition.camera(withLatitude: latitude+0.001, longitude: longitude, zoom: 17)
        faeMapView.animate(to: camera)
    }
    
    func hideOpenUserPinAnimation() {
        UIView.animate(withDuration: 0.2, animations: ({
            self.uiviewDialog.alpha = 0.0
        }))
    }
    
    func getColor(_ red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    func loadTags(){
        uiviewTag = UIView(frame: CGRect(x: 0, y: 168, width: maxLength, height: tagHeight))
        uiviewCard.addSubview(uiviewTag)
        
        
        let totalInterval = (CGFloat)(tagName.count - 1) * selectedInterval
        var totalTag : CGFloat = 0
        
        for tag in tagName {
            
            let attributedString = NSMutableAttributedString(string: tag)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.1), range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBold",size: 11)!, range: NSRange(location: 0, length: attributedString.length))
            
            let length = attributedString.widthWithConstrainedHeight(15)
            tagLength.append(length + 2*exlength)
            totalTag += length + 2*exlength
            tagTitle.append(attributedString)
            
        }
        
        var xOffset : CGFloat = (maxLength - totalTag - totalInterval) / 2
        
        for i in 0 ..< tagName.count {
            let buttonTag : UIButton = UIButton(frame: CGRect(x: xOffset, y: 0, width: tagLength[i], height: tagHeight))
            buttonTag.backgroundColor = tagColor[i]
            buttonTag.setAttributedTitle(tagTitle[i], for: UIControlState())
            buttonTag.titleLabel?.textColor = UIColor.white
            uiviewTag.addSubview(buttonTag)
            xOffset += (tagLength[i]+intervalInLine)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch: UITouch = touches.first{
            if(touch.view != uiviewFunction && touch.view != buttonMore){
                hideFunctionview()
            }
            if(touch.view == uiviewDialog || touch.view == uiviewCard){
                imageviewUserPinBackground.isHidden = true
                imageviewNamecardAvatar.frame.origin.y = -10
                //viewLine2.hidden = false
                labelNamecardName.isHidden = true
                uiviewCard.isHidden = false
                //uiviewTag.hidden = false
                //imageViewGender.hidden = false
            }
        }
    }
    
    func loadFunctionview(){
        
        
        uiviewFunction = UIView(frame: CGRect(x: (maxLength - 288)/2,y: 116,width: 288,height: 70))
        uiviewFunction.backgroundColor = UIColor.clear
        uiviewCard.addSubview(uiviewFunction)
        
        let buttonWidth = 44.0
        let interval = 26.0
        
        buttonShare = UIButton(frame: CGRect(x: (288-3*buttonWidth-3*interval)/2,y: 10,width: buttonWidth,height: 51))
        buttonShare.setImage(UIImage(named: "map_userpin_share"), for: UIControlState())
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), for: .touchUpInside)
        //uiviewFunction.addSubview(buttonShare)
        
        buttonKeep = UIButton(frame: CGRect(x: (288-buttonWidth)/2,y: 10,width: buttonWidth,height: 51))
        buttonKeep.setImage(UIImage(named: "map_userpin_keep"), for: UIControlState())
        buttonKeep.addTarget(self, action: #selector(buttonKeepAction(_:)), for: .touchUpInside)
        //uiviewFunction.addSubview(buttonKeep)
        
        //buttonReport = UIButton(frame: CGRect(x: (298-3*buttonWidth-2*interval)/2+2*interval+2*buttonWidth,y: 10,width: buttonWidth,height: 51))
        buttonReport = UIButton(frame: CGRect(x: (288-buttonWidth)/2,y: 10,width: buttonWidth,height: 51))
        buttonReport.setImage(UIImage(named: "map_userpin_report"), for: UIControlState())
        buttonReport.addTarget(self, action: #selector(buttonReportAction(_:)), for: .touchUpInside)
        
        uiviewFunction.addSubview(buttonReport)
        
        uiviewFunction.isHidden = true
    }
    
    func buttonFollowAction(_ sender: UIButton!){
        print("Follow")
    }
    
    func buttonShareAction(_ sender: UIButton!){
        print("Share")
    }
    
    func buttonKeepAction(_ sender: UIButton!){
        print("Keep")
    }
    
    func buttonReportAction(_ sender: UIButton!){
        print("Report")
    }
    
    
    func buttonChatAction(_ sender: UIButton!){
        let withUserId:NSNumber = NSNumber(value: self.currentViewingUserId)
        
        //First get chatroom id
        getFromURL("chats/users/\(user_id)/\(withUserId)", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            var resultJson1 = JSON([])
            if(status / 100 == 2){
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(withUserId)/profile", parameter: nil, authentication: headerAuthentication()) { (status, result) in
                if(status / 100 == 2){
                    let resultJson2 = JSON(result!)
                    var chat_id: String?
                    
                    if let id = resultJson1["chat_id"].number{
                        chat_id = id.stringValue
                    }
                    if let withUserName = resultJson2["user_name"].string {
                        self.startChat(chat_id ,withUserId: withUserId, withUserName: withUserName)
                    }else{
                        self.startChat(chat_id, withUserId: withUserId, withUserName: nil)
                    }
                }
            }
        }
    }
    func startChat(_ chat_id: String? ,withUserId: NSNumber, withUserName: String?){
        let chatVC = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        
        chatVC.chatRoomId = user_id.compare(withUserId).rawValue < 0 ? "\(user_id.stringValue)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(user_id.stringValue)"
        chatVC.chat_id = chat_id
        let withUserName = withUserName ?? "Chat"
        chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func buttonMoreAction(_ sender: UIButton!){
        print("more")
        showFunctionview()
    }
    
    func hideFunctionview(){
        buttonMore.setImage(UIImage(named: "map_userpin_more"), for: UIControlState())
        uiviewFunction.isHidden = true
        labelNamecardDescription.isHidden = false
        uiviewTag.isHidden = false
        print("hiddend")
    }
    
    func showFunctionview(){
        buttonMore.setImage(UIImage(named: "map_userpin_dark"), for: UIControlState())
        uiviewFunction.isHidden = false
        labelNamecardDescription.isHidden = true
        uiviewTag.isHidden = true
        print("show")
    }
    
    func loadUserPinInformation(_ userId: String){
        //        let avatar = FaeImage()
        //        let image = UIImage(named: "navigationBack")
        //        avatar.image = image
        //        avatar.faeUploadImageInBackground { (code:Int, message: Any?) in
        //            print("")
        //            print(code)
        //            print(message)
        //            if code / 100 == 2 {//upload success
        //                self.imageViewAvatarMore.image = image
        //            } else {
        //                //failure, we need to hanld the error here
        //            }
        //        }
        let user = FaeUser();
        imageviewUserPinBackground.isHidden = false
        imageviewNamecardAvatar.frame.origin.y = 90
        labelNamecardName.isHidden = false
        uiviewCard.isHidden = true
        //let stringHeaderURL = "baseURL + "/files/users/"29/avatar"
        let stringHeaderURL = baseURL + "/files/users/" + userId + "/avatar"
        imageviewNamecardAvatar.sd_setImage(with: URL(string: stringHeaderURL))
        if imageviewNamecardAvatar.image == nil{
            imageviewNamecardAvatar.image = UIImage(named: "myAvatorLin")
        }
        user.getNamecardOfSpecificUser(userId){(status:Int?, message: Any?) in
//            print("kick")
//            print(message)
            if(status! / 100 == 2){
                // success
                if let message = message as? NSDictionary{
                    if message["nick_name"] != nil{
                        self.labelNamecardName.text = message["nick_name"] as? String
                    }
                    if message["short_intro"] != nil{
                        self.labelNamecardDescription.text = message["short_intro"] as? String
                    }
                    if message["show_gender"] as! Bool == true{
                        print("get in")
                        self.imageViewGender.alpha = 1.0
                        if message["show_age"] as! Bool == true{
                            self.imageViewGender.frame.size.width = 50
                            if message["gender"] as? String == "male" {
                                self.imageViewGender.image = UIImage(named: "map_userpin_male&age")
                            }
                            if message["gender"] as? String == "female"{
                                self.imageViewGender.image = UIImage(named: "map_userpin_female&age")
                            }
                            self.labelNamecardAge.isHidden = false
                            if !(message["age"] is NSNull){
                                self.labelNamecardAge.text = String(message["age"] as! Int)
                            }
                        }
                        else{
                            self.imageViewGender.frame.size.width = 30
                            if message["gender"] as? String == "male" {
                                self.imageViewGender.image = UIImage(named: "map_userpin_male")
                            }
                            if message["gender"] as? String == "female"{
                                self.imageViewGender.image = UIImage(named: "map_userpin_female")
                            }
                            self.labelNamecardAge.alpha = 0.0;
                        }
                    }
                    else{
                        self.imageViewGender.isHidden = true
                    }
                    if message["tags"] != nil{
                        self.tagName.removeAll()
                        self.tagColor.removeAll()
                        let arr = message["tags"] as! [[String : AnyObject]]
                        for i in 0 ..< arr.count{
                            self.tagName.append(arr[i]["title"] as! String)
                            self.tagColor.append(self.colorWithHexString(String(arr[i]["color"]! as! String)))
                        }
                        self.uiviewTag.removeFromSuperview()
                        self.loadTags()
                    }
                    
                }
            }
            else{
                // failure
            }
        }
        
    }
    
    func colorWithHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

