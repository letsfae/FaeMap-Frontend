//
//  LocDetailViewController.swift
//  faeBeta
//
//  Created by Yue Shen on 9/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

/*
    Logics:
        When make a save to this location
        1. create location pin in back-end
        2. when success, front end now has the pin id
        3. use the pin id to save this location pin
    Notice:
        1. when trainsitioning from a new location pin, saved_status will be always false
        2. when trainsitioning from collections, saved_status will be always true
        So, no need to check saved_status in back end
*/

protocol LocDetailDelegate: class {
    func jumpToViewLocation(coordinate: CLLocationCoordinate2D, created: Bool)
}

class LocDetailViewController: UIViewController, AddPinToCollectionDelegate, MKMapViewDelegate, AfterAddedToListDelegate {
    
    weak var delegate: MapSearchDelegate?
    weak var locationDelegate: LocDetailDelegate?
    
    public var coordinate: CLLocationCoordinate2D!
    
    private var uiviewHeader: UIView!
    private var uiviewSubHeader: FixedHeader!
    private var uiviewFooter: UIView!
    
    private var btnBack: UIButton!
    private var btnSave: UIButton!
    private var imgSaved: UIImageView!
    private var btnRoute: UIButton!
    private var btnShare: UIButton!
    
    private var tblNearby: UITableView!
    private var arrNearbyPlaces = [PlacePin]()
    private let faeMap = FaeMap()
    private let faePinAction = FaePinAction()
    private var boolSaved: Bool = false
    
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    
    private var lblClctViewTitle: UILabel!
    private var btnSeeAll: UIButton!
    private var clctNearby: UICollectionView!
    private var uiviewClctView: UIView!
    weak var delegateSeeAll: SeeAllPlacesDelegate?
    
    public var strLocName = ""
    public var strLocAddr = ""
    
    private var mapView: MKMapView!
    
    private var arrListSavedThisPin = [Int]()
    private var boolSavedListLoaded = false
    
    private var fullLoaded = false
    
    private var viewModelNearby: BoardPlaceCategoryViewModel!
    
    var locationId: Int = 0 {
        didSet {
            guard fullLoaded else { return }
            checkSavedStatus {}
        }
    }
    
    public var boolShared: Bool = false
    public var enterMode: EnterPlaceLocDetailMode!
    public var boolCreated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadMap()
        loadHeader()
        loadCollectionView()
        loadFooter()
        updateLocation()
        view.bringSubview(toFront: uiviewSavedList)
        view.bringSubview(toFront: uiviewAfterAdded)
        checkSavedStatus() {}
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti(_:)), name: NSNotification.Name(rawValue: "showSavedNoti_locDetail"), object: nil)
        
        // Joshua: Add this two lines to enable the edge-gesture on the left side of screen
        //         whole table view and cell will automatically disable this
        let uiviewLeftMargin = LeftMarginToEnableNavGestureView()
        view.addSubview(uiviewLeftMargin)
        
        fullLoaded = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_locDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard coordinate != nil else { return }
        let lat = String(coordinate.latitude)
        let long = String(coordinate.longitude)
        self.getNearbyPlaces(lat, long) {
            self.viewModelNearby = BoardPlaceCategoryViewModel(title: "Near this Location", places: self.arrNearbyPlaces)
            self.clctNearby.reloadData()
        }
        if boolShared {
            //uiviewAfterAdded.lblSaved.text = "You shared a Location."
            uiviewAfterAdded.lblSaved.frame = CGRect(x: 20, y: 19, width: 200, height: 25)
            uiviewAfterAdded.btnUndo.isHidden = true
            uiviewAfterAdded.btnSeeList.isHidden = true
            uiviewAfterAdded.show("You shared a Location.")
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
    
    func updateLocation() {
        uiviewSubHeader.lblName.text = strLocName
        uiviewSubHeader.lblCategory.text = strLocAddr
    }
    
    func checkSavedStatus(_ completion: @escaping () -> ()) {
        guard locationId != 0 else { return }
        FaeMap.shared.getPin(type: "location", pinId: String(locationId)) { [weak self] (status, message) in
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
            guard let `self` = self else { return }
            self.arrListSavedThisPin = ids
            self.uiviewSavedList.arrListSavedThisPin = ids
            self.boolSavedListLoaded = true
            if ids.count != 0 {
                self.savedNotiAnimation()
            }
            completion()
        }
    }
    
    func getNearbyPlaces(_ lat: String, _ long: String, _ completion: @escaping () -> Void) {
        arrNearbyPlaces.removeAll()
        FaeMap.shared.whereKey("geo_latitude", value: lat)
        FaeMap.shared.whereKey("geo_longitude", value: long)
        FaeMap.shared.whereKey("radius", value: "5000")
        FaeMap.shared.whereKey("type", value: "place")
        FaeMap.shared.whereKey("max_count", value: "20")
        FaeMap.shared.getMapPins { [weak self] (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                //print("Get Related Places Fail \(status) \(message!)")
                completion()
                return
            }
            let json = JSON(message!)
            guard let placeJson = json.array else { return }
            guard let `self` = self else { return }
            self.arrNearbyPlaces = placeJson.map({ PlacePin(json: $0) })
            self.uiviewClctView.isHidden = self.arrNearbyPlaces.count == 0
            completion()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is AddressAnnotation {
            let identifier = "destination"
            var anView: AddressAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AddressAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = AddressAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
            return anView
        }
        return nil
    }
    
    private func loadMap() {
        mapView = MKMapView()
        if screenHeight == 812 {
            mapView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 352 + 60 + device_offset_top * 2)
        } else {
            mapView.frame = CGRect(x: 0, y: 0, w: 414, h: 352 + 48)
        }
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = false
        view.addSubview(mapView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(tapGesture)
        
        if let coor = coordinate {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, 1500, 1500)
            mapView.setRegion(coordinateRegion, animated: false)
            let addressPin = AddressAnnotation()
            addressPin.coordinate = coor
            mapView.addAnnotation(addressPin)
        }
    }
    
    @objc private func handleMapTap() {
        hideAddCollectionView()
        
        var arrCtrlers = navigationController?.viewControllers
        if let ctrler = Key.shared.FMVCtrler {
            ctrler.arrCtrlers = arrCtrlers!
            ctrler.boolFromMap = false
        }
        while !(arrCtrlers?.last is InitialPageController) {
            arrCtrlers?.removeLast()
        }
        locationDelegate = Key.shared.FMVCtrler
        locationDelegate?.jumpToViewLocation(coordinate: coordinate, created: boolCreated)
        Key.shared.initialCtrler?.goToFaeMap(animated: false)
        navigationController?.setViewControllers(arrCtrlers!, animated: false)
    }
    
    private func getRelatedPlaces(lat: String, long: String, radius: Int, isSimilar: Bool, completion:@escaping ([PlacePin]) -> Void) {
        faeMap.whereKey("geo_latitude", value: "\(lat)")
        faeMap.whereKey("geo_longitude", value: "\(long)")
        faeMap.whereKey("radius", value: "\(radius)")
        faeMap.whereKey("type", value: "place")
        faeMap.whereKey("max_count", value: "1000")
        faeMap.getMapPins { (status: Int, message: Any?) in
            var arrPlaces = [PlacePin]()
            arrPlaces.removeAll()
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let placeJson = json.array else {
                    return
                }
                for pl in placeJson {
                    let placePin = PlacePin(json: pl)
                    arrPlaces.append(placePin)
                }
            } else {
                //print("Get Related Places Fail \(status) \(message!)")
            }
            completion(arrPlaces)
        }
    }
    
    private func loadHeader() {
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: screenHeight - 234 - 49 - 101 * screenHeightFactor - device_offset_bot, width: screenWidth, height: 101 * screenHeightFactor))
        view.addSubview(uiviewSubHeader)
        uiviewSubHeader.lblPrice.isHidden = true
    }
    
    private func loadFooter() {
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
        
        imgSaved = UIImageView(frame: CGRect(x: 29, y: 5, width: 18, height: 18))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.alpha = 0
        
        loadAddtoCollection()
    }
    
    @objc private func showSavedNoti(_ sender: Notification) {
        if let id = sender.object as? Int {
            self.locationId = id
        }
        savedNotiAnimation()
    }
    
    private func savedNotiAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 29, y: 5, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    private func hideSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 38, y: 14, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
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
    
    @objc private func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveThisPin() {
        print("locDetail \(locationId)")
        func showCollections() {
            uiviewSavedList.tableMode = .location
//            uiviewSavedList.loadCollectionData()
            guard let position = coordinate else { return }
            let pinData = LocationPin(position: position)
            uiviewSavedList.pinToSave = FaePinAnnotation(type: .location, cluster: nil, data: pinData as AnyObject)
            uiviewSavedList.show()
            uiviewSavedList.fromLocDetail = true
            uiviewSavedList.locId = locationId
            print("locDetail \(uiviewSavedList.fromLocDetail) \(locationId)")
        }
        if locationId <= 0 {
            showCollections()
        } else {
            checkSavedStatus {
                showCollections()
            }
        }
    }
    
    @objc private func routeToThisPin() {
        guard coordinate != nil else {
            showAlert(title: "Unexpected Error Occured!", message: "Please try again later", viewCtrler: self)
            return
        }
        let vc = RoutingMapController()
        vc.mode = .location
        vc.startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        vc.destinationAddr = RouteAddress(name: strLocName, coordinate: coordinate)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc private func shareThisPin() {
        let vcShareLoc = NewChatShareController(friendListMode: .location)
        AddPinToCollectionView().mapScreenShot(coordinate: coordinate!) { [weak self] (snapShotImage) in
            guard let `self` = self else { return }
            vcShareLoc.locationDetail = "\(self.coordinate?.latitude ?? 0.0),\(self.coordinate?.longitude ?? 0.0),\(self.strLocName),\(self.strLocAddr)"
            vcShareLoc.locationSnapImage = snapShotImage
            vcShareLoc.boolFromLocDetail = true
            self.navigationController?.pushViewController(vcShareLoc, animated: true)
        }
    }
    
    private func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    @objc private func hideAddCollectionView() {
        uiviewSavedList.hide()
    }
    
    // MARK: - SeeAllPlacesDelegate
//    func jumpToAllPlaces(places: BoardPlaceCategoryViewModel) {
//        let vc = AllPlacesViewController()
//        vc.viewModelPlaces = places
//        vc.strTitle = places.title
////        vc.recommendedPlaces = places
////        vc.strTitle = title
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // MARK: - AddPinToCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .location
        present(vc, animated: true)
    }
    // AddPlintoCollectionDelegate End
    
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
    
    // MARK: - AfterAddedToListDelegate
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
            savedNotiAnimation()
        }
    }
}

extension LocDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func loadCollectionView() {
        uiviewClctView = UIView(frame: CGRect(x: 0, y: screenHeight - 234 - 49 - device_offset_bot, width: screenWidth, height: 234))
        uiviewClctView.isHidden = true
        view.addSubview(uiviewClctView)
        
        lblClctViewTitle = UILabel(frame: CGRect(x: 15, y: 15, width: 150, height: 20))
        lblClctViewTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        lblClctViewTitle.textColor = UIColor._138138138()
        lblClctViewTitle.text = "Near this Location"
        uiviewClctView.addSubview(lblClctViewTitle)
        
        btnSeeAll = UIButton(frame: CGRect(x: screenWidth - 78, y: 5, width: 78, height: 40))
        btnSeeAll.setTitleColor(UIColor._155155155(), for: .normal)
        btnSeeAll.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        btnSeeAll.setTitle("See All", for: .normal)
        btnSeeAll.addTarget(self, action: #selector(btnSeeAllTapped(_:)), for: .touchUpInside)
        uiviewClctView.addSubview(btnSeeAll)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 122, height: 222 - 45)
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 24, 0, 24)
        clctNearby = UICollectionView(frame: CGRect(x: 0, y: 45, width: screenWidth, height: 222 - 45), collectionViewLayout: flowLayout)
        clctNearby.showsHorizontalScrollIndicator = false
        clctNearby.delegate = self
        clctNearby.dataSource = self
        clctNearby.register(PlacesCollectionCell.self, forCellWithReuseIdentifier: "PlacesCollectionCell")
        clctNearby.backgroundColor = .clear
        uiviewClctView.addSubview(clctNearby)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrNearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacesCollectionCell", for: indexPath) as! PlacesCollectionCell
//        let place = arrNearbyPlaces[indexPath.row]
        if let viewModelPlace = viewModelNearby.viewModel(for: indexPath.row) {
            colCell.setValueForColCell(place: viewModelPlace, row: indexPath.row)
        }
        return colCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        jumpToPlaceDetail(place: arrNearbyPlaces[indexPath.row])
    }
    
    @objc private func btnSeeAllTapped(_ sender: UIButton) {
        let vc = AllPlacesViewController()
        vc.viewModelPlaces = viewModelNearby
        vc.strTitle = viewModelNearby.title
        //        vc.recommendedPlaces = places
        //        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
//        delegateSeeAll?.jumpToAllPlaces(places: viewModelNearby)
    }
}
