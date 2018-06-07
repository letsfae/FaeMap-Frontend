//
//  PlaceDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

enum EnterPlaceLocDetailMode {
    case collection
    case boards
    case map
}

class PlaceDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPinToCollectionDelegate, AfterAddedToListDelegate {
    
    public var place: PlacePin!
    private var uiviewHeader: UIView!
    private var uiview_bottomLine: UIView!
    private var uiviewSubHeader: FixedHeader!
    private var uiviewFixedHeader: FixedHeader!
    
    private var uiviewPlaceImages: PlacePinImagesView!
    
    private var uiviewFooter: UIView!
    private var btnBack: UIButton!
    private var btnSave: UIButton!
    private var imgSaved: UIImageView!
    private var btnRoute: UIButton!
    private var btnShare: UIButton!
    private var tblPlaceDetail: UITableView!
    private let arrTitle = ["Similar Places", "Near this Place"]
    private var arrRelatedPlaces = [[PlacePin]]()
    private var arrSimilarPlaces = [PlacePin]()
    private var arrNearbyPlaces = [PlacePin]()
    private let faePinAction = FaePinAction()
    private var boolSaved: Bool = false
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    private var arrListSavedThisPin = [Int]()
    private var boolSavedListLoaded = false
    private var uiviewWhite: UIView!
    private var intHaveHour = 0
    private var intHaveWebPhone = 0
    private var boolHaveWeb = false
    private var intCellCount = 0
    private var intSimilar = 0
    private var intNearby = 0
    private var isScrollViewDidScrollEnabled: Bool = true
    
    var boolShared: Bool = false
    public var enterMode: EnterPlaceLocDetailMode!
    
    // MARK: - Life Cycles
    
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
        
        let content = place.class_2
        if catDict[content] == nil {
            catDict[content] = 0
        } else {
            catDict[content] = catDict[content]! + 1;
        }
        favCategoryCache.setObject(catDict as AnyObject, forKey: Key.shared.user_id as AnyObject)
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
    
    // MARK: -
    
    private func initPlaceRelatedData() {
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
    
    private func setCellCount() {
        guard place != nil else { return }
        intHaveHour = place.hours.count > 0 ? 1 : 0
        intHaveWebPhone = place.url != "" || place.phone != "" ? 1 : 0
        boolHaveWeb = place.url != ""
        intCellCount = intHaveHour + intHaveWebPhone + 2
    }
    
    private func checkSavedStatus(_ completion: @escaping () -> ()) {
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
    
    private func getRelatedPlaces(_ lat: String, _ long: String, isSimilar: Bool, _ completion: @escaping () -> Void) {
        if isSimilar {
            arrSimilarPlaces.removeAll()
            FaeSearch.shared.whereKey("content", value: place.class_2 == "" ? place.class_1 : place.class_2)
            FaeSearch.shared.whereKey("source", value: "categories")
            FaeSearch.shared.whereKey("type", value: "place")
            FaeSearch.shared.whereKey("size", value: "20")
            FaeSearch.shared.whereKey("radius", value: "20000")
            FaeSearch.shared.whereKey("offset", value: "0")
            FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
            FaeSearch.shared.whereKey("location", value: ["latitude": lat,
                                                          "longitude": long])
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
    
    // MARK: - UI Setups
    
    private func loadHeader() {
        let txtHeight = heightForView(text: place.name, font: UIFont(name: "AvenirNext-Medium", size: 20)!, width: screenWidth - 40)
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: (309 - 27 + txtHeight) * screenHeightFactor + device_offset_top))
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: 208 * screenHeightFactor + device_offset_top, width: screenWidth, height: (101 - 27 + txtHeight) * screenHeightFactor))
        uiviewSubHeader.lblName.frame.size.height = txtHeight
        let origin_y = uiviewSubHeader.lblCategory.frame.origin.y - 27 + txtHeight
        uiviewSubHeader.lblCategory.frame.origin.y = origin_y
        uiviewHeader.addSubview(uiviewSubHeader)
        uiviewSubHeader.setValue(place: place)
    }
    
    private func loadFixedHeader() {
        let txtHeight = heightForView(text: place.name, font: UIFont(name: "AvenirNext-Medium", size: 20)!, width: screenWidth - 40)
        uiviewFixedHeader = FixedHeader(frame: CGRect(x: 0, y: 22 * screenHeightFactor, width: screenWidth, height: (101-27+txtHeight) * screenHeightFactor))
        if screenHeight == 812 { uiviewFixedHeader.frame.origin.y = 30 }
        uiviewFixedHeader.lblName.frame.size.height = txtHeight
        let origin_y = uiviewFixedHeader.lblCategory.frame.origin.y - 27 + txtHeight
        uiviewFixedHeader.lblCategory.frame.origin.y = origin_y
        view.addSubview(uiviewFixedHeader)
        uiviewFixedHeader.setValue(place: place)
        uiviewFixedHeader.isHidden = true
        uiviewWhite = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 22))
        if screenHeight == 812 { uiviewWhite.frame.size.height = 30 }
        uiviewWhite.backgroundColor = .white
        view.addSubview(uiviewWhite)
        uiviewWhite.alpha = 0
    }
    
    private func loadMidTable() {
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
        
        uiviewPlaceImages = PlacePinImagesView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 208 * screenHeightFactor + device_offset_top))
        tblPlaceDetail.addSubview(uiviewPlaceImages)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionTapImages))
        uiviewPlaceImages.addGestureRecognizer(tapGes)
        uiviewPlaceImages.arrURLs = place.imageURLs
        uiviewPlaceImages.loadContent()
        uiviewPlaceImages.setup()
        let bottomLine = UIView(frame: CGRect(x: 0, y: 208 + device_offset_top, w: 414, h: 1))
        bottomLine.backgroundColor = UIColor._241241241()
        uiviewPlaceImages.addSubview(bottomLine)
        uiviewPlaceImages.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: bottomLine)
        uiviewPlaceImages.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
    private func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49 - device_offset_bot, width: screenWidth, height: 49 + device_offset_bot))
        view.addSubview(uiviewFooter)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFooter.addSubview(line)
        
        btnBack = UIButton(frame: CGRect(x: -10, y: 1, width: 60.5, height: 48))
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
    
    private func loadAddtoCollection() {
        uiviewSavedList = AddPinToCollectionView()
        uiviewSavedList.delegate = self
        uiviewSavedList.tableMode = .place
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    @objc private func showSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 29, y: 5, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc private func hideSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 38, y: 14, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }

    // MARK: - UIScrollViewDelegate
    
    private var boolAnimateTo_1 = true

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tblPlaceDetail else { return }
        if uiviewPlaceImages != nil {
            var frame = uiviewPlaceImages.frame
            if tblPlaceDetail.contentOffset.y < 0 {
                frame.origin.y = tblPlaceDetail.contentOffset.y
                uiviewPlaceImages.frame = frame
                let height = 208 * screenHeightFactor + device_offset_top - tblPlaceDetail.contentOffset.y
                uiviewPlaceImages.frame.size.height = height
                uiviewPlaceImages.contentSize.height = height
                uiviewPlaceImages.viewObjects[uiviewPlaceImages.currentPage].frame.size.height = height
            } else {
                frame.origin.y = 0
                uiviewPlaceImages.frame.origin.y = 0
            }
        }
        var offset_y: CGFloat = 186 * screenHeightFactor
        if screenHeight == 812 { offset_y = 182 }
        if tblPlaceDetail.contentOffset.y >= offset_y {
            uiviewFixedHeader.isHidden = false
            UIApplication.shared.statusBarStyle = .default
            if boolAnimateTo_1 {
                boolAnimateTo_1 = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.uiviewPlaceImages.alpha = 0
                    self.uiviewSubHeader.alpha = 0
                    self.uiviewWhite.alpha = 1
                })
            }
        } else {
            uiviewFixedHeader.isHidden = true
            self.uiviewWhite.alpha = 0
            self.uiviewSubHeader.alpha = 1
            UIApplication.shared.statusBarStyle = .lightContent
            if boolAnimateTo_1 == false {
                boolAnimateTo_1 = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.uiviewPlaceImages.alpha = 1
                })
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideAddCollectionView()
    }
    
    // MARK: - Actions
    
    @objc private func backToMapBoard(_ sender: UIButton) {
        let mbIsOn = SideMenuViewController.boolMapBoardIsOn
        if mbIsOn {
            Key.shared.initialCtrler?.goToMapBoard(animated: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveThisPin() {
        func showCollections() {
            uiviewSavedList.tableMode = .place
            //uiviewSavedList.loadCollectionData()
            uiviewSavedList.pinToSave = FaePinAnnotation(type: .place, cluster: nil, data: place)
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
    
    @objc private func routeToThisPin() {
        let vc = RoutingMapController()
        vc.startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        vc.destinationAddr = RouteAddress(name: place.name, coordinate: place.coordinate)
        vc.destPlaceInfo = self.place
        vc.mode = .place
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc private func shareThisPin() {
        let vcShareCollection = NewChatShareController(friendListMode: .place)
        vcShareCollection.placeDetail = place
        vcShareCollection.boolFromPlaceDetail = true
        navigationController?.pushViewController(vcShareCollection, animated: true)
    }
    
    private func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    @objc private func hideAddCollectionView() {
        uiviewSavedList.hide()
    }
    
    @objc private func actionTapImages() {
        guard uiviewPlaceImages.arrSKPhoto.count > 0 else {
            return
        }
        let browser = SKPhotoBrowser(photos: uiviewPlaceImages.arrSKPhoto, initialPageIndex: uiviewPlaceImages.currentPage)
        present(browser, animated: false, completion: nil)
    }
    
    // MARK: - SeeAllPlacesDelegate
    func jumpToAllPlaces(places: [PlacePin], title: String) {
        let vc = AllPlacesViewController()
        vc.recommendedPlaces = places
        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        guard var arrCtrlers = navigationController?.viewControllers else {
            showAlert(title: "Unexpected Error", message: "please try again", viewCtrler: self)
            return
        }
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        arrCtrlers.removeLast()
        arrCtrlers.append(vcPlaceDetail)
        
        navigationController?.setViewControllers(arrCtrlers, animated: true)
    }
    
    // MARK: - AddPintoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    // MARK: - AfterAddedToListDelegate
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
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
        }
        if uiviewSavedList.arrListSavedThisPin.count <= 0 {
            hideSavedNoti()
        } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
            showSavedNoti()
        }
    }
}

// MARK: - FixedHeader

class FixedHeader: UIView {
    
    var lblName: UILabel!
    var lblCategory: UILabel!
    var lblPrice: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        lblName = UILabel(frame: CGRect(x: 20, y: 21 * screenHeightFactor, width: screenWidth - 40, height: 27))
        lblName.numberOfLines = 0
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblName.textColor = UIColor._898989()
        addSubview(lblName)
        
        lblCategory = UILabel(frame: CGRect(x: 20, y: 53 * screenHeightFactor, width: screenWidth - 90, height: 22))
        lblCategory.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCategory.textColor = UIColor._146146146()
        addSubview(lblCategory)
        
        lblPrice = UILabel()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPrice.textColor = UIColor._107105105()
        lblPrice.textAlignment = .right
        addSubview(lblPrice)
        addConstraintsWithFormat("H:[v0(100)]-15-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:[v0(22)]-\(14 * screenHeightFactor)-|", options: [], views: lblPrice)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 96, w: 414, h: 5))
        uiviewLine.backgroundColor = UIColor._241241241()
        addSubview(uiviewLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewLine)
        addConstraintsWithFormat("V:[v0(\(5 * screenHeightFactor))]-0-|", options: [], views: uiviewLine)
    }
    
    public func setValue(place: PlacePin) {
        lblName.text = place.name
        lblCategory.text = place.class_1
        lblPrice.text = place.price
    }
}

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate, PlaceDetailMapCellDelegate {
    
    // MARK: - UITableViewDelegate & Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return intCellCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        func similarNearbyCount() -> Int {
            let count = intSimilar + intNearby
            if count == 0 {
                return 0
            } else if count == 1 {
                return 1
            } else {
                return 2
            }
        }
        
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return 1
            } else {
                return similarNearbyCount()
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                return 1
            } else if section == 1 {
                if place.phone == "" { return 1 }
                if place.url == "" { return 1 }
                return 2
            } else {
                return similarNearbyCount()
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section <= 1 {
                return 1
            } else {
                return similarNearbyCount()
            }
        } else {
            if section <= 1 {
                return 1
            } else if section == 2 {
                if place.phone == "" { return 1 }
                if place.url == "" { return 1 }
                return 2
            } else {
                return similarNearbyCount()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tblPlaceDetail.rowHeight = UITableViewAutomaticDimension
        tblPlaceDetail.estimatedRowHeight = 60
        let section = indexPath.section
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 1 {
            if section <= 2 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        } else {
            if section <= 1 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return getMapCell(tableView, indexPath)
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                return getMapCell(tableView, indexPath)
            } else if section == 1 {
                if place.phone == "" && row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else if place.url == "" && row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                } else if indexPath.row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                }
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section <= 1 {
                if section == 0 {
                    return getMapCell(tableView, indexPath)
                }
                return getHoursCell(tableView, indexPath)
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else {
            if section <= 1 {
                if section == 0 {
                    return getMapCell(tableView, indexPath)
                }
                return getHoursCell(tableView, indexPath)
            } else if section == 2 {
                if place.phone == "" && row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else if place.url == "" && row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                } else if indexPath.row == 0 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                }
            } else {
                return getMBCell(tableView, indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func tapMapOrHour() {
            let cell = tableView.cellForRow(at: indexPath) as! PlaceDetailCell
            PlaceDetailCell.boolFold = cell.imgDownArrow.image == #imageLiteral(resourceName: "arrow_up")
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        func tapWebOrPhone() {
            var strURL = ""
            if boolHaveWeb && indexPath.row == 0 {
                strURL = place.url
            } else {
                let phoneNum = place.phone.onlyNumbers()
                strURL = "tel://\(phoneNum)"
            }
            if let url = URL(string: strURL), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        let section = indexPath.section
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                tapMapOrHour()
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                tapMapOrHour()
            } else if section == 1 {
                tapWebOrPhone()
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section <= 1 {
                tapMapOrHour()
            }
        } else {
            if section <= 1 {
                tapMapOrHour()
            } else if section == 2 {
                tapWebOrPhone()
            }
        }
    }
    
    func getMBCell(_ tableView: UITableView, _ indexPath: IndexPath) -> MBPlacesCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MBPlacesCell", for: indexPath) as! MBPlacesCell
        cell.delegate = self
        let count = intSimilar + intNearby
        if count == 1 {
            if intSimilar == 1 {
                cell.setValueForCell(title: arrTitle[0], places: arrSimilarPlaces)
            } else {
                cell.setValueForCell(title: arrTitle[1], places: arrNearbyPlaces)
            }
        } else {
            if indexPath.row == 0 {
                cell.setValueForCell(title: arrTitle[0], places: arrSimilarPlaces)
            } else {
                cell.setValueForCell(title: arrTitle[1], places: arrNearbyPlaces)
            }
        }
        return cell
    }
    
    func getMapCell(_ tableView: UITableView, _ indexPath: IndexPath) -> PlaceDetailMapCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailMapCell", for: indexPath) as! PlaceDetailMapCell
        cell.delegate = self
        cell.setValueForCell(place: place)
        return cell
    }
    
    func getHoursCell(_ tableView: UITableView, _ indexPath: IndexPath) -> PlaceDetailHoursCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailHoursCell", for: indexPath) as! PlaceDetailHoursCell
        cell.setValueForCell(place: place)
        return cell
    }
    
    func getWebPhoneCell(_ tableView: UITableView, _ indexPath: IndexPath, isURL: Bool) -> PlaceDetailSection3Cell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection3Cell", for: indexPath) as! PlaceDetailSection3Cell
        cell.isURL = isURL
        cell.setValueForCell(place: place)
        return cell
    }
    
    func jumpToMainMapWithPlace() {
        let vcMap = PlaceViewMapController()
        vcMap.placePin = self.place
        vcMap.mapCenter = .placeCoordinate
        navigationController?.pushViewController(vcMap, animated: false)
    }
}
