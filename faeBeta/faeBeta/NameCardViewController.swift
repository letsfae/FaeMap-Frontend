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

class NameCardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialTableview()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        setupNavigationBar()
        let showGenderAge = FaeUser()
        showGenderAge.getSelfNamecard(){(status:Int, message: Any?) in
            print("DEBUG showgender")
            if(status / 100 == 2){
//                print(message)
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
    
    func getColor(_ red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }

}
// MARK: tableview
extension NameCardViewController : UITableViewDelegate, UITableViewDataSource {
    func initialTableview() {
        tableViewNameCard = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 736*screenHeightFactor))
        tableViewNameCard.delegate = self
        tableViewNameCard.dataSource = self
        tableViewNameCard.backgroundColor = UIColor.clear
        tableViewNameCard.separatorStyle = .none
        tableViewNameCard.rowHeight = 55 * screenHeightFactor
        
        tableViewNameCard.register(NameCardFirstFiveCell.self, forCellReuseIdentifier: cellGeneral)
        tableViewNameCard.register(NameCardWithSwitchCell.self, forCellReuseIdentifier: cellSwitch)
        
        self.view.addSubview(tableViewNameCard)
        initialHeaderView()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row <= 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellGeneral, for: indexPath) as! NameCardFirstFiveCell
            cell.selectionStyle = .none
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSwitch, for: indexPath) as! NameCardWithSwitchCell
            cell.selectionStyle = .none
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NameCardTagsViewController")as! NameCardTagsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToNickname() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "NameSettingViewController")as! NameSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToIntro() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "IntroSettingViewController")as! IntroSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationBack"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
        let label = UILabel(frame: CGRect(x: 0,y: 0,width: 147,height: 27))
        label.text = "Your NameCard"
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        self.navigationItem.titleView = label
    }
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
//add Header view
extension NameCardViewController {
    func initialHeaderView() {
        viewHeaderBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 274*screenHeightFactor))
        viewHeaderBackground.center.x = screenWidth/2
        tableViewNameCard.tableHeaderView = viewHeaderBackground
        //tableViewNameCard.tableHeaderView?.frame = CGRectMake(0, 0, screenWidth, 316)
        viewUpUnderline = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        viewDownUnderline = UIView(frame: CGRect(x: 17,y: 274*screenHeightFactor,width: screenWidth - 34,height: 1))
        viewUpUnderline.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        viewDownUnderline.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        self.view.addSubview(viewUpUnderline)
        viewHeaderBackground.addSubview(viewDownUnderline)
        viewNameCardTitle = UIView(frame: CGRect(x: (screenWidth-268)/2, y: 51*screenHeightFactor, width: 268*screenWidthFactor, height: 180*screenHeightFactor))
        viewNameCardTitle.center.x = screenWidth / 2
        viewNameCardTitle.layer.borderColor = UIColor.gray.cgColor
        viewNameCardTitle.layer.borderWidth = 1.0
        viewNameCardTitle.layer.cornerRadius = 15
        viewNameCardTitle.clipsToBounds = true
        viewHeaderBackground.addSubview(viewNameCardTitle)
        
        imageViewCover = UIImageView(frame: CGRect(x: 0, y: 0, width: 268*screenWidthFactor, height: 120*screenHeightFactor))
        imageViewCover.layer.masksToBounds = true
        imageViewCover.clipsToBounds = true
        imageViewCover.contentMode = .scaleAspectFill
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id)/name_card_cover"
            imageViewCover.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .refreshCached)
        }
        viewNameCardTitle.addSubview(imageViewCover)
        
        imageViewTitleProfile = UIImageView(frame: CGRect(x: 103.5*screenWidthFactor, y: 71*screenHeightFactor, width: 61*screenWidthFactor, height: 61*screenHeightFactor))
        imageViewTitleProfile.layer.cornerRadius = 30.5 * screenWidthFactor
        imageViewTitleProfile.layer.masksToBounds = true
        imageViewTitleProfile.clipsToBounds = true
        imageViewTitleProfile.layer.borderWidth = 5
        imageViewTitleProfile.layer.borderColor = UIColor.white.cgColor
        imageViewTitleProfile.contentMode = .scaleAspectFill
        
        /*
        imageViewTitleProfile.layer.shadowOpacity = 0.5
        imageViewTitleProfile.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        imageViewTitleProfile.layer.shadowRadius = 61 / 2
        imageViewTitleProfile.layer.shadowColor = UIColor.grayColor().CGColor
         */
        
        viewNameCardTitle.addSubview(imageViewTitleProfile)
        
        labelNickname = UILabel(frame: CGRect(x: 0, y: 138*screenHeightFactor, width: 268*screenWidthFactor, height: 27*screenHeightFactor))
        if nickname == nil || nickname == "" {
            labelNickname.text = "Anonymous"
        } else {
            labelNickname.text = nickname
        }
        labelNickname.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNickname.textAlignment = .center
        labelNickname.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        viewNameCardTitle.addSubview(labelNickname)
        
        //the second header view
        viewNameCardDescr = UIView(frame: CGRect(x: 73 + self.screenWidth,y: 119 - 64,width: 268,height: 180))
        viewNameCardDescr.layer.borderColor = UIColor.gray.cgColor
        viewNameCardDescr.layer.borderWidth = 1.0
        viewNameCardDescr.layer.cornerRadius = 15
        viewHeaderBackground.addSubview(viewNameCardDescr)
        
        imageViewDescrProfile = UIImageView(frame: CGRect(x: (268 - 61) / 2, y: 96 - 119, width: 61, height: 61))
        imageViewDescrProfile.layer.cornerRadius = 61 / 2
        imageViewDescrProfile.layer.masksToBounds = true
        imageViewDescrProfile.clipsToBounds = true
        imageViewDescrProfile.layer.borderWidth = 5
        imageViewDescrProfile.layer.borderColor = UIColor.white.cgColor
        imageViewDescrProfile.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        imageViewDescrProfile.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        imageViewDescrProfile.layer.shadowOpacity = 0.3
        imageViewDescrProfile.layer.shadowRadius = 5.0
        imageViewDescrProfile.contentMode = .scaleAspectFill
        viewNameCardDescr.addSubview(imageViewDescrProfile)
        if user_id != nil {
            let stringHeaderURL = baseURL + "/files/users/" + user_id.stringValue + "/avatar"
            print(user_id)
            imageViewTitleProfile.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        }
        viewGender = UIView(frame: CGRect(x: 90 - 73, y: 139 - 119, width: 50, height: 18))
        viewGender.backgroundColor = getColor(149, green: 207, blue: 246)
        let tempImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 18))
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
        
        buttonMore = UIButton(frame: CGRect(x: 292 - 73, y: 139 - 119, width: 32, height: 18))
        buttonMore.setImage(UIImage(named: "map_userpin_dark"), for: UIControlState())
        viewNameCardDescr.addSubview(buttonMore)
        
        viewLine = UIView(frame: CGRect(x: 0, y: 56,width: 268,height: 1))
        viewLine.backgroundColor = getColor(200, green: 199, blue: 204)
        viewNameCardDescr.addSubview(viewLine)
        
        labelIntro = UILabel(frame: CGRect(x: 97 - 73, y: 193 - 119,width: 220, height: 45))
        labelIntro.textColor = getColor(155, green: 155, blue: 155)
        labelIntro.numberOfLines = 2
        labelIntro.textAlignment = .center
        labelIntro.text = "nothing here"
        labelIntro.font = UIFont(name: "AvenirNext-Medium", size: 15)
        viewNameCardDescr.addSubview(labelIntro)
        
        buttonDoFaevor = UIButton(frame: CGRect(x: 101 - 73, y: 248 - 119, width: 104, height: 27))
        buttonDoFaevor.backgroundColor = getColor(255, green: 128, blue: 128)
        buttonDoFaevor.setTitle("I do Faevors", for: UIControlState())
        buttonDoFaevor.titleLabel?.textColor = UIColor.white
        buttonDoFaevor.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonDoFaevor.layer.cornerRadius = 4.6
        viewNameCardDescr.addSubview(buttonDoFaevor)
        
        buttonFriends = UIButton(frame: CGRect(x: 215 - 73, y: 248 - 119, width: 99, height: 27))
        buttonFriends.backgroundColor = getColor(230, green: 140, blue: 102)
        buttonFriends.setTitle("LF Friends", for: UIControlState())
        buttonFriends.titleLabel?.textColor = UIColor.white
        buttonFriends.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        buttonFriends.layer.cornerRadius = 4.6
        viewNameCardDescr.addSubview(buttonFriends)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(NameCardViewController.showNameCardTitle))
        swipeRight.direction = .right
        self.viewHeaderBackground.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(NameCardViewController.showNameCardDescr))
        swipeLeft.direction = .left
        self.viewHeaderBackground.addGestureRecognizer(swipeLeft)
    }
    func showNameCardTitle() {// right swipe
        UIView.animate(withDuration: 0.25, animations: ({
            self.viewNameCardTitle.center.x = self.view.center.x
            self.viewNameCardDescr.center.x = self.view.center.x + self.screenWidth
        }))
    }
    func showNameCardDescr() {// left swipe
        UIView.animate(withDuration: 0.25, animations: ({
            self.viewNameCardTitle.center.x = self.view.center.x - self.screenWidth
            self.viewNameCardDescr.center.x = self.view.center.x
        }))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        if imagePick == 0 {
            self.imageViewTitleProfile.image = image
            let avatar = FaeImage()
            avatar.image = image
            avatar.faeUploadImageInBackground { (code:Int, message: Any?) in
//                print(code)
//                print(message)
                if code / 100 == 2 {
                    //                self.imageViewAvatarMore.image = image
                } else {
                    //failure
                }
            }
        } else {
            self.imageViewCover.image = image
            let coverImage = FaeImage()
            coverImage.image = image
            
            coverImage.faeUploadCoverImageInBackground { (code:Int, message: Any?) in
//                print(code)
//                print(message)
                if code / 100 == 2 {
                    //                self.imageViewAvatarMore.image = image
                } else {
                    //failure
                }
            }
        }

        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func showPhotoSelected(_ sender: Int) {
        //if sender = 0 show profile
        self.imagePick = sender
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = colorFae
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            menu.removeFromParentViewController()
            self.present(self.imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
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
}
extension NSAttributedString {
    
    func widthWithConstrainedHeight(_ height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}
