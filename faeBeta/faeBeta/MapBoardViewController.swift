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

class MapBoardViewController: UIViewController, LeftSlidingMenuDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    var ageLBVal: Int = 16
    var ageUBVal: Int = 21
    var boolIsLoaded: Bool = false
    var boolNoMatch: Bool = false
    var boolUsrVisibleIsOn: Bool = true
    var btnChangeAgeLB: UIButton!
    var btnChangeAgeUB: UIButton!
    var btnChangeDis: UIButton!
    var btnComments: UIButton!
    var btnGenderBoth: UIButton!
    var btnGenderFemale: UIButton!
    var btnGenderMale: UIButton!
    var btnMyTalks: UIButton!
    var btnNavBarMenu: UIButton!
    var btnPeople: UIButton!
    var btnPeopleLocDetail: UIButton!
    var btnPlaces: UIButton!
    var btnSocial: UIButton!
    var btnTalk: UIButton!
    var btnTalkFeed: UIButton!
    var btnTalkMypost: UIButton!
    var btnTalkTopic: UIButton!
    var curtTitle: String = "Social"
    var disVal: String = "23.0"
    var imgBubbleHint: UIImageView!
    var imgIconBeforeAllCom: UIImageView!
    var imgTick: UIImageView!
    var lblAgeVal: UILabel!
    var lblAllCom: UILabel!
    var lblBubbleHint: UILabel!
    var lblDisVal: UILabel!
    var loadedTalkPage = false
//    var mbComments = [MBSocialStruct]()
//    var mbStories = [MBSocialStruct]()
    var mbPeople = [MBPeopleStruct]()
    var mbPlaces = [MBPlacesStruct]()
    
    var navBarMenuBtnClicked = false
    var selectedGender: String = "Both"
    var sliderAgeFilter: TTRangeSlider!
    var sliderDisFilter: UISlider!
    var strBubbleHint: String = ""
    var tblMapBoard: UITableView!
    var titleArray: [String] = ["Places", "People", "Social", "Talk Talk"]
    var uiviewAgeRedLine: UIView!
    var uiviewAllCom: UIView!
    var uiviewBubbleHint: UIView!
    var uiviewDisRedLine: UIView!
    var uiviewDropDownMenu: UIView!
    var uiviewNavBar: FaeNavBar!
    var uiviewPeopleLocDetail: UIView!
    var uiviewRedUnderLine: UIView!
    var uiviewTalkPostHead: UIView!
    var uiviewTalkTab: UIView!
    var window: UIWindow?
    
    // data for social table
    let lblTitleTxt: Array = ["Comments", "Chats", "Stories"]
    let imgIconArr: [UIImage] = [#imageLiteral(resourceName: "mb_comment"), #imageLiteral(resourceName: "mb_chat"), #imageLiteral(resourceName: "mb_story")]
    let lblContTxt: Array = ["70K Interactions Today", "180K Interactions Today", "3200 Interactions Today"]
    
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
        view.backgroundColor = .white
        
        // loading order
        loadTable()
        loadCannotFindPeople()
        loadMidViewContent()
        loadNavBar()
        loadTalkTabView()
        uiviewBubbleHint.isHidden = true
        uiviewTalkTab.isHidden = true
        
//        self.updateCurtLoc()
        // 这两个方法中已经进行了renewSelfLocation的操作
        //        self.getMBSocialInfo(socialType: "comment")
        //        self.getMBSocialInfo(socialType: "media")
//        getMBPlaceInfo()
        
        tblMapBoard.addGestureRecognizer(setGestureRecognizer())
        uiviewTalkTab.addGestureRecognizer(setGestureRecognizer())
        uiviewBubbleHint.addGestureRecognizer(setGestureRecognizer())
        
        // userStatus == 5 -> invisible, userStatus == 1 -> visible
        userInvisible(isOn: userStatus == 5)
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 使用navigationController之后，存在space between navigation bar and first cell，加上这句话后可解决这个问题
        automaticallyAdjustsScrollViewInsets = false
        tblMapBoard.contentInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("[viewWillDisappear]")
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        boolIsLoaded = false
    }
    
    // UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    fileprivate func loadNavBar() {
        loadDropDownMenu()
        
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "mb_leftWindow"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.addTalkFeed(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth - 140) / 2, y: 24, width: 140, height: 42))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarSetTitle()
        
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
    }
    
    func actionLeftWindowShow(_ sender: UIButton) {
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.displayName = Key.shared.nickname ?? "Someone"
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
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
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 201))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -136 // 65 - 201
        uiviewDropDownMenu.isHidden = true
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        
        btnPlaces = UIButton(frame: CGRect(x: 56, y: 9, width: 240 * screenWidthFactor, height: 38))
        uiviewDropDownMenu.addSubview(btnPlaces)
        btnPlaces.tag = 0
        //        btnPlaces.setTitle(titleArray[0], for: .normal)
        //        btnPlaces.setTitleColor(UIColor.faeAppInputTextGrayColor(), for: .normal)
        //        btnPlaces.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnPlaces.contentHorizontalAlignment = .left
        btnPlaces.setImage(#imageLiteral(resourceName: "mb_places"), for: .normal)
        btnPlaces.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnPeople = UIButton(frame: CGRect(x: 56, y: 59, width: 240 * screenWidthFactor, height: 38))
        uiviewDropDownMenu.addSubview(btnPeople)
        btnPeople.tag = 1
        btnPeople.contentHorizontalAlignment = .left
        btnPeople.setImage(#imageLiteral(resourceName: "mb_people"), for: .normal)
        btnPeople.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnSocial = UIButton(frame: CGRect(x: 56, y: 109, width: 240 * screenWidthFactor, height: 38))
        uiviewDropDownMenu.addSubview(btnSocial)
        btnSocial.tag = 2
        btnSocial.contentHorizontalAlignment = .left
        btnSocial.setImage(#imageLiteral(resourceName: "mb_social"), for: .normal)
        btnSocial.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnTalk = UIButton(frame: CGRect(x: 56, y: 157, width: 240 * screenWidthFactor, height: 38))
        uiviewDropDownMenu.addSubview(btnTalk)
        btnTalk.tag = 3
        btnTalk.contentHorizontalAlignment = .left
        btnTalk.setImage(#imageLiteral(resourceName: "mb_talk"), for: .normal)
        btnTalk.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        // imgTick.frame.origin.y = 20, 70, 120, 168
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 120, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
        
        let uiviewDropMenuFirstLine = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuFirstLine)
        uiviewDropMenuFirstLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1)
        
        let uiviewDropMenuSecLine = UIView(frame: CGRect(x: 41, y: 100, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuSecLine)
        uiviewDropMenuSecLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1)
        
        let uiviewDropMenuThirdLine = UIView(frame: CGRect(x: 41, y: 150, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuThirdLine)
        uiviewDropMenuThirdLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1)
    }
    
    fileprivate func loadMidViewContent() {
        uiviewAllCom = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 49))
        uiviewAllCom.backgroundColor = .white
        view.addSubview(uiviewAllCom)
        
        imgIconBeforeAllCom = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        lblAllCom = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        btnPeopleLocDetail = UIButton()
        uiviewAllCom.addSubview(btnPeopleLocDetail)
        btnPeopleLocDetail.setImage(#imageLiteral(resourceName: "mb_iconLoc"), for: .normal)
        btnPeopleLocDetail.isHidden = true
        uiviewAllCom.addConstraintsWithFormat("H:[v0(39)]-5-|", options: [], views: btnPeopleLocDetail)
        uiviewAllCom.addConstraintsWithFormat("V:|-6-[v0(38)]", options: [], views: btnPeopleLocDetail)
        btnPeopleLocDetail.addTarget(self, action: #selector(chooseNearbyPeopleInfo(_:)), for: .touchUpInside)
        
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
        view.addSubview(uiviewTalkPostHead)
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
        
        uiviewRedUnderLine = UIView(frame: CGRect(x: 40, y: uiviewTalkPostHead.frame.height - 2, width: 130, height: 2))
        uiviewRedUnderLine.backgroundColor = UIColor.faeAppRedColor()
        uiviewTalkPostHead.addSubview(uiviewRedUnderLine)
        
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
            btnPeopleLocDetail.isHidden = false
            loadChooseNearbyPeopleView()
        } else {
            btnPeopleLocDetail.isHidden = true
        }
        
        if tableMode == .talk {
            uiviewTalkTab.isHidden = false
            switchTalkTabPage()
        } else {
            if loadedTalkPage {
                uiviewNavBar.rightBtn.isHidden = true
                uiviewTalkTab.isHidden = true
                uiviewTalkPostHead.isHidden = true
                uiviewAllCom.isHidden = false
                uiviewNavBar.bottomLine.isHidden = false
                tblMapBoard.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114)
            }
        }
    }
    
    fileprivate func loadTable() {
        tblMapBoard = UITableView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114), style: UITableViewStyle.plain)
        view.addSubview(tblMapBoard)
        tblMapBoard.backgroundColor = .white
        tblMapBoard.register(MBSocialCell.self, forCellReuseIdentifier: "mbSocialCell")
        tblMapBoard.register(MBPeopleCell.self, forCellReuseIdentifier: "mbPeopleCell")
        tblMapBoard.register(MBPlacesCell.self, forCellReuseIdentifier: "mbPlacesCell")
        tblMapBoard.register(MBTalkFeedCell.self, forCellReuseIdentifier: "mbTalkFeedCell")
        tblMapBoard.register(MBTalkTopicCell.self, forCellReuseIdentifier: "mbTalkTopicCell")
        tblMapBoard.register(MBTalkMytalksCell.self, forCellReuseIdentifier: "mbTalkMytalksCell")
        tblMapBoard.register(MBTalkCommentsCell.self, forCellReuseIdentifier: "mbTalkCommentsCell")
        tblMapBoard.delegate = self
        tblMapBoard.dataSource = self
        tblMapBoard.separatorStyle = .none
    }
    
    fileprivate func loadTalkTabView() {
        uiviewTalkTab = UIView()
        uiviewTalkTab.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
        view.addSubview(uiviewTalkTab)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewTalkTab)
        view.addConstraintsWithFormat("V:[v0(49)]-0-|", options: [], views: uiviewTalkTab)
        
        let tabLine = UIView()
        tabLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewTalkTab.addSubview(tabLine)
        uiviewTalkTab.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tabLine)
        uiviewTalkTab.addConstraintsWithFormat("V:|-0-[v0(1)]", options: [], views: tabLine)
        
        // add three buttons
        btnTalkFeed = UIButton()
        btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_activeTalkFeed"), for: .selected)
        btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_inactiveTalkFeed"), for: .normal)
        
        btnTalkFeed.tag = 0
        uiviewTalkTab.addSubview(btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("H:|-67-[v0(47)]", options: [], views: btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkFeed)
        
        btnTalkTopic = UIButton()
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_activeTalkTopic"), for: .selected)
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_inactiveTalkTopic"), for: .normal)
        btnTalkTopic.tag = 1
        uiviewTalkTab.addSubview(btnTalkTopic)
        let padding = (screenWidth - 47) / 2
        uiviewTalkTab.addConstraintsWithFormat("H:|-\(padding)-[v0(47)]-\(padding)-|", options: [], views: btnTalkTopic)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkTopic)
        
        btnTalkMypost = UIButton()
        btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_activeTalkMypost"), for: .selected)
        btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_inactiveTalkMypost"), for: .normal)
        btnTalkMypost.tag = 2
        uiviewTalkTab.addSubview(btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("H:[v0(47)]-67-|", options: [], views: btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkMypost)
        
        btnTalkFeed.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkTopic.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkMypost.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
    }
    
    // function for drop down menu button, to show / hide the drop down menu
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            uiviewDropDownMenu.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65
            })
            navBarMenuBtnClicked = true
            if talkTableMode == .post {
                uiviewNavBar.bottomLine.isHidden = false
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
        switch sender.tag {
        case 0:
            curtTitle = titleArray[0]
            imgTick.frame.origin.y = 20
            break
        case 1:
            curtTitle = titleArray[1]
            imgTick.frame.origin.y = 70
            break
        case 2:
            curtTitle = titleArray[2]
            imgTick.frame.origin.y = 120
            break
        case 3:
            curtTitle = titleArray[3]
            imgTick.frame.origin.y = 168
            break
        default:
            return
        }
        btnNavBarSetTitle()
        getCurtTableMode()
        hideDropDownMenu()
        setViewContent()
        
        reloadTableMapBoard()
    }
    
    fileprivate func hideDropDownMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -136
        }, completion: { _ in
            self.uiviewDropDownMenu.isHidden = true
        })
        
        navBarMenuBtnClicked = false
        if tableMode == .talk && talkTableMode == .post {
            uiviewNavBar.bottomLine.isHidden = true
        }
    }
    
    // get current table mode: social / people / places / talk
    fileprivate func getCurtTableMode() {
        if curtTitle == "Social" {
            tableMode = .social
        } else if curtTitle == "People" {
            tableMode = .people
            updateNearbyPeople()
        } else if curtTitle == "Places" {
            tableMode = .places
            getMBPlaceInfo()
        } else if curtTitle == "Talk Talk" {
            tableMode = .talk
        }
        getPeoplePage()
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
            btnTalkFeed.isSelected = true
            btnTalkTopic.isSelected = false
            btnTalkMypost.isSelected = false
            uiviewNavBar.rightBtn.isHidden = false
        } else if talkTableMode == .topic {
            btnTalkFeed.isSelected = false
            btnTalkTopic.isSelected = true
            btnTalkMypost.isSelected = false
            uiviewNavBar.rightBtn.isHidden = true
        } else if talkTableMode == .post {
            btnTalkFeed.isSelected = false
            btnTalkTopic.isSelected = false
            btnTalkMypost.isSelected = true
            uiviewNavBar.rightBtn.isHidden = true
        }
        
        if talkTableMode == .post {
            tblMapBoard.frame = CGRect(x: 0, y: 95, width: screenWidth, height: screenHeight - 145)
            uiviewAllCom.isHidden = true
            uiviewNavBar.bottomLine.isHidden = true
            uiviewTalkPostHead.isHidden = false
        } else {
            tblMapBoard.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 164)
            uiviewAllCom.isHidden = false
            uiviewNavBar.bottomLine.isHidden = false
            uiviewTalkPostHead.isHidden = true
        }
    }
    
    // function for add talk feed when press upper right plus button in talk mode
    func addTalkFeed(_ sender: UIButton) {
        print("addTalkFeed")
    }
    
    func switchBetweenTalkAndComment(_ sender: UIButton) {
        var targetCenter: CGFloat = 0
        if sender.tag == 0 {
            talkPostTableMode = .talk
            btnMyTalks.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnComments.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnMyTalks.center.x
        } else if sender.tag == 1 {
            talkPostTableMode = .comment
            btnComments.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnMyTalks.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnComments.center.x
        }
        
        // Animation of the red sliding line (My Talks, Comments)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedUnderLine.center.x = targetCenter
        }), completion: { _ in
        })
        
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
        tblMapBoard.reloadData()
        tblMapBoard.layoutIfNeeded()
        tblMapBoard.setContentOffset(CGPoint.zero, animated: false)
    }
    
//    func renewSelfLocation() {
//        
//        if currentLocation != nil {
//            
//            let selfLocation = FaeMap()
//            selfLocation.whereKey("geo_latitude", value: "\(currentLatitude)")
//            selfLocation.whereKey("geo_longitude", value: "\(currentLongitude)")
//            selfLocation.renewCoordinate { (status: Int, _: Any?) in
//                if status / 100 == 2 {
//                    // print("Successfully renew self position")
//                } else {
//                    print("[renewSelfLocation] fail")
//                }
//            }
//        }
//    }
    
    fileprivate func loadCannotFindPeople() {
        uiviewBubbleHint = UIView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114))
        uiviewBubbleHint.backgroundColor = .white
        view.addSubview(uiviewBubbleHint)
        
        imgBubbleHint = UIImageView(frame: CGRect(x: 82 * screenWidthFactor, y: 142 * screenHeightFactor, width: 252, height: 209))
        imgBubbleHint.image = #imageLiteral(resourceName: "mb_bubbleHint")
        uiviewBubbleHint.addSubview(imgBubbleHint)
        
        lblBubbleHint = UILabel(frame: CGRect(x: 24, y: 7, width: 206, height: 75))
        lblBubbleHint.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBubbleHint.textColor = UIColor.faeAppInputTextGrayColor()
        lblBubbleHint.lineBreakMode = .byWordWrapping
        lblBubbleHint.numberOfLines = 0
        imgBubbleHint.addSubview(lblBubbleHint)
        lblBubbleHint.text = strBubbleHint
    }
    
    fileprivate func getPeoplePage() {
        vickyPrint("userStatus \(userStatus)")
        if curtTitle == "People" && !boolUsrVisibleIsOn {
            tblMapBoard.isHidden = true
            uiviewBubbleHint.isHidden = false
            strBubbleHint = "Oops, you are invisible right now, turn off invisibility to discover! :)"
            lblBubbleHint.text = strBubbleHint
            btnPeopleLocDetail.isUserInteractionEnabled = false
        } else {
            tblMapBoard.isHidden = false
            uiviewBubbleHint.isHidden = true
            btnPeopleLocDetail.isUserInteractionEnabled = true
        }
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        vickyPrint("isOn \(isOn)")
        if (isOn) {
            boolUsrVisibleIsOn = false
        } else {
            boolUsrVisibleIsOn = true
        }
        getPeoplePage()
    }
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    func jumpToCollections() {
        let vcCollections = CollectionsBoardViewController()
        navigationController?.pushViewController(vcCollections, animated: true)
    }
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
    }
    func logOutInLeftMenu() {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: true)
    }
    func jumpToFaeUserMainPage() {
        let vc = MyFaeMainPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func reloadSelfPosition() {
        
    }
    func switchMapMode() {
        if let vc = self.navigationController?.viewControllers.first {
            if vc is InitialPageController {
                if let vcRoot = vc as? InitialPageController {
                    vcRoot.goToFaeMap()
                    LeftSlidingMenuViewController.boolMapBoardIsOn = false
                }
            }
        }
    }
}
