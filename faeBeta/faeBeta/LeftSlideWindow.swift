//
//  LeftSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SDWebImage

//MARK: show left slide window
extension FaeMapViewController {
//    UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate 
//    var imagePicker : UIImagePickerController!
    func loadMore() {
        //self.navigationController?.navigationBarHidden = false
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        dimBackgroundMoreButton = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        dimBackgroundMoreButton.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundMoreButton.alpha = 0.0
        self.view.addSubview(dimBackgroundMoreButton)
        dimBackgroundMoreButton.layer.zPosition = 599
        dimBackgroundMoreButton.addTarget(self, action: #selector(FaeMapViewController.animationMoreHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.animationMoreHide(_:)))
        leftSwipe.direction = .Left
        
        uiviewMoreButton = UIView(frame: CGRectMake(-tableViewWeight, 0, tableViewWeight, screenHeight))
        uiviewMoreButton.backgroundColor = UIColor.whiteColor()
        uiviewMoreButton.layer.zPosition = 600
        uiviewMoreButton.addGestureRecognizer(leftSwipe)
        self.view.addSubview(uiviewMoreButton)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        //initial tableview
        tableviewMore = UITableView(frame: CGRectMake(0, 0, tableViewWeight, screenHeight), style: .Grouped)
        tableviewMore.delegate = self
        tableviewMore.dataSource = self
        tableviewMore.registerNib(UINib(nibName: "MoreVisibleTableViewCell",bundle: nil), forCellReuseIdentifier: cellTableViewMore)
        tableviewMore.backgroundColor = UIColor.clearColor()
        tableviewMore.separatorColor = UIColor.clearColor()
        tableviewMore.rowHeight = 60
//        tableviewMore.scrollEnabled = falsey
        tableviewMore.alwaysBounceVertical = false
        self.tableviewMore.bounces = false
        
        uiviewMoreButton.addSubview(tableviewMore)
        addHeaderViewForMore()
    }
    
    func jumpToMoodAvatar() {
        animationMoreHide(nil)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("MoodAvatarViewController")as! MoodAvatarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToNameCard() {
        animationMoreHide(nil)// new add
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NameCardViewController")as! NameCardViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToMyFaeMainPage() {
        animationMoreHide(nil)// new add
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("MyFaeMainPageViewController")as! MyFaeMainPageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("FaeAccountViewController")as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func jumpToMyPins(){
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("MyPinsViewController")as! MyPinsViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func jumpTowelcomeVC() {
        //        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
        //        self.presentViewController(vc, animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NavigationWelcomeViewController")as! NavigationWelcomeViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func addHeaderViewForMore(){
        viewHeaderForMore = UIView(frame: CGRectMake(0,0,tableViewWeight,268))
        viewHeaderForMore.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        tableviewMore.tableHeaderView = viewHeaderForMore
        tableviewMore.tableHeaderView?.frame = CGRectMake(0, 0, 311, 268)
        
        imageViewBackgroundMore = UIImageView(frame: CGRectMake(0, 148, tableViewWeight, 120))
        imageViewBackgroundMore.image = UIImage(named: "tableViewMoreBackground")
        viewHeaderForMore.addSubview(imageViewBackgroundMore)
        
        //exchange left and right button
        //left button is mapboard button
        buttonMoreLeft = UIButton(frame: CGRectMake(15,27,29,29))
        buttonMoreLeft.setImage(UIImage(named: "tableviewMoreRightButton-1"), forState: .Normal)
//        viewHeaderForMore.addSubview(buttonMoreLeft)
        
        //right button is my namecard button
        buttonMoreRight = UIButton(frame: CGRectMake((tableViewWeight - 29 - 15),26,29,29))
        buttonMoreRight.setImage(UIImage(named: "tableViewMoreLeftButton"), forState: .Normal)
        buttonMoreRight.addTarget(self, action: #selector(FaeMapViewController.jumpToNameCard), forControlEvents: .TouchUpInside)
        viewHeaderForMore.addSubview(buttonMoreRight)
        
        
        imageViewAvatarMore = UIImageView(frame: CGRectMake((tableViewWeight - 91) / 2,36,91,91))
//        imageViewAvatarMore.layer.cornerRadius = 81 / 2
        imageViewAvatarMore.layer.cornerRadius = 91 / 2
        imageViewAvatarMore.layer.masksToBounds = true
        imageViewAvatarMore.clipsToBounds = true
        imageViewAvatarMore.layer.borderWidth = 5
        imageViewAvatarMore.layer.borderColor = UIColor.whiteColor().CGColor
//        imageViewAvatarMore.image = UIImage(named: "myAvatorLin")
        if user_id != nil {
        let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewAvatarMore.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .RefreshCached)
        }
        viewHeaderForMore.addSubview(imageViewAvatarMore)
        
        buttonImagePicker = UIButton(frame: CGRectMake((tableViewWeight - 91) / 2, 36, 91, 91))
//        buttonImagePicker.addTarget(self, action: #selector(FaeMapViewController.showPhotoSelected), forControlEvents: .TouchUpInside)
        buttonImagePicker.addTarget(self, action: #selector(FaeMapViewController.jumpToMyFaeMainPage), forControlEvents: .TouchUpInside)
        viewHeaderForMore.addSubview(buttonImagePicker)
        
        labelMoreName = UILabel(frame: CGRectMake((tableViewWeight - 180) / 2,134,180,27))
        labelMoreName.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMoreName.textAlignment = .Center
        labelMoreName.textColor = UIColor.whiteColor()
        if userFirstname != nil {
            labelMoreName.text = userFirstname! + " " + userLastname!
        }

        if nickname != nil {
            labelMoreName.text = nickname
        } else {
            labelMoreName.text = userUserName
        }
        viewHeaderForMore.addSubview(labelMoreName)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        arrayNameCard[imageIndex] = image
        imageViewAvatarMore.image = image
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadImageInBackground { (code:Int, message:AnyObject?) in
            print(code)
            print(message)
            if code / 100 == 2 {
                self.imageViewAvatarMore.image = image
            } else {
                //failure
            }
        }
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    func showPhotoSelected() {
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .ActionSheet)
        let showLibrary = UIAlertAction(title: "Choose from library", style: .Default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .PhotoLibrary
            menu.removeFromParentViewController()
            self.presentViewController(self.imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photoes", style: .Default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .Camera
            menu.removeFromParentViewController()
            self.presentViewController(self.imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.presentViewController(menu,animated:true,completion: nil)
    }
    func animationMoreShow(sender: UIButton!) {
        if user_id != nil {
            self.getAndSetUserAvatar(self.imageViewAvatarMore, userID: Int(user_id))
        }
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x + self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.7
            self.dimBackgroundMoreButton.layer.opacity = 0.7
        }))
    }
    
    func animationMoreHide(sender: UIButton!) {
        UIView.animateWithDuration(0.2, animations:({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x - self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {

            }
        })
    }
    
    func switchToInvisibleOrOnline(sender: UISwitch) {
        let switchToInvisible = FaeUser()
        if (sender.on == true){
            print("sender.on")
            switchToInvisible.whereKey("status", value: "5")
            switchToInvisible.setSelfStatus({ (status, message) in
                if status / 100 == 2 {
                    userStatus = 5
                    let storageForUserStatus = NSUserDefaults.standardUserDefaults()
                    storageForUserStatus.setObject(userStatus, forKey: "userStatus")
                    print("Successfully switch to invisible")
                    if userStatus == 5 {
                        self.faeMapView.myLocationEnabled = true
                        if self.myPositionOutsideMarker_1 != nil {
                            self.myPositionOutsideMarker_1.hidden = true
                        }
                        if self.myPositionOutsideMarker_2 != nil {
                            self.myPositionOutsideMarker_2.hidden = true
                        }
                        if self.myPositionOutsideMarker_3 != nil {
                            self.myPositionOutsideMarker_3.hidden = true
                        }
                        if self.myPositionIcon != nil {
                            self.myPositionIcon.hidden = true
                        }
                    }
                }
                else {
                    print("Fail to switch to invisible")
                }
            })
        }
        else{
            print("sender.off")
            switchToInvisible.whereKey("status", value: "1")
            switchToInvisible.setSelfStatus({ (status, message) in
                if status / 100 == 2 {
                    userStatus = 1
                    self.actionSelfPosition(self.buttonSelfPosition)
                    let storageForUserStatus = NSUserDefaults.standardUserDefaults()
                    storageForUserStatus.setObject(userStatus, forKey: "userStatus")
                    print("Successfully switch to online")
                }
                else {
                    print("Fail to switch to online")
                }
            })
        }
    }
    
    func userIsInactive() {
        let userIsInactive = FaeUser()
        userIsInactive.whereKey("status", value: "0")
        userIsInactive.setSelfStatus({ (status, message) in
            if status / 100 == 2 {
                print("Successfully set user to offline")
            }
            else {
                print("Fail to switch to offline")
            }
        })
    }
    
    func userIsActive(status: Int) {
        let userIsInactive = FaeUser()
        userIsInactive.whereKey("status", value: "\(status)")
        userIsInactive.setSelfStatus({ (status, message) in
            if status / 100 == 2 {
                print("Successfully set user to offline")
            }
            else {
                print("Fail to switch to offline")
            }
        })
    }
    
    func getUserStatus() -> Int {
        let storageForUserStatus = LocalStorageManager()
        if let user_status = storageForUserStatus.readByKey("userStatus") {
            userStatus = user_status as! Int
            self.userIsActive(userStatus)
            return userStatus
        }
        return -999
    }
    
    func getAndSetUserAvatar(userAvatar: UIImageView, userID: Int) {
        let stringHeaderURL = "https://api.letsfae.com/files/users/\(userID)/avatar"
        let block = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            // completion code here
            if userAvatar.image != nil {
                let croppedImage = self.cropToBounds(userAvatar.image!)
                userAvatar.image = croppedImage
            }
        }
        userAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: UIImage(named: "defaultMan"), completed: block)
    }
    
}
