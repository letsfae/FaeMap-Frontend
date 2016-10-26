//
//  TestViewController.swift
//  faeBeta
//
//  Created by 王彦翔 on 16/7/26.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension FaeMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func loadNamecard() {
        self.view.backgroundColor = UIColor.whiteColor()
        
        uiviewDialog = UIView(frame: CGRect(x: (screenWidth-maxLength)/2, y: 140,width: maxLength,height: 302))
        uiviewDialog.backgroundColor = UIColor(patternImage: UIImage(named: "map_userpin_dialog")!)
        uiviewDialog.layer.zPosition = 20
        
        uiviewCard = UIView(frame: CGRect(x: 0, y: 0,width: maxLength,height: 200))
        uiviewCard.backgroundColor = UIColor.clearColor()
        uiviewCard.hidden = true
        uiviewDialog.addSubview(uiviewCard)
        
        
        
        //avatar
        imageviewNamecardAvatar = UIImageView(frame: CGRect(x: (maxLength-70)/2, y: 90, width: 70, height: 70))
        imageviewNamecardAvatar.image = UIImage(named: "map_namecard_photo1")
        imageviewNamecardAvatar.layer.cornerRadius = 35
        imageviewNamecardAvatar.clipsToBounds = true
        imageviewNamecardAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        imageviewNamecardAvatar.layer.borderWidth = 5
        
        //background
        imageviewUserPinBackground = UIImageView(frame: CGRect(x: (maxLength - 268)/2, y: 20, width: 268, height: 126))
        imageviewUserPinBackground.image = UIImage(named: "map_userpin_background")
        imageviewUserPinBackground.clipsToBounds = false
        
        
        //button more
        buttonMore = UIButton(frame: CGRect(x: (maxLength-72), y: 40/736*screenHeight, width: 37, height: 17))
        
        buttonMore.setImage(UIImage(named: "map_namecard_dots"), forState: UIControlState.Normal)
        
        //buttonMore.backgroundColor = UIColor.blackColor()
        buttonMore.addTarget(self, action: #selector(FaeMapViewController.buttonMoreAction(_:)), forControlEvents: .TouchUpInside)
        
        //load function view
        loadFunctionview()
        
        //label name
        labelNamecardName = UILabel(frame: CGRect(x: (maxLength-180)/2, y: 166, width: 180, height: 27))
        labelNamecardName.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNamecardName.textColor = UIColor.darkGrayColor()
        labelNamecardName.textAlignment = .Center
        labelNamecardName.text = "LinLInLiN"
        
        //label description
        labelNamecardDescription = UILabel(frame: CGRect(x: (maxLength-294)/2, y: 100, width: 294, height: 44))
        labelNamecardDescription.numberOfLines = 2
        labelNamecardDescription.font = UIFont(name: "AvenirNext-Medium", size: 15.0)
        labelNamecardDescription.textColor = UIColor.lightGrayColor()
        labelNamecardDescription.textAlignment = .Center
        labelNamecardDescription.text = "hahahaaahahah\nahaahahahahahahahe\nhahahhahahahahahahahahahahah"
        
        //line
        viewLine2 = UIView(frame: CGRect(x: (maxLength-268)/2, y: 80, width: 268, height: 1))
        viewLine2.backgroundColor = UIColor.lightGrayColor()
        //viewLine2.hidden = true
        viewLine = UIView(frame: CGRect(x: (maxLength-252)/2, y: 210, width: 252, height: 1))
        viewLine.backgroundColor = UIColor.lightGrayColor()
        
        //gender
        imageViewGender = UIImageView(frame: CGRectMake(37, 40, 50, 19))
        imageViewGender.image = UIImage(named: "map_userpin_male")
        //imageViewGender.hidden = true
        uiviewCard.addSubview(imageViewGender)
        
        //age
        labelNamecardAge = UILabel(frame: CGRect(x: 27, y: 1, width: 16, height: 18))
        labelNamecardAge.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelNamecardAge.textColor = UIColor.whiteColor()
        imageViewGender.addSubview(labelNamecardAge)
        
        //load button
        buttonChat = UIButton(frame: CGRect(x:(maxLength-190)/2, y: 230, width: 190, height: 39))
        buttonChat.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        buttonChat.layer.cornerRadius = 19
        buttonChat.setTitle("Chat", forState: .Normal)
        buttonChat.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        buttonChat.addTarget(self, action: #selector(FaeMapViewController.buttonChatAction(_:)), forControlEvents: .TouchUpInside)
        
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

        let user1 = FaeUser()
        user1.getNamecardOfSpecificUser(String(4)){(status:Int, message:AnyObject?) in
            if(status / 100 == 2){
                print("Succesfully get namecard of user")
            }
        }
//        user1.getSelfNamecard{(status:Int, message:AnyObject?) in
//            if(status / 100 == 2){
//                print("gets self name")
//                print(message)
//            }
//        }
//        user1.getAllTags{(status:Int, message:AnyObject?) in
//            if(status / 100 == 2){
//                print("gets all tags")
//                print(message)
//            }
//        }
//        
        user1.getSelfProfile{(status:Int, message:AnyObject?) in
            if(status / 100 == 2){
                print("Successfully gets self profile")
            }
        }
//
//        user1.getOthersProfile(String(1)){(status:Int, message:AnyObject?) in
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
//        user1.updateNameCard{(status:Int, message:AnyObject?) in
//            if(status / 100 == 2){
//                print("update name card")
//                print(status)
//                print(message)
//            }
//        }
    }
    
    func showOpenUserPinAnimation(lati: CLLocationDegrees, longi: CLLocationDegrees) {
        UIView.animateWithDuration(0.2, animations: ({
            self.uiviewDialog.alpha = 1.0
        }))
        openUserPinActive = true
        let camera = GMSCameraPosition.cameraWithLatitude(lati+0.001, longitude: longi, zoom: 17)
        faeMapView.animateToCameraPosition(camera)
    }
    
    func hideOpenUserPinAnimation() {
        UIView.animateWithDuration(0.2, animations: ({
            self.uiviewDialog.alpha = 0.0
        }))
    }
    
    func getColor(red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
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
            buttonTag.setAttributedTitle(tagTitle[i], forState: .Normal)
            buttonTag.titleLabel?.textColor = UIColor.whiteColor()
            uiviewTag.addSubview(buttonTag)
            xOffset += (tagLength[i]+intervalInLine)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: UITouch = touches.first{
            if(touch.view != uiviewFunction && touch.view != buttonMore){
                hideFunctionview()
            }
            if(touch.view == uiviewDialog || touch.view == uiviewCard){
                imageviewUserPinBackground.hidden = true
                imageviewNamecardAvatar.frame.origin.y = -10
                //viewLine2.hidden = false
                labelNamecardName.hidden = true
                uiviewCard.hidden = false
                //uiviewTag.hidden = false
                //imageViewGender.hidden = false
            }
        }
    }
    
    func loadFunctionview(){
        
        
        uiviewFunction = UIView(frame: CGRect(x: (maxLength - 288)/2,y: 116,width: 288,height: 70))
        uiviewFunction.backgroundColor = UIColor.clearColor()
        uiviewCard.addSubview(uiviewFunction)
        
        let buttonWidth = 44.0
        let interval = 26.0
        
        buttonShare = UIButton(frame: CGRect(x: (298-3*buttonWidth-3*interval)/2,y: 10,width: buttonWidth,height: 51))
        buttonShare.setImage(UIImage(named: "map_userpin_share"), forState: .Normal)
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonShare)
        
        buttonKeep = UIButton(frame: CGRect(x: (298-buttonWidth)/2,y: 10,width: buttonWidth,height: 51))
        buttonKeep.setImage(UIImage(named: "map_userpin_keep"), forState: .Normal)
        buttonKeep.addTarget(self, action: #selector(buttonKeepAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonKeep)
        
        buttonReport = UIButton(frame: CGRect(x: (298-3*buttonWidth-2*interval)/2+2*interval+2*buttonWidth,y: 10,width: buttonWidth,height: 51))
        buttonReport.setImage(UIImage(named: "map_userpin_report"), forState: .Normal)
        buttonReport.addTarget(self, action: #selector(buttonReportAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonReport)
        
        uiviewFunction.hidden = true
    }
    
    func buttonFollowAction(sender: UIButton!){
        print("Follow")
    }
    
    func buttonShareAction(sender: UIButton!){
        print("Share")
    }
    
    func buttonKeepAction(sender: UIButton!){
        print("Keep")
    }
    
    func buttonReportAction(sender: UIButton!){
        print("Report")
    }
    
    
    func buttonChatAction(sender: UIButton!){
        print("chat")
    }
    
    func buttonMoreAction(sender: UIButton!){
        print("more")
        showFunctionview()
    }
    
    func hideFunctionview(){
        buttonMore.setImage(UIImage(named: "map_userpin_more"), forState: .Normal)
        uiviewFunction.hidden = true
        labelNamecardDescription.hidden = false
        uiviewTag.hidden = false
        print("hiddend")
    }
    
    func showFunctionview(){
        buttonMore.setImage(UIImage(named: "map_userpin_dark"), forState: UIControlState.Normal)
        uiviewFunction.hidden = false
        labelNamecardDescription.hidden = true
        uiviewTag.hidden = true
        print("show")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellPhotos, forIndexPath: indexPath)as! NameCardAddCollectionViewCell
        if indexPath.row==1{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo")
        }
        else if indexPath.row==0{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==2{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo")
        }
        else if indexPath.row==3{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo1")
        }
        else if indexPath.row==4{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo2")
        }
        else if indexPath.row==5{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==6{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==7{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else{
            cell.imageViewTitle.image = UIImage(named: "nameCardEmpty")
        }
        
        return cell
    }
    
    
    func loadUserPinInformation(userId: String){
        let user = FaeUser();
        imageviewUserPinBackground.hidden = false
        imageviewNamecardAvatar.frame.origin.y = 90
        labelNamecardName.hidden = false
        uiviewCard.hidden = true

        user.getNamecardOfSpecificUser(userId){(status:Int?, message:AnyObject?) in
            print("kick")
            print(message)
            if(status! / 100 == 2){
                // success
                if message != nil{
                    if message!["nick_name"] != nil{
                        self.labelNamecardName.text = message!["nick_name"] as? String
                    }
                    if message!["short_intro"] != nil{
                        self.labelNamecardDescription.text = message!["short_intro"] as? String
                    }
                    if message!["show_gender"] as! Bool == true{
                        self.imageViewGender.alpha = 1.0
                        if message!["show_age"] as! Bool == true{
                            self.imageViewGender.frame.size.width = 50
                            if message!["gender"] as? String == "male" {
                                self.imageViewGender.image = UIImage(named: "map_userpin_male&age")
                            }
                            if message!["gender"] as? String == "female"{
                                self.imageViewGender.image = UIImage(named: "map_userpin_female&age")
                            }
                            self.labelNamecardAge.hidden = false
                            self.labelNamecardAge.text = message!["age"] as? String
                        }
                        else{
                            self.imageViewGender.frame.size.width = 30
                            if message!["gender"] as? String == "male" {
                                self.imageViewGender.image = UIImage(named: "map_userpin_male")
                            }
                            if message!["gender"] as? String == "female"{
                                self.imageViewGender.image = UIImage(named: "map_userpin_female")
                            }
                            self.labelNamecardAge.alpha = 0.0;
                        }
                    }
                    else{
                        self.imageViewGender.hidden = true
                    }
                    if message!["tags"] != nil{
                        self.tagName.removeAll()
                        self.tagColor.removeAll()
                        let arr = message!["tags"] as! [[String : AnyObject]]
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
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
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

