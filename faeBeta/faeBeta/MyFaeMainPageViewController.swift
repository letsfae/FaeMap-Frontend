//
//  MyFaeMainPageViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MyFaeMainPageViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //7 : 736 5 : 
    var imageViewAvatar : UIImageView!
    var label1 : UILabel!
    var label2 : UILabel!
    var viewUnderline : UIView!
    var labelBird : UILabel!
    //
    var imageViewBird : UIImageView!
    var imageViewText1 : UIImageView!
    var imageViewText2 : UIImageView!
    var imageViewText3 : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(screenHeigh)
        // Do any additional setup after loading the view.
        loadAvatar()
        loadName()
        loadBird()
    }
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRectMake((screenWidth - 125) / 2, 72 - 64, 125, 125))
        imageViewAvatar.layer.cornerRadius = 125 / 2
        imageViewAvatar.layer.masksToBounds = true
        imageViewAvatar.clipsToBounds = true
//        imageViewAvatar.layer.borderWidth = 5
//        imageViewAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        if user_id != nil {
            let stringHeaderURL = "https://api.letsfae.com/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL))
        }
        self.view.addSubview(imageViewAvatar)
    }
    func loadName() {
        label1 = UILabel(frame: CGRectMake((screenWidth - 280) / 2, 138, 280, 38))
        label1.text = "LINLINLINLINLINLIN"
        label1.textAlignment = .Center
        label1.font = UIFont(name: "AvenirNext-Medium", size: 28)
        self.view.addSubview(label1)

        label2 = UILabel(frame: CGRectMake((screenWidth - 280) / 2, 180, 280, 25))
        label2.text = "Lin"
        label2.textAlignment = .Center
        label2.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label2.textColor = UIColor.grayColor()
        self.view.addSubview(label2)

        viewUnderline = UIView(frame: CGRectMake(20, 223, screenWidth - 40, 2))
        viewUnderline.backgroundColor = UIColor.grayColor()
        self.view.addSubview(viewUnderline)

        labelBird = UILabel(frame: CGRectMake((screenWidth - 162) / 2, 258, 162, 25))
        labelBird.text = "You're an Early Bird"
        labelBird.textAlignment = .Center
        labelBird.textColor = UIColor.grayColor()
        
        self.view.addSubview(labelBird)
    }
    func loadBird() {
        imageViewBird = UIImageView(frame: CGRectMake((screenWidth - 150) / 2, 283, 150, 140))
        imageViewBird.image = UIImage(named: "myFaeBird")
        self.view.addSubview(imageViewBird)
        imageViewText1 = UIImageView(frame: CGRectMake((screenWidth - 311) / 2, 533 - 75, 311, 18))
        imageViewText1.image = UIImage(named: "myFaeBirdText1")
        self.view.addSubview(imageViewText1)
        imageViewText2 = UIImageView(frame: CGRectMake((screenWidth - 322) / 2, 570 - 75, 322, 18))
        imageViewText2.image = UIImage(named: "myFaeBirdText2")
        self.view.addSubview(imageViewText2)
        imageViewText3 = UIImageView(frame: CGRectMake((screenWidth - 323) / 2, 607 - 75, 323, 38))
        imageViewText3.image = UIImage(named: "myFaeBirdText3")
        self.view.addSubview(imageViewText3)
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
