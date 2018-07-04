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

enum MapBoardTableMode: Int {
    case people = 1
    case places = 2
}

enum PlaceTableMode: Int {
    case left = 0
    case right = 1
}

class MapBoardViewController: UIViewController, SideMenuDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    var ageLBVal: Int = 18
    var ageUBVal: Int = 21
    var boolIsLoaded: Bool = false
    var boolNoMatch: Bool = false
    var boolUsrVisibleIsOn: Bool = true
    var btnNavBarMenu: UIButton!
    var btnPeople: UIButton!
    var imgPeopleLocDetail: UIImageView!
    var btnPlaces: UIButton!
    var curtTitle: String = "Places"
    var locToSearchTextRaw: String?
    var imgCurtLoc: UIImageView!
    var imgTick: UIImageView!
    var lblCurtLoc: UILabel!
    var lblPlaces: UILabel!
    var lblPeople: UILabel!
    var viewModelCategories: BoardPlaceTabLeftViewModel!
    var viewModelPlaces: BoardPlaceTabRightViewModel!
    var viewModelPeople: BoardPeopleViewModel!
    
    var navBarMenuBtnClicked = false
    var tblPlaceLeft: UITableView!
    var tblPlaceRight: UITableView!
    var tblPeople: UITableView!
    var titleArray: [String] = ["Places", "People"]
    var uiviewCurtLoc: UIView!
    var uiviewDropDownMenu: UIView!
    var uiviewLineBelowLoc: UIView!
    var uiviewNavBar: FaeNavBar!
    var uiviewPeopleNearyFilter: BoardPeopleNearbyFilter!
    var uiviewPlaceTab: PlaceTabView!
    var uiviewPlaceHeader: BoardCategorySearchView!
    var btnSearchAllPlaces: UIButton!
    var lblSearchContent: UILabel!
    var btnClearSearchRes: UIButton!
    var btnSearchLoc: UIButton!   // fake button to search location
    
    var tblRightActivityIndicator: UIActivityIndicatorView!

    var testArrPlaces = [[PlacePin]]()
//    var testArrPopular = [PlacePin]()
//    var testArrRecommend = [PlacePin]()
//    var testArrFood = [PlacePin]()
//    var testArrShopping = [PlacePin]()
//    var testArrOutdoors = [PlacePin]()
//    var arrAllPlaces = [PlacePin]()
    
    var tableMode: MapBoardTableMode = .places
    var placeTableMode: PlaceTableMode = .left
    private var indicatorView: UIActivityIndicatorView!
    
    var selectedLoc: CLLocationCoordinate2D? // user-chosen location
    
    // Loading Waves
    var uiviewAvatarWave: BoardAvatarWaves!
    // name card view - when click people cell
    var uiviewNameCard = FMNameCardView()
    
    var fullyLoaded: Bool = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // loading order
        loadTable()
        addPullToRefresh()
        loadPlaceTabView()
        loadNearbyPeopleFilter()
        loadChooseLocation()
        loadNavBar()
        loadAvatarWaves()
        
        createActivityIndicator()
        loadViewModels()
        loadNameCard()
        
        tblPlaceLeft.addGestureRecognizer(setGestureRecognizer())
        tblPlaceRight.addGestureRecognizer(setGestureRecognizer())
        tblPeople.addGestureRecognizer(setGestureRecognizer())
        
        // userStatus == 5 -> invisible, userStatus == 1 -> visible
        userInvisible(isOn: Key.shared.onlineStatus == 5)
        
        fullyLoaded = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 使用navigationController之后，存在space between navigation bar and first cell，加上这句话后可解决这个问题
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        automaticallyAdjustsScrollViewInsets = false
        
        // After select "imperial" or "metric" in Settings page
        if let viewModelPeople = viewModelPeople {
            viewModelPeople.unit = Key.shared.measurementUnits == "imperial" ? " mi" : " km"
        }
        if let uiviewPeopleFilter = uiviewPeopleNearyFilter {
            uiviewPeopleFilter.unit = Key.shared.measurementUnits == "imperial" ? " mi" : " km"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func loadViewModels() {

        let locToSearch = LocManager.shared.locToSearch_board ?? LocManager.shared.curtLoc.coordinate
        LocManager.shared.locToSearch_board = LocManager.shared.curtLoc.coordinate
        
        // viewModelCategories - BoardPlaceTabLeftViewModel
        viewModelCategories = BoardPlaceTabLeftViewModel()
        viewModelCategories.location = locToSearch
        viewModelCategories.categoriesDataLoaded = { [unowned self] (categories) in
            self.tblPlaceLeft.reloadData()
            self.tblPlaceLeft.stopPullRefreshEver()
        }
        
        // viewModelPlaces - BoardPlaceTabRightViewModel
        viewModelPlaces = BoardPlaceTabRightViewModel()
        viewModelPlaces.category = "All Places"
        viewModelPlaces.placesDataLoaded = { [unowned self] (places) in
            self.tblPlaceRight.reloadData()
            self.tblPlaceRight.stopPullRefreshEver()
        }
        viewModelPlaces.boolDataLoaded = { [unowned self] (loaded) in
            if loaded {
//                self.indicatorView.stopAnimating()
//                self.tblPlaceRight.isUserInteractionEnabled = true
            } else {
//                self.indicatorView.startAnimating()
//                self.tblPlaceRight.isUserInteractionEnabled = false
            }
        }
        
        // viewModelPeople - BoardPeopleViewModel
        viewModelPeople = BoardPeopleViewModel()
        viewModelPeople.location = locToSearch
        viewModelPeople.boolUserVisible = { [unowned self] (visible) in
            self.tblPeople.reloadData()
            self.tblPeople.stopPullRefreshEver()
        }
        
        viewModelPeople.peopleDataLoaded = { [unowned self] (people) in
            self.tblPeople.reloadData()
            self.tblPeople.stopPullRefreshEver()
        }
        viewModelPeople.boolDataLoaded = { [unowned self] (loaded) in
            if loaded {
                self.uiviewAvatarWave.hideWaves()
                self.tblPeople.isUserInteractionEnabled = true
            } else {
                self.uiviewAvatarWave.showWaves()
                self.tblPeople.isUserInteractionEnabled = false
            }
        }
    }
    
    fileprivate func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = CGPoint(x: view.center.x, y: view.center.y - CGFloat(114))
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        tblPlaceRight.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
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
        uiviewNavBar.rightBtn.isHidden = true
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth - 260) / 2, y: 23 + device_offset_top, width: 260, height: 37))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarMenu.setTitleColor(UIColor._898989(), for: .normal)
        btnNavBarMenu.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnNavBarSetTitle()
        
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        loadPlaceSearchHeader()
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
        uiviewCurtLoc = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        uiviewCurtLoc.backgroundColor = .white
        view.addSubview(uiviewCurtLoc)
        
        btnSearchLoc = UIButton()
        btnSearchLoc.tag = 0
        uiviewCurtLoc.addSubview(btnSearchLoc)
        btnSearchLoc.addTarget(self, action: #selector(selectLocation(_:)), for: .touchUpInside)
        uiviewCurtLoc.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: btnSearchLoc)
        uiviewCurtLoc.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnSearchLoc)
        
        imgCurtLoc = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        imgCurtLoc.contentMode = .center
        lblCurtLoc = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        lblCurtLoc.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCurtLoc.textColor = UIColor._107107107()
        imgPeopleLocDetail = UIImageView()
        imgPeopleLocDetail.contentMode = .center
        uiviewCurtLoc.addSubview(imgPeopleLocDetail)
        uiviewCurtLoc.addConstraintsWithFormat("H:[v0(39)]-5-|", options: [], views: imgPeopleLocDetail)
        uiviewCurtLoc.addConstraintsWithFormat("V:|-6-[v0(38)]", options: [], views: imgPeopleLocDetail)
        
        imgCurtLoc.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
        lblCurtLoc.text = "Current Location"
        
        setViewContent()
        
        // draw line
        uiviewLineBelowLoc = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        uiviewLineBelowLoc.backgroundColor = UIColor._200199204()
        uiviewCurtLoc.addSubview(uiviewLineBelowLoc)
        
        uiviewCurtLoc.addSubview(imgCurtLoc)
        uiviewCurtLoc.addSubview(lblCurtLoc)
    }
    
    // load three tables
    fileprivate func loadTable() {
        loadPlaceHeader()
        
        tblPlaceLeft = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - 51 - device_offset_top - device_offset_bot), style: .plain)
        view.addSubview(tblPlaceLeft)
        tblPlaceLeft.backgroundColor = .white
        tblPlaceLeft.register(BoardPlacesCell.self, forCellReuseIdentifier: "BoardPlacesCell")
        tblPlaceLeft.tableHeaderView = uiviewPlaceHeader
        tblPlaceLeft.delegate = self
        tblPlaceLeft.dataSource = self
        tblPlaceLeft.separatorStyle = .none
        tblPlaceLeft.showsVerticalScrollIndicator = false
        tblPlaceLeft.scrollsToTop = true
        
        tblPlaceRight = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - 51 - device_offset_top - device_offset_bot + 1), style: .plain)
        view.addSubview(tblPlaceRight)
        tblPlaceRight.backgroundColor = .white
        tblPlaceRight.register(AllPlacesCell.self, forCellReuseIdentifier: "AllPlacesCell")
        tblPlaceRight.register(BoardNoResultCell.self, forCellReuseIdentifier: "BoardNoResultCell")
        tblPlaceRight.delegate = self
        tblPlaceRight.dataSource = self
        tblPlaceRight.separatorStyle = .none
        tblPlaceRight.showsVerticalScrollIndicator = true
        tblPlaceRight.scrollsToTop = true
        let footViewHeight: CGFloat = 75
        tblPlaceRight.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -footViewHeight, right: 0)
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: footViewHeight))
//        footView.backgroundColor = .blue
        tblPlaceRight.tableFooterView = footView
        tblRightActivityIndicator = faeBeta.createActivityIndicator(large: false)
        tblRightActivityIndicator.center = CGPoint(x: screenWidth / 2, y: footViewHeight / 2)
        tblRightActivityIndicator.startAnimating()
        footView.addSubview(tblRightActivityIndicator)
        
        tblPeople = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top - device_offset_bot), style: .plain)
        view.addSubview(tblPeople)
        tblPeople.backgroundColor = .white
        tblPeople.register(BoardPeopleCell.self, forCellReuseIdentifier: "BoardPeopleCell")
        tblPeople.register(BoardNoResultCell.self, forCellReuseIdentifier: "BoardNoResultCell")
        tblPeople.delegate = self
        tblPeople.dataSource = self
        tblPeople.separatorStyle = .none
        tblPeople.showsVerticalScrollIndicator = false
        tblPeople.scrollsToTop = true
        
//        tblPlaceLeft.backgroundColor = .blue
//        tblPlaceRight.backgroundColor = .green
//        tblPeople.backgroundColor = .red
    }
    
    fileprivate func addPullToRefresh() {
        tblPlaceLeft.addPullRefresh { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                if let locToSearch = LocManager.shared.locToSearch_board {
                    self?.viewModelCategories.location = locToSearch
                } else {
                    self?.viewModelCategories.location = LocManager.shared.curtLoc.coordinate
                }
            })
        }
        tblPlaceRight.addPullRefresh { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                if let locToSearch = LocManager.shared.locToSearch_board {
                    self?.viewModelPlaces.location = locToSearch
                } else {
                    self?.viewModelPlaces.location = LocManager.shared.curtLoc.coordinate
                }
            })
        }
        tblPeople.addPullRefresh { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                if let locToSearch = LocManager.shared.locToSearch_board {
                    self?.viewModelPeople.location = locToSearch
                } else {
                    self?.viewModelPeople.location = LocManager.shared.curtLoc.coordinate
                }
            })
        }
    }
    
    // each time change the table mode (click the button in drop menu), call setViewContent()
    fileprivate func setViewContent() {
        if tableMode == .places {
            uiviewPlaceTab.isHidden = false
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            btnSearchLoc.tag = 0
            
            tblPeople.isHidden = true
            if placeTableMode == .left {
                tblPlaceLeft.isHidden = false
                tblPlaceRight.isHidden = true
            } else {
                tblPlaceLeft.isHidden = true
                tblPlaceRight.isHidden = false
            }
        } else {
            uiviewPlaceTab.isHidden = true
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_curtLoc")
            btnSearchLoc.tag = 1
            
            tblPeople.isHidden = false
            tblPlaceLeft.isHidden = true
            tblPlaceRight.isHidden = true
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        
        return tapRecognizer
    }
    
    // MARK: - Button actions
    @objc func actionLeftWindowShow(_ sender: UIButton) {
        let leftMenuVC = SideMenuViewController()
        leftMenuVC.delegate = self
        leftMenuVC.displayName = Key.shared.nickname
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        present(leftMenuVC, animated: false, completion: nil)
    }
    
    // function for drop down menu button, to show / hide the drop down menu
    @objc func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            showDropDownMenu()
            
            btnNavBarMenu.setAttributedTitle(nil, for: .normal)
            btnNavBarMenu.setTitle("Choose a Board...", for: .normal)
            
            navBarMenuBtnClicked = true
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
        default: return
        }
        
        btnNavBarSetTitle()
        getCurtTableMode()
        hideDropDownMenu()
        setViewContent()
    }
    
    // MARK: - Animations
    fileprivate func showDropDownMenu() {
        uiviewDropDownMenu.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = 65 + device_offset_top
        })
    }
    
    fileprivate func hideDropDownMenu() {
        btnNavBarSetTitle()
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36 + device_offset_top
        }, completion: { _ in
            self.uiviewDropDownMenu.isHidden = true
        })
        
        navBarMenuBtnClicked = false
    }
    
    // get current table mode: social / people / places / talk
    fileprivate func getCurtTableMode() {
        if curtTitle == "People" {
            tableMode = .people
        } else if curtTitle == "Places" {
            tableMode = .places
        }
    }
    
//    func reloadTableMapBoard() {
//        tblMapBoard.reloadData()
//        tblMapBoard.layoutIfNeeded()
//        tblMapBoard.setContentOffset(CGPoint.zero, animated: false)
//    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
    
    // MARK: - LeftSlidingMenuDelegate
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        navigationController?.pushViewController(moodAvatarVC, animated: true)
    }
    func jumpToCollections() {
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
            SideMenuViewController.boolMapBoardIsOn = false
        }
    }
}
