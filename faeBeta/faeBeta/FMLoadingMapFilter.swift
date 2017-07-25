//
//  FMLoadingMapFilter.swift
//  MapFilterIcon
//
//  Created by Yue on 1/24/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func loadMapFilter() {
        guard FILTER_ENABLE else { return }
        
        btnMapFilter = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        btnMapFilter.center.x = screenWidth / 2
        btnMapFilter.center.y = screenHeight - 25
        btnMapFilter.setImage(#imageLiteral(resourceName: "mapFilterHexagon"), for: .normal)
    
        btnMapFilter.adjustsImageWhenDisabled = false
        btnMapFilter.adjustsImageWhenHighlighted = false
        btnMapFilter.clipsToBounds = true
        btnMapFilter.layer.zPosition = 601
        self.view.addSubview(btnMapFilter)
//        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
//        self.btnMapFilter.addGestureRecognizer(draggingGesture)
    }
}
    
    /*
    var filterPinStatusDic = [String: MFilterButton]() // Filter data processing
    var filterPinTypeDic = [String: MFilterButton]() // Filter data processing
    var filterPlaceDic = [String: MFilterButton]() // Filter data processing
    var uiviewFilterMenu: UIView! // Filter Menu
    var btnDraggingMenu: UIButton! // Filter Menu
    var btnMFilterBeauty: MFilterButton! // Filter Item
    var btnMFilterCafe: MFilterButton! // Filter Item
    var btnMFilterChats: MFilterButton! // Filter Item
    var btnMFilterCinema: MFilterButton! // Filter Item
    var btnMFilterComments: MFilterButton! // Filter Item
    var btnMFilterDessert: MFilterButton! // Filter Item
    var btnMFilterDistance: MFilterButton! // Filter Item
    var btnMFilterGallery: MFilterButton! // Filter Item
    var btnMFilterHot: MFilterButton! // Filter Item
    var btnMFilterMyPins: MFilterButton! // Filter Item
    var btnMFilterNew: MFilterButton! // Filter Item
    var btnMFilterPeople: MFilterButton! // Filter Item
    var btnMFilterPlacesAll: MFilterButton! // Filter Item
    var btnMFilterRead: MFilterButton! // Filter Item
    var btnMFilterRestr: MFilterButton! // Filter Item
    var btnMFilterSavedLoc: MFilterButton! // Filter Item
    var btnMFilterSavedPins: MFilterButton! // Filter Item
    var btnMFilterSavedPlaces: MFilterButton! // Filter Item
    var btnMFilterShowAll: MFilterButton! // Filter Item
    var btnMFilterSports: MFilterButton! // Filter Item
    var btnMFilterStatusAll: MFilterButton! // Filter Item
    var btnMFilterStories: MFilterButton! // Filter Item
    var btnMFilterTypeAll: MFilterButton! // Filter Item
    var btnMFilterUnread: MFilterButton! // Filter Item
    
    fileprivate func loadFilterMenu() {
//        let viewFilterMenu = MapFilterMenu(frame: CGRect(x: 0, y: screenHeight - 470, width: screenWidth, height: 470))
//        self.view.addSubview(viewFilterMenu)
//        viewFilterMenu.layer.zPosition = 700
        
        uiviewFilterMenu = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 700))
        uiviewFilterMenu.backgroundColor = UIColor.white
        uiviewFilterMenu.layer.zPosition = 600
        self.view.addSubview(uiviewFilterMenu)

        let imgMenuArrow = UIImageView(frame: CGRect(x: 0, y: 11 * screenHeightFactor, width: 16 * screenHeightFactor, height: 8 * screenHeightFactor))
        imgMenuArrow.center.x = screenWidth / 2
        imgMenuArrow.image = #imageLiteral(resourceName: "mapFilterMenuArrow")
        imgMenuArrow.contentMode = .scaleAspectFit
        uiviewFilterMenu.addSubview(imgMenuArrow)

        let lblMenuTitle = UILabel(frame: CGRect(x: 0, y: 29 * screenHeightFactor, width: 250, height: 27 * screenHeightFactor))
        lblMenuTitle.center.x = screenWidth / 2
        lblMenuTitle.text = "Map Filters"
        lblMenuTitle.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        lblMenuTitle.textAlignment = .center
        lblMenuTitle.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewFilterMenu.addSubview(lblMenuTitle)

        let btnMenuDragging = UIButton(frame: CGRect(x: -1, y: 0, width: screenWidth+2, height: 66 * screenHeightFactor))
        btnMenuDragging.backgroundColor = UIColor.clear
        btnMenuDragging.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        btnMenuDragging.layer.borderWidth = 1
        btnMenuDragging.addTarget(self, action: #selector(self.actionHideFilterMenu(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMenuDragging)
        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesMenuDragging(_:)))
        btnMenuDragging.addGestureRecognizer(draggingGesture)
        loadFilterItemTitles()
        loadFilterItems()
    }
    
    // Item collection titles
    
    fileprivate func loadFilterItemTitles() {
        let lblGeneral = MFilterLabel(frame: CGRect(x: 25, y: 86, width: 89, height: 22))
        lblGeneral.text = "General"
        uiviewFilterMenu.addSubview(lblGeneral)
        
        let lblPinType = MFilterLabel(frame: CGRect(x: 25, y: 163, width: 89, height: 22))
        lblPinType.text = "Pins"
        uiviewFilterMenu.addSubview(lblPinType)
        
        let lblPinStatus = MFilterLabel(frame: CGRect(x: 25, y: 240, width: 89, height: 22))
        lblPinStatus.text = "Pin Status"
        uiviewFilterMenu.addSubview(lblPinStatus)
        
        let lblPlaces = MFilterLabel(frame: CGRect(x: 25, y: 317, width: 89, height: 22))
        lblPlaces.text = "Places"
        uiviewFilterMenu.addSubview(lblPlaces)
        
        let lblCollections = MFilterLabel(frame: CGRect(x: 25, y: 429, width: 89, height: 22))
        lblCollections.text = "Collections"
        uiviewFilterMenu.addSubview(lblCollections)
    }
    
    fileprivate func loadFilterItems() {
        loadMFilterGeneral()
        loadMFilterPinType()
        loadMFilterPinStatus()
        loadMFilterPlaces()
        loadMFilterCollections()
    }
    
    fileprivate func loadMFilterGeneral() {
        btnMFilterShowAll = MFilterButton(frame: CGRect(x: 50, y: 118, width: 78, height: 25))
        btnMFilterShowAll.setTitle("Show All", for: .normal)
        btnMFilterShowAll.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterShowAll)
        btnMFilterShowAll.filterType = .showAll
        
        btnMFilterDistance = MFilterButton(frame: CGRect(x: 153, y: 118, width: 80, height: 25))
        btnMFilterDistance.setTitle("Distance", for: .normal)
        btnMFilterDistance.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterDistance)
        btnMFilterDistance.filterType = .distance
        
        btnMFilterPeople = MFilterButton(frame: CGRect(x: 255, y: 118, width: 65, height: 25))
        btnMFilterPeople.setTitle("People", for: .normal)
        btnMFilterPeople.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterPeople)
        btnMFilterPeople.filterType = .people
    }
    
    fileprivate func loadMFilterPinType() {
        btnMFilterTypeAll = MFilterButton(frame: CGRect(x: 50, y: 195, width: 29, height: 25))
        btnMFilterTypeAll.setTitle("All", for: .normal)
        btnMFilterTypeAll.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterTypeAll)
        btnMFilterTypeAll.filterType = .pinAll
        
        btnMFilterComments = MFilterButton(frame: CGRect(x: 102, y: 195, width: 98, height: 25))
        btnMFilterComments.setTitle("Comments", for: .normal)
        btnMFilterComments.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterComments)
        btnMFilterComments.filterType = .comment
        
        btnMFilterChats = MFilterButton(frame: CGRect(x: 222, y: 195, width: 57, height: 25))
        btnMFilterChats.setTitle("Chats", for: .normal)
        btnMFilterChats.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterChats)
        btnMFilterChats.filterType = .chat_room
        
        btnMFilterStories = MFilterButton(frame: CGRect(x: 299, y: 195, width: 64, height: 25))
        btnMFilterStories.setTitle("Stories", for: .normal)
        btnMFilterStories.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterStories)
        btnMFilterStories.filterType = .media
    }
    
    fileprivate func loadMFilterPinStatus() {
        btnMFilterStatusAll = MFilterButton(frame: CGRect(x: 50, y: 272, width: 29, height: 25))
        btnMFilterStatusAll.setTitle("All", for: .normal)
        btnMFilterStatusAll.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterStatusAll)
        btnMFilterStatusAll.filterType = .statusAll
        
        btnMFilterHot = MFilterButton(frame: CGRect(x: 102, y: 272, width: 37, height: 25))
        btnMFilterHot.setTitle("Hot", for: .normal)
        btnMFilterHot.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterHot)
        btnMFilterHot.filterType = .hot
        
        btnMFilterNew = MFilterButton(frame: CGRect(x: 162, y: 272, width: 45, height: 25))
        btnMFilterNew.setTitle("New", for: .normal)
        btnMFilterNew.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterNew)
        btnMFilterNew.filterType = .new
        
        btnMFilterUnread = MFilterButton(frame: CGRect(x: 230, y: 272, width: 68, height: 25))
        btnMFilterUnread.setTitle("Unread", for: .normal)
        btnMFilterUnread.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterUnread)
        btnMFilterUnread.filterType = .unread
        
        btnMFilterRead = MFilterButton(frame: CGRect(x: 321, y: 272, width: 49, height: 25))
        btnMFilterRead.setTitle("Read", for: .normal)
        btnMFilterRead.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterRead)
        btnMFilterRead.filterType = .read
    }
    
    fileprivate func loadMFilterPlaces() {
        btnMFilterPlacesAll = MFilterButton(frame: CGRect(x: 50, y: 349, width: 29, height: 25))
        btnMFilterPlacesAll.setTitle("All", for: .normal)
        btnMFilterPlacesAll.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterPlacesAll)
        btnMFilterPlacesAll.filterType = .placeAll
        
        btnMFilterRestr = MFilterButton(frame: CGRect(x: 102, y: 349, width: 102, height: 25))
        btnMFilterRestr.setTitle("Restaurants", for: .normal)
        btnMFilterRestr.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterRestr)
        btnMFilterRestr.filterType = .restaurant
        
        btnMFilterCafe = MFilterButton(frame: CGRect(x: 227, y: 349, width: 45, height: 25))
        btnMFilterCafe.setTitle("Cafe", for: .normal)
        btnMFilterCafe.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterCafe)
        btnMFilterCafe.filterType = .cafe
        
        btnMFilterDessert = MFilterButton(frame: CGRect(x: 295, y: 349, width: 75, height: 25))
        btnMFilterDessert.setTitle("Desserts", for: .normal)
        btnMFilterDessert.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterDessert)
        btnMFilterDessert.filterType = .dessert
        
        btnMFilterCinema = MFilterButton(frame: CGRect(x: 50, y: 384, width: 71, height: 25))
        btnMFilterCinema.setTitle("Cinema", for: .normal)
        btnMFilterCinema.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterCinema)
        btnMFilterCinema.filterType = .cinema
        
        btnMFilterBeauty = MFilterButton(frame: CGRect(x: 144, y: 384, width: 64, height: 25))
        btnMFilterBeauty.setTitle("Beauty", for: .normal)
        btnMFilterBeauty.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterBeauty)
        btnMFilterBeauty.filterType = .beauty
        
        btnMFilterSports = MFilterButton(frame: CGRect(x: 231, y: 384, width: 60, height: 25))
        btnMFilterSports.setTitle("Sports", for: .normal)
        btnMFilterSports.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterSports)
        btnMFilterSports.filterType = .sports
        
        btnMFilterGallery = MFilterButton(frame: CGRect(x: 314, y: 384, width: 66, height: 25))
        btnMFilterGallery.setTitle("Gallery", for: .normal)
        btnMFilterGallery.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterGallery)
        btnMFilterGallery.filterType = .gallery
    }
    
    fileprivate func loadMFilterCollections() {
        btnMFilterMyPins = MFilterButton(frame: CGRect(x: 50, y: 461, width: 70, height: 25))
        btnMFilterMyPins.setTitle("My Pins", for: .normal)
        btnMFilterMyPins.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterMyPins)
        btnMFilterMyPins.filterType = .myPins
        
        btnMFilterSavedPins = MFilterButton(frame: CGRect(x: 143, y: 461, width: 95, height: 25))
        btnMFilterSavedPins.setTitle("Saved Pins", for: .normal)
        btnMFilterSavedPins.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterSavedPins)
        btnMFilterSavedPins.filterType = .savedPins
        
        btnMFilterSavedPlaces = MFilterButton(frame: CGRect(x: 50, y: 496, width: 114, height: 25))
        btnMFilterSavedPlaces.setTitle("Saved Places", for: .normal)
        btnMFilterSavedPlaces.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterSavedPlaces)
        btnMFilterSavedPlaces.filterType = .savedPlaces
        
        btnMFilterSavedLoc = MFilterButton(frame: CGRect(x: 187, y: 496, width: 144, height: 25))
        btnMFilterSavedLoc.setTitle("Saved Locations", for: .normal)
        btnMFilterSavedLoc.addTarget(self, action: #selector(self.actionFilterBtnCtrl(_:)), for: .touchUpInside)
        uiviewFilterMenu.addSubview(btnMFilterSavedLoc)
        btnMFilterSavedLoc.filterType = .savedLocations
    }
}

class MFilterLabel: UILabel {
    
    override init(frame: CGRect) {
        let newFrame = CGRect(origin: CGPoint(x: frame.minX * screenWidthFactor,
                                              y: frame.minY * screenHeightFactor),
                              size: CGSize(width: frame.size.width * screenWidthFactor,
                                           height: frame.size.height * screenHeightFactor))
        
        super.init(frame: newFrame)
        self.font = UIFont(name: "AvenirNext-Medium", size: 16*screenHeightFactor)
        self.textAlignment = .left
        self.textColor = UIColor.faeAppInputTextGrayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MFilterButton: UIButton {
    
    enum MFilterType {
        case showAll
        case distance
        case people
        
        case pinAll
        case comment
        case chat_room
        case media
        
        case statusAll
        case hot
        case new
        case unread
        case read
        
        case placeAll
        case restaurant
        case cafe
        case dessert
        case cinema
        case beauty
        case sports
        case gallery
        
        case myPins
        case savedPins
        case savedPlaces
        case savedLocations
        
        case none
    }
    
    var filterType: MFilterType = .none
    
    override init(frame: CGRect) {
        let newFrame = CGRect(origin: CGPoint(x: frame.minX * screenWidthFactor,
                                              y: frame.minY * screenHeightFactor),
                              size: CGSize(width: frame.size.width * screenWidthFactor,
                                           height: frame.size.height * screenHeightFactor))
        
        super.init(frame: newFrame)
        self.setTitleColor(UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1), for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18*screenHeightFactor)
        self.titleLabel?.textAlignment = .left
        self.tag = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
*/
