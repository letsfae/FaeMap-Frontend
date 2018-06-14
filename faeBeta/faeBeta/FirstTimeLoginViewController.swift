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

class FirstTimeLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseAvatarDelegate {
    
    // MARK: - Properties
    weak var delegate: ButtonFinishClickedDelegate?
    private var uiviewSetPicture: UIView!
    private var lblTitle: UILabel!
    private var btnAvatar: UIButton!
    private var textFieldDisplayName: UITextField!
    private var btnFinish: UIButton!
    private var uiviewBackground: UIView!
    var imgAvatar: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showGenderAge()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.uiviewBackground.alpha = 1
        }, completion: nil)
    }
    
    private func showGenderAge() {
        let updateGenderAge = FaeUser()
        updateGenderAge.whereKey("show_gender", value: "true")
        updateGenderAge.whereKey("show_age", value: "true")
        updateGenderAge.updateNameCard { status, _ in
            if status / 100 == 2 {
                // print("[showGenderAge] Successfully update namecard")
            } else { // TODO: error code undecided
                print("[showGenderAge] Fail to update namecard")
            }
        }
    }
    
    private func setupUI() {
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 0.5)
        uiviewBackground.alpha = 0
        view.addSubview(uiviewBackground)
        
        var offset = 116 * screenWidthFactor
        if screenHeight == 812 {
            offset = 175
        }
        uiviewSetPicture = UIView(frame: CGRect(x: 62 * screenWidthFactor, y: offset, width: 290 * screenWidthFactor, height: 334 * screenWidthFactor))
        uiviewSetPicture.backgroundColor = UIColor.white
        uiviewSetPicture.layer.cornerRadius = 16
        uiviewBackground.addSubview(uiviewSetPicture)
        
        lblTitle = UILabel(frame: CGRect(x: 48 * screenWidthFactor, y: 27 * screenWidthFactor, width: 194 * screenWidthFactor, height: 44 * screenWidthFactor))
        lblTitle.text = "Set your Profile Picture\n & Display Name"
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenWidthFactor)
        uiviewSetPicture.addSubview(lblTitle)
        
        imgAvatar = UIImageView(frame: CGRect(x: 100, y: 88, w: 90, h: 90))
        updateDefaultProfilePic()
        imgAvatar.layer.cornerRadius = 45 * screenWidthFactor
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        uiviewSetPicture.addSubview(imgAvatar)
        
        btnAvatar = UIButton(frame: CGRect(x: 100, y: 88, w: 90, h: 90))
        uiviewSetPicture.addSubview(btnAvatar)
        btnAvatar.addTarget(self, action: #selector(addProfileAvatar(_:)), for: .touchUpInside)
        
        textFieldDisplayName = UITextField(frame: CGRect(x: 0, y: 203, w: 160, h: 34))
        textFieldDisplayName.center.x = uiviewSetPicture.frame.size.width / 2
        textFieldDisplayName.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor._155155155()])
        textFieldDisplayName.font = UIFont(name: "AvenirNext-Regular", size: 25 * screenWidthFactor)
        textFieldDisplayName.tintColor = UIColor._2499090()
        textFieldDisplayName.textColor = UIColor._2499090()
        textFieldDisplayName.textAlignment = .center
        textFieldDisplayName.addTarget(self, action: #selector(displayNameValueChanged(_:)), for: .editingChanged)
        textFieldDisplayName.textColor = UIColor._898989()
        textFieldDisplayName.autocorrectionType = .no
        uiviewSetPicture.addSubview(textFieldDisplayName)
        
        btnFinish = UIButton(frame: CGRect(x: 40, y: 269, w: 210, h: 40))
        btnFinish.layer.cornerRadius = 20 * screenWidthFactor
        btnFinish.setTitle("Save", for: .normal)
        btnFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16 * screenWidthFactor)
        btnFinish.backgroundColor = UIColor._255160160()
        uiviewSetPicture.addSubview(btnFinish)
        btnFinish.isEnabled = false
        btnFinish.addTarget(self, action: #selector(buttonFinishClicked(_:)), for: .touchUpInside)
    }
    
    private func updateDefaultProfilePic() {
        if Key.shared.gender == "female" {
            imgAvatar.image = #imageLiteral(resourceName: "PeopleWomen")
        } else {
            imgAvatar.image = #imageLiteral(resourceName: "PeopleMen")
        }
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({ (status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let selfUserInfoJSON = JSON(message!)
            if let gender = selfUserInfoJSON["gender"].string {
                Key.shared.gender = gender
                if gender == "female" {
                    self.imgAvatar.image = #imageLiteral(resourceName: "PeopleWomen")
                } else {
                    self.imgAvatar.image = #imageLiteral(resourceName: "PeopleMen")
                }
            }
        })
    }
    
    // MARK: - Button & text field actions
    @objc private func addProfileAvatar(_ sender: UIButton) {
        SetAvatar.addUserImage(vc: self, type: "firstTimeLogin")
    }
    
    @objc private func displayNameValueChanged(_ sender: UITextField) {
        if sender.text != "" {
            btnFinish.backgroundColor = UIColor._2499090()
            btnFinish.isEnabled = true
        } else {
            btnFinish.backgroundColor = UIColor._255160160()
            btnFinish.isEnabled = false
        }
    }
    
    @objc private func buttonFinishClicked(_ sender: UIButton) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        if let image = imgAvatar.image {
            SetAvatar.uploadUserImage(image: image, vc: self, type: "firstTimeLogin") {
                self.modifyDisplayName()
            }
        }
    }
    
    // MARK: - Helper functions
    private func modifyDisplayName() {
        let user = FaeUser()
        if let displayName = textFieldDisplayName.text {
            if displayName == "" {
                activityIndicator.stopAnimating()
                faeBeta.showAlert(title: "Please Enter Display Name", message: "try again", viewCtrler: self)
                return
            }
            user.whereKey("nick_name", value: displayName)
            user.updateNameCard { (status: Int, _: Any?) in
                if status / 100 == 2 {
                    self.activityIndicator.stopAnimating()
                    self.textFieldDisplayName.resignFirstResponder()
                    self.updateUserRealm()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.uiviewBackground.alpha = 0
                    }) { _ in
                        self.dismiss(animated: false, completion: nil)
                    }
                } else if status != 422 {
                    self.activityIndicator.stopAnimating()
                    faeBeta.showAlert(title: "Tried to Change Display Name but Failed", message: "please try again", viewCtrler: self)
                } else {
                    self.activityIndicator.stopAnimating()
                    faeBeta.showAlert(title: "Please follow the rules to create a display name:", message: "1. Up to 50 characters\n2. No limits on uppercase or lowercase letters\n3. No limits on this symbols: !@#$%^&*)(+=._-, and space, but can't be all of them", viewCtrler: self)
                }
            }
        }
    }
    
    private func updateUserRealm() {
        let realm = try! Realm()
        let userRealm = FaeUserRealm()
        userRealm.userId = Int(Key.shared.user_id)
        userRealm.firstUpdate = true
        try! realm.write {
            realm.add(userRealm, update: true)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        imgAvatar.image = image
        SetAvatar.uploadUserImage(image: image, vc: self, type: "firstTimeLogin")
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ChooseAvatarDelegate
    func finishChoosingAvatar(with imageData: Data) {
        imgAvatar.image = UIImage(data: imageData)
    }
}
