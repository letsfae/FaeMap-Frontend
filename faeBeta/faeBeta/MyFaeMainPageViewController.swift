//
//  MyFaeMainPageViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MyFaeMainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeigh = UIScreen.main.bounds.height
    //7 : 736 5 : 
    var scroll : UIScrollView!
    var imageViewAvatar : UIImageView!
    var imagePicker : UIImagePickerController!
    var fullAlbumVC : FullAlbumCollectionViewController!
    var buttonImage : UIButton!
    var label1 : UILabel!
    var label2 : UILabel!
    var viewUnderline : UIView!
    var labelBird : UILabel!
    //
    var imageViewBird : UIImageView!

    var viewBackground : UIView!
    var viewRed1 : UIView!
    var viewRed2 : UIView!
    var viewRed3 : UIView!
    var labelDesc1 : UILabel!
    var labelDesc2 : UILabel!
    var labelDesc3 : UILabel!
    var buttonFeedback : UIButton!
    
    //no use
    /*
    var imageViewText1 : UIImageView!
    var imageViewText2 : UIImageView!
    var imageViewText3 : UIImageView!*/
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(screenHeigh)
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        scroll = UIScrollView(frame: CGRect(x: 0,y: 0 - 64,width: screenWidth,height: screenHeight + 64))
        scroll.contentSize = CGSize(width: screenWidth, height: 650)
        scroll.isPagingEnabled = true
        print(screenHeigh + 64)
        if 650 > screenHeigh + 64 {
            scroll.isScrollEnabled = true
        } else {
            scroll.isScrollEnabled = false
        }

        self.view.addSubview(scroll)
        setupNavigationBar()
        loadAvatar()
        loadName()
        loadBird()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRect(x: 0, y: 44, width: 100, height: 100))
        imageViewAvatar.center.x = screenWidth / 2
        imageViewAvatar.layer.cornerRadius = 100 / 2
        imageViewAvatar.layer.masksToBounds = true
        imageViewAvatar.clipsToBounds = true
        imageViewAvatar.contentMode = UIViewContentMode.scaleAspectFill
//        imageViewAvatar.layer.borderWidth = 5
//        imageViewAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        if user_id != nil {
            let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(stringHeaderURL)
            imageViewAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        }
        self.scroll.addSubview(imageViewAvatar)
        buttonImage = UIButton(frame: CGRect(x: 0,y: 44,width: 100,height: 100))
        buttonImage.center.x = screenWidth / 2
        buttonImage.addTarget(self, action: #selector(MyFaeMainPageViewController.showPhotoSelected), for: .touchUpInside)
        self.scroll.addSubview(buttonImage)
    }
    func showPhotoSelected() {
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            //self.imagePicker.sourceType = .photoLibrary
            menu.removeFromParentViewController()
            //self.present(self.imagePicker,animated:true,completion:nil)
            // add code here to change imagePickerStyle [mingjie jin]
            self.fullAlbumVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumCollectionViewController")
            as! FullAlbumCollectionViewController
            self.fullAlbumVC._maximumSelectedPhotoNum = 1
            self.fullAlbumVC.imageDelegate = self
            self.navigationController?.pushViewController(self.fullAlbumVC, animated: true)
            //self.present(self.fullAlbumVC, animated: true, completion: nil)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //        arrayNameCard[imageIndex] = image
        //        imageViewAvatarMore.image = image

        imageViewAvatar.image = image
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadImageInBackground { (code:Int, message:Any?) in
//            print(code)
//            print(message)
            if code / 100 == 2 {
                //                self.imageViewAvatarMore.image = image
            } else {
                //failure
            }
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    func loadName() {
        label1 = UILabel(frame: CGRect(x: (screenWidth - 280) / 2, y: 154, width: 280, height: 38))
        if nickname != nil {
            label1.text = nickname
        } else {
            label1.text = "someone"
        }
        label1.textAlignment = .center
        label1.font = UIFont(name: "AvenirNext-Medium", size: 23)
        label1.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.scroll.addSubview(label1)

        label2 = UILabel(frame: CGRect(x: (screenWidth - 280) / 2, y: 190, width: 280, height: 25))
        label2.text = username
        label2.textAlignment = .center
        label2.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label2.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.scroll.addSubview(label2)

        viewUnderline = UIView(frame: CGRect(x: 20, y: 228, width: screenWidth - 40, height: 2))
        viewUnderline.backgroundColor = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        self.scroll.addSubview(viewUnderline)

        labelBird = UILabel(frame: CGRect(x: (screenWidth - 162) / 2, y: 244, width: 162, height: 25))
        labelBird.text = "You're an Early Bird"
        labelBird.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelBird.textAlignment = .center
        labelBird.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        
        self.scroll.addSubview(labelBird)
    }
    func loadBird() {
        imageViewBird = UIImageView(frame: CGRect(x: 0, y: 274, width: 110, height: 110))
        imageViewBird.center.x = screenWidth / 2
        imageViewBird.image = UIImage(named: "myFaeBird")
        self.scroll.addSubview(imageViewBird)
        /*
        imageViewText1 = UIImageView(frame: CGRectMake((screenWidth - 311) / 2, 533 - 75, 311, 18))
        imageViewText1.image = UIImage(named: "myFaeBirdText1")
        self.scroll.addSubview(imageViewText1)
        imageViewText2 = UIImageView(frame: CGRectMake((screenWidth - 322) / 2, 570 - 75, 322, 18))
        imageViewText2.image = UIImage(named: "myFaeBirdText2")
        self.scroll.addSubview(imageViewText2)
        imageViewText3 = UIImageView(frame: CGRectMake((screenWidth - 323) / 2, 607 - 75, 323, 38))
        imageViewText3.image = UIImage(named: "myFaeBirdText3")
        self.scroll.addSubview(imageViewText3)*/
        viewBackground = UIView(frame: CGRect(x: 22,y: 393, width: screenWidth - 44, height: 151))
        self.scroll.addSubview(viewBackground)
        let wid = screenWidth - 44 - 24
        viewRed1 = UIView(frame: CGRect(x: 0,y: 0,width: 12,height: 12))
        viewRed1.layer.cornerRadius = 6
        viewRed1.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed1)
        labelDesc1 = UILabel(frame: CGRect(x: 24,y: 0 - 2,width: wid, height: 36))
        labelDesc1.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc1.text = "Congrats! You’re among the first to use Fae Map"
        labelDesc1.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc1.numberOfLines = 0
        labelDesc1.sizeToFit()
        viewBackground.addSubview(labelDesc1)

        viewRed2 = UIView(frame: CGRect(x: 0,y: 50,width: 12,height: 12))
        viewRed2.layer.cornerRadius = 6
        viewRed2.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed2)
        labelDesc2 = UILabel(frame: CGRect(x: 24,y: 50 - 2,width: wid, height: 36))
        labelDesc2.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc2.text = "No Levels for Early Birds; Full access to everything"
        labelDesc2.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc2.numberOfLines = 0
        labelDesc2.sizeToFit()
        viewBackground.addSubview(labelDesc2)

        viewRed3 = UIView(frame: CGRect(x: 0,y: 100,width: 12,height: 12))
        viewRed3.layer.cornerRadius = 6
        viewRed3.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed3)
        labelDesc3 = UILabel(frame: CGRect(x: 24,y: 100 - 2,width: wid, height: 54))
        labelDesc3.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc3.text = "We value your opinion, chat with us for feedbacks and let’s make Fae Map better together!"
        labelDesc3.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc3.numberOfLines = 0
        labelDesc3.sizeToFit()
        viewBackground.addSubview(labelDesc3)

        buttonFeedback = UIButton(frame: CGRect(x: 0,y: 544 + 30, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        buttonFeedback.center.x = screenWidth / 2
        buttonFeedback.backgroundColor = UIColor.faeAppRedColor()
        buttonFeedback.setTitle("Give Feedback", for: UIControlState())
        buttonFeedback.layer.cornerRadius = 25 * screenHeightFactor
        buttonFeedback.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        buttonFeedback.addTarget(self, action: #selector(MyFaeMainPageViewController.jumpToFeedback), for: .touchUpInside)
        scroll.addSubview(buttonFeedback)
    }
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func jumpToFeedback() {//MARK: add jump to feedback report view
        let reportCommentPinVC = ReportCommentPinViewController()
        reportCommentPinVC.reportType = 1
        self.present(reportCommentPinVC, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendImages(_ images: [UIImage]) {
        print("send image for avatar")
        imageViewAvatar.image = images[0]
        let avatar = FaeImage()
        avatar.image = images[0]
        avatar.faeUploadImageInBackground { (code:Int, message:Any?) in
            if code / 100 == 2 {
            } else {
            }
        }
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        //self.navigationController?.navigationBar.isTranslucent = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
