//
//  FirstTimeLoginViewController.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class FirstTimeLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var uiViewSetPicture: UIView!
    var labelTitle: UILabel!
    var buttonAvatar: UIButton!
    var textFieldDisplayName: UITextField!
    var buttonFinish: UIButton!
    var dimBackground: UIView!
    var imageViewAvatar: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showGenderAge()
        firstTimeLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.dimBackground.alpha = 1
        }, completion: nil)
    }
    
    func showGenderAge() {
        let updateGenderAge = FaeUser()
        updateGenderAge.whereKey("show_gender", value: "true")
        updateGenderAge.whereKey("show_age", value: "true")
        updateGenderAge.updateNameCard { (status, message) in
            if status / 100 == 2 {
                print("[showGenderAge] Successfully update namecard")
            } else {
                print("[showGenderAge] Fail to update namecard")
            }
        }
    }
    
    func updateDefaultProfilePic() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let selfUserInfoJSON = JSON(message!)
            if let gender = selfUserInfoJSON["gender"].string {
                userUserGender = gender
                if gender == "female" {
                    self.imageViewAvatar.image = #imageLiteral(resourceName: "PeopleWomen")
                }
                else {
                    self.imageViewAvatar.image = #imageLiteral(resourceName: "PeopleMen")
                }
            }
        })
    }

    func firstTimeLogin() {
        dimBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        dimBackground.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        dimBackground.alpha = 0
        self.view.addSubview(dimBackground)
        
        uiViewSetPicture = UIView(frame:CGRect(x: 62*screenWidthFactor, y: 116*screenWidthFactor, width: 290*screenWidthFactor, height: 334*screenWidthFactor))
        uiViewSetPicture.backgroundColor = UIColor.white
        uiViewSetPicture.layer.cornerRadius = 16
        self.dimBackground.addSubview(uiViewSetPicture)
        
        labelTitle = UILabel(frame: CGRect(x: 48*screenWidthFactor, y: 27*screenWidthFactor, width: 194*screenWidthFactor, height: 44*screenWidthFactor))
        labelTitle.text = "Set your Profile Picture\n & Display Name"
        labelTitle.numberOfLines = 0
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.textColor = UIColor(red: 89/255, green: 89.0/255, blue: 89.0/255, alpha: 1.0)
        labelTitle.font = UIFont(name: "AvenirNext-Medium",size: 16*screenWidthFactor)
        uiViewSetPicture.addSubview(labelTitle)
        
        imageViewAvatar = UIImageView(frame: CGRect(x: 100*screenWidthFactor, y: 88*screenWidthFactor, width: 90*screenWidthFactor, height: 90*screenWidthFactor))
        self.updateDefaultProfilePic()
        imageViewAvatar.layer.cornerRadius = 45*screenWidthFactor
        imageViewAvatar.clipsToBounds = true
        imageViewAvatar.contentMode = .scaleAspectFill
        uiViewSetPicture.addSubview(imageViewAvatar)
        
        buttonAvatar = UIButton(frame: CGRect(x: 100*screenWidthFactor, y: 88*screenWidthFactor, width: 90*screenWidthFactor, height: 90*screenWidthFactor))
        uiViewSetPicture.addSubview(buttonAvatar)
        buttonAvatar.addTarget(self, action: #selector(self.addProfileAvatar(_:)), for: .touchUpInside)
        
        textFieldDisplayName = UITextField(frame: CGRect(x: 0*screenWidthFactor, y: 203*screenWidthFactor, width: 160*screenWidthFactor, height: 34*screenWidthFactor))
        textFieldDisplayName.center.x = uiViewSetPicture.frame.size.width / 2
        textFieldDisplayName.placeholder = "Display Name"
        textFieldDisplayName.font = UIFont(name: "AvenirNext-Regular", size: 25*screenWidthFactor)
        textFieldDisplayName.tintColor = UIColor.faeAppRedColor()
        textFieldDisplayName.textColor = UIColor.faeAppRedColor()
        textFieldDisplayName.textAlignment = .center
        textFieldDisplayName.addTarget(self, action: #selector(self.displayNameValueChanged(_:)), for: .editingChanged)
        textFieldDisplayName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        textFieldDisplayName.autocorrectionType = .no
        uiViewSetPicture.addSubview(textFieldDisplayName)
        
        buttonFinish = UIButton(frame: CGRect(x: 40*screenWidthFactor, y: 269*screenWidthFactor, width: 210*screenWidthFactor, height: 40*screenWidthFactor))
        buttonFinish.layer.cornerRadius = 20*screenWidthFactor
        buttonFinish.setTitle("Finish!", for: .normal)
        buttonFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16*screenWidthFactor)
        buttonFinish.backgroundColor = UIColor(red: 255/255, green: 160/255, blue: 160/255, alpha: 1.0)
        uiViewSetPicture.addSubview(buttonFinish)
        buttonFinish.isEnabled = false
        buttonFinish.addTarget(self, action: #selector(self.buttonFinishClicked(_:)), for: .touchUpInside)
    }
    
    func buttonFinishClicked(_ sender: UIButton) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.faeAppRedColor()
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        uploadProfileAvatar()
    }
    
    func uploadProfileAvatar() {
        let avatar = FaeImage()
        avatar.image = imageViewAvatar.image
        avatar.faeUploadImageInBackground { (code: Int, message: Any?) in
            if code / 100 == 2 {
                self.modifyDisplayName()
            }
            else {
                print("[uploadProfileAvatar] fail")
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Upload Profile Avatar Failed", message: "please try again")
                return
            }
        }
    }
    
    func modifyDisplayName() {
        let user = FaeUser()
        if let displayName = textFieldDisplayName.text {
            if displayName == "" {
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Please Enter Display Name", message: "try again")
                return
            }
            user.whereKey("nick_name", value: displayName)
            user.updateNameCard { (status:Int, objects:Any?) in
                if status / 100 == 2 {
                    self.activityIndicator.stopAnimating()
                    self.textFieldDisplayName.resignFirstResponder()
                    self.updateUserRealm()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.dimBackground.alpha = 0
                    }) { (done: Bool) in
                        if done {
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Tried to Change Display Name but Failed", message: "please try again")
                }
            }
        }
    }
    
    func updateUserRealm() {
        let realm = try! Realm()
        let userRealm = FaeUserRealm()
        userRealm.userId = Int(user_id)
        userRealm.firstUpdate = true
        try! realm.write {
            realm.add(userRealm, update: true)
        }
    }
    
    func displayNameValueChanged(_ sender: UITextField) {
        if(sender.text != "") {
            buttonFinish.backgroundColor = UIColor(red: 249.0/255, green: 90.0/255, blue: 90.0/255, alpha:1.0)
            buttonFinish.isEnabled = true
        } else {
            buttonFinish.backgroundColor = UIColor(red: 255.0/255, green: 160.0/255, blue: 160.0/255, alpha: 1.0)
            buttonFinish.isEnabled = false
        }
    }
    
    func addProfileAvatar(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            menu.removeFromParentViewController()
            self.present(imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            imagePicker.sourceType = .camera
            menu.removeFromParentViewController()
            self.present(imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu,animated:true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageViewAvatar.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
