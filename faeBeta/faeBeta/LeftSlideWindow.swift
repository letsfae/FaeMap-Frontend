//
//  LeftSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

//MARK: show left slide window
extension FaeMapViewController {
    func loadMore() {
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        dimBackgroundMoreButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackgroundMoreButton.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        dimBackgroundMoreButton.alpha = 0.0
        self.view.addSubview(dimBackgroundMoreButton)
        dimBackgroundMoreButton.layer.zPosition = 599
        dimBackgroundMoreButton.addTarget(self, action: #selector(FaeMapViewController.animationMoreHide(_:)), for: UIControlEvents.touchUpInside)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.animationMoreHide(_:)))
        leftSwipe.direction = .left
        
        uiviewMoreButton = UIView(frame: CGRect(x: -tableViewWeight, y: 0, width: tableViewWeight, height: screenHeight))
        uiviewMoreButton.backgroundColor = UIColor.white
        uiviewMoreButton.layer.zPosition = 600
        uiviewMoreButton.addGestureRecognizer(leftSwipe)
        self.view.addSubview(uiviewMoreButton)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        //initial tableview
        tableviewMore = UITableView(frame: CGRect(x: 0, y: 0, width: tableViewWeight, height: screenHeight), style: .grouped)
        tableviewMore.delegate = self
        tableviewMore.dataSource = self
        tableviewMore.register(UINib(nibName: "MoreVisibleTableViewCell",bundle: nil), forCellReuseIdentifier: cellTableViewMore)
        tableviewMore.backgroundColor = UIColor.clear
        tableviewMore.separatorColor = UIColor.clear
        tableviewMore.rowHeight = 60
//        tableviewMore.scrollEnabled = falsey
        tableviewMore.alwaysBounceVertical = false
        self.tableviewMore.bounces = false
        
        uiviewMoreButton.addSubview(tableviewMore)
        addHeaderViewForMore()
    }
    
    func jumpToMoodAvatar() {
        animationMoreHide(dimBackgroundMoreButton)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MoodAvatarViewController")as! MoodAvatarViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToNameCard() {
        animationMoreHide(dimBackgroundMoreButton)// new add
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NameCardViewController")as! NameCardViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToMyFaeMainPage() {
        animationMoreHide(dimBackgroundMoreButton)// new add
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MyFaeMainPageViewController")as! MyFaeMainPageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "FaeAccountViewController")as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func jumpToMyPins(){
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MyPinsViewController")as! MyPinsViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func jumpTowelcomeVC() {
        //        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
        //        self.presentViewController(vc, animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NavigationWelcomeViewController")as! NavigationWelcomeViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func addHeaderViewForMore(){
        viewHeaderForMore = UIView(frame: CGRect(x: 0,y: 0,width: tableViewWeight,height: 268))
        viewHeaderForMore.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        tableviewMore.tableHeaderView = viewHeaderForMore
        tableviewMore.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: 311, height: 268)
        
        imageViewBackgroundMore = UIImageView(frame: CGRect(x: 0, y: 148, width: tableViewWeight, height: 120))
        imageViewBackgroundMore.image = UIImage(named: "tableViewMoreBackground")
        viewHeaderForMore.addSubview(imageViewBackgroundMore)
        
        //exchange left and right button
        //left button is mapboard button
        buttonMoreLeft = UIButton(frame: CGRect(x: 15,y: 27,width: 29,height: 29))
        buttonMoreLeft.setImage(UIImage(named: "tableviewMoreRightButton-1"), for: UIControlState())
//        viewHeaderForMore.addSubview(buttonMoreLeft)
        
        //right button is my namecard button
        buttonMoreRight = UIButton(frame: CGRect(x: (tableViewWeight - 29 - 15),y: 26,width: 29,height: 29))
        buttonMoreRight.setImage(UIImage(named: "tableViewMoreLeftButton"), for: UIControlState())
        buttonMoreRight.addTarget(self, action: #selector(FaeMapViewController.jumpToNameCard), for: .touchUpInside)
        viewHeaderForMore.addSubview(buttonMoreRight)
        
        
        imageViewAvatarMore = UIImageView(frame: CGRect(x: (tableViewWeight - 91) / 2,y: 36,width: 91,height: 91))
//        imageViewAvatarMore.layer.cornerRadius = 81 / 2
        imageViewAvatarMore.layer.cornerRadius = 91 / 2
        imageViewAvatarMore.layer.masksToBounds = true
        imageViewAvatarMore.clipsToBounds = true
        imageViewAvatarMore.layer.borderWidth = 5
        imageViewAvatarMore.layer.borderColor = UIColor.white.cgColor
//        imageViewAvatarMore.image = UIImage(named: "myAvatorLin")
        if user_id != nil {
        let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewAvatarMore.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        }
        viewHeaderForMore.addSubview(imageViewAvatarMore)
        
        buttonImagePicker = UIButton(frame: CGRect(x: (tableViewWeight - 91) / 2, y: 36, width: 91, height: 91))
//        buttonImagePicker.addTarget(self, action: #selector(FaeMapViewController.showPhotoSelected), forControlEvents: .TouchUpInside)
        buttonImagePicker.addTarget(self, action: #selector(FaeMapViewController.jumpToMyFaeMainPage), for: .touchUpInside)
        viewHeaderForMore.addSubview(buttonImagePicker)
        
        labelMoreName = UILabel(frame: CGRect(x: (tableViewWeight - 180) / 2,y: 134,width: 180,height: 27))
        labelMoreName.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        labelMoreName.textAlignment = .center
        labelMoreName.textColor = UIColor.white
        if userFirstname != nil {
            labelMoreName.text = userFirstname! + " " + userLastname!
        }

        if nickname != nil {
            labelMoreName.text = nickname
        } else {
            labelMoreName.text = "someone"
        }
        viewHeaderForMore.addSubview(labelMoreName)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        arrayNameCard[imageIndex] = image
        imageViewAvatarMore.image = image
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadImageInBackground { (code:Int, message:Any?) in
//            print(code)
//            print(message)
            if code / 100 == 2 {
                self.imageViewAvatarMore.image = image
            } else {
                //failure
            }
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    func showPhotoSelected() {
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            menu.removeFromParentViewController()
            self.present(self.imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photoes", style: .default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .camera
            menu.removeFromParentViewController()
            self.present(self.imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu,animated:true,completion: nil)
    }
    func animationMoreShow(_ sender: UIButton!) {
        updateName()
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id)/avatar"
            self.imageViewAvatarMore.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        }
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x + self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.7
            self.dimBackgroundMoreButton.layer.opacity = 0.7
        }))
    }
    
    func animationMoreHide(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations:({
            self.uiviewMoreButton.center.x = self.uiviewMoreButton.center.x - self.tableViewWeight
            self.dimBackgroundMoreButton.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                if self.dimBackgroundMoreButton.tag == 1 {
                    self.dimBackgroundMoreButton.tag = 0
                    self.invisibleMode()
                }
            }
        })
    }
    
    func switchToInvisibleOrOnline(_ sender: UISwitch) {
        let switchToInvisible = FaeUser()
        if (sender.isOn == true){
            print("sender.on")
            switchToInvisible.whereKey("status", value: "5")
            switchToInvisible.setSelfStatus({ (status, message) in
                if status / 100 == 2 {
                    userStatus = 5
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
                    print("Successfully switch to invisible")
                    if userStatus == 5 {
                        self.faeMapView.isMyLocationEnabled = true
                        if self.myPositionOutsideMarker_1 != nil {
                            self.myPositionOutsideMarker_1.isHidden = true
                        }
                        if self.myPositionOutsideMarker_2 != nil {
                            self.myPositionOutsideMarker_2.isHidden = true
                        }
                        if self.myPositionOutsideMarker_3 != nil {
                            self.myPositionOutsideMarker_3.isHidden = true
                        }
                        if self.myPositionIcon != nil {
                            self.myPositionIcon.isHidden = true
                        }
                    }
                    self.dimBackgroundMoreButton.tag = 1
                    self.animationMoreHide(self.dimBackgroundMoreButton)
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
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
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
                
            }
            else {
                print("Fail to switch to offline")
            }
        })
    }
    
    func userIsActive(_ status: Int) {
        let userIsActive = FaeUser()
        userIsActive.whereKey("status", value: "\(status)")
        userIsActive.setSelfStatus({ (status, message) in
            if status / 100 == 2 {
                
            }
            else {
                print("Fail to switch to online")
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
    
    func updateName() {
        let updateNickName = FaeUser()
        updateNickName.getSelfNamecard(){(status:Int, message: Any?) in
            if(status / 100 == 2){
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string{
                    nickname = str
                }
                self.labelMoreName.text = nickname
            }
        }
    }
}
