//
//  NameCardViewController.swift
//  faeBeta
//
//  Created by User on 7/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    //tableView
    var tableViewNameCard : UITableView!
    let cellGeneral = "cellGenral"
    let cellSwitch = "cellSwitch"
    //header view
    var viewHeaderBackground : UIView!
    //header view 1
    var viewNameCardTitle : UIView!
    var imageViewCover : UIImageView!
    var imageViewTitleProfile : UIImageView!
    var labelNickname : UILabel!
    //header view 2
    var viewNameCardDescr : UIView!
    
    var imagePicker : UIImagePickerController!
    var imagePick : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your NameCards"
        initialTableview()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getColor(red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }

}
// MARK: tableview
extension NameCardViewController : UITableViewDelegate, UITableViewDataSource {
    func initialTableview() {
        tableViewNameCard = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        tableViewNameCard.delegate = self
        tableViewNameCard.dataSource = self
        tableViewNameCard.backgroundColor = UIColor.clearColor()
        tableViewNameCard.separatorStyle = .None
        tableViewNameCard.rowHeight = 60
        
        tableViewNameCard.registerNib(UINib(nibName: "MyFaeGeneralTableViewCell", bundle: nil), forCellReuseIdentifier: cellGeneral)
        tableViewNameCard.registerNib(UINib(nibName: "NameCardShowTableViewCell", bundle: nil), forCellReuseIdentifier: cellSwitch)
        
        self.view.addSubview(tableViewNameCard)
        initialHeaderView()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row <= 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellGeneral, forIndexPath: indexPath) as! MyFaeGeneralTableViewCell
            if indexPath.row == 0 {
                cell.labelTitle.text = "Nickname"
                cell.labelStatus.text = nickname
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Short Intro"
                cell.labelStatus.text = shortIntro
            } else if indexPath.row == 2 {
                cell.labelTitle.text = "Choose Tags"
                cell.labelStatus.text = ""
                
            } else if indexPath.row == 3 {
                cell.labelTitle.text = "Change Profile Picture"
                cell.labelStatus.text = ""
            } else if indexPath.row == 4 {
                cell.labelTitle.text = "Change Cover Photo"
                cell.labelStatus.text = ""
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSwitch, forIndexPath: indexPath) as! NameCardShowTableViewCell
            if indexPath.row == 5 {
                cell.labelShow.text = "Show Gender"
            } else {
                cell.labelShow.text = "Show Age"
            }
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {//nickname
            
        } else if indexPath.row == 1 {//short intro
            
        } else if indexPath.row == 2 {//choose tags
            jumpToTags()
        } else if indexPath.row == 3 {//change profile picture
            showPhotoSelected(0)
            
        } else if indexPath.row == 4 {//change cover photo
            showPhotoSelected(1)
        }
    }
    func jumpToTags() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NameCardTagsViewController")as! NameCardTagsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//add Header view
extension NameCardViewController {
    func initialHeaderView() {
        viewHeaderBackground = UIView(frame: CGRectMake(0,0,screenWidth,316))
        tableViewNameCard.tableHeaderView = viewHeaderBackground
        tableViewNameCard.tableHeaderView?.frame = CGRectMake(0, 0, screenWidth, 316)
        
        viewNameCardTitle = UIView(frame: CGRectMake(73,119,268,180))
        viewNameCardTitle.layer.borderColor = UIColor.grayColor().CGColor
        viewNameCardTitle.layer.borderWidth = 1.0
        viewNameCardTitle.layer.cornerRadius = 10
        viewHeaderBackground.addSubview(viewNameCardTitle)
        
        imageViewCover = UIImageView(frame: CGRectMake(0, 0, 268, 120))
        imageViewCover.layer.masksToBounds = true
        imageViewCover.clipsToBounds = true
        viewNameCardTitle.addSubview(imageViewCover)
        
        imageViewTitleProfile = UIImageView(frame: CGRectMake((268 - 61) / 2, 190 - 119, 61, 61))
        imageViewTitleProfile.layer.cornerRadius = 61 / 2
        imageViewTitleProfile.layer.masksToBounds = true
        imageViewTitleProfile.clipsToBounds = true
        imageViewTitleProfile.layer.borderWidth = 5
        imageViewTitleProfile.layer.borderColor = UIColor.clearColor().CGColor
        viewNameCardTitle.addSubview(imageViewTitleProfile)
        if user_id != nil {
            let stringHeaderURL = "https://api.letsfae.com/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewTitleProfile.sd_setImageWithURL(NSURL(string: stringHeaderURL))
        }
        
        labelNickname = UILabel(frame: CGRectMake(0,257-119,268,27))
        labelNickname.text = "Anonymous"
        labelNickname.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNickname.textAlignment = .Center
        labelNickname.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        viewNameCardTitle.addSubview(labelNickname)
        
        //the second header view
        viewNameCardDescr = UIView(frame: CGRectMake(73,119,268,180))
        viewNameCardDescr.layer.borderColor = UIColor.grayColor().CGColor
        viewNameCardDescr.layer.borderWidth = 1.0
        viewNameCardDescr.layer.cornerRadius = 10
        viewHeaderBackground.addSubview(viewNameCardDescr)
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //        arrayNameCard[imageIndex] = image
//        imageViewAvatarMore.image = image
        if imagePick == 0 {
            imageViewTitleProfile.image = image
        } else {
            imageViewCover.image = image
        }
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
    func showPhotoSelected(sender: Int) {
        //if sender = 0 show profile
        self.imagePick = sender
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
}
