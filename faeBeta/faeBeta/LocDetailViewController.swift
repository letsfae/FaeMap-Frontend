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

class LocDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPinToCollectionDelegate, MKMapViewDelegate, AfterAddedToListDelegate {
    
    weak var delegate: MapSearchDelegate?
    weak var featureDelegate: PlaceDetailDelegate?
    weak var locationDelegate: LocDetailDelegate?
    
    var coordinate: CLLocationCoordinate2D!
    
    var uiviewHeader: UIView!
    var uiviewSubHeader: FixedHeader!
    var uiviewFooter: UIView!
    
    var btnBack: UIButton!
    var btnSave: UIButton!
    var imgSaved: UIImageView!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    
    var tblNearby: UITableView!
    var arrNearbyPlaces = [PlacePin]()
    let faeMap = FaeMap()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    
    var lblClctViewTitle: UILabel!
    var btnSeeAll: UIButton!
    var clctNearby: UICollectionView!
    var uiviewClctView: UIView!
    weak var delegateSeeAll: SeeAllPlacesDelegate?
    
    var strLocName = ""
    var strLocAddr = ""
    
    var mapView: MKMapView!
    
    var arrListSavedThisPin = [Int]()
    var boolSavedListLoaded = false
    
    var fullLoaded = false
    
    var locationId: Int = 0 {
        didSet {
            guard fullLoaded else { return }
            checkSavedStatus {}
        }
    }
    
    var boolShared: Bool = false
    var enterMode: EnterPlaceLocDetailMode!
    var boolCreated: Bool = false
    
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
        FaeMap.shared.getPin(type: "location", pinId: String(locationId)) { (status, message) in
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
        FaeMap.shared.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                //print("Get Related Places Fail \(status) \(message!)")
                completion()
                return
            }
            let json = JSON(message!)
            guard let placeJson = json.array else { return }
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
    
    func loadMap() {
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
    
    @objc func handleMapTap() {
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
    
    func getRelatedPlaces(lat: String, long: String, radius: Int, isSimilar: Bool, completion:@escaping ([PlacePin]) -> Void) {
        faeMap.whereKey("geo_latitude", value: "\(lat)")
        faeMap.whereKey("geo_longitude", value: "\(long)")
        faeMap.whereKey("radius", value: "\(radius)")
        faeMap.whereKey("type", value: "place")
        faeMap.whereKey("max_count", value: "1000")
        faeMap.getMapInformation { (status: Int, message: Any?) in
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
    
    func loadHeader() {
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: screenHeight - 234 - 49 - 101 * screenHeightFactor - device_offset_bot, width: screenWidth, height: 101 * screenHeightFactor))
        view.addSubview(uiviewSubHeader)
        uiviewSubHeader.lblPrice.isHidden = true
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
        
        imgSaved = UIImageView(frame: CGRect(x: 29, y: 5, width: 18, height: 18))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.alpha = 0
        
        loadAddtoCollection()
    }
    
    @objc func showSavedNoti(_ sender: Notification) {
        if let id = sender.object as? Int {
            self.locationId = id
        }
        savedNotiAnimation()
    }
    
    func savedNotiAnimation() {
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
    
    @objc func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveThisPin() {
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
    
    @objc func routeToThisPin() {
        guard coordinate != nil else {
            showAlert(title: "Unexpected Error Occured!", message: "Please try again later", viewCtrler: self)
            return
        }
        let vc = RoutingMapController()
        vc.mode = .location
        vc.startPointAddr = RouteAddress(name: "Current Location", coordinate: LocManager.shared.curtLoc.coordinate)
        vc.destinationAddr = RouteAddress(name: strLocName, coordinate: coordinate)
        navigationController?.pushViewController(vc, animated: false)
//        featureDelegate?.getRouteToPin(mode: .location, placeInfo: nil)
//        navigationController?.popViewController(animated: false)
    }
    
    @objc func shareThisPin() {
        let vcShareLoc = NewChatShareController(friendListMode: .location)
        AddPinToCollectionView().mapScreenShot(coordinate: coordinate!) { (snapShotImage) in
            vcShareLoc.locationDetail = "\(self.coordinate?.latitude ?? 0.0),\(self.coordinate?.longitude ?? 0.0),\(self.strLocName),\(self.strLocAddr)"
            vcShareLoc.locationSnapImage = snapShotImage
            vcShareLoc.boolFromLocDetail = true
            self.navigationController?.pushViewController(vcShareLoc, animated: true)
        }
    }
    
    func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    @objc func hideAddCollectionView() {
        uiviewSavedList.hide()
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
    
    // AddPinToCollectionDelegate
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
            savedNotiAnimation()
        }
    }
}
