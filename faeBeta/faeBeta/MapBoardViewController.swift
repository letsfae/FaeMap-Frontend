//
//  MapBoardViewController.swift
//  FaeMapBoard
//
//  Created by Vicky on 4/10/17.
//  Copyright © 2017 Fae. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import TTRangeSlider

class MapBoardViewController: UIViewController, LeftSlidingMenuDelegate, UIGestureRecognizerDelegate {
    
    var window: UIWindow?
    var uiviewNavBar: UIView!
    var blurViewDropDownMenu: UIVisualEffectView!
    var uiviewAllCom: UIView!
    var tableMapBoard: UITableView!
    var curtTitle: String = "Social"
    var titleArray: [String] = ["People", "Places", "Talk Talk"]
    var btnNavBarMenu: UIButton!
    var btnTop: UIButton!
    var btnMiddle: UIButton!
    var btnBottom: UIButton!
    var navBarMenuBtnClicked = false
    var imgIconBeforeAllCom: UIImageView!
    var lblAllCom: UILabel!
    var btnPeopleLocDetail: UIButton!
    var uiviewPeopleLocDetail: UIView!
    var btnGenderBoth: UIButton!
    var btnGenderFemale: UIButton!
    var btnGenderMale: UIButton!
    var btnChangeDis: UIButton!
    var btnChangeAgeLB: UIButton!
    var btnChangeAgeUB: UIButton!
    var uiviewDisRedLine: UIView!
    var uiviewAgeRedLine: UIView!
    var lblDisVal: UILabel!
    var lblAgeVal: UILabel!
    var btnTalkPlus: UIButton!
    var loadedTalkPage = false
    var uiviewTalkTab: UIView!
    var btnTalkFeed: UIButton!
    var btnTalkTopic: UIButton!
    var btnTalkMypost: UIButton!
    var uiviewTalkPostHead: UIView!
    var btnMyTalks: UIButton!
    var btnComments: UIButton!
    var uiviewRedUnderLine: UIView!
    var sliderDisFilter: UISlider!
    var sliderAgeFilter: TTRangeSlider!
    var seletedGender: String = "Both"
    var uiviewNavLine: UIView!
    
    var mbComments = [MBSocialStruct]()
    var mbStories = [MBSocialStruct]()
    var mbPlaces = [MBPlacesStruct]()
    var mbPeople = [MBPeopleStruct]()
    
    // data for social table
    let imgIconArr: [UIImage] = [#imageLiteral(resourceName: "mb_comment"), #imageLiteral(resourceName: "mb_chat"), #imageLiteral(resourceName: "mb_story")]
    let lblTitleTxt: Array = ["Comments", "Chats", "Stories"]
    let lblContTxt: Array = ["70K Interactions Today", "180K Interactions Today", "3200 Interactions Today"]
    // data for people table
    let imgAvatarArr: Array = [#imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar")]
    let lblUsrNameTxt: Array = ["Alexis", "Shirohige", "nekoneko"]
    let gender: Array = ["F", "M", "F"]
    let age: Array = ["", "21", "5"]
    let peopleDis: Array = ["< 0.1km", "1.1km", "1.5km"]
    let lblIntroTxt: Array = ["@alexis_boa", "I was there", "tontatasagsakeiahgkdalkkjgeiajijgasgehuihagejiuahgkdajhue"]
    
    var disVal: String = "23.0"
    var ageLBVal: Int = 16
    var ageUBVal: Int = 21
    
    // data for places table
//    let placeIcon: Array = [#imageLiteral(resourceName: "mb_defaultPlace"), #imageLiteral(resourceName: "mb_defaultPlace"), #imageLiteral(resourceName: "mb_defaultPlace"), #imageLiteral(resourceName: "mb_defaultPlace"), #imageLiteral(resourceName: "mb_defaultPlace")]
//    let placeName: Array = ["USC Roski", "Starbuckle Coffeeeez", "PollyWood", "PollyWoodddddddddddddddddd", "PollyWood"]
//    let placeAddr: Array = ["888 University Park, Los Angeles, CA", "888 University Park, Los Angeles, CA", "888 University Park, Los Angeles, CA", "888 University Park, Los Angeles, CA", "888 University Park, Los Angeles, California"]
//    let distance: Array = ["< 0.1km", "1.6km", "2.2km", "3.0km", "5.0km"]
    
    // data for talk feed table
    let avatarArr: Array = [#imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar")]
    let valUsrName: Array = ["Balalaxiaomoxian", "Snowbearonmoon", "Snowbearonamouooonnnnnnn"]
    let valTalkTime: Array = ["Yesterday", "Yesterday", "Mar 28, 2017"]
    let valReplyCount: Array = [12, 0, 999]
    let valContent: Array = ["There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME"]
    let valTopic: Array = ["general", "relationships", "singlereadaytomingle"]
    let valVoteCount: Array = [1, 888, 1]
    
    // data for talk topic table
    let topic: Array = ["foodpics", "singlereadytomingle", "nightlife", "general", "funny", "whispers", "relationships", "topicsuggestions", "Q&A"]
    let postsCount: Array = [288, 32, 288, 32, 288, 32, 288, 32, 288]
    
    // data for talk MyTalks table
    let myTalk_avatarArr: Array = [#imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar")]
    let myTalk_valUsrName: Array = ["Balalaxiaomoxian", "Snowbearonmoon", "Snowbearonamouooonnnnnnn"]
    let myTalk_valTalkTime: Array = ["Yesterday", "Yesterday", "Mar 28, 2017"]
    let myTalk_valReplyCount: Array = [12, 0, 999]
    let myTalk_valContent: Array = ["There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOMECOMECOMECOMECOMECOMECOME"]
    let myTalk_valTopic: Array = ["general", "relationships", "singlereadaytomingle"]
    let myTalk_valVoteCount: Array = [1, 888, 1]
    
    // data for talk Comments table
    let comment_avatarArr: Array = [#imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar")]
    let comment_valUsrName: Array = ["Anonymous", "Boogie Woogie Woogie"]
    let comment_valTalkTime: Array = ["Septermber 23, 2015", "Mar 28, 2017"]
    let comment_valContent: Array = ["LOL what are you talking abouta???", "I understand perfectly O(∩_∩)O"]
    let comment_valVoteCount: Array = [90, 90]
    
    var currentLatitude: CLLocationDegrees = 34.0205378 // location manage
    var currentLocation2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081) // location manage
    var currentLocation: CLLocation! // location manage
    var currentLongitude: CLLocationDegrees = -118.2854081 // location manage
    var btnLeftWindow: UIButton!
    
    weak var delegate: SwitchMapModeDelegate?

    enum MapBoardTableMode: Int {
        case social = 0
        case people = 1
        case places = 2
        case talk = 3
    }
    
    enum TalkTableMode: Int {
        case feed = 0
        case topic = 1
        case post = 2
    }
    
    enum TalkPostTableMode: Int {
        case talk = 0
        case comment = 1
    }
    
    var tableMode: MapBoardTableMode = .social
    var talkTableMode: TalkTableMode = .feed
    var talkPostTableMode: TalkPostTableMode = .talk
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        /*
        let user = FaeUser()
        user.whereKey("email", value: "test123@fae.com")//"12345678@qq.com")
        user.whereKey("password", value: "A1234567")//"Vickyvj5")
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status, message) in
            guard let loginInfo = message else {
                print("[logInBackground] log in fail")
                return
            }
            let loginInfoJSON = JSON(loginInfo)
            print(loginInfoJSON)
        }
        */
        
        // loading order
        loadTable()
        loadMidViewContent()
        loadNavBar()
        loadTalkTabView()
        uiviewTalkTab.isHidden = true
//        self.renewSelfLocation()
        // 这两个方法中已经进行了renewSelfLocation的操作
        self.getMBSocialInfo(socialType: "comment")
        self.getMBSocialInfo(socialType: "media")
        self.getMBPlaceInfo()

        self.tableMapBoard.addGestureRecognizer(setGestureRecognizer())
        self.uiviewTalkTab.addGestureRecognizer(setGestureRecognizer())
        
        // 使用navigationController之后，存在space between navigation bar and first cell，加上这句话后可解决这个问题
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        return tapRecognizer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 如果写在这里，每次回到MapBoard主页时CPU消耗太大。目前获取的comments/stories半径很大
//        self.renewSelfLocation()
//        self.getMBSocialInfo(socialType: "comment")
//        self.getMBSocialInfo(socialType: "media")
        print("viewDidAppear")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("[viewWillDisappear]")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    fileprivate func loadNavBar() {
        loadDropDownMenu()
        
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        uiviewNavBar.backgroundColor = .white
        self.view.addSubview(uiviewNavBar)
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth-140)/2, y: 24, width: 140, height: 42))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarSetTitle()
        
        btnNavBarMenu.addTarget(self, action: #selector(self.navBarMenuAct(_:)), for: .touchUpInside)
        
        btnTalkPlus = UIButton(frame: CGRect(x: screenWidth-34-7, y: 25, width: 34, height: 34))
        uiviewNavBar.addSubview(btnTalkPlus)
        btnTalkPlus.addTarget(self, action: #selector(self.addTalkFeed(_:)), for: .touchUpInside)
        loadedTalkPage = true
        
        uiviewNavLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewNavLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewNavBar.addSubview(uiviewNavLine)
        
        btnLeftWindow = UIButton(frame: CGRect(x: 0, y: 18,width: 40.5, height: 46))
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mb_leftWindow"), for: .normal)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        self.uiviewNavBar.addSubview(btnLeftWindow)
    }
    
    func actionLeftWindowShow(_ sender: UIButton) {
        let leftMenuVC = LeftSlidingMenuViewController()
        if let displayName = nickname {
            leftMenuVC.displayName = displayName
        }
        else {
            leftMenuVC.displayName = "someone"
        }
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        self.present(leftMenuVC, animated: false, completion: nil)
    }
    
    fileprivate func btnNavBarSetTitle() {
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    fileprivate func loadDropDownMenu() {
        blurViewDropDownMenu = UIVisualEffectView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 157))
        blurViewDropDownMenu.effect = UIBlurEffect(style: .light)
        self.view.addSubview(blurViewDropDownMenu)
        blurViewDropDownMenu.frame.origin.y = -92   // 65 - 157
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 156, width: screenWidth, height: 1))
        blurViewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        
        btnTop = UIButton(frame: CGRect(x: (screenWidth-200)/2, y:3, width: 200, height: 45))
        blurViewDropDownMenu.addSubview(btnTop)
        btnTop.tag = 0
        btnTop.setTitle(titleArray[0], for: .normal)
        btnTop.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        btnTop.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnTop.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnMiddle = UIButton(frame: CGRect(x: (screenWidth-200)/2, y: 55, width: 200, height: 45))
        blurViewDropDownMenu.addSubview(btnMiddle)
        btnMiddle.tag = 1
        btnMiddle.setTitle(titleArray[1], for: .normal)
        btnMiddle.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        btnMiddle.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnMiddle.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnBottom = UIButton(frame: CGRect(x: (screenWidth-200)/2, y: 106, width: 200, height: 45))
        blurViewDropDownMenu.addSubview(btnBottom)
        btnBottom.tag = 2
        btnBottom.setTitle(titleArray[2], for: .normal)
        btnBottom.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        btnBottom.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnBottom.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        let uiviewDropMenuFirstLine = UIView(frame: CGRect(x: (screenWidth-280)/2, y: 51, width: 280, height: 1))
        blurViewDropDownMenu.addSubview(uiviewDropMenuFirstLine)
        uiviewDropMenuFirstLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1)
        
        let uiviewDropMenuSecLine = UIView(frame: CGRect(x: (screenWidth-280)/2, y: 103, width: 280, height: 1))
        blurViewDropDownMenu.addSubview(uiviewDropMenuSecLine)
        uiviewDropMenuSecLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1)
    }
    
    fileprivate func loadMidViewContent() {
        uiviewAllCom = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 49))
        uiviewAllCom.backgroundColor = .white
        self.view.addSubview(uiviewAllCom)

        imgIconBeforeAllCom = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        lblAllCom = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        btnPeopleLocDetail = UIButton()
        uiviewAllCom.addSubview(btnPeopleLocDetail)
        uiviewAllCom.addConstraintsWithFormat("H:[v0(39)]-5-|", options: [], views: btnPeopleLocDetail)
        uiviewAllCom.addConstraintsWithFormat("V:|-6-[v0(38)]", options: [], views: btnPeopleLocDetail)
        btnPeopleLocDetail.addTarget(self, action: #selector(self.chooseNearbyPeopleInfo(_:)), for: .touchUpInside)
        
        setViewContent()
        
        // draw line
        let lblAllComLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        lblAllComLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewAllCom.addSubview(lblAllComLine)
        
        uiviewAllCom.addSubview(imgIconBeforeAllCom)
        uiviewAllCom.addSubview(lblAllCom)
        
        loadTalkPostHead()
    }
    
    // function for loading talk post uiview and switch buttons
    fileprivate func loadTalkPostHead() {
        uiviewTalkPostHead = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 31))
        self.view.addSubview(uiviewTalkPostHead)
        uiviewTalkPostHead.backgroundColor = .white
        uiviewTalkPostHead.isHidden = true
        
        btnMyTalks = UIButton()
        uiviewTalkPostHead.addSubview(btnMyTalks)
        uiviewTalkPostHead.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnMyTalks)
        uiviewTalkPostHead.addConstraintsWithFormat("H:|-40-[v0(130)]", options: [], views: btnMyTalks)
        
        let uiviewGrayUnderLine = UIView(frame: CGRect(x: 0, y: uiviewTalkPostHead.frame.height - 1, width: screenWidth, height: 1))
        uiviewGrayUnderLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewTalkPostHead.addSubview(uiviewGrayUnderLine)
        
        btnMyTalks.setTitle("My Talks", for: .normal)
        btnMyTalks.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnMyTalks.tag = 0
        btnMyTalks.addTarget(self, action: #selector(self.switchBetweenTalkAndComment(_:)), for: .touchUpInside)
        uiviewTalkPostHead.bringSubview(toFront: btnMyTalks)
        
        uiviewRedUnderLine = UIView(frame: CGRect(x: 0, y: uiviewTalkPostHead.frame.height - 2, width: 130, height: 2))
        uiviewRedUnderLine.backgroundColor = UIColor.faeAppRedColor()
        btnMyTalks.addSubview(uiviewRedUnderLine)
        
        btnComments = UIButton()
        uiviewTalkPostHead.addSubview(btnComments)
        uiviewTalkPostHead.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnComments)
        uiviewTalkPostHead.addConstraintsWithFormat("H:[v0(130)]-40-|", options: [], views: btnComments)
        
        btnComments.setTitle("Comments", for: .normal)
        btnComments.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
        btnComments.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        btnComments.tag = 1
        btnComments.addTarget(self, action: #selector(self.switchBetweenTalkAndComment(_:)), for: .touchUpInside)
    }
    
    // each time change the table mode (click the button in drop menu), call setViewContent()
    fileprivate func setViewContent() {
        if tableMode == .social || tableMode == .talk {
            imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeAllCom")
            lblAllCom.text = "All Communities"
        } else {
            imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
            lblAllCom.text = "Current Location"
        }
        
        lblAllCom.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblAllCom.textColor = UIColor.faeAppTimeTextBlackColor()
        
        if tableMode == .people {
            btnPeopleLocDetail.setImage(#imageLiteral(resourceName: "mb_iconLoc"), for: .normal)
            btnPeopleLocDetail.isEnabled = true
            loadChooseNearbyPeopleView()
        } else {
            btnPeopleLocDetail.setImage(nil, for: .normal)
            btnPeopleLocDetail.isEnabled = false
        }

        if tableMode == .talk {
            uiviewTalkTab.isHidden = false
            switchTalkTabPage()
        } else {
            if loadedTalkPage {
                btnTalkPlus.setImage(nil, for: .normal)
                btnTalkPlus.isEnabled = false
                uiviewTalkTab.isHidden = true
                uiviewTalkPostHead.isHidden = true
                uiviewAllCom.isHidden = false
                uiviewNavLine.isHidden = false
                tableMapBoard.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114)
            }
        }
    }
    
    fileprivate func loadTable() {
        tableMapBoard = UITableView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114), style: UITableViewStyle.plain)
        self.view.addSubview(tableMapBoard)
        tableMapBoard.backgroundColor = .white
        tableMapBoard.register(MBSocialCell.self, forCellReuseIdentifier: "mbSocialCell")
        tableMapBoard.register(MBPeopleCell.self, forCellReuseIdentifier: "mbPeopleCell")
        tableMapBoard.register(MBPlacesCell.self, forCellReuseIdentifier: "mbPlacesCell")
        tableMapBoard.register(MBTalkFeedCell.self, forCellReuseIdentifier: "mbTalkFeedCell")
        tableMapBoard.register(MBTalkTopicCell.self, forCellReuseIdentifier: "mbTalkTopicCell")
        tableMapBoard.register(MBTalkMytalksCell.self, forCellReuseIdentifier: "mbTalkMytalksCell")
        tableMapBoard.register(MBTalkCommentsCell.self, forCellReuseIdentifier: "mbTalkCommentsCell")
        tableMapBoard.delegate = self
        tableMapBoard.dataSource = self
        tableMapBoard.separatorStyle = .none
    }
    
    fileprivate func loadTalkTabView() {
        uiviewTalkTab = UIView()
        uiviewTalkTab.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        uiviewTalkTab.layer.borderColor = UIColor.faeAppNavBarBorderColor().cgColor
        uiviewTalkTab.layer.borderWidth = 1
        self.view.addSubview(uiviewTalkTab)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewTalkTab)
        self.view.addConstraintsWithFormat("V:[v0(50)]-0-|", options: [], views: uiviewTalkTab)
        
        // add three buttons
        btnTalkFeed = UIButton()
        btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_activeTalkFeed"), for: .normal)
        btnTalkFeed.tag = 0
        uiviewTalkTab.addSubview(btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("H:|-67-[v0(47)]", options: [], views: btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkFeed)
        
        btnTalkTopic = UIButton()
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_inactiveTalkTopic"), for: .normal)
        btnTalkTopic.tag = 1
        uiviewTalkTab.addSubview(btnTalkTopic)
        let padding = (screenWidth - 47) / 2
        uiviewTalkTab.addConstraintsWithFormat("H:|-\(padding)-[v0(47)]-\(padding)-|", options: [], views: btnTalkTopic)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkTopic)
        
        btnTalkMypost = UIButton()
        btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_inactiveTalkMypost"), for: .normal)
        btnTalkMypost.tag = 2
        uiviewTalkTab.addSubview(btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("H:[v0(47)]-67-|", options: [], views: btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkMypost)
        
        btnTalkFeed.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkTopic.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkMypost.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
    }
    
    // function for drop down menu button, to show / hide the drop down menu (UIVisualView)
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            UIView.animate(withDuration: 0.2,animations: {
                self.blurViewDropDownMenu.frame.origin.y = 65
            })
            navBarMenuBtnClicked = true
            if talkTableMode == .post {
                uiviewNavLine.isHidden = false
            }
        } else {
            hideDropDownMenu()
        }
    }
    
    // function for hide the drop down menu when tap on table
    func rollUpDropDownMenu(_ tap: UITapGestureRecognizer) {
        hideDropDownMenu()
    }
    
    // function for buttons in drop down menu
    func dropDownMenuAct(_ sender: UIButton) {
        if sender.tag == 0 {
            let temp = titleArray[0]
            titleArray[0] = curtTitle
            curtTitle = temp
        } else if sender.tag == 1 {
            let temp = titleArray[1]
            titleArray[1] = curtTitle
            curtTitle = temp
        } else if sender.tag == 2 {
            let temp = titleArray[2]
            titleArray[2] = curtTitle
            curtTitle = temp
        }
        titleArray.sort{$0.characters.count < $1.characters.count}
        btnTop.setTitle(titleArray[0], for: .normal)
        btnMiddle.setTitle(titleArray[1], for: .normal)
        btnBottom.setTitle(titleArray[2], for: .normal)
        btnNavBarSetTitle()
        getCurtTableMode()
        hideDropDownMenu()
        setViewContent()
//        print(tableMode)
        
        reloadTableMapBoard()
    }
    
    fileprivate func hideDropDownMenu() {
        UIView.animate(withDuration: 0.2,animations: {
            self.blurViewDropDownMenu.frame.origin.y = -92
        })
        navBarMenuBtnClicked = false
        if tableMode == .talk && talkTableMode == .post {
            uiviewNavLine.isHidden = true
        }
    }
    
    // get current table mode: social / people / places / talk
    fileprivate func getCurtTableMode() {
        if curtTitle == "Social" {
            tableMode = .social
        } else if curtTitle == "People" {
            tableMode = .people
        } else if curtTitle == "Places" {
            tableMode = .places
        } else if curtTitle == "Talk Talk" {
            tableMode = .talk
        }
    }
    
    func getTalkTableMode(_ sender: UIButton) {
        if sender.tag == 0 {
            talkTableMode = .feed
        } else if sender.tag == 1 {
            talkTableMode = .topic
        } else if sender.tag == 2 {
            talkTableMode = .post
        }
        switchTalkTabPage()
        reloadTableMapBoard()
    }
    
    // function for switch tab page in talk mode
    fileprivate func switchTalkTabPage() {
        if talkTableMode == .feed {
            btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_activeTalkFeed"), for: .normal)
            btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_inactiveTalkTopic"), for: .normal)
            btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_inactiveTalkMypost"), for: .normal)
            btnTalkPlus.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
            btnTalkPlus.isEnabled = true
        } else if talkTableMode == .topic {
            btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_inactiveTalkFeed"), for: .normal)
            btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_activeTalkTopic"), for: .normal)
            btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_inactiveTalkMypost"), for: .normal)
            btnTalkPlus.setImage(nil, for: .normal)
            btnTalkPlus.isEnabled = false
        } else if talkTableMode == .post {
            btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_inactiveTalkFeed"), for: .normal)
            btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_inactiveTalkTopic"), for: .normal)
            btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_activeTalkMypost"), for: .normal)
            btnTalkPlus.setImage(nil, for: .normal)
            btnTalkPlus.isEnabled = false
        }
        
        if talkTableMode == .post {
            tableMapBoard.frame = CGRect(x: 0, y: 95, width: screenWidth, height: screenHeight - 145)
            uiviewAllCom.isHidden = true
            uiviewNavLine.isHidden = true
            uiviewTalkPostHead.isHidden = false
        } else {
            tableMapBoard.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 164)
            uiviewAllCom.isHidden = false
            uiviewNavLine.isHidden = false
            uiviewTalkPostHead.isHidden = true
        }
    }
    
    // function for add talk feed when press upper right plus button in talk mode
    func addTalkFeed(_ sender: UIButton) {
        print("addTalkFeed")
    }
    
    func switchBetweenTalkAndComment(_ sender: UIButton) {
        if sender.tag == 0 {
            talkPostTableMode = .talk
            btnMyTalks.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnComments.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            btnMyTalks.addSubview(uiviewRedUnderLine)
        } else if sender.tag == 1 {
            talkPostTableMode = .comment
            btnComments.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnMyTalks.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            btnComments.addSubview(uiviewRedUnderLine)
        }

        reloadTableMapBoard()
    }
    
    func incDecVoteCount(_ sender: UIButton) {
        if sender.tag == 0 {
            print("0")
        } else if sender.tag == 1 {
            print("1")
        }
    }
    
    fileprivate func reloadTableMapBoard() {
        self.tableMapBoard.reloadData()
        self.tableMapBoard.layoutIfNeeded()
        self.tableMapBoard.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func renewSelfLocation() {
        if currentLocation != nil {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
            selfLocation.renewCoordinate {(status: Int, message: Any?) in
                if status / 100 == 2 {
                // print("Successfully renew self position")
                }
                else {
                    print("[renewSelfLocation] fail")
                }
            }
        }
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        
    }
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    func jumpToCollections() {
        let vcCollections = CollectionsBoardViewController()
        self.navigationController?.pushViewController(vcCollections, animated: true)
    }
    func logOutInLeftMenu() {
        let welcomeVC = WelcomeViewController()
        self.navigationController?.pushViewController(welcomeVC, animated: true)
    }
    func jumpToFaeUserMainPage() {
        let vc = MyFaeMainPageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func reloadSelfPosition() {
        
    }
    func switchMapMode() {
        self.navigationController?.popViewController(animated: false)
        self.delegate?.pushRealMap()
        LeftSlidingMenuViewController.boolMapBoardIsOn = false
    }
}

