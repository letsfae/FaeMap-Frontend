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
    func getRouteToPin()
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
    let faeMap = FaeMap()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    var arrListSavedThisPin = [Int]()
    var boolSavedListLoaded = false
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_placeDetail"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideSavedNoti_placeDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiviewSubHeader.setValue(place: place)
        uiviewFixedHeader.setValue(place: place)
        tblPlaceDetail.reloadData()
        getRelatedPlaces(lat: String(LocManager.shared.curtLat), long: String(LocManager.shared.curtLong), radius: 500000, isSimilar: true, completion: { arrPlaces in
            self.arrRelatedPlaces.append(arrPlaces)
            self.getRelatedPlaces(lat: String(self.place.coordinate.latitude), long: String(self.place.coordinate.longitude), radius: 5000, isSimilar: false, completion: { arrPlaces in
                self.arrRelatedPlaces.append(arrPlaces)
                self.tblPlaceDetail.reloadData()
            })
        })
        PlaceDetailCell.boolFold = true
        
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
    
    func getRelatedPlaces(lat: String, long: String, radius: Int, isSimilar: Bool, completion: @escaping ([PlacePin]) -> Void) {
        faeMap.whereKey("geo_latitude", value: "\(lat)")
        faeMap.whereKey("geo_longitude", value: "\(long)")
        faeMap.whereKey("radius", value: "\(radius)")
        faeMap.whereKey("type", value: "place")
        faeMap.whereKey("max_count", value: "20")
        faeMap.getMapInformation { (status: Int, message: Any?) in
            var arrPlaces = [PlacePin]()
            arrPlaces.removeAll()
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let placeJson = json.array else { return }
                for pl in placeJson {
                    let placePin = PlacePin(json: pl)
                    if arrPlaces.count < 15 && placePin.id != self.place.id {
                        if isSimilar && placePin.class_1 == self.place.class_1 || !isSimilar {
                            arrPlaces.append(placePin)
                        }
                    }
                }
            } else {
                print("Get Related Places Fail \(status) \(message!)")
            }
            completion(arrPlaces)
        }
    }
    
    func loadHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 309))
        
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: 208, w: 414, h: 101))
        uiviewHeader.addSubview(uiviewSubHeader)
        uiviewSubHeader.setValue(place: place)
    }
    
    func loadFixedHeader() {
        uiviewFixedHeader = FixedHeader(frame: CGRect(x: 0, y: 0, w: 414, h: 101))
        view.addSubview(uiviewFixedHeader)
        uiviewFixedHeader.setValue(place: place)
        uiviewFixedHeader.isHidden = true
    }
    
    func loadMidTable() {
        tblPlaceDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49), style: .plain)
        view.addSubview(tblPlaceDetail)
        tblPlaceDetail.tableHeaderView = uiviewHeader
        
        tblPlaceDetail.delegate = self
        tblPlaceDetail.dataSource = self
        tblPlaceDetail.register(PlaceDetailSection1Cell.self, forCellReuseIdentifier: "PlaceDetailSection1Cell")
        tblPlaceDetail.register(PlaceDetailSection2Cell.self, forCellReuseIdentifier: "PlaceDetailSection2Cell")
        tblPlaceDetail.register(PlaceDetailSection3Cell.self, forCellReuseIdentifier: "PlaceDetailSection3Cell")
        tblPlaceDetail.register(MBPlacesCell.self, forCellReuseIdentifier: "MBPlacesCell")
        tblPlaceDetail.separatorStyle = .none
        tblPlaceDetail.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            tblPlaceDetail.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        uiviewScrollingPhotos = InfiniteScrollingView(frame: CGRect(x: 0, y: 0, w: 414, h: 208))
        tblPlaceDetail.addSubview(uiviewScrollingPhotos)
        let bottomLine = UIView(frame: CGRect(x: 0, y: 208, w: 414, h: 1))
        bottomLine.backgroundColor = UIColor._241241241()
        uiviewScrollingPhotos.addSubview(bottomLine)
        uiviewScrollingPhotos.loadImages(place: place)
    }
    
    func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
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
    
    func showSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 29, y: 5, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    func hideSavedNoti() {
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
        if tblPlaceDetail.contentOffset.y >= 208 * screenHeightFactor {
            uiviewFixedHeader.isHidden = false
            UIApplication.shared.statusBarStyle = .default
        } else {
            uiviewFixedHeader.isHidden = true
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func saveThisPin() {
        func showCollections() {
            uiviewSavedList.tableMode = .place
            uiviewSavedList.loadCollectionData()
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
    
    func routeToThisPin() {
        featureDelegate?.getRouteToPin()
        navigationController?.popViewController(animated: false)
    }
    
    func shareThisPin() {
        let vcShareCollection = NewChatShareController(friendListMode: .place)
        vcShareCollection.placeDetail = place
        navigationController?.pushViewController(vcShareCollection, animated: true)
    }
    
    func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    func hideAddCollectionView() {
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
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // AddPlacetoCollectionDelegate
    func cancelAddPlace() {
        hideAddCollectionView()
    }
    
    // AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.colId
        vcList.colInfo = uiviewAfterAdded.selectedCollection
        navigationController?.pushViewController(vcList, animated: true)
    }
    
    // AfterAddedToListDelegate
    func undoCollect(colId: Int) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        if uiviewSavedList.arrListSavedThisPin.contains(colId) {
            let arrListIds = uiviewSavedList.arrListSavedThisPin
            arrListSavedThisPin = arrListIds.filter { $0 != colId }
            uiviewSavedList.arrListSavedThisPin = arrListSavedThisPin
        }
        guard uiviewSavedList.arrListSavedThisPin.count <= 0 else { return }
        // shrink imgSaved button
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
