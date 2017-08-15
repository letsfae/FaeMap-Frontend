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
import Photos

protocol ButtonFinishClickedDelegate: class {
    func jumpToEnableNotification()
}

class FirstTimeLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate {

    weak var delegate: ButtonFinishClickedDelegate?
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
                // print("[showGenderAge] Successfully update namecard")
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
        labelTitle.textColor = UIColor._898989()
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
        textFieldDisplayName.tintColor = UIColor._2499090()
        textFieldDisplayName.textColor = UIColor._2499090()
        textFieldDisplayName.textAlignment = .center
        textFieldDisplayName.addTarget(self, action: #selector(self.displayNameValueChanged(_:)), for: .editingChanged)
        textFieldDisplayName.textColor = UIColor._898989()
        textFieldDisplayName.autocorrectionType = .no
        uiViewSetPicture.addSubview(textFieldDisplayName)
        
        buttonFinish = UIButton(frame: CGRect(x: 40*screenWidthFactor, y: 269*screenWidthFactor, width: 210*screenWidthFactor, height: 40*screenWidthFactor))
        buttonFinish.layer.cornerRadius = 20*screenWidthFactor
        buttonFinish.setTitle("Finish!", for: .normal)
        buttonFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16*screenWidthFactor)
        buttonFinish.backgroundColor = UIColor._255160160()
        uiViewSetPicture.addSubview(buttonFinish)
        buttonFinish.isEnabled = false
        buttonFinish.addTarget(self, action: #selector(self.buttonFinishClicked(_:)), for: .touchUpInside)
    }
    
    func buttonFinishClicked(_ sender: UIButton) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        uploadProfileAvatar()
    }
    
    func uploadProfileAvatar() {
        let avatar = FaeImage()
        avatar.image = imageViewAvatar.image
        avatar.faeUploadProfilePic { (code: Int, message: Any?) in
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
                    }) {_ in
                        self.dismiss(animated: false, completion: {_ in
                            self.delegate?.jumpToEnableNotification()
                        })
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Tried to Change Display Name but Failed", message: "please try again")
                }
            }
        }
    }
    
    func updateUserRealm() {
        let realm = try! Realm()
        let userRealm = FaeUserRealm()
        userRealm.userId = Int(Key.shared.user_id)
        userRealm.firstUpdate = true
        try! realm.write {
            realm.add(userRealm, update: true)
        }
    }
    
    func displayNameValueChanged(_ sender: UITextField) {
        if(sender.text != "") {
            buttonFinish.backgroundColor = UIColor._2499090()
            buttonFinish.isEnabled = true
        } else {
            buttonFinish.backgroundColor = UIColor._255160160()
            buttonFinish.isEnabled = false
        }
    }
    
    func addProfileAvatar(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor._2499090()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access")
                        return
                    }
                    //let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
                    //let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
                    let imagePicker = FullAlbumCollectionViewController()
                    imagePicker.imageDelegate = self
                    imagePicker.isCSP = false
                    imagePicker._maximumSelectedPhotoNum = 1
                    self.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                //let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
                //let albumPicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
                let albumPicker = FullAlbumCollectionViewController()
                albumPicker.imageDelegate = self
                albumPicker.isCSP = false
                albumPicker._maximumSelectedPhotoNum = 1
                self.present(albumPicker, animated: true, completion: nil)
            }
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access")
                        return
                    }
                    menu.removeFromParentViewController()
                    self.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                menu.removeFromParentViewController()
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
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
    
    func sendImages(_ images: [UIImage]) {
        print("send image for avatar")
        imageViewAvatar.image = images[0]
    }
    
}
