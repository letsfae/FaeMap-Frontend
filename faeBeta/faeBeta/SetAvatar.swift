//
//  SetAvatarViewController.swift
//  faeBeta
//
//  Created by Jichao on 2017/11/11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class SetAvatar {
    
    static func uploadUserImage(image: UIImage, vc: UIViewController, type: String, isProfilePic: Bool = true, _ complete: (() -> Void)? = nil) {
        //let currentVC: UIViewController
        var activityIndicator = UIActivityIndicatorView()
        var imgView = UIImageView()
        switch type {
        case "leftSlidingMenu":
            let currentVC = vc as! LeftSlidingMenuViewController
            activityIndicator = currentVC.activityIndicator
            imgView = currentVC.imgAvatar
        case "firstTimeLogin":
            let currentVC = vc as! FirstTimeLoginViewController
            activityIndicator = currentVC.activityIndicator
            imgView = currentVC.imageViewAvatar
        case "setInfoNamecard":
            let currentVC = vc as! SetInfoNamecard
            activityIndicator = currentVC.activityIndicator
            if isProfilePic {
                imgView = currentVC.uiviewNameCard.imgAvatar
            } else {
                imgView = currentVC.uiviewNameCard.imgCover
            }
        default: break
        }
        vc.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        let avatar = FaeImage()
        avatar.image = image
        let uploadHandler = isProfilePic ? avatar.faeUploadProfilePic : avatar.faeUploadCoverPhoto
        uploadHandler { (code: Int, message: Any?) in
            activityIndicator.stopAnimating()
            vc.view.isUserInteractionEnabled = true
            if code / 100 == 2 {
                imgView.image = image
                print("[uploadProfileAvatar] succeed")
                let realm = try! Realm()
                let realmUser = UserImage()
                realmUser.user_id = "\(Key.shared.user_id)"
                realmUser.userSmallAvatar = RealmChat.compressImageToData(image)! as NSData
                try! realm.write {
                    realm.add(realmUser, update: true)
                }
                complete?()
            } else {
                print("[uploadProfileAvatar] fail")
                self.showAlert(title: "Upload Profile Avatar Failed", message: "please try again", vc: vc)
                return
            }
        }
    }
    
    static func showAlert(title: String, message: String, vc: UIViewController, more: Bool = false, second_option: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        if more {
            let secondOpt = UIAlertAction(title: second_option, style: UIAlertActionStyle.default) {
                (alert: UIAlertAction) in
                if second_option == "Settings" {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
            alertController.addAction(secondOpt)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func addUserImage(vc: UIViewController, type: String) {
        var imageDelegate: ChooseAvatarDelegate!
        var imagePickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)!
        switch type {
        case "leftSlidingMenu":
            let currentVC = vc as! LeftSlidingMenuViewController
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        case "firstTimeLogin":
            let currentVC = vc as! FirstTimeLoginViewController
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        case "setInfoNamecard":
            let currentVC = vc as! SetInfoNamecard
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        default: break
        }
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor._2499090()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc)
                        return
                    }
                    let imagePicker = ChooseAvatarViewController()
                    imagePicker.delegate = imageDelegate
                    imagePicker.vcComeFromType = ChooseAvatarViewController.ComeFromType(rawValue: type)!
                    imagePicker.vcComeFrom = vc
                    vc.present(imagePicker, animated: true, completion: nil)
                    /*let imagePicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                    imagePicker.imageDelegate = imageDelegate
                    imagePicker.vcComeFromType = .lefeSlidingMenu
                    imagePicker.vcComeFrom = vc
                    imagePicker._maximumSelectedPhotoNum = 1
                    vc.present(imagePicker, animated: true, completion: nil)*/
                })
            } else {
                let imagePicker = ChooseAvatarViewController()
                imagePicker.delegate = imageDelegate
                imagePicker.vcComeFromType = ChooseAvatarViewController.ComeFromType(rawValue: type)!
                imagePicker.vcComeFrom = vc
                vc.present(imagePicker, animated: true, completion: nil)
                /*let albumPicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                albumPicker.imageDelegate = imageDelegate
                albumPicker.vcComeFromType = .lefeSlidingMenu
                albumPicker.vcComeFrom = vc
                albumPicker._maximumSelectedPhotoNum = 1
                vc.present(albumPicker, animated: true, completion: nil)*/
            }
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = imagePickerDelegate
            imagePicker.sourceType = .camera
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc, more: true, second_option: "Settings")
                        return
                    }
                    menu.removeFromParentViewController()
                    vc.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
                case .authorized:
                    menu.removeFromParentViewController()
                    vc.present(imagePicker, animated: true, completion: nil)
                    break
                case .denied, .notDetermined, .restricted:
                    self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc, more: true, second_option: "Settings")
                    return
                }
                
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        vc.present(menu, animated: true, completion: nil)
    }
}

protocol ChooseAvatarDelegate: class {
    func finishChoosingAvatar(with faePHAsset: FaePHAsset)
}

class ChooseAvatarViewController: UIViewController {
    var faePhotoPicker: FaePhotoPicker!
    weak var delegate: ChooseAvatarDelegate?
    
    enum ComeFromType: String {
        case leftSlidingMenu
        case firstTimeLogin
        case setInfoNamecard
    }
    var vcComeFromType: ComeFromType = .firstTimeLogin
    var vcComeFrom: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var configure = FaePhotoPickerConfigure()
        configure.boolAllowdVideo = false
        configure.strRightBtnTitle = "Camera"
        configure.boolSingleSelection = true
        faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), with: configure)
        faePhotoPicker.leftBtnHandler = cancel
        faePhotoPicker.rightBtnHandler = handleDone
        view.addSubview(faePhotoPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleDone(_ results: [FaePHAsset], _ camera: Bool) {
        if camera {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            switch vcComeFromType {
            case .leftSlidingMenu:
                imagePicker.delegate = vcComeFrom as! LeftSlidingMenuViewController
            case .firstTimeLogin:
                imagePicker.delegate = vcComeFrom as! FirstTimeLoginViewController
            case .setInfoNamecard:
                imagePicker.delegate = vcComeFrom as! SetInfoNamecard
            }
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status != .authorized {
                        let alert = UIAlertController(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        self.vcComeFrom.present(imagePicker, animated: true, completion: nil)
                    }
                })
            } else {
                dismiss(animated: true, completion: nil)
                vcComeFrom.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            delegate?.finishChoosingAvatar(with: results[0])
            dismiss(animated: true, completion: nil)
        }
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
