//
//  MapFilterMenuMenu.swift
//  faeBeta
//
//  Created by Vicky on 7/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol MapFilterMenuDelegate: class {
    func autoReresh(isOn: Bool)
    func autoCyclePins(isOn: Bool)
    func hideAvatars(isOn: Bool)
    func showSavedPins(type: String, savedPinIds: [Int])
}

class FMFilterMenu: UIView, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: MapFilterMenuDelegate?
    
    var btnFilterIcon = FMFilterIcon()
    var uiviewMapOpt: UIView!
    var uiviewPlaceLoc: UIView!
    var btnDiscovery: UIButton!
    var btnHideMFMenu: UIButton!
    var lblDiscovery: UILabel!
    var lblRefresh: UILabel!
    var lblCyclePins: UILabel!
    var lblHideAvatars: UILabel!
    var switchRefresh: UISwitch!
    var switchCyclePins: UISwitch!
    var switchHideAvatars: UISwitch!
    var pageMapOptions: UIPageControl!
    var scrollViewFilterMenu: UIScrollView!
    var btnPlaceLoc: UIButton!
    var curtTitle: String = "Choose a Collection..."
    var uiviewBubbleHint: UIView!
    var tblPlaceLoc: UITableView!
    
    
    var imgTick: UIImageView!
    var uiviewDropDownMenu: UIView!
    var tblCollections: UITableView!
    var btnPlaces: UIButton!
    var btnLocations: UIButton!
    var lblPlaces: UILabel!
    var lblLocations: UILabel!
    var countPlaces: Int = 0
    var countLocations: Int = 0
    var navBarMenuBtnClicked: Bool = false
    var arrPlaces = [PinCollection]()
    var arrLocations = [PinCollection]()
    
    let faeCollection = FaeCollection()
    var tableMode: CollectionTableMode = .place
    var arrListThatSavedThisPin = [Int]() {
        didSet {
            guard fullLoaded else { return }
            guard arrListThatSavedThisPin.count > 0 else { return }
            tblPlaceLoc.reloadData()
        }
    }
    var fullLoaded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        loadCollectionData()
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCollectionData() {
        faeCollection.getCollections {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let collections = JSON(message!)
                guard let colArray = collections.array else {
                    print("[loadCollectionData] fail to parse collections info")
                    return
                }
                
                self.arrPlaces.removeAll()
                self.arrLocations.removeAll()
                for col in colArray {
                    let data = PinCollection(json: col)
                    if data.colType == "place" {
                        self.arrPlaces.append(data)
                    }
                    if data.colType == "location" {
                        self.arrLocations.append(data)
                    }
                }
                self.countPlaces = self.arrPlaces.count
                self.countLocations = self.arrLocations.count
                self.tblPlaceLoc.reloadData()
            } else {
                print("[Get Collections] Fail to Get \(status) \(message!)")
            }
        }
    }
    
    fileprivate func setUpUI() {
        backgroundColor = .white
        // draw header & footer
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        topLine.backgroundColor = UIColor._200199204()
        addSubview(topLine)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 433 * screenHeightFactor, width: screenWidth, height: 1))
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        
        // draw downArraw button
        let imgDownArrow = UIImageView(frame: CGRect(x: (screenWidth-36)/2, y: 0, width: 36, height: 30))
        imgDownArrow.image = #imageLiteral(resourceName: "mapFilterMenuArrow")
        imgDownArrow.contentMode = .center
        addSubview(imgDownArrow)
        
        
        // draw fake button to hide map filter menu
        btnHideMFMenu = UIButton(frame: CGRect(x: 0, y: 0, w: 414, h: 66))
        btnHideMFMenu.addTarget(self, action: #selector(self.hide(_:)), for: .touchUpInside)
        addSubview(btnHideMFMenu)
        
        // draw two uiview of Map Options
        uiviewMapOpt = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 405))
        
        uiviewPlaceLoc = UIView(frame: CGRect(x: 414, y: 0, w: 414, h: 405))
        
        scrollViewFilterMenu = UIScrollView(frame: CGRect(x: 0, y: 28, w: 414, h: 405))
        scrollViewFilterMenu.delegate = self
        scrollViewFilterMenu.isPagingEnabled = true
        scrollViewFilterMenu.showsHorizontalScrollIndicator = false
        scrollViewFilterMenu.addSubview(uiviewMapOpt)
        scrollViewFilterMenu.addSubview(uiviewPlaceLoc)
        scrollViewFilterMenu.contentSize = CGSize(width: screenWidth * 2, height: 405 * screenHeightFactor)
        addSubview(scrollViewFilterMenu)
        
        // draw two dots - page control
        pageMapOptions = UIPageControl(frame: CGRect(x: 0, y: 448 * screenHeightFactor, width: screenWidth, height: 8))
        pageMapOptions.numberOfPages = 2
        pageMapOptions.currentPage = 0
        pageMapOptions.pageIndicatorTintColor = UIColor._182182182()
        pageMapOptions.currentPageIndicatorTintColor = UIColor._2499090()
        pageMapOptions.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        addSubview(pageMapOptions)
        
        loadView1()
        loadView2()
    }
    
    func loadView1() {
        // draw "Map Options"
        let lblMapOptions = UILabel(frame: CGRect(x: (screenWidth-250)/2, y: 0, width: 250, height: 27 * screenHeightFactor))
        lblMapOptions.text = "Map Options"
        lblMapOptions.textAlignment = .center
        lblMapOptions.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        lblMapOptions.textColor = UIColor._898989()
        uiviewMapOpt.addSubview(lblMapOptions)
        
        let lineBelowTitle = UIView(frame: CGRect(x: 0, y: 36 * screenHeightFactor, width: screenWidth, height: 1))
        lineBelowTitle.backgroundColor = UIColor._200199204()
        uiviewMapOpt.addSubview(lineBelowTitle)
        
        // draw "Map Type"
        let lblMapType = UILabel(frame: CGRect(x: 30, y: 54, w: 100, h: 25))
        lblMapType.text = "Map Type"
        lblMapType.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblMapType.textColor = UIColor._898989()
        uiviewMapOpt.addSubview(lblMapType)
        
        // draw Discovery button
        btnDiscovery = UIButton(frame: CGRect(x: 0, y: 94, w: 138, h: 90))
        btnDiscovery.center.x = screenWidth / 2
        btnDiscovery.setImage(#imageLiteral(resourceName: "mapFilterDiscovery"), for: .normal)
        btnDiscovery.addTarget(self, action: #selector(self.switchBetweenDisAndSocial(_:)), for: .touchUpInside)
        uiviewMapOpt.addSubview(btnDiscovery)
        
        // draw "Discovery" label
        lblDiscovery = UILabel(frame: CGRect(x: 0, y: 191, w: 100, h: 19))
        lblDiscovery.center.x = screenWidth / 2
        lblDiscovery.text = "Discovery"
        lblDiscovery.textAlignment = .center
        lblDiscovery.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        lblDiscovery.textColor = UIColor._2499090()
        uiviewMapOpt.addSubview(lblDiscovery)
        
        // draw three labels - "Auto Refresh", "Auto Cycle Pins", "Show Avatars"
        lblRefresh = UILabel(frame: CGRect(x: 30, y: 235, w: 159, h: 25))
        lblRefresh.text = "Auto Refresh"
        lblRefresh.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblRefresh.textColor = UIColor._115115115()
        uiviewMapOpt.addSubview(lblRefresh)
        
        lblCyclePins = UILabel(frame: CGRect(x: 30, y: 289, w: 150, h: 25))
        lblCyclePins.text = "Auto Cycle Pins"
        lblCyclePins.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblCyclePins.textColor = UIColor._115115115()
        uiviewMapOpt.addSubview(lblCyclePins)
        
        lblHideAvatars = UILabel(frame: CGRect(x: 30, y: 342, w: 150, h: 25))
        lblHideAvatars.text = "Hide Avatars"
        lblHideAvatars.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblHideAvatars.textColor = UIColor._146146146()
        uiviewMapOpt.addSubview(lblHideAvatars)
        
        // draw three Switch buttons
        switchRefresh = UISwitch()
        switchRefresh.onTintColor = UIColor._2499090()
        switchRefresh.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchRefresh.addTarget(self, action: #selector(self.switchAutoRefresh(_:)), for: .valueChanged)
        switchRefresh.isOn = true
        uiviewMapOpt.addSubview(switchRefresh)
        addConstraintsWithFormat("H:[v0(39)]-\(26*screenWidthFactor)-|", options: [], views: switchRefresh)
        addConstraintsWithFormat("V:|-\(232*screenHeightFactor)-[v0(23)]", options: [], views: switchRefresh)
        
        switchCyclePins = UISwitch()
        switchCyclePins.onTintColor = UIColor._2499090()
        switchCyclePins.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchCyclePins.addTarget(self, action: #selector(self.switchAutoCyclePins(_:)), for: .valueChanged)
        switchCyclePins.isOn = true
        uiviewMapOpt.addSubview(switchCyclePins)
        addConstraintsWithFormat("H:[v0(39)]-\(26*screenWidthFactor)-|", options: [], views: switchCyclePins)
        addConstraintsWithFormat("V:|-\(286*screenHeightFactor)-[v0(23)]", options: [], views: switchCyclePins)
        
        switchHideAvatars = UISwitch()
        switchHideAvatars.onTintColor = UIColor._2499090()
        switchHideAvatars.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchHideAvatars.addTarget(self, action: #selector(self.switchShowAvatars(_:)), for: .valueChanged)
        switchHideAvatars.isOn = false
        uiviewMapOpt.addSubview(switchHideAvatars)
        addConstraintsWithFormat("H:[v0(39)]-\(26*screenWidthFactor)-|", options: [], views: switchHideAvatars)
        addConstraintsWithFormat("V:|-\(339*screenHeightFactor)-[v0(23)]", options: [], views: switchHideAvatars)
    }
    
    func loadView2() {
        let uiviewMyList = UIView(frame: CGRect(x: 0, y: 36, w: 414, h: 27))
        uiviewMyList.backgroundColor = UIColor._248248248()
        uiviewPlaceLoc.addSubview(uiviewMyList)
        
        let lblMyList = UILabel(frame: CGRect(x: 15, y: 4, w: 60, h: 20))
        lblMyList.text = "My Lists"
        lblMyList.textColor = UIColor._155155155()
        lblMyList.font = UIFont(name: "AvenirNext-DemiBold", size: 15 * screenHeightFactor)
        uiviewMyList.addSubview(lblMyList)
        
        let firstLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        firstLine.backgroundColor = UIColor._200199204()
        uiviewMyList.addSubview(firstLine)
        
        let secLine = UIView()
        secLine.backgroundColor = UIColor._200199204()
        uiviewMyList.addSubview(secLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: secLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: secLine)
        
        uiviewBubbleHint = UIView(frame: CGRect(x: 0, y: 63, w: 414, h: 342))
        uiviewPlaceLoc.addSubview(uiviewBubbleHint)
        
        let imgBubble = UIImageView(frame: CGRect(x: 0, y: 51, w: 260, h: 212))
        imgBubble.center.x = screenWidth / 2
        imgBubble.image = #imageLiteral(resourceName: "mb_bubbleHint")
        uiviewBubbleHint.addSubview(imgBubble)
        
        let lblBubbleHint = UILabel(frame: CGRect(x: 20, y: 10, w: 220, h: 75))
        lblBubbleHint.text = "You don't have any lists \nto show! Let's go create \na List in Collections."
        lblBubbleHint.lineBreakMode = .byTruncatingTail
        lblBubbleHint.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblBubbleHint.textColor = UIColor._898989()
        lblBubbleHint.numberOfLines = 0
        imgBubble.addSubview(lblBubbleHint)
        
        tblPlaceLoc = UITableView(frame: CGRect(x: 0, y: 63, w: 414, h: 342))
        tblPlaceLoc.delegate = self
        tblPlaceLoc.dataSource = self
        tblPlaceLoc.separatorStyle = .none
        tblPlaceLoc.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        uiviewPlaceLoc.addSubview(tblPlaceLoc)
        
        uiviewBubbleHint.isHidden = true
        
        loadDropDownMenu()
        
        // button "Places" & "Locations"
        btnPlaceLoc = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36 * screenHeightFactor + 1))
        btnPlaceLoc.center.x = screenWidth / 2
        btnPlaceLoc.backgroundColor = .white
        uiviewPlaceLoc.addSubview(btnPlaceLoc)
        btnPlaceLoc.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        btnPlaceLoc.setTitle(curtTitle, for: .normal)
        btnPlaceLoc.setTitleColor(UIColor._898989(), for: .normal)
        btnPlaceLoc.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        
        let line = UIView(frame: CGRect(x: 0, y: 36 * screenHeightFactor, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        btnPlaceLoc.addSubview(line)
    }
    
    fileprivate func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 36 * screenHeightFactor + 1, width: screenWidth, height: 102))
        uiviewDropDownMenu.backgroundColor = .white
        uiviewPlaceLoc.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = 36 * screenHeightFactor - 101
        uiviewDropDownMenu.isHidden = true
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 101, width: screenWidth, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor._200199204()
        
        btnPlaces = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnPlaces)
        btnPlaces.tag = 0
        btnPlaces.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnLocations = UIButton(frame: CGRect(x: 0, y: 51, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnLocations)
        btnLocations.tag = 1
        btnLocations.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        lblPlaces = FaeLabel(CGRect(x: 104, y: 16, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnPlaces.addSubview(lblPlaces)
        
        lblLocations = FaeLabel(CGRect(x: 104, y: 16, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnLocations.addSubview(lblLocations)
        
        let imgPlaces = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgPlaces.image = #imageLiteral(resourceName: "collection_places")
        imgPlaces.contentMode = .center
        btnPlaces.addSubview(imgPlaces)
        
        let imgLocations = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgLocations.image = #imageLiteral(resourceName: "collection_locations")
        imgLocations.contentMode = .center
        btnLocations.addSubview(imgLocations)
        
        // imgTick.frame.origin.y = 20, 70, 120, 168
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
        
        let uiviewDropMenuFirstLine = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuFirstLine)
        uiviewDropMenuFirstLine.backgroundColor = UIColor._206203203()
        
        updateCount()
    }
    
    fileprivate func updateCount() {
        countPlaces = arrPlaces.count
        let attributedStr1 = NSMutableAttributedString()
        let strPlaces = NSAttributedString(string: "Places ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        let countP = NSAttributedString(string: "(\(countPlaces))", attributes: [NSForegroundColorAttributeName : UIColor._155155155()])
        attributedStr1.append(strPlaces)
        attributedStr1.append(countP)
        lblPlaces.attributedText = attributedStr1
        
        countLocations = arrLocations.count
        let attributedStr2 = NSMutableAttributedString()
        let strLocations = NSAttributedString(string: "Locations ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        let countL = NSAttributedString(string: "(\(countLocations))", attributes: [NSForegroundColorAttributeName : UIColor._155155155()])
        attributedStr2.append(strLocations)
        attributedStr2.append(countL)
        lblLocations.attributedText = attributedStr2
    }
    
    func setView2CurtTitle() {
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)!, NSForegroundColorAttributeName: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnPlaceLoc.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    fileprivate func hideDropDownMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = 36 * screenHeightFactor - 101
        }, completion: { _ in
            self.uiviewDropDownMenu.isHidden = true
        })
        
        navBarMenuBtnClicked = false
    }
    
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            uiviewDropDownMenu.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 36 * screenHeightFactor + 1
            })
            navBarMenuBtnClicked = true
        } else {
            hideDropDownMenu()
        }
        updateCount()
    }
    
    // function for buttons in drop down menu
    func dropDownMenuAct(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            curtTitle = "Places"
            tableMode = .place
            imgTick.frame.origin.y = 20
            break
        case 1:
            curtTitle = "Locations"
            tableMode = .location
            imgTick.frame.origin.y = 70
            break
        default:
            return
        }
        hideDropDownMenu()
        setView2CurtTitle()
        tblPlaceLoc.reloadData()
    }
    
    func changePage(_ sender: Any?) {
        scrollViewFilterMenu.contentOffset.x = screenWidth * CGFloat(pageMapOptions.currentPage)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollViewFilterMenu {
            pageMapOptions.currentPage = scrollView.contentOffset.x == 0 ? 0 : 1
        }
    }
    
    func switchBetweenDisAndSocial(_ sender: UIButton) {
    }
    
    func switchAutoRefresh(_ sender: UISwitch) {
        if switchRefresh.isOn {
            lblRefresh.textColor = UIColor._115115115()
            delegate?.autoReresh(isOn: true)
        } else {
            lblRefresh.textColor = UIColor._146146146()
            delegate?.autoReresh(isOn: false)
        }
    }
    
    func switchAutoCyclePins(_ sender: UISwitch) {
        if switchCyclePins.isOn {
            lblCyclePins.textColor = UIColor._115115115()
            delegate?.autoCyclePins(isOn: true)
        } else {
            lblCyclePins.textColor = UIColor._146146146()
            delegate?.autoCyclePins(isOn: false)
        }
    }
    
    func switchShowAvatars(_ sender: UISwitch) {
        if switchHideAvatars.isOn {
            lblHideAvatars.textColor = UIColor._115115115()
            delegate?.hideAvatars(isOn: true)
        } else {
            lblHideAvatars.textColor = UIColor._146146146()
            delegate?.hideAvatars(isOn: false)
        }
    }
    
    func hide(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = screenHeight
            if self.btnFilterIcon.center.y < screenHeight - 25 {
                self.btnFilterIcon.center.y = screenHeight - 25
            }
        })
    }
    
    // MARK - TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableMode == .place ? arrPlaces.count : arrLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPlaceLoc.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
        let collection = tableMode == .place ? arrPlaces[indexPath.row] : arrLocations[indexPath.row]
        let isSavedInThisList = arrListThatSavedThisPin.contains(collection.colId)
        cell.setValueForCell(cols: collection, isIn: isSavedInThisList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let colInfo = tableMode == .place ? arrPlaces[indexPath.row] : arrLocations[indexPath.row]
        FaeCollection.shared.getOneCollection(String(colInfo.colId)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let arrLocPinId = resultJson["pins"].arrayValue
            let arrSavedPinIds = arrLocPinId.map({ $0["pin_id"].intValue })
            self.delegate?.showSavedPins(type: colInfo.colType, savedPinIds: arrSavedPinIds)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
}
