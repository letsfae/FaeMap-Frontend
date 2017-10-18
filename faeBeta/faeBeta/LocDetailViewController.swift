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
class LocDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPlacetoCollectionDelegate, MKMapViewDelegate {
    
    weak var delegate: MapSearchDelegate?
    
    var place: PlacePin!
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
    
    var uiviewAddCollection: AddPlaceToCollectionView!
    
    var lblClctViewTitle: UILabel!
    var btnSeeAll: UIButton!
    var clctNearby: UICollectionView!
    //    var places = [PlacePin]()
    weak var delegateSeeAll: SeeAllPlacesDelegate?
    
    var strLocName = ""
    var strLocAddr = ""
    
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadMap()
        loadHeader()
        loadCollectionView()
        loadFooter()
        updateLocation()
//        let line = UIView(frame: CGRect(x: 0, y: 169, width: screenWidth, height: 1))
//        line.backgroundColor = .black
//        view.addSubview(line)
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
        btnSave.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnRoute = UIButton(frame: CGRect(x: (screenWidth - 47) / 2, y: 2, width: 47, height: 47))
        btnRoute.setImage(#imageLiteral(resourceName: "place_route"), for: .normal)
        btnRoute.tag = 1
        btnRoute.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnShare = UIButton(frame: CGRect(x: screenWidth / 2 + 58, y: 2, width: 47, height: 47))
        btnShare.setImage(#imageLiteral(resourceName: "place_share"), for: .normal)
        btnShare.tag = 2
        btnShare.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        uiviewFooter.addSubview(btnBack)
        uiviewFooter.addSubview(btnSave)
        uiviewFooter.addSubview(btnRoute)
        uiviewFooter.addSubview(btnShare)
        
        imgSaved = UIImageView(frame: CGRect(x: 29, y: 5, width: 18, height: 18))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.isHidden = true
        
        loadAddtoCollection()
    }
    
    fileprivate func loadAddtoCollection() {
        uiviewAddCollection = AddPlaceToCollectionView()
        uiviewAddCollection.delegate = self
        uiviewAddCollection.tableMode = .location
        view.addSubview(uiviewAddCollection)
    }
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if boolSaved {
                faePinAction.unsaveThisPin("location", pinID: String(place.id)) { (status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.boolSaved = false
                        self.imgSaved.isHidden = true
                    } else {
                        print("[PlaceDetail-Unsave Pin] Unsave Place Pin Fail \(status) \(message!)")
                    }
                }
            } else {
                showAddCollectionView()
            }
            break
        case 1:
            break
        case 2:
            // TODO jichao
            
            break
        default:
            break
        }
    }
    
    func showAddCollectionView() {
        uiviewAddCollection.show()
    }
    
    func hideAddCollectionView() {
        uiviewAddCollection.hide()
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
    // SeeAllPlacesDelegate End
    
    // AddPlacetoCollectionDelegate
    func cancelAddPlace() {
        hideAddCollectionView()
    }
    
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .location
        present(vc, animated: true)
        //        navigationController?.pushViewController(vc, animated: true)
    }
    // AddPlacetoCollectionDelegate End
}
