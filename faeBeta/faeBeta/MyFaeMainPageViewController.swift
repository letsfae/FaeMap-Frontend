//
//  MyFaeMainPageViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MyFaeMainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //7 : 736 5 : 
    var imageViewAvatar : UIImageView!
    var imagePicker : UIImagePickerController!
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

    
    //no use
    /*
    var imageViewText1 : UIImageView!
    var imageViewText2 : UIImageView!
    var imageViewText3 : UIImageView!*/
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(screenHeigh)
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        setupNavigationBar()
        loadAvatar()
        loadName()
        loadBird()
    }
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRectMake(0, 44, 100, 100))
        imageViewAvatar.center.x = screenWidth / 2
        imageViewAvatar.layer.cornerRadius = 100 / 2
        imageViewAvatar.layer.masksToBounds = true
        imageViewAvatar.clipsToBounds = true
        imageViewAvatar.contentMode = UIViewContentMode.ScaleAspectFill
//        imageViewAvatar.layer.borderWidth = 5
//        imageViewAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        if user_id != nil {
            let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(stringHeaderURL)
            imageViewAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .RefreshCached)
        }
        self.view.addSubview(imageViewAvatar)
        buttonImage = UIButton(frame: CGRectMake(0,44,100,100))
        buttonImage.center.x = screenWidth / 2
        buttonImage.addTarget(self, action: #selector(MyFaeMainPageViewController.showPhotoSelected), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonImage)
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //        arrayNameCard[imageIndex] = image
        //        imageViewAvatarMore.image = image

        imageViewAvatar.image = image
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadImageInBackground { (code:Int, message:AnyObject?) in
            print(code)
            print(message)
            if code / 100 == 2 {
                //                self.imageViewAvatarMore.image = image
            } else {
                //failure
            }
        }
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    func loadName() {
        label1 = UILabel(frame: CGRectMake((screenWidth - 280) / 2, 154, 280, 38))
        if nickname != nil {
            label1.text = nickname
        } else {
            label1.text = "someone"
        }
        label1.textAlignment = .Center
        label1.font = UIFont(name: "AvenirNext-Medium", size: 23)
        label1.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.view.addSubview(label1)

        label2 = UILabel(frame: CGRectMake((screenWidth - 280) / 2, 190, 280, 25))
        label2.text = username
        label2.textAlignment = .Center
        label2.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label2.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.view.addSubview(label2)

        viewUnderline = UIView(frame: CGRectMake(20, 228, screenWidth - 40, 2))
        viewUnderline.backgroundColor = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        self.view.addSubview(viewUnderline)

        labelBird = UILabel(frame: CGRectMake((screenWidth - 162) / 2, 244, 162, 25))
        labelBird.text = "You're an Early Bird"
        labelBird.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelBird.textAlignment = .Center
        labelBird.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        
        self.view.addSubview(labelBird)
    }
    func loadBird() {
        imageViewBird = UIImageView(frame: CGRectMake(0, 274, 110, 110))
        imageViewBird.center.x = screenWidth / 2
        imageViewBird.image = UIImage(named: "myFaeBird")
        self.view.addSubview(imageViewBird)
        /*
        imageViewText1 = UIImageView(frame: CGRectMake((screenWidth - 311) / 2, 533 - 75, 311, 18))
        imageViewText1.image = UIImage(named: "myFaeBirdText1")
        self.view.addSubview(imageViewText1)
        imageViewText2 = UIImageView(frame: CGRectMake((screenWidth - 322) / 2, 570 - 75, 322, 18))
        imageViewText2.image = UIImage(named: "myFaeBirdText2")
        self.view.addSubview(imageViewText2)
        imageViewText3 = UIImageView(frame: CGRectMake((screenWidth - 323) / 2, 607 - 75, 323, 38))
        imageViewText3.image = UIImage(named: "myFaeBirdText3")
        self.view.addSubview(imageViewText3)*/
        viewBackground = UIView(frame: CGRectMake(22,393, screenWidth - 44, 151))
        self.view.addSubview(viewBackground)
        let wid = screenWidth - 44 - 24
        viewRed1 = UIView(frame: CGRectMake(0,0,12,12))
        viewRed1.layer.cornerRadius = 6
        viewRed1.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed1)
        labelDesc1 = UILabel(frame: CGRectMake(24,0 - 2,wid, 36))
        labelDesc1.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc1.text = "Congrats! You’re among the first to use Fae Map"
        labelDesc1.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc1.numberOfLines = 0
        labelDesc1.sizeToFit()
        viewBackground.addSubview(labelDesc1)

        viewRed2 = UIView(frame: CGRectMake(0,50,12,12))
        viewRed2.layer.cornerRadius = 6
        viewRed2.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed2)
        labelDesc2 = UILabel(frame: CGRectMake(24,50 - 2,wid, 36))
        labelDesc2.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc2.text = "No Levels for Early Birds; Full access to everything"
        labelDesc2.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc2.numberOfLines = 0
        labelDesc2.sizeToFit()
        viewBackground.addSubview(labelDesc2)

        viewRed3 = UIView(frame: CGRectMake(0,100,12,12))
        viewRed3.layer.cornerRadius = 6
        viewRed3.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewBackground.addSubview(viewRed3)
        labelDesc3 = UILabel(frame: CGRectMake(24,100 - 2,wid, 54))
        labelDesc3.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc3.text = "We value your opinion, chat with us for feedbacks and let’s make Fae Map better together!"
        labelDesc3.textColor = UIColor(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1)
        labelDesc3.numberOfLines = 0
        labelDesc3.sizeToFit()
        viewBackground.addSubview(labelDesc3)


    }
    private func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.translucent = true
    }
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
