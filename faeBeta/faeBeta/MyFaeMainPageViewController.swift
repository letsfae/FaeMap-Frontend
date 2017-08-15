//
//  MyFaeMainPageViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/22/16.
//  Copyright © 2016 fae. All rights reserved.
//
//  Rewrited by Vicky on 06/22/17

import UIKit
import Photos

class MyFaeMainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate, UIGestureRecognizerDelegate {
    
//    var fullAlbumVC: FullAlbumCollectionViewController!

    var uiviewNavBar: UIView!
    var btnBack: UIButton!
    var imgAvatar: UIImageView!
    var lblNickname: UILabel!
    var lblUsrame: UILabel!
    var uiviewUnderline: UIView!
    var lblBird: UILabel!
    var imgBird: UIImageView!
    var uiviewContent: UIView!
    var uiviewRedCircle1: UIView!
    var uiviewRedCircle2: UIView!
    var uiviewRedCircle3: UIView!
    var lblDesp1: UILabel!
    var lblDesp2: UILabel!
    var lblDesp3: UILabel!
    var btnFeedback: UIButton!
    var scroll: UIScrollView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        loadScrollView()
        loadNavBar()
        loadAvatar()
        loadName()
        loadContent()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .lightContent
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .default
//    }
    
    func loadScrollView() {
        scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        scroll.contentSize = CGSize(width: screenWidth, height: 650)
        scroll.isPagingEnabled = true
        scroll.isScrollEnabled = screenHeight < 650
        self.view.addSubview(scroll)
    }
    
    func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        view.addSubview(uiviewNavBar)
        uiviewNavBar.backgroundColor = .clear
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 22, width: 40.5, height: 38))
        btnBack.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToMap(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBack)
    }
    
    func backToMap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func loadAvatar() {
        imgAvatar = UIImageView(frame: CGRect(x: 0, y: 44, width: 100, height: 100))
        imgAvatar.center.x = screenWidth / 2
        imgAvatar.layer.cornerRadius = 50
        imgAvatar.layer.masksToBounds = true
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = UIViewContentMode.scaleAspectFill
        
        General.shared.avatar(userid: Key.shared.user_id, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
        
        scroll.addSubview(imgAvatar)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showPhotoSelected(_:)))
        imgAvatar.addGestureRecognizer(tapRecognizer)
        imgAvatar.isUserInteractionEnabled = true
    }
    
    func loadName() {
        lblNickname = UILabel(frame: CGRect(x: (screenWidth - 280) / 2, y: 154, width: 280, height: 38))
        lblNickname.text = Key.shared.nickname ?? "someone"
        lblNickname.textAlignment = .center
        lblNickname.font = UIFont(name: "AvenirNext-Medium", size: 23)
        lblNickname.textColor = UIColor._898989()
        scroll.addSubview(lblNickname)
        
        lblUsrame = UILabel(frame: CGRect(x: (screenWidth - 280) / 2, y: 190, width: 280, height: 25))
        lblUsrame.text = username
        lblUsrame.textAlignment = .center
        lblUsrame.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblUsrame.textColor = UIColor._898989()
        scroll.addSubview(lblUsrame)
        
        uiviewUnderline = UIView(frame: CGRect(x: 20, y: 228, width: screenWidth - 40, height: 2))
        uiviewUnderline.backgroundColor = UIColor._155155155()
        scroll.addSubview(uiviewUnderline)
    }
    
    func loadContent() {
        lblBird = UILabel(frame: CGRect(x: (screenWidth - 162) / 2, y: 244, width: 162, height: 25))
        lblBird.text = "You're an Early Bird"
        lblBird.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBird.textAlignment = .center
        lblBird.textColor = UIColor._898989()
        scroll.addSubview(lblBird)
        
        imgBird = UIImageView(frame: CGRect(x: 0, y: 274, width: 110, height: 110))
        imgBird.center.x = screenWidth / 2
        imgBird.image = #imageLiteral(resourceName: "myFaeBird")
        scroll.addSubview(imgBird)

        uiviewContent = UIView(frame: CGRect(x: 22, y: 393, width: screenWidth - 44, height: 151))
        scroll.addSubview(uiviewContent)
        
        let wid = screenWidth - 44 - 24
        uiviewRedCircle1 = UIView(frame: CGRect(x: 0, y: 12, width: 12, height: 12))
        uiviewRedCircle1.layer.cornerRadius = 6
        uiviewRedCircle1.backgroundColor = UIColor._2499090()
        uiviewContent.addSubview(uiviewRedCircle1)
        
        uiviewRedCircle2 = UIView(frame: CGRect(x: 0, y: 62, width: 12, height: 12))
        uiviewRedCircle2.layer.cornerRadius = 6
        uiviewRedCircle2.backgroundColor = UIColor._2499090()
        uiviewContent.addSubview(uiviewRedCircle2)
        
        uiviewRedCircle3 = UIView(frame: CGRect(x: 0, y: 112, width: 12, height: 12))
        uiviewRedCircle3.layer.cornerRadius = 6
        uiviewRedCircle3.backgroundColor = UIColor._2499090()
        uiviewContent.addSubview(uiviewRedCircle3)
        
        lblDesp1 = UILabel(frame: CGRect(x: 24, y: 0, width: wid, height: 36))
        lblDesp1.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblDesp1.text = "Congrats! You’re among the first to use Fae Map"
        lblDesp1.textColor = UIColor._155155155()
        lblDesp1.numberOfLines = 0
        lblDesp1.lineBreakMode = .byWordWrapping
        uiviewContent.addSubview(lblDesp1)

        lblDesp2 = UILabel(frame: CGRect(x: 24, y: 50, width: wid, height: 36))
        lblDesp2.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblDesp2.text = "No Levels for Early Birds; Full access to everything"
        lblDesp2.textColor = UIColor._155155155()
        lblDesp2.numberOfLines = 0
        lblDesp2.lineBreakMode = .byWordWrapping
        uiviewContent.addSubview(lblDesp2)
        
        lblDesp3 = UILabel(frame: CGRect(x: 24, y: 100, width: wid, height: 54))
        lblDesp3.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblDesp3.text = "We value your opinion, chat with us for feedbacks and let’s make Fae Map better together!"
        lblDesp3.textColor = UIColor._155155155()
        lblDesp3.numberOfLines = 0
        lblDesp3.lineBreakMode = .byWordWrapping
        uiviewContent.addSubview(lblDesp3)
        
        btnFeedback = UIButton(frame: CGRect(x: 0, y: 544 + 30, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnFeedback.center.x = screenWidth / 2
        btnFeedback.backgroundColor = UIColor._2499090()
        btnFeedback.setTitle("Give Feedback", for: UIControlState())
        btnFeedback.layer.cornerRadius = 25 * screenHeightFactor
        btnFeedback.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnFeedback.addTarget(self, action: #selector(jumpToFeedback), for: .touchUpInside)
        scroll.addSubview(btnFeedback)
    }
    
    func showPhotoSelected(_ sender: UIGestureRecognizer) {
        let alertMenu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        alertMenu.view.tintColor = UIColor._2499090()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .destructive) { (_: UIAlertAction) in
            //self.imagePicker.sourceType = .photoLibrary
//            alertMenu.removeFromParentViewController()
            //self.present(self.imagePicker,animated:true,completion:nil)
            // add code here to change imagePickerStyle [mingjie jin]
//            self.fullAlbumVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumCollectionViewController")
//                as! FullAlbumCollectionViewController
//            self.fullAlbumVC._maximumSelectedPhotoNum = 1
//            self.fullAlbumVC.imageDelegate = self
//            self.navigationController?.pushViewController(self.fullAlbumVC, animated: true)
//            self.present(self.fullAlbumVC, animated: true, completion: nil)
//            self.present(self.fullAlbumVC, animated: true, completion: {
//                UIApplication.shared.statusBarStyle = .default
//            })
            
            alertMenu.removeFromParentViewController()
            self.checkLibraryAccessStatus()
        }
        
        let showCamera = UIAlertAction(title: "Take photos", style: .destructive) { (_: UIAlertAction) in
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
            
            alertMenu.removeFromParentViewController()
            self.checkCameraAccessStatus()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertMenu.addAction(showLibrary)
        alertMenu.addAction(showCamera)
        alertMenu.addAction(cancel)
        self.present(alertMenu, animated: true, completion: nil)
    }

//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
//        //        arrayNameCard[imageIndex] = image
//        //        imgAvatarMore.image = image
//        
//        imgAvatar.image = image
//        let avatar = FaeImage()
//        avatar.image = image
//        avatar.faeUploadProfilePic { (code: Int, _: Any?) in
//            if code / 100 == 2 {
//                //                self.imgAvatarMore.image = image
//            } else {
//                //failure
//            }
//        }
//        imagePicker.dismiss(animated: true, completion: nil)
//    }
    
    //MARK: add jump to feedback report view
    func jumpToFeedback() {
        let reportCommentPinVC = ReportViewController()
        reportCommentPinVC.reportType = 1
        self.present(reportCommentPinVC, animated: true, completion: nil)
    }

    func sendImages(_ images: [UIImage]) {
        print("send image for avatar")
        imgAvatar.image = images[0]
        let avatar = FaeImage()
        avatar.image = images[0]
        avatar.faeUploadProfilePic { (code: Int, _: Any?) in
            if code / 100 == 2 {
            } else {
            }
        }
    }

    // select photos from camera / library as avatar
    fileprivate func checkLibraryAccessStatus() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .authorized:
            //let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
            //let nav = FullAlbumCollectionViewController()
            //let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
            //layout.scrollDirection = .vertical
            //layout.itemSize = CGSize(width: (screenWidth - 4) / 3, height: (screenWidth - 4) / 3)
            //layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1)
            let imagePicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            imagePicker.imageDelegate = self
            imagePicker.isSelectAvatar = true
            imagePicker._maximumSelectedPhotoNum = 1
            self.present(imagePicker, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .default
            })
        case .denied:
            self.alertToEncourageAccess("library")
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ _ in
                self.checkLibraryAccessStatus()
            })
            return
        case .restricted:
            self.showAlert(title: "Photo library not allowed", message: "You're not allowed to access photo library")
            return
        }
    }
    
    fileprivate func checkCameraAccessStatus() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch cameraStatus {
        case .authorized:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        case .denied:
            self.alertToEncourageAccess("camera")
            return
        case .notDetermined:
            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { _ in
                    DispatchQueue.main.async() {
                        self.checkCameraAccessStatus()
                    }
                }
            }
            return
        case .restricted:
            self.showAlert(title: "Camera not allowed", message: "You're not allowed to capture camera devices")
            return
        }
    }
    
    // MARK: - CAMERA & GALLERY NOT ALLOWING ACCESS - ALERT
    fileprivate func alertToEncourageAccess(_ accessType: String) {
        // Camera or photo library not available - Alert
        var title: String!
        var message: String!
        if accessType == "camera" {
            title = "Cannot access camera"
            message = "Open System Settings -> Fae Map to turn on the camera access"
        } else {
            title = "Cannot access photo library"
            message = "Open System Settings -> Fae Map to turn on the photo library access"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                if accessType == "camera" {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                } else {
                    UIApplication.shared.openURL(url as URL)
                    // UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
