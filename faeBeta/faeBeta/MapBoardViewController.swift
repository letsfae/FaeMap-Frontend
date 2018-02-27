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

enum MapBoardTableMode: Int {
    case social = 0
    case people = 1
    case places = 2
    case talk = 3
}

enum PlaceTableMode: Int {
    case recommend = 0
    case search = 1
}

class MapBoardViewController: UIViewController, LeftSlidingMenuDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, BoardsSearchDelegate {
    
    var ageLBVal: Int = 18
    var ageUBVal: Int = 21
    var boolIsLoaded: Bool = false
    var boolLoadedTalkPage = false
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
    var imgPeopleLocDetail: UIImageView!
    var btnPlaces: UIButton!
    var btnSocial: UIButton!
    var btnTalk: UIButton!
    var btnTalkFeed: UIButton!
    var btnTalkMypost: UIButton!
    var btnTalkTopic: UIButton!
    var curtTitle: String = "Places"
    var disVal: String = "23.0"
    var imgBubbleHint: UIImageView!
    var imgIconBeforeAllCom: UIImageView!
    var imgTick: UIImageView!
    var lblAgeVal: UILabel!
    var lblAllCom: UILabel!
    var lblBubbleHint: UILabel!
    var lblDisVal: UILabel!
    var lblPlaces: UILabel!
    var lblPeople: UILabel!
//    var mbComments = [MBSocialStruct]()
//    var mbStories = [MBSocialStruct]()
    var mbPeople = [MBPeopleStruct]()
    var mbPlaces = [PlacePin]()
    
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
    var uiviewLineBelowLoc: UIView!
    var uiviewNavBar: FaeNavBar!
    var uiviewPeopleLocDetail: UIView!
    var uiviewRedUnderLine: UIView!
    var uiviewTalkPostHead: UIView!
    var uiviewTalkTab: UIView!
    var uiviewPlaceTab: PlaceTabView!
    var uiviewPlaceHeader: UIView!
    var scrollViewPlaceHeader: UIScrollView!
    var uiviewPlaceHedaderView1: UIView!
    var uiviewPlaceHedaderView2: UIView!
    var pageCtrlPlace: UIPageControl!
    var btnSearchAllPlaces: UIButton!
    var lblSearchContent: UILabel!
    var btnClearSearchRes: UIButton!
    var imgIcon: UIImageView!
    var lblCurtLoc: UILabel!
    var btnSearchLoc: UIButton!   // fake button to search location
    
    var imgPlaces1: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    var arrPlaceNames1: [String] = ["Restaurant", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    var imgPlaces2: [UIImage] = [#imageLiteral(resourceName: "place_result_69"), #imageLiteral(resourceName: "place_result_20"), #imageLiteral(resourceName: "place_result_46"), #imageLiteral(resourceName: "place_result_6"), #imageLiteral(resourceName: "place_result_21"), #imageLiteral(resourceName: "place_result_29")]
    var arrPlaceNames2: [String] = ["Fast Food", "Beer Bar", "Cosmetics", "Fitness", "Groceries", "Pharmacy"]
    let arrTitle = ["Most Popular", "Recommended", "Nearby Food & Drinks", "Shopping", "Outdoors & Recreation"]
    var testArrPlaces = [[PlacePin]]()
    var testArrPopular = [PlacePin]()
    var testArrRecommend = [PlacePin]()
    var testArrFood = [PlacePin]()
    var testArrShopping = [PlacePin]()
    var testArrOutdoors = [PlacePin]()
    var arrAllPlaces = [PlacePin]()
    
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
    let myTalk_valTopic: Array = ["general", "relationships", "sin@objc @objc @objc glereadaytomingle"]
    let myTalk_valVoteCount: Array = [1, 888, 1]
    
    // data for talk Comments table
    let comment_avatarArr: Array = [#imageLiteral(resourceName: "default_Avatar"), #imageLiteral(resourceName: "default_Avatar")]
    let comment_valUsrName: Array = ["Anonymous", "Boogie Woogie Woogie"]
    let comment_valTalkTime: Array = ["Septermber 23, 2015", "Mar 28, 2017"]
    let comment_valContent: Array = ["LOL what are you talking abouta???", "I understand perfectly O(∩_∩)O"]
    let comment_valVoteCount: Array = [90, 90]
 
    enum TalkTableMode: Int {
        case feed = 0
        case topic = 1
        case post = 2
    }
    
    enum TalkPostTableMode: Int {
        case talk = 0
        case comment = 1
    }
    
    var tableMode: MapBoardTableMode = .places
    var placeTableMode: PlaceTableMode = .recommend
    var talkTableMode: TalkTableMode = .feed
    var talkPostTableMode: TalkPostTableMode = .talk
    
    var chosenLoc: CLLocationCoordinate2D? // user-chosen location
    
    // Loading Waves
    var uiviewAvatarWaveSub: UIView!
    var imgAvatar: FaeAvatarView!
    var filterCircle_1: UIImageView!
    var filterCircle_2: UIImageView!
    var filterCircle_3: UIImageView!
    var filterCircle_4: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // loading order
        loadTable()
        loadCannotFindPeople()
        loadPlaceTabView()
        loadChooseNearbyPeopleView()
        loadChooseLocation()
        loadNavBar()
        loadTalkTabView()
        loadAvatar()
        
        uiviewBubbleHint.alpha = 0
        uiviewTalkTab.isHidden = true

        getMBPlaceInfo(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)
        
        tblMapBoard.addGestureRecognizer(setGestureRecognizer())
        uiviewTalkTab.addGestureRecognizer(setGestureRecognizer())
        uiviewBubbleHint.addGestureRecognizer(setGestureRecognizer())
        
        // userStatus == 5 -> invisible, userStatus == 1 -> visible
        boolLoadedTalkPage = true
        userInvisible(isOn: Key.shared.onlineStatus == 5)
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        
        return tapRecognizer
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear")
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 使用navigationController之后，存在space between navigation bar and first cell，加上这句话后可解决这个问题
        automaticallyAdjustsScrollViewInsets = false
        tblMapBoard.contentInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        automaticallyAdjustsScrollViewInsets = false
        tblMapBoard.contentInset = .zero
        loadWaves()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        print("[viewWillDisappear]")
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
        uiviewNavBar.leftBtnWidth = 30
        uiviewNavBar.leftBtnPadding = 20
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "mb_menu"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.addTalkFeed(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth - 260) / 2, y: 23 + device_offset_top, width: 260, height: 37))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarMenu.setTitleColor(UIColor._898989(), for: .normal)
        btnNavBarMenu.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnNavBarSetTitle()
        
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        
        loadPlaceSearchHeader()
    }
    
    @objc func actionLeftWindowShow(_ sender: UIButton) {
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.delegate = self
        leftMenuVC.displayName = Key.shared.nickname
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
    }
    
    fileprivate func btnNavBarSetTitle() {
        let curtTitleAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    fileprivate func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 101))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -36 + device_offset_top // 65 - 201
        uiviewDropDownMenu.isHidden = true
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor._200199204()
        
        btnPlaces = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnPlaces)
        btnPlaces.tag = 0
        btnPlaces.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnPeople = UIButton(frame: CGRect(x: 0, y: 51, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnPeople)
        btnPeople.tag = 1
        btnPeople.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)

        lblPlaces = FaeLabel(CGRect(x: 104, y: 14, width: 200 , height: 25), .left, .medium, 18, UIColor._898989())
        lblPlaces.text = "Places"
        btnPlaces.addSubview(lblPlaces)
        
        lblPeople = FaeLabel(CGRect(x: 104, y: 14, width: 200 , height: 25), .left, .medium, 18, UIColor._898989())
        lblPeople.text = "People"
        btnPeople.addSubview(lblPeople)
        
        let imgPlaces = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgPlaces.image = #imageLiteral(resourceName: "collection_locations")
        imgPlaces.contentMode = .center
        btnPlaces.addSubview(imgPlaces)
        
        let imgPeople = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgPeople.image = #imageLiteral(resourceName: "mb_people")
        imgPeople.contentMode = .center
        btnPeople.addSubview(imgPeople)
        
        // imgTick.frame.origin.y = 20, 70, 120, 168
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
        
        let uiviewDropMenuFirstLine = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuFirstLine)
        uiviewDropMenuFirstLine.backgroundColor = UIColor._206203203()
    }
    
    fileprivate func loadChooseLocation() {
        uiviewAllCom = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        uiviewAllCom.backgroundColor = .white
        view.addSubview(uiviewAllCom)
        
        btnSearchLoc = UIButton()
        btnSearchLoc.tag = 0
        uiviewAllCom.addSubview(btnSearchLoc)
        btnSearchLoc.addTarget(self, action: #selector(chooseNearbyPeopleInfo(_:)), for: .touchUpInside)
        uiviewAllCom.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: btnSearchLoc)
        uiviewAllCom.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnSearchLoc)
        
        imgIconBeforeAllCom = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        imgIconBeforeAllCom.contentMode = .center
        lblAllCom = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        lblAllCom.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblAllCom.textColor = UIColor._107107107()
        imgPeopleLocDetail = UIImageView()
        imgPeopleLocDetail.contentMode = .center
        uiviewAllCom.addSubview(imgPeopleLocDetail)
        uiviewAllCom.addConstraintsWithFormat("H:[v0(39)]-5-|", options: [], views: imgPeopleLocDetail)
        uiviewAllCom.addConstraintsWithFormat("V:|-6-[v0(38)]", options: [], views: imgPeopleLocDetail)
        
        imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
        lblAllCom.text = "Current Location"
        
        setViewContent()
        
        // draw line
        uiviewLineBelowLoc = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        uiviewLineBelowLoc.backgroundColor = UIColor._200199204()
        uiviewAllCom.addSubview(uiviewLineBelowLoc)
        
        uiviewAllCom.addSubview(imgIconBeforeAllCom)
        uiviewAllCom.addSubview(lblAllCom)
        
        loadTalkPostHead()
    }
    
    // each time change the table mode (click the button in drop menu), call setViewContent()
    fileprivate func setViewContent() {
        /*
        if tableMode == .social || tableMode == .talk {
            imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeAllCom")
            lblAllCom.text = "All Communities"
        } else {
            imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
            lblAllCom.text = "Current Location"
        }
        */
        
        if tableMode == .places {
            uiviewPlaceTab.isHidden = false
            tblMapBoard.tableHeaderView = uiviewPlaceHeader
            tblMapBoard.frame.size.height = screenHeight - 163 - device_offset_top - device_offset_bot
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            btnSearchLoc.tag = 0
//            switchPlaceTabPage()
        } else {
            uiviewPlaceTab.isHidden = true
            tblMapBoard.tableHeaderView = nil
            tblMapBoard.frame.size.height = screenHeight - 114 - device_offset_top - device_offset_bot
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_curtLoc")
            btnSearchLoc.tag = 1
        }
        
        if tableMode == .talk {
            uiviewTalkTab.isHidden = false
            switchTalkTabPage()
        } else {
            if boolLoadedTalkPage {
                uiviewNavBar.rightBtn.isHidden = true
                uiviewTalkTab.isHidden = true
                uiviewTalkPostHead.isHidden = true
                uiviewAllCom.isHidden = false
                uiviewNavBar.bottomLine.isHidden = false
            }
        }
    }
    
    fileprivate func loadTable() {
        tblMapBoard = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 163 - device_offset_top - device_offset_bot), style: .plain)
        view.addSubview(tblMapBoard)
        tblMapBoard.backgroundColor = .white
        tblMapBoard.register(MBSocialCell.self, forCellReuseIdentifier: "mbSocialCell")
        tblMapBoard.register(MBPeopleCell.self, forCellReuseIdentifier: "mbPeopleCell")
        tblMapBoard.register(MBPlacesCell.self, forCellReuseIdentifier: "mbPlacesCell")
        tblMapBoard.register(AllPlacesCell.self, forCellReuseIdentifier: "AllPlacesCell")
        
        tblMapBoard.register(MBTalkFeedCell.self, forCellReuseIdentifier: "mbTalkFeedCell")
        tblMapBoard.register(MBTalkTopicCell.self, forCellReuseIdentifier: "mbTalkTopicCell")
        tblMapBoard.register(MBTalkMytalksCell.self, forCellReuseIdentifier: "mbTalkMytalksCell")
        tblMapBoard.register(MBTalkCommentsCell.self, forCellReuseIdentifier: "mbTalkCommentsCell")
        tblMapBoard.delegate = self
        tblMapBoard.dataSource = self
        tblMapBoard.separatorStyle = .none
        tblMapBoard.showsVerticalScrollIndicator = false
        
        loadPlaceHeader()
    }
    
    // function for drop down menu button, to show / hide the drop down menu
    @objc func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            uiviewDropDownMenu.isHidden = false
            btnNavBarMenu.setAttributedTitle(nil, for: .normal)
            btnNavBarMenu.setTitle("Choose a Board...", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65 + device_offset_top
            })
            navBarMenuBtnClicked = true
            if talkTableMode == .post {
                uiviewNavBar.bottomLine.isHidden = false
            }
        } else {
            hideDropDownMenu()
        }
        rollUpFilter()
    }
    
    // function for hide the drop down menu when tap on table
    @objc func rollUpDropDownMenu(_ tap: UITapGestureRecognizer) {
        hideDropDownMenu()
        rollUpFilter()
    }
    
    // function for buttons in drop down menu
    @objc func dropDownMenuAct(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            curtTitle = titleArray[0]
            imgTick.frame.origin.y = 20
        case 1:
            curtTitle = titleArray[1]
            imgTick.frame.origin.y = 70
        case 2:
            curtTitle = titleArray[2]
            imgTick.frame.origin.y = 120
        case 3:
            curtTitle = titleArray[3]
            imgTick.frame.origin.y = 168
        default: return
        }
        btnNavBarSetTitle()
        getCurtTableMode()
        hideDropDownMenu()
        setViewContent()
        
        reloadTableMapBoard()
    }
    
    fileprivate func hideDropDownMenu() {
        btnNavBarSetTitle()
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36 + device_offset_top
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
            getMBPlaceInfo(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)
        } else if curtTitle == "Talk Talk" {
            tableMode = .talk
        }
        getPeoplePage()
    }
    
    func reloadTableMapBoard() {
        tblMapBoard.reloadData()
        tblMapBoard.layoutIfNeeded()
        tblMapBoard.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
    
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    func jumpToCollections() {
//        let vcCollections = CollectionsBoardViewController()
        let vcCollections = CollectionsViewController()
        navigationController?.pushViewController(vcCollections, animated: true)
    }
    func jumpToContacts() {
        let vcContacts = ContactsViewController()
        self.navigationController?.pushViewController(vcContacts, animated: true)
    }
    func jumpToSettings() {
        let vcSettings = SettingsViewController()
        navigationController?.pushViewController(vcSettings, animated: true)
    }
    func jumpToFaeUserMainPage() {
        let vc = MyFaeMainPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func reloadSelfPosition() {
        
    }
    func switchMapMode() {
        guard let vc = self.navigationController?.viewControllers.first else { return }
        guard vc is InitialPageController else { return }
        if let vcRoot = vc as? InitialPageController {
            vcRoot.goToFaeMap()
            LeftSlidingMenuViewController.boolMapBoardIsOn = false
        }
    }
}
