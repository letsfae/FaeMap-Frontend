//
//  PlaceDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PlaceDetailDelegate: class {
    func getRouteToPin(mode: CollectionTableMode, placeInfo: PlacePin?)
}

enum EnterPlaceLocDetailMode {
    case collection
    case boards
    case map
}

class PlaceDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPinToCollectionDelegate, AfterAddedToListDelegate {
    
    weak var delegate: MapSearchDelegate?
    weak var featureDelegate: PlaceDetailDelegate?
    
    var place: PlacePin!
    var allPlaces = [PlacePin]()
    var uiviewHeader: UIView!
    var uiviewSubHeader: FixedHeader!
    var uiviewFixedHeader: FixedHeader!
    var uiviewScrollingPhotos: InfiniteScrollingView!
    var uiviewFooter: UIView!
    var btnBack: UIButton!
    var btnSave: UIButton!
    var imgSaved: UIImageView!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    var tblPlaceDetail: UITableView!
    let arrTitle = ["Similar Places", "Near this Place"]
    var arrRelatedPlaces = [[PlacePin]]()
    var arrSimilarPlaces = [PlacePin]()
    var arrNearbyPlaces = [PlacePin]()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    var arrListSavedThisPin = [Int]()
    var boolSavedListLoaded = false
    var uiviewWhite: UIView!
    var intHaveHour = 0
    var intHaveWebPhone = 0
    var boolHaveWeb = false
    var intCellCount = 0
    var intSimilar = 0
    var intNearby = 0
    
    var boolShared: Bool = false
    var enterMode: EnterPlaceLocDetailMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadFooter()
        loadHeader()
        loadMidTable()
        loadFixedHeader()
        view.bringSubview(toFront: uiviewSavedList)
        view.bringSubview(toFront: uiviewAfterAdded)
        checkSavedStatus() {}
        setCellCount()
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_placeDetail"), object: nil)
        
        // Joshua: Add this two lines to enable the edge-gesture on the left side of screen
        //         whole table view and cell will automatically disable this
        let uiviewLeftMargin = LeftMarginToEnableNavGestureView()
        view.addSubview(uiviewLeftMargin)
        
        initPlaceRelatedData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideSavedNoti_placeDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PlaceDetailCell.boolFold = true
        if boolShared {
            //uiviewAfterAdded.lblSaved.text = "You shared a Place."
            uiviewAfterAdded.lblSaved.frame = CGRect(x: 20, y: 19, width: 200, height: 25)
            uiviewAfterAdded.btnUndo.isHidden = true
            uiviewAfterAdded.btnSeeList.isHidden = true
            uiviewAfterAdded.show("You shared a Place.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.uiviewAfterAdded.hide()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                self.uiviewAfterAdded.lblSaved.text = "Collocted to List!"
                self.uiviewAfterAdded.lblSaved.frame = CGRect(x: 20, y: 19, width: 150, height: 25)
                self.uiviewAfterAdded.btnUndo.isHidden = false
                self.uiviewAfterAdded.btnSeeList.isHidden = false
            }
            boolShared = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        if tblPlaceDetail.contentOffset.y >= 208 * screenHeightFactor {
            UIApplication.shared.statusBarStyle = .default
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func initPlaceRelatedData() {
        uiviewSubHeader.setValue(place: place)
        uiviewFixedHeader.setValue(place: place)
        tblPlaceDetail.reloadData()
        let lat = String(place.coordinate.latitude)
        let long = String(place.coordinate.longitude)
        getRelatedPlaces(lat, long, isSimilar: true) {
            self.getRelatedPlaces(lat, long, isSimilar: false, {
                self.tblPlaceDetail.reloadData()
            })
        }
    }
    
    func setCellCount() {
        guard place != nil else { return }
        intHaveHour = place.hours.count > 0 ? 1 : 0
        intHaveWebPhone = place.url != "" || place.phone != "" ? 1 : 0
        boolHaveWeb = place.url != ""
        intCellCount = intHaveHour + intHaveWebPhone + 2
    }
    
    func checkSavedStatus(_ completion: @escaping () -> ()) {
        FaeMap.shared.getPin(type: "place", pinId: String(place.id)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            guard let is_saved = resultJson["user_pin_operations"]["is_saved"].string else {
                completion()
                return
            }
            guard is_saved != "false" else {
                completion()
                return
            }
            var ids = [Int]()
            for colIdRaw in is_saved.split(separator: ",") {
                let strColId = String(colIdRaw)
                guard let colId = Int(strColId) else { continue }
                ids.append(colId)
            }
            self.arrListSavedThisPin = ids
            self.uiviewSavedList.arrListSavedThisPin = ids
            self.boolSavedListLoaded = true
            if ids.count != 0 {
                self.showSavedNoti()
            }
            completion()
        }
    }
    
    func getRelatedPlaces(_ lat: String, _ long: String, isSimilar: Bool, _ completion: @escaping () -> Void) {
        if isSimilar {
            arrSimilarPlaces.removeAll()
            FaeSearch.shared.whereKey("content", value: place.class_2 == "" ? place.class_1 : place.class_2)
            FaeSearch.shared.whereKey("source", value: "categories")
            FaeSearch.shared.whereKey("type", value: "place")
            FaeSearch.shared.whereKey("size", value: "20")
            FaeSearch.shared.whereKey("radius", value: "20000")
            FaeSearch.shared.whereKey("offset", value: "0")
            FaeSearch.shared.search { (status, message) in
                guard status / 100 == 2 && message != nil else {
                    //print("Get Related Places Fail \(status) \(message!)")
                    self.intSimilar = self.arrSimilarPlaces.count > 0 ? 1 : 0
                    completion()
                    return
                }
                let json = JSON(message!)
                guard let placeJson = json.array else { return }
                self.arrSimilarPlaces = placeJson.map({ PlacePin(json: $0) })
                self.arrSimilarPlaces = self.arrSimilarPlaces.filter({ $0.id != self.place.id })
                self.intSimilar = self.arrSimilarPlaces.count > 0 ? 1 : 0
                completion()
            }
        } else { // Near this Location
            arrNearbyPlaces.removeAll()
            FaeMap.shared.whereKey("geo_latitude", value: lat)
            FaeMap.shared.whereKey("geo_longitude", value: long)
            FaeMap.shared.whereKey("radius", value: "5000")
            FaeMap.shared.whereKey("type", value: "place")
            FaeMap.shared.whereKey("max_count", value: "20")
            FaeMap.shared.getMapInformation { (status: Int, message: Any?) in
                guard status / 100 == 2 && message != nil else {
                    //print("Get Related Places Fail \(status) \(message!)")
                    self.intNearby = self.arrNearbyPlaces.count > 0 ? 1 : 0
                    completion()
                    return
                }
                let json = JSON(message!)
                guard let placeJson = json.array else { return }
                self.arrNearbyPlaces = placeJson.map({ PlacePin(json: $0) })
                self.arrNearbyPlaces = self.arrNearbyPlaces.filter({ $0.id != self.place.id })
                self.intNearby = self.arrNearbyPlaces.count > 0 ? 1 : 0
                completion()
            }
        }
    }
    
    func loadHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 309 + device_offset_top))
        
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: 208 + device_offset_top, w: 414, h: 101))
        uiviewHeader.addSubview(uiviewSubHeader)
        uiviewSubHeader.setValue(place: place)
    }
    
    func loadFixedHeader() {
        uiviewFixedHeader = FixedHeader(frame: CGRect(x: 0, y: 22, w: 414, h: 101))
        view.addSubview(uiviewFixedHeader)
        uiviewFixedHeader.setValue(place: place)
        uiviewFixedHeader.isHidden = true
        uiviewWhite = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 22))
        uiviewWhite.backgroundColor = .white
        view.addSubview(uiviewWhite)
        uiviewWhite.alpha = 0
    }
    
    func loadMidTable() {
        tblPlaceDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49 - device_offset_bot), style: .plain)
        view.addSubview(tblPlaceDetail)
        tblPlaceDetail.tableHeaderView = uiviewHeader
        
        tblPlaceDetail.delegate = self
        tblPlaceDetail.dataSource = self
        tblPlaceDetail.register(PlaceDetailMapCell.self, forCellReuseIdentifier: "PlaceDetailMapCell")
        tblPlaceDetail.register(PlaceDetailHoursCell.self, forCellReuseIdentifier: "PlaceDetailHoursCell")
        tblPlaceDetail.register(PlaceDetailSection3Cell.self, forCellReuseIdentifier: "PlaceDetailSection3Cell")
        tblPlaceDetail.register(MBPlacesCell.self, forCellReuseIdentifier: "MBPlacesCell")
        tblPlaceDetail.separatorStyle = .none
        tblPlaceDetail.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            tblPlaceDetail.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideAddCollectionView))
        tblPlaceDetail.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        uiviewScrollingPhotos = InfiniteScrollingView(frame: CGRect(x: 0, y: 0, w: 414, h: 208))
        uiviewScrollingPhotos = InfiniteScrollingView(frame: CGRect(x: 0, y: 0, w: 414, h: 208 + device_offset_top))
        tblPlaceDetail.addSubview(uiviewScrollingPhotos)
        let bottomLine = UIView(frame: CGRect(x: 0, y: 208 + device_offset_top, w: 414, h: 1))
        bottomLine.backgroundColor = UIColor._241241241()
        uiviewScrollingPhotos.addSubview(bottomLine)
        uiviewScrollingPhotos.loadImages(place: place)
    }
    
    func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49 - device_offset_bot, width: screenWidth, height: 49 + device_offset_bot))
        view.addSubview(uiviewFooter)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFooter.addSubview(line)
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 1, width: 40.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToMapBoard(_:)), for: .touchUpInside)
        
        btnSave = UIButton(frame: CGRect(x: screenWidth / 2 - 105, y: 2, width: 47, height: 47))
        btnSave.setImage(#imageLiteral(resourceName: "place_save"), for: .normal)
        btnSave.tag = 0
        btnSave.addTarget(self, action: #selector(saveThisPin), for: .touchUpInside)
        
        btnRoute = UIButton(frame: CGRect(x: (screenWidth - 47) / 2, y: 2, width: 47, height: 47))
        btnRoute.setImage(#imageLiteral(resourceName: "place_route"), for: .normal)
        btnRoute.tag = 1
        btnRoute.addTarget(self, action: #selector(routeToThisPin), for: .touchUpInside)
        
        btnShare = UIButton(frame: CGRect(x: screenWidth / 2 + 58, y: 2, width: 47, height: 47))
        btnShare.setImage(#imageLiteral(resourceName: "place_share"), for: .normal)
        btnShare.tag = 2
        btnShare.addTarget(self, action: #selector(shareThisPin), for: .touchUpInside)
        
        uiviewFooter.addSubview(btnBack)
        uiviewFooter.addSubview(btnSave)
        uiviewFooter.addSubview(btnRoute)
        uiviewFooter.addSubview(btnShare)
        
        imgSaved = UIImageView(frame: CGRect(x: 38, y: 14, width: 0, height: 0))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.alpha = 0
        
        loadAddtoCollection()
    }
    
    @objc func showSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 29, y: 5, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc func hideSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 38, y: 14, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }
    
    fileprivate func loadAddtoCollection() {
        uiviewSavedList = AddPinToCollectionView()
        uiviewSavedList.delegate = self
        uiviewSavedList.tableMode = .place
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    var boolAnimateTo_1 = true
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if uiviewScrollingPhotos != nil {
            var frame = uiviewScrollingPhotos.frame
            if tblPlaceDetail.contentOffset.y < 0 {
                frame.origin.y = tblPlaceDetail.contentOffset.y
                uiviewScrollingPhotos.frame = frame
            } else {
                frame.origin.y = 0
                uiviewScrollingPhotos.frame = frame
            }
        }
        if tblPlaceDetail.contentOffset.y >= (186 + device_offset_top) * screenHeightFactor {
            uiviewFixedHeader.isHidden = false
            UIApplication.shared.statusBarStyle = .default
            if boolAnimateTo_1 {
                boolAnimateTo_1 = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.uiviewScrollingPhotos.alpha = 0
                    self.uiviewWhite.alpha = 1
                })
            }
        } else {
            uiviewFixedHeader.isHidden = true
            self.uiviewWhite.alpha = 0
            UIApplication.shared.statusBarStyle = .lightContent
            if boolAnimateTo_1 == false {
                boolAnimateTo_1 = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.uiviewScrollingPhotos.alpha = 1
                })
            }
        }
    }
    
    @objc func backToMapBoard(_ sender: UIButton) {
        let mbIsOn = LeftSlidingMenuViewController.boolMapBoardIsOn
        if mbIsOn {
            Key.shared.initialCtrler?.goToMapBoard(animated: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveThisPin() {
        func showCollections() {
            uiviewSavedList.tableMode = .place
//            uiviewSavedList.loadCollectionData()
            uiviewSavedList.pinToSave = FaePinAnnotation(type: "place", cluster: nil, data: place)
            uiviewSavedList.show()
        }
        if boolSavedListLoaded {
            showCollections()
        } else {
            checkSavedStatus {
                showCollections()
            }
        }
    }
    
    @objc func routeToThisPin() {
        var arrCtrlers = navigationController?.viewControllers
        if let ctrler = Key.shared.FMVCtrler {
            ctrler.arrCtrlers = arrCtrlers!
            ctrler.boolFromMap = false
            ctrler.routingMode = .fromPinDetail
        }
        while !(arrCtrlers?.last is InitialPageController) {
            arrCtrlers?.removeLast()
        }
        featureDelegate = Key.shared.FMVCtrler
        featureDelegate?.getRouteToPin(mode: .place, placeInfo: place)
        Key.shared.initialCtrler?.goToFaeMap(animated: false)
        navigationController?.setViewControllers(arrCtrlers!, animated: false)
    }
    
    @objc func shareThisPin() {
        let vcShareCollection = NewChatShareController(friendListMode: .place)
        vcShareCollection.placeDetail = place
        vcShareCollection.boolFromPlaceDetail = true
        navigationController?.pushViewController(vcShareCollection, animated: true)
    }
    
    func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    @objc func hideAddCollectionView() {
        uiviewSavedList.hide()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideAddCollectionView()
    }
    
    // SeeAllPlacesDelegate
    func jumpToAllPlaces(places: [PlacePin], title: String) {
        let vc = AllPlacesViewController()
        vc.recommendedPlaces = places
        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // AddPintoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
//        vcList.colInfo = uiviewAfterAdded.selectedCollection
//        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
        navigationController?.pushViewController(vcList, animated: true)
    }
    
    // AfterAddedToListDelegate
    func undoCollect(colId: Int, mode: UndoMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        switch mode {
        case .save:
            uiviewSavedList.arrListSavedThisPin.append(colId)
            break
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
            break
        }
        if uiviewSavedList.arrListSavedThisPin.count <= 0 {
            hideSavedNoti()
        } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
            showSavedNoti()
        }
    }
}

class FixedHeader: UIView {
    var lblName: UILabel!
    var lblCategory: UILabel!
    var lblPrice: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        backgroundColor = .white
        
        lblName = UILabel(frame: CGRect(x: 20, y: 21 * screenHeightFactor, width: screenWidth - 40, height: 27))
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblName.textColor = UIColor._898989()
        
        lblCategory = UILabel(frame: CGRect(x: 20, y: 53 * screenHeightFactor, width: screenWidth - 90, height: 22))
        lblCategory.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCategory.textColor = UIColor._146146146()
        
        lblPrice = UILabel()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPrice.textColor = UIColor._107105105()
        lblPrice.textAlignment = .right
        
        addSubview(lblName)
        addSubview(lblCategory)
        addSubview(lblPrice)
        addConstraintsWithFormat("H:[v0(100)]-15-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:[v0(22)]-\(14 * screenHeightFactor)-|", options: [], views: lblPrice)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 96, w: 414, h: 5))
        uiviewLine.backgroundColor = UIColor._241241241()
        addSubview(uiviewLine)
    }
    
    func setValue(place: PlacePin) {
        lblName.text = place.name
        lblCategory.text = place.class_1
        lblPrice.text = "$$$"
    }
}
