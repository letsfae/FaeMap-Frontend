//
//  NameCardViewController.swift
//  faeBeta
//
//  Created by User on 7/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class NameCardViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    //tableView
    var tableViewNameCard : UITableView!
    let cellGeneral = "cellGenral"
    let cellSwitch = "cellSwitch"
    //underline
    var viewUpUnderline : UIView!
    var viewDownUnderline : UIView!
    //header view
    var viewHeaderBackground : UIView!
    //header view 1
    var viewNameCardTitle : UIView!
    var imageViewCover : UIImageView!
    var imageViewTitleProfile : UIImageView!
    var labelNickname : UILabel!
    //header view 2
    var viewNameCardDescr : UIView!
    var imageViewDescrProfile : UIImageView!
    var viewGender : UIView!
    var imageViewGender : UIImageView!
    var labelAge : UILabel!
    
    var buttonMore : UIButton!
    var viewLine : UIView!
    var labelIntro : UILabel!
    var buttonDoFaevor : UIButton!
    var buttonFriends : UIButton!
    
    //image picker
    var imagePicker : UIImagePickerController!
    var imagePick : Int!
    
    //Cache cover image and avatar
    var imageCachedAvatar: UIImage!
    var imageCachedCover: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialTableview()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
        setupNavigationBar()
        let showGenderAge = FaeUser()
        showGenderAge.getSelfNamecard(){(status:Int, message:AnyObject?) in
            print("DEBUG showgender")
            if(status / 100 == 2){
                print(message)
                let genderAgeInfo = JSON(message!)
                if let genderInfo = genderAgeInfo["show_gender"].bool {
                    showGender = genderInfo
                }
                if let ageInfo = genderAgeInfo["show_age"].bool {
                    showAge = ageInfo
                }
                if let str = genderAgeInfo["nick_name"].string{
                    nickname = str
                }
                if let str = genderAgeInfo["short_intro"].string{
                    shortIntro = str
                }
                if let ageNow = genderAgeInfo["age"].int {
                    userAge = ageNow
                }
                self.updateName()
            }
        }
//        updateName()
    }

    func updateName() {
        labelNickname.text = nickname
        labelIntro.text = shortIntro
        self.tableViewNameCard.reloadData()
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
        tableViewNameCard = UITableView(frame: CGRectMake(0, 0, screenWidth, 736*screenHeightFactor))
        tableViewNameCard.delegate = self
        tableViewNameCard.dataSource = self
        tableViewNameCard.backgroundColor = UIColor.clearColor()
        tableViewNameCard.separatorStyle = .None
        tableViewNameCard.rowHeight = 55 * screenHeightFactor
        
        tableViewNameCard.registerClass(NameCardFirstFiveCell.self, forCellReuseIdentifier: cellGeneral)
        tableViewNameCard.registerClass(NameCardWithSwitchCell.self, forCellReuseIdentifier: cellSwitch)
        
        self.view.addSubview(tableViewNameCard)
        initialHeaderView()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row <= 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellGeneral, forIndexPath: indexPath) as! NameCardFirstFiveCell
            cell.selectionStyle = .None
            if indexPath.row == 0 {
                cell.labelDes.text = "Display Name"
                cell.labelUserSet.text = nickname
            } else if indexPath.row == 1 {
                cell.labelDes.text = "Short Intro"
                cell.labelUserSet.text = shortIntro
            } else if indexPath.row == 2 {
                cell.labelDes.text = "Choose Tags"
                cell.labelUserSet.text = ""
            } else if indexPath.row == 3 {
                cell.labelDes.text = "Change Profile Picture"
                cell.labelUserSet.text = ""
            } else if indexPath.row == 4 {
                cell.labelDes.text = "Change Cover Photo"
                cell.labelUserSet.text = ""
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSwitch, forIndexPath: indexPath) as! NameCardWithSwitchCell
            cell.selectionStyle = .None
            if indexPath.row == 5 {
                cell.labelDes.text = "Show Gender"
                cell.cellSwitch.setOn(showGender, animated: false)
            } else {
                cell.labelDes.text = "Show Age"
                cell.cellSwitch.setOn(showAge, animated: false)
            }
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {//nickname
            jumpToNickname()
        } else if indexPath.row == 1 {//short intro
            jumpToIntro()
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
    func jumpToNickname() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NameSettingViewController")as! NameSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToIntro() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("IntroSettingViewController")as! IntroSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationBack"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.navigationBarHidden = false
        let label = UILabel(frame: CGRectMake(0,0,147,27))
        label.text = "Your NameCard"
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        self.navigationItem.titleView = label
    }
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
//add Header view
extension NameCardViewController {
    func initialHeaderView() {
        viewHeaderBackground = UIView(frame: CGRectMake(0, 0, screenWidth, 274*screenHeightFactor))
        tableViewNameCard.tableHeaderView = viewHeaderBackground
        //tableViewNameCard.tableHeaderView?.frame = CGRectMake(0, 0, screenWidth, 316)
        viewUpUnderline = UIView(frame: CGRectMake(0, 0, screenWidth, 1))
        viewDownUnderline = UIView(frame: CGRectMake(17,274*screenHeightFactor,screenWidth - 34,1))
        viewUpUnderline.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        viewDownUnderline.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        self.view.addSubview(viewUpUnderline)
        viewHeaderBackground.addSubview(viewDownUnderline)
        viewNameCardTitle = UIView(frame: CGRectMake((screenWidth-268)/2, 51, 268*screenWidthFactor, 180*screenHeightFactor))
        viewNameCardTitle.layer.borderColor = UIColor.grayColor().CGColor
        viewNameCardTitle.layer.borderWidth = 1.0
        viewNameCardTitle.layer.cornerRadius = 10
        viewNameCardTitle.clipsToBounds = true
        viewHeaderBackground.addSubview(viewNameCardTitle)
        
        imageViewCover = UIImageView(frame: CGRectMake(0, 0, 268*screenWidthFactor, 120*screenHeightFactor))
        imageViewCover.layer.masksToBounds = true
        imageViewCover.clipsToBounds = true
        imageViewCover.contentMode = UIViewContentMode.ScaleAspectFill
        if user_id != nil {
            self.getAndSetCoverImage(imageViewCover, userID: Int(user_id))
        }
        viewNameCardTitle.addSubview(imageViewCover)
        
        imageViewTitleProfile = UIImageView(frame: CGRectMake(103.5*screenWidthFactor, 71*screenHeightFactor, 61*screenWidthFactor, 61*screenHeightFactor))
        imageViewTitleProfile.layer.cornerRadius = 30.5 * screenWidthFactor
        imageViewTitleProfile.layer.masksToBounds = true
        imageViewTitleProfile.clipsToBounds = true
        imageViewTitleProfile.layer.borderWidth = 5
        imageViewTitleProfile.layer.borderColor = UIColor.whiteColor().CGColor
        
        /*
        imageViewTitleProfile.layer.shadowOpacity = 0.5
        imageViewTitleProfile.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        imageViewTitleProfile.layer.shadowRadius = 61 / 2
        imageViewTitleProfile.layer.shadowColor = UIColor.grayColor().CGColor
         */
        
        viewNameCardTitle.addSubview(imageViewTitleProfile)
        if user_id != nil {
            self.getAndSetUserAvatar(self.imageViewTitleProfile, userID: Int(user_id))
        }
        
        labelNickname = UILabel(frame: CGRectMake(0, 138*screenHeightFactor, 268*screenWidthFactor, 27*screenHeightFactor))
        if nickname == nil || nickname == "" {
            labelNickname.text = "Anonymous"
        } else {
            labelNickname.text = nickname
        }
        labelNickname.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNickname.textAlignment = .Center
        labelNickname.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        viewNameCardTitle.addSubview(labelNickname)
        
        //the second header view
        viewNameCardDescr = UIView(frame: CGRectMake(73 + self.screenWidth,119 - 64,268,180))
        viewNameCardDescr.layer.borderColor = UIColor.grayColor().CGColor
        viewNameCardDescr.layer.borderWidth = 1.0
        viewNameCardDescr.layer.cornerRadius = 15
        viewHeaderBackground.addSubview(viewNameCardDescr)
        
        imageViewDescrProfile = UIImageView(frame: CGRectMake((268 - 61) / 2, 96 - 119, 61, 61))
        imageViewDescrProfile.layer.cornerRadius = 61 / 2
        imageViewDescrProfile.layer.masksToBounds = true
        imageViewDescrProfile.clipsToBounds = true
        imageViewDescrProfile.layer.borderWidth = 5
        imageViewDescrProfile.layer.borderColor = UIColor.whiteColor().CGColor
        imageViewDescrProfile.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        imageViewDescrProfile.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        imageViewDescrProfile.layer.shadowOpacity = 0.3
        imageViewDescrProfile.layer.shadowRadius = 5.0
        viewNameCardDescr.addSubview(imageViewDescrProfile)
        if user_id != nil {
            let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewDescrProfile.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .RefreshCached)
        }
        viewGender = UIView(frame: CGRectMake(90 - 73, 139 - 119, 50, 18))
        viewGender.backgroundColor = getColor(149, green: 207, blue: 246)
        let tempImage = UIImageView(frame: CGRectMake(0, 0, 50, 18))
        tempImage.image = UIImage(named: "map_userpin_male")
        viewGender.addSubview(tempImage)
        viewNameCardDescr.addSubview(viewGender)
//        imageViewGender = UIImageView(frame: CGRectMake(9, 3, 12, 12))
//        imageViewGender.image = UIImage(named: "nameCardMale")
//        viewGender.addSubview(imageViewGender)
//        labelAge = UILabel(frame: CGRectMake(27,0,16,18))
//        labelAge.text = "21"//Mark : not finished
//        labelAge.textColor = UIColor.whiteColor()
//        viewGender.addSubview(labelAge)
        
        buttonMore = UIButton(frame: CGRectMake(292 - 73, 139 - 119, 32, 18))
        buttonMore.setImage(UIImage(named: "map_userpin_dark"), forState: .Normal)
        viewNameCardDescr.addSubview(buttonMore)
        
        viewLine = UIView(frame: CGRectMake(0, 56,268,1))
        viewLine.backgroundColor = getColor(200, green: 199, blue: 204)
        viewNameCardDescr.addSubview(viewLine)
        
        labelIntro = UILabel(frame: CGRectMake(97 - 73, 193 - 119,220, 45))
        labelIntro.textColor = getColor(155, green: 155, blue: 155)
        labelIntro.numberOfLines = 2
        labelIntro.textAlignment = .Center
        labelIntro.text = "nothing here"
        labelIntro.font = UIFont(name: "AvenirNext-Medium", size: 15)
        viewNameCardDescr.addSubview(labelIntro)
        
        buttonDoFaevor = UIButton(frame: CGRectMake(101 - 73, 248 - 119, 104, 27))
        buttonDoFaevor.backgroundColor = getColor(255, green: 128, blue: 128)
        buttonDoFaevor.setTitle("I do Faevors", forState: .Normal)
        buttonDoFaevor.titleLabel?.textColor = UIColor.whiteColor()
        buttonDoFaevor.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonDoFaevor.layer.cornerRadius = 4.6
        viewNameCardDescr.addSubview(buttonDoFaevor)
        
        buttonFriends = UIButton(frame: CGRectMake(215 - 73, 248 - 119, 99, 27))
        buttonFriends.backgroundColor = getColor(230, green: 140, blue: 102)
        buttonFriends.setTitle("LF Friends", forState: .Normal)
        buttonFriends.titleLabel?.textColor = UIColor.whiteColor()
        buttonFriends.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonFriends.layer.cornerRadius = 4.6
        viewNameCardDescr.addSubview(buttonFriends)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(NameCardViewController.showNameCardTitle))
        swipeRight.direction = .Right
        self.viewHeaderBackground.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(NameCardViewController.showNameCardDescr))
        swipeLeft.direction = .Left
        self.viewHeaderBackground.addGestureRecognizer(swipeLeft)
    }
    func showNameCardTitle() {// right swipe
        UIView.animateWithDuration(0.25, animations: ({
            self.viewNameCardTitle.center.x = self.view.center.x
            self.viewNameCardDescr.center.x = self.view.center.x + self.screenWidth
        }))
    }
    func showNameCardDescr() {// left swipe
        UIView.animateWithDuration(0.25, animations: ({
            self.viewNameCardTitle.center.x = self.view.center.x - self.screenWidth
            self.viewNameCardDescr.center.x = self.view.center.x
        }))
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        if imagePick == 0 {
            imageCachedAvatar = image
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
        } else {
            imageCachedCover = image
            let coverImage = FaeImage()
            coverImage.image = image
            
            coverImage.faeUploadCoverImageInBackground { (code:Int, message:AnyObject?) in
                print(code)
                print(message)
                if code / 100 == 2 {
                    //                self.imageViewAvatarMore.image = image
                } else {
                    //failure
                }
            }
        }

        self.imagePicker.dismissViewControllerAnimated(true, completion: {
            if self.imagePick == 0 {
                self.imageViewTitleProfile.image = self.cropToBounds(self.imageCachedAvatar)
            }
            else {
                self.imageViewCover.image = self.cropToBounds(self.imageCachedCover)
            }
        })
    }
    func showPhotoSelected(sender: Int) {
        //if sender = 0 show profile
        self.imagePick = sender
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .ActionSheet)
        menu.view.tintColor = colorFae
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
    
    func getAndSetUserAvatar(userAvatar: UIImageView, userID: Int) {
        let stringHeaderURL = "https://api.letsfae.com/files/users/\(userID)/avatar"
        let block = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            // completion code here
            if userAvatar.image != nil {
                let croppedImage = self.cropToBounds(userAvatar.image!)
                userAvatar.image = croppedImage
            }
        }
        userAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: UIImage(named: "defaultMan"), completed: block)
    }
    
    func getAndSetCoverImage(userAvatar: UIImageView, userID: Int) {
        let stringHeaderURL = "https://api.letsfae.com/files/users/\(userID)/name_card_cover"
        let block = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            // completion code here
            if userAvatar.image != nil {
                let croppedImage = self.cropToBounds(userAvatar.image!)
                userAvatar.image = croppedImage
            }
        }
        userAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: UIImage(named: "map_userpin_background"), completed: block)
    }
    
    func cropToBounds(image: UIImage) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(contextSize.width)
        var cgheight: CGFloat = CGFloat(contextSize.height)
        
        print("DEBUG: cgwidth cgheight")
        print(cgwidth)
        print(cgheight)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage!, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}
extension NSAttributedString {
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}
