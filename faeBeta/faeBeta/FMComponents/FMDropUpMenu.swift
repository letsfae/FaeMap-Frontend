//
//  FMDropUpMenu.swift
//  faeBeta
//
//  Created by Yue Shen on 12/21/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class FMDropUpMenu: UIView, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: MapFilterMenuDelegate?
    
    var imgBackground_sm: UIImageView!
    var imgBackground_lg: UIImageView!
    
    var lblMenuTitle: UILabel!
    
    var btnCollection: UIButton!
    var btnOptions: UIButton!
    
    var sizeFrom: CGFloat = 0 // Pan gesture var
    var sizeTo: CGFloat = 0 // Pan gesture var
    var old_origin_y: CGFloat = 0 // Pan gesture var
    
    var uiviewOptionsContainer: UIView!
    var uiviewCollectionsContainer: UIView!
    
    var btnPlaceLoc: UIButton!
    var curtTitle: String = "Places"
    var uiviewBubbleHint: UIView!
    var tblPlaceLoc: UITableView!
    var selectedIndexPath: IndexPath?
    
    var tblOptions: UITableView!
    
    var imgTick: UIImageView!
    var uiviewDropDownMenu: UIView!
    var btnPlaces: UIButton!
    var btnLocations: UIButton!
    var lblPlaces: UILabel!
    var lblLocations: UILabel!
    var countPlaces: Int = 0
    var countLocations: Int = 0
    var navBarMenuBtnClicked: Bool = false
    //    var arrPlaces = [PinCollection]()
    //    var arrLocations = [PinCollection]()
    var realmColPlaces: Results<RealmCollection>!
    var realmColLocations: Results<RealmCollection>!
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    let faeCollection = FaeCollection()
    var tableMode: CollectionTableMode = .place
    var arrListThatSavedThisPin = [Int]() {
        didSet {
            guard fullLoaded else { return }
            guard arrListThatSavedThisPin.count > 0 else { return }
            tblPlaceLoc.reloadData()
        }
    }
    
    var mode: FaeMode = .off {
        didSet {
            guard fullLoaded else { return }
            lblMenuTitle.isHidden = mode == .off
            uiviewOptionsContainer.isHidden = mode == .off
            uiviewCollectionsContainer.isHidden = mode == .on
        }
    }
    
    var fullLoaded = false
    
    var swipeGes: UISwipeGestureRecognizer!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 170)
        loadContent()
        loadCollectionData()
        observeOnCollectionChange()
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Loading Parts
    
    fileprivate func loadContent() {
        loadBackground()
        loadOptions()
        loadCollection()
        let btnBack = UIButton(frame: CGRect(x: 5, y: 20, width: 9.37 + 26, height: 16.06 + 24))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgBackground_lg.addSubview(btnBack)
        btnBack.addTarget(self, action: #selector(self.smallMode), for: .touchUpInside)
        //let horiPan = UIPanGestureRecognizer(target: self, action: #selector(self.horizontalPan(_:)))
        //self.addGestureRecognizer(horiPan)
        swipeGes = UISwipeGestureRecognizer(target: self, action: #selector(self.smallMode))
        swipeGes.direction = .right
        self.addGestureRecognizer(swipeGes)
        swipeGes.isEnabled = false
    }
    
    fileprivate func loadBackground() {
        imgBackground_lg = UIImageView(frame: CGRect(x: 5 + screenWidth, y: 1, width: screenWidth - 10, height: 420))
        imgBackground_lg.contentMode = .scaleAspectFit
        imgBackground_lg.image = #imageLiteral(resourceName: "main_drop_up_backg_lg")
        addSubview(imgBackground_lg)
        imgBackground_lg.isUserInteractionEnabled = true
        
        imgBackground_sm = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 170))
        imgBackground_sm.contentMode = .scaleAspectFit
        imgBackground_sm.image = #imageLiteral(resourceName: "main_drop_up_backg_sm")
        addSubview(imgBackground_sm)
        imgBackground_sm.isUserInteractionEnabled = true
        
        let lblMapActions = UILabel(frame: CGRect(x: (screenWidth-250)/2, y: 28, width: 250, height: 27 * screenHeightFactor))
        lblMapActions.text = "Map Actions"
        lblMapActions.textAlignment = .center
        lblMapActions.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        lblMapActions.textColor = UIColor._898989()
        imgBackground_sm.addSubview(lblMapActions)
        
        btnCollection = UIButton(frame: CGRect(x: 0, y: 66, width: 61, height: 94))
        btnCollection.frame.origin.x = screenWidth / 2 - 90
        btnCollection.setImage(#imageLiteral(resourceName: "drop_up_collection"), for: .normal)
        imgBackground_sm.addSubview(btnCollection)
        btnCollection.addTarget(self, action: #selector(self.actionMapActions(_:)), for: .touchUpInside)
        
        btnOptions = UIButton(frame: CGRect(x: 0, y: 66, width: 61, height: 94))
        btnOptions.frame.origin.x = screenWidth / 2 + 29
        btnOptions.setImage(#imageLiteral(resourceName: "drop_up_options"), for: .normal)
        imgBackground_sm.addSubview(btnOptions)
        btnOptions.addTarget(self, action: #selector(self.actionMapActions(_:)), for: .touchUpInside)
        
        lblMenuTitle = UILabel(frame: CGRect(x: (screenWidth-250)/2, y: 28, width: 250, height: 27 * screenHeightFactor))
        lblMenuTitle.text = "Map Options"
        lblMenuTitle.textAlignment = .center
        lblMenuTitle.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        lblMenuTitle.textColor = UIColor._898989()
        imgBackground_lg.addSubview(lblMenuTitle)
    }
    
    fileprivate func loadOptions() {
        
        uiviewOptionsContainer = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 10, height: 420))
        imgBackground_lg.addSubview(uiviewOptionsContainer)
        
        tblOptions = UITableView(frame: CGRect(x: 5, y: 65.5, width: screenWidth - 20, height: 410 - 66.5))
        tblOptions.delegate = self
        tblOptions.dataSource = self
        tblOptions.separatorStyle = .none
        tblOptions.register(DropUpMenuOptionsCell.self, forCellReuseIdentifier: "dropUpOptionsCell")
        uiviewOptionsContainer.addSubview(tblOptions)
        tblOptions.layer.cornerRadius = 12
    }
    
    func loadCollectionData() {
        realmColPlaces = RealmCollection.filterCollectedTypes(type: "place")
        realmColLocations = RealmCollection.filterCollectedTypes(type: "location")
    }
    
    fileprivate func loadCollection() {
        uiviewCollectionsContainer = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 420))
        imgBackground_lg.addSubview(uiviewCollectionsContainer)
        
        let uiviewMyList = UIView(frame: CGRect(x: 5, y: 64, width: screenWidth - 20, height: 27))
        uiviewMyList.backgroundColor = UIColor._248248248()
        uiviewCollectionsContainer.addSubview(uiviewMyList)
        
        let lblMyList = UILabel(frame: CGRect(x: 15, y: 4, width: 60, height: 20))
        lblMyList.text = "My Lists"
        lblMyList.textColor = UIColor._155155155()
        lblMyList.font = UIFont(name: "AvenirNext-DemiBold", size: 15 * screenHeightFactor)
        uiviewMyList.addSubview(lblMyList)
        
        let firstLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 1))
        firstLine.backgroundColor = UIColor._200199204()
        uiviewMyList.addSubview(firstLine)
        
        let secLine = UIView()
        secLine.backgroundColor = UIColor._225225225()
        uiviewMyList.addSubview(secLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: secLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: secLine)
        
        uiviewBubbleHint = UIView(frame: CGRect(x: 0, y: 63, w: 414, h: 342))
        uiviewCollectionsContainer.addSubview(uiviewBubbleHint)
        
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
        
        tblPlaceLoc = UITableView(frame: CGRect(x: 5, y: 91, width: screenWidth - 20, height: 410 - 92))
        tblPlaceLoc.delegate = self
        tblPlaceLoc.dataSource = self
        tblPlaceLoc.separatorStyle = .none
        tblPlaceLoc.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        uiviewCollectionsContainer.addSubview(tblPlaceLoc)
        tblPlaceLoc.layer.cornerRadius = 12
        
        uiviewBubbleHint.alpha = 0
        
        loadDropDownMenu()
        
        // button "Places" & "Locations"
        btnPlaceLoc = UIButton(frame: CGRect(x: 0, y: 28, width: 250, height: 25))
        btnPlaceLoc.center.x = screenWidth / 2
        btnPlaceLoc.backgroundColor = .white
        uiviewCollectionsContainer.addSubview(btnPlaceLoc)
        btnPlaceLoc.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        btnPlaceLoc.setTitleColor(UIColor._898989(), for: .normal)
        btnPlaceLoc.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        setCollectionTitle()
        
        updateCount()
    }
    
    fileprivate func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 5, y: 65, width: screenWidth - 20, height: 0))
        uiviewDropDownMenu.backgroundColor = .white
        uiviewCollectionsContainer.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.isHidden = true
        uiviewDropDownMenu.clipsToBounds = true
        
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
        
        lblPlaces = FaeLabel(CGRect(x: 104, y: 14, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnPlaces.addSubview(lblPlaces)
        
        lblLocations = FaeLabel(CGRect(x: 104, y: 14, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
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
    }
    
    fileprivate func updateCount() {
        countPlaces = realmColPlaces != nil ? realmColPlaces.count : 0
        let attributedStr1 = NSMutableAttributedString()
        let strPlaces = NSAttributedString(string: "Places ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let countP = NSAttributedString(string: "(\(countPlaces))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr1.append(strPlaces)
        attributedStr1.append(countP)
        lblPlaces.attributedText = attributedStr1
        
        countLocations = realmColLocations != nil ? realmColLocations.count : 0
        let attributedStr2 = NSMutableAttributedString()
        let strLocations = NSAttributedString(string: "Locations ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let countL = NSAttributedString(string: "(\(countLocations))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr2.append(strLocations)
        attributedStr2.append(countL)
        lblLocations.attributedText = attributedStr2
    }
    
    func setCollectionTitle() {
        let curtTitleAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnPlaceLoc.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    fileprivate func hideDropDownMenu(animated: Bool = true) {
        setCollectionTitle()
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.size.height = 0
            }, completion: { _ in
                self.uiviewDropDownMenu.isHidden = true
            })
        } else {
            uiviewDropDownMenu.frame.size.height = 0
            uiviewDropDownMenu.isHidden = true
        }
        navBarMenuBtnClicked = false
    }
    
    @objc func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            btnPlaceLoc.setAttributedTitle(nil, for: .normal)
            btnPlaceLoc.setTitle("Choose a Collection...", for: .normal)
            uiviewDropDownMenu.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.size.height = 120
            })
            navBarMenuBtnClicked = true
        } else {
            hideDropDownMenu()
        }
        updateCount()
    }
    
    // function for buttons in drop down menu
    @objc func dropDownMenuAct(_ sender: UIButton) {
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
        hideDropDownMenu(animated: false)
        setCollectionTitle()
        //        tblPlaceLoc.reloadData()
        observeOnCollectionChange()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblOptions {
            return 92
        }
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblOptions {
            return 3
        }
        return tableMode == .place ? realmColPlaces.count : realmColLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblOptions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dropUpOptionsCell", for: indexPath) as! DropUpMenuOptionsCell
            switch indexPath.row {
            case 0:
                cell.lblTitle.text = "Auto Refresh Map"
                cell.lblDesc.text = "Allow Fae Map to automatically refresh for\nnew pins when moving to a different location."
                cell.switchButton.isOn = Key.shared.autoRefresh
            case 1:
                cell.lblTitle.text = "Auto Cycle Pins"
                cell.lblDesc.text = "Allow Fae Map to automatically cycle pins in\nthe same location when zooming in and out."
                cell.switchButton.isOn = Key.shared.autoCycle
            case 2:
                cell.lblTitle.text = "Hide Map Avatars"
                cell.lblDesc.text = "Hide all Map Avatars on the map. Self Avatar\nis still publicly visible unless you Go Invisible."
                cell.switchButton.isOn = Key.shared.hideAvatars
            default:
                break
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
        let collection = tableMode == .place ? realmColPlaces[indexPath.row] : realmColLocations[indexPath.row]
        let isSavedInThisList = arrListThatSavedThisPin.contains(collection.collection_id)
        cell.setValueForCell(cols: collection, isIn: isSavedInThisList)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblOptions {
            let cell = tableView.cellForRow(at: indexPath) as! DropUpMenuOptionsCell
            switch indexPath.row {
            case 0:
                delegate?.autoReresh?(isOn: !cell.switchButton.isOn)
            case 1:
                delegate?.autoCyclePins?(isOn: !cell.switchButton.isOn)
            case 2:
                delegate?.hideAvatars?(isOn: !cell.switchButton.isOn)
            default:
                break
            }
            cell.switchButton.setOn(!cell.switchButton.isOn, animated: true)
            return
        }
        if let idxPath = selectedIndexPath {
            if let cell = tableView.cellForRow(at: idxPath) as? CollectionsListCell {
                cell.imgIsIn.isHidden = true
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) as? CollectionsListCell {
            cell.imgIsIn.isHidden = false
            selectedIndexPath = indexPath
        }
        let colInfo = tableMode == .place ? realmColPlaces[indexPath.row] : realmColLocations[indexPath.row]
        
        vibrate(type: 4)
        getSavedItems(colInfo: colInfo)
        
        //        self.delegate?.showSavedPins(type: colInfo.type, savedPinIds: arrSavedPinIds, isCollections: true, colName: colInfo.name)
        
        //        FaeCollection.shared.getOneCollection(String(colInfo.collection_id)) { (status, message) in
        //            guard status / 100 == 2 else { return }
        //            guard message != nil else { return }
        //            let resultJson = JSON(message!)
        //            let arrLocPinId = resultJson["pins"].arrayValue
        //        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
    
    func getSavedItems(colInfo: RealmCollection) {
        var arrSavedPinIds = [Int]()
        if colInfo.count == colInfo.pins.count {
            for pin in colInfo.pins {
                arrSavedPinIds.append(pin.pin_id)
            }
            delegate?.showSavedPins(type: colInfo.type, savedPinIds: arrSavedPinIds, isCollections: true, colName: colInfo.name)
            return
        }
        
        if colInfo.pins.count != 0 {
            try! realm.write {
                colInfo.pins.removeAll()
            }
        }
        
        FaeCollection.shared.getOneCollection(String(colInfo.collection_id), completion: { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let arrLocPinId = resultJson["pins"].arrayValue
            
            for pin in arrLocPinId {
                arrSavedPinIds.append(pin["pin_id"].intValue)
                let collectedPin = CollectedPin(value: ["\(Key.shared.user_id)_\(pin["pin_id"].intValue)", Key.shared.user_id, pin["pin_id"].intValue, pin["added_at"].stringValue])
                let realm = try! Realm()
                try! realm.write {
                    realm.add(collectedPin, update: true)
                    colInfo.pins.append(collectedPin)
                }
            }
            
            self.delegate?.showSavedPins(type: colInfo.type, savedPinIds: arrSavedPinIds, isCollections: true, colName: colInfo.name)
        })
    }
    
    private func observeOnCollectionChange() {
        let datasource = tableMode == .place ? realmColPlaces : realmColLocations
        notificationToken?.invalidate()
        notificationToken = datasource?.observe { (changes: RealmCollectionChange) in
            guard let tableview = self.tblPlaceLoc else { return }
            switch changes {
            case .initial:
                tableview.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableview.beginUpdates()
                tableview.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .right)
                tableview.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.endUpdates()
            case .error:
                print("error")
            }
        }
    }
    
    public func panCtrlParaSetting(showed: Bool) {
        if showed {
            sizeFrom = screenHeight - self.frame.size.height - device_offset_bot_main
            sizeTo = screenHeight
        } else {
            sizeFrom = screenHeight
            sizeTo = screenHeight - self.frame.size.height - device_offset_bot_main
        }
    }
    
    @objc func actionMapActions(_ sender: UIButton) {
        if sender == btnCollection {
            mode = .off
        } else {
            mode = .on
        }
        self.frame.origin.y -= 250
        old_origin_y = self.frame.origin.y
        self.frame.size.height = 420
        imgBackground_sm.frame.origin.y += 250
        showLargeBackground()
    }
    
    func showLargeBackground() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.imgBackground_lg.frame.origin.x = 5
            self.imgBackground_sm.frame.origin.x = -screenWidth
        }) { _ in
            self.swipeGes.isEnabled = true
        }
    }
    
    func hideLargeBackground() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.imgBackground_lg.frame.origin.x = 5 + screenWidth
            self.imgBackground_sm.frame.origin.x = 0
        }) { _ in
            self.imgBackground_lg.frame.origin.y = 1
        }
    }
    
    func show() {
        Key.shared.FMVCtrler?.mapGesture(isOn: false)
        Key.shared.FMVCtrler?.animateMainScreenButtons(hide: true, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - 170 - device_offset_bot_main
        }) { _ in
            self.old_origin_y = self.frame.origin.y
        }
    }
    
    func hide() {
        Key.shared.FMVCtrler?.btnDropUpMenu.isSelected = false
        Key.shared.FMVCtrler?.mapGesture(isOn: true)
        Key.shared.FMVCtrler?.animateMainScreenButtons(hide: false, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }) { _ in
            self.smallMode()
        }
    }
    
    @objc public func smallMode() {
        self.frame.origin.y += 250
        old_origin_y = self.frame.origin.y
        self.frame.size.height = 170
        imgBackground_sm.frame.origin.y = 0
        imgBackground_lg.frame.origin.y = -249
        hideLargeBackground()
        hideDropDownMenu(animated: false)
        swipeGes.isEnabled = false
    }
    
    var end: CGFloat = 0
    
    /*
    @objc func horizontalPan(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            end = pan.location(in: self).x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: self)
            let location = pan.location(in: self)
            let distanceMoved = end - location.x
            let percent = distanceMoved / screenWidth
            print("[horizontalPan]", percent)
            resumeTime = abs(Double(CGFloat(distanceMoved) / velocity.x))
            if resumeTime > 0.5 {
                resumeTime = 0.5
            } else if resumeTime < 0.3 {
                resumeTime = 0.3
            }
            let absPercent: CGFloat = 0.1
            if percent < -absPercent {
                UIView.animate(withDuration: resumeTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    
                }, completion: { _ in
                    
                })
            } else if percent > absPercent {
//                panToNext(resumeTime)
            } else {
                UIView.animate(withDuration: resumeTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    
                }, completion: nil)
            }
        } else if pan.state == .changed {
            let translation = pan.translation(in: self)
            imgBackground_sm.center.x = imgBackground_sm.center.x + translation.x
            imgBackground_lg.center.x = imgBackground_lg.center.x + translation.x
            pan.setTranslation(CGPoint.zero, in: self)
        }
    }
    */
}

class DropUpMenuOptionsCell: UITableViewCell {
    
    var lblTitle: FaeLabel!
    var lblDesc: FaeLabel!
    var switchButton: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        lblTitle = FaeLabel(CGRect(x: 20, y: 21, width: 150, height: 22), .left, .medium, 18, UIColor._107105105())
        lblTitle.text = "Auto Refresh Map"
        addSubview(lblTitle)
        
        lblDesc = FaeLabel(CGRect(x: 20, y: 48, width: screenWidth - 60, height: 41), .left, .mediumItalic, 15, UIColor._168168168())
        lblDesc.numberOfLines = 0
        lblDesc.text = "Allow Fae Map to automatically refresh for\nnew pins when moving to a different location."
        addSubview(lblDesc)
        
        switchButton = UISwitch()
        switchButton.onTintColor = UIColor._2499090()
        switchButton.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchButton.isUserInteractionEnabled = false
        addSubview(switchButton)
        addConstraintsWithFormat("H:[v0(39)]-20-|", options: [], views: switchButton)
        addConstraintsWithFormat("V:|-18-[v0(23)]", options: [], views: switchButton)
    }
}
