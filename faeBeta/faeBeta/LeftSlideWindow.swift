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
import RealmSwift

//MARK: show left slide window
extension FaeMapViewController {
    func jumpToNameCard() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NameCardViewController") as! NameCardViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToMyFaeMainPage() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MyFaeMainPageViewController") as! MyFaeMainPageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "FaeAccountViewController") as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func jumpToMyPins(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MyPinsViewController") as! MyPinsViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func jumpTowelcomeVC() {
        //        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
        //        self.presentViewController(vc, animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NavigationWelcomeViewController") as! NavigationWelcomeViewController
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
        imageViewAvatarMore.layer.cornerRadius = 91 / 2
        imageViewAvatarMore.layer.masksToBounds = true
        imageViewAvatarMore.clipsToBounds = true
        imageViewAvatarMore.layer.borderWidth = 5
        imageViewAvatarMore.layer.borderColor = UIColor.white.cgColor
        imageViewAvatarMore.contentMode = .scaleAspectFill
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
            imageViewAvatarMore.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        }
        viewHeaderForMore.addSubview(imageViewAvatarMore)
        
        buttonImagePicker = UIButton(frame: CGRect(x: (tableViewWeight - 91) / 2, y: 36, width: 91, height: 91))
        buttonImagePicker.addTarget(self, action: #selector(self.jumpToMyFaeMainPage), for: .touchUpInside)
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
        imageViewAvatarMore.image = image
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadImageInBackground { (code:Int, message:Any?) in
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
            self.present(self.imagePicker, animated:true, completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu,animated:true,completion: nil)
    }
    func animationMoreShow(_ sender: UIButton!) {
        let leftMenuVC = LeftSlidingMenuViewController()
        if let displayName = nickname {
            leftMenuVC.displayName = displayName
        }
        else {
            leftMenuVC.displayName = "someone"
        }
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        self.present(leftMenuVC, animated: false, completion: nil)
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
    
    func updateSelfInfo() {
        let updateNickName = FaeUser()
        updateNickName.getSelfNamecard(){(status:Int, message: Any?) in
            if(status / 100 == 2){
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string{
                    nickname = str
                }
            }
        }
        if user_id != nil {
            let realm = try! Realm()
            let selfInfoRealm = realm.objects(SelfInformation.self).filter("currentUserID == \(user_id.stringValue) AND avatar != nil")
            if selfInfoRealm.count == 0 {
                imageViewAvatarMore = UIImageView()
                let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
                imageViewAvatarMore.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let selfInfoRealm = SelfInformation()
                        selfInfoRealm.currentUserID = Int(user_id)
                        selfInfoRealm.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(selfInfoRealm)
                        }
                    }
                })
            }
        }
    }
}
