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
class LocDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPinToCollectionDelegate, MKMapViewDelegate, AfterAddedToListDelegate {
    
    weak var delegate: MapSearchDelegate?
    weak var featureDelegate: PlaceDetailDelegate?
    
    var location: PlacePin!
    var allPlaces = [PlacePin]()
    var coordinate: CLLocationCoordinate2D?
    var uiviewHeader: UIView!
    var uiviewSubHeader: FixedHeader!
    var uiviewFooter: UIView!
    
    var btnBack: UIButton!
    var btnSave: UIButton!
    var imgSaved: UIImageView!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    
    var tblNearby: UITableView!
    let arrTitle = ["Similar Places", "Near this Place"]
    var arrNearbyPlaces = [PlacePin]()
    let faeMap = FaeMap()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    
    var lblClctViewTitle: UILabel!
    var btnSeeAll: UIButton!
    var clctNearby: UICollectionView!
    //    var places = [PlacePin]()
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
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_locDetail"), object: nil)
        
        fullLoaded = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_locDetail"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideSavedNoti_locDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRelatedPlaces(lat: String(LocManager.shared.curtLat), long: String(LocManager.shared.curtLong), radius: 5000, isSimilar: false, completion: { (arrPlaces) in
            self.arrNearbyPlaces = arrPlaces
            self.clctNearby.reloadData()
        })
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
            anView.icon.image = #imageLiteral(resourceName: "icon_destination")
            return anView
        }
        return nil
    }
    
    func loadMap() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, w: 414, h: 352 + 48))
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
    
    func handleMapTap() {
        
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
                print("Get Related Places Fail \(status) \(message!)")
            }
            completion(arrPlaces)
        }
    }
    
    func loadHeader() {
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: screenHeight - 234 - 49 - 101 * screenHeightFactor, width: screenWidth, height: 101 * screenHeightFactor))
        view.addSubview(uiviewSubHeader)
        uiviewSubHeader.lblPrice.isHidden = true
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
        
        imgSaved = UIImageView(frame: CGRect(x: 29, y: 5, width: 18, height: 18))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.alpha = 0
        
        loadAddtoCollection()
    }
    
    func showSavedNoti(_ sender: Notification) {
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
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func saveThisPin() {
        func showCollections() {
            uiviewSavedList.tableMode = .location
            uiviewSavedList.loadCollectionData()
            guard let position = coordinate else { return }
            let pinData = LocationPin(position: position)
            uiviewSavedList.pinToSave = FaePinAnnotation(type: "location", cluster: nil, data: pinData as AnyObject)
            uiviewSavedList.show()
        }
        if locationId == 0 {
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
        let vcShareCollection = NewChatShareController(friendListMode: .location)
        vcShareCollection.locationDetail = "\(coordinate?.latitude ?? 0.0),\(coordinate?.longitude ?? 0.0),\(strLocName),\(strLocAddr)"
        navigationController?.pushViewController(vcShareCollection, animated: true)
    }
    
    func showAddCollectionView() {
        uiviewSavedList.show()
    }
    
    func hideAddCollectionView() {
        uiviewSavedList.hide()
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
    
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .location
        present(vc, animated: true)
    }
    // AddPlacetoCollectionDelegate End
    
    // AfterAddedToListDelegate
    func seeList() {
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.colId
        vcList.colInfo = uiviewAfterAdded.selectedCollection
        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
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
