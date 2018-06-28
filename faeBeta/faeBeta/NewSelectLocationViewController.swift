//
//  NewSelectLocationViewController.swift
//
//  Created by Yue on 5/31/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit
import RealmSwift

class NewSelectLocationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Variables Declarations
    weak var delegate: SelectLocationDelegate?
    
    // Screen Buttons
    private var uiviewTopBar: UIView!
    private var btnBack: UIButton!
    private var faeMapView: FaeMapView!
    private var btnLocat: FMLocateSelf!
    private var btnZoom: FMZoomButton!
    private var btnSelect: FMDistIndicator!
    
    // Address parsing & display
    private var lblSearchContent: UILabel!
    private var btnSearch: UIButton!
    private var btnClearSearchRes: UIButton!
    private var routeAddress: RouteAddress!
    public var mode: SelectLoctionMode = .full
    
    // Place pins data management
    private var placeClusterManager: CCHMapClusterController!
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    private var arrPlaceData = [PlacePin]()
    private var selfAnView: SelfAnnotationView?
    private var selectedPlaceAnno: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation? {
        didSet {
            if selectedPlace != nil {
                selectedLocation = nil
            }
        }
    }
    private var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // Search Bar
    private var uiviewSchbarShadow: UIView!
    private var imgSearchIcon: UIImageView!
    private var imgAddressIcon: UIImageView!
    private var btnCancelSelect: UIButton!
    private var btnMainMapSearch: UIButton!
    private var uiviewPinActionDisplay: FMPinActionDisplay! // indicate which action is being pressing to release

    // Selected Place Control
    private var swipingState: PlaceInfoBarState = .map {
        didSet {
            guard fullyLoaded else { return }
            btnTapToShowResultTbl.alpha = swipingState == .multipleSearch ? 1 : 0
            btnTapToShowResultTbl.isHidden = swipingState != .multipleSearch
            tblPlaceResult.isHidden = swipingState != .multipleSearch
        }
    }
    
    // Results from Search
    private var btnTapToShowResultTbl: UIButton!
    private var tblPlaceResult = FMPlacesTable()
    private var pinsFromSearch = [FaePinAnnotation]()
    
    // MapView Offset Control
    private var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var prevAltitude: CLLocationDistance = 0
    
    // Location Pin Control
    private var selectedLocation: FaePinAnnotation?
    private var selectedLocAnno: LocPinAnnotationView?
    private var uiviewLocationBar: FMLocationInfoBar!
    private var locationPinClusterManager: CCHMapClusterController!
    
    // Collections Managements
    private var boolCanOpenPin = true // A boolean var to control if user can open another pin, basically, user cannot open if one pin is under opening process
    private var PLACE_ENABLE = true
    private var boolPreventUserPinOpen = false
    private var fullyLoaded = false // indicate if all components are fully loaded
    private var boolCanUpdatePlaces = true
    private var PLACE_INSTANT_SHOWUP = false
    private var PLACE_INSTANT_REMOVE = false
    private var LOC_INSTANT_SHOWUP = false
    private var LOC_INSTANT_REMOVE = false
    
    // Auxiliary
    private var activityIndicator: UIActivityIndicatorView!
    
    enum PreviousViewControlerType {
        case board
        case chat
        case explore
    }
    
    public var previousVC = PreviousViewControlerType.board
    public var previousLabelText = ""
    
    var boolFromBoard = false
    var boolSearchEnabled = false
    var boolFromExplore = false
    var boolFromChat = false
    
    public var strShownLoc: String = ""
    private var strRawLoc_board: String = ""
    private var strRawLoc_explore: String = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadTopBar()
        loadButtons()
        loadPlaceDetail()
        loadLocInfoBar()
        loadPinIcon()
        fullyLoaded = true
    }
    
    deinit {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renewSelfLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTimerForAllPins()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        Key.shared.selectedLoc = LocManager.shared.curtLoc.coordinate
    }
    
    // MARK: - Switches
    
    private func checkIfResultTableAppearred() {
        tblPlaceResult.isHidden = !tblPlaceResult.showed
        btnTapToShowResultTbl.isHidden = !(tblPlaceResult.showed && swipingState == .multipleSearch)
    }
    
    private var modeLocation: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            uiviewSchbarShadow.isHidden = modeLocation != .off
            if modeLocation != .off {
                Key.shared.onlineStatus = 5
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
            } else {
                Key.shared.onlineStatus = 1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
            }
        }
    }
    
    private var modeLocCreating: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            if modeLocCreating == .off {
                uiviewLocationBar.hide()
                uiviewLocationBar.activityIndicator.stopAnimating()
                if selectedLocation != nil {
                    locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                        self.locationPinClusterManager.isForcedRefresh = true
                        self.locationPinClusterManager.manuallyCallRegionDidChange()
                        self.locationPinClusterManager.isForcedRefresh = false
                        self.deselectAllLocAnnos()
                    })
                }
            }
        }
    }
    
    private func updateTimerForAllPins() {
        updatePlacePins()
    }
    
    private func refreshMap(pins: Bool, users: Bool, places: Bool) {
        if users {
            
        }
        if places {
            updatePlacePins()
        }
    }
    
    private func reAddPlacePins(_ completion: (() -> ())? = nil) {
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: {
            completion?()
        })
    }
    
    private func reAddLocPins(_ completion: (() -> ())? = nil) {
        guard let pin = selectedLocation else { return }
        locationPinClusterManager.addAnnotations([pin], withCompletionHandler: {
            completion?()
        })
    }
    
    private func removePlacePins(_ completion: (() -> ())? = nil, otherThan pin: FaePinAnnotation? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        
        if pin != nil {
            for i in 0..<faePlacePins.count {
                if faePlacePins[i] == pin {
                    faePlacePins.remove(at: i)
                    break
                }
            }
        }
        
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(faePlacePins) {
            self.placeClusterManager.isForcedRefresh = false
            completion?()
        }
    }
    
    private func cancelAllPinLoading() {
        placeAdderQueue.cancelAllOperations()
    }
    
    func useActivityIndicator(on: Bool) {
        if on {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Load Parts
    
    private func loadPinIcon() {
        guard previousVC != .chat else { return }
        let imgIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 52))
        imgIcon.image = #imageLiteral(resourceName: "icon_destination")
        imgIcon.center.x = screenWidth / 2
        imgIcon.center.y = screenHeight / 2 - 26
        view.addSubview(imgIcon)
    }
    
    private func loadMapView() {
        faeMapView = FaeMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.showsUserLocation = true
        faeMapView.delegate = self
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.tintColor = UIColor._2499090()
        faeMapView.singleTap.isEnabled = !boolFromExplore
        faeMapView.doubleTap.isEnabled = !boolFromExplore
        faeMapView.longPress.isEnabled = !boolFromExplore
        faeMapView.isShowFourIconsEnabled = false
        faeMapView.mapAction = self
        view.addSubview(faeMapView)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        placeClusterManager.minUniqueLocationsForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 60
        locationPinClusterManager.animator = self
        locationPinClusterManager.clusterer = self
        
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        switch previousVC {
        case .board:
            if previousLabelText == "Current Location" {
                camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
            } else {
                if let locToSearch = LocManager.shared.locToSearch_board {
                    camera.centerCoordinate = locToSearch
                }
            }
        case .explore:
            if let locToSearch = LocManager.shared.locToSearch_explore {
                camera.centerCoordinate = locToSearch
            }
        case .chat:
            if let locToSearch = LocManager.shared.locToSearch_chat {
                camera.centerCoordinate = locToSearch
            }
        }
        camera.altitude = 35000
        faeMapView.setCamera(camera, animated: false)
    }
    
    @objc private func firstUpdateLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 10000, 10000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        refreshMap(pins: false, users: true, places: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    private func loadTopBar() {
        uiviewTopBar = UIView()
        uiviewTopBar.backgroundColor = .white
        uiviewTopBar.layer.cornerRadius = 2
        view.addSubview(uiviewTopBar)
        view.addConstraintsWithFormat("H:|-8-[v0]-8-|", options: [], views: uiviewTopBar)
        view.addConstraintsWithFormat("V:|-\(23+device_offset_top)-[v0(48)]", options: [], views: uiviewTopBar)
        addShadow(view: uiviewTopBar, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        btnBack = UIButton()
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        uiviewTopBar.addSubview(btnBack)
        uiviewTopBar.addConstraintsWithFormat("H:|-1-[v0(38.5)]", options: [], views: btnBack)
        uiviewTopBar.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnBack)
        
        let imgSearchIcon = UIImageView()
        imgSearchIcon.image = boolSearchEnabled ? #imageLiteral(resourceName: "Search") : #imageLiteral(resourceName: "Location")
        uiviewTopBar.addSubview(imgSearchIcon)
        uiviewTopBar.addConstraintsWithFormat("H:|-48-[v0(15)]", options: [], views: imgSearchIcon)
        uiviewTopBar.addConstraintsWithFormat("V:|-17-[v0(15)]", options: [], views: imgSearchIcon)
        
        lblSearchContent = UILabel()
        lblSearchContent.text = boolFromChat ? "Search Place or Address" : strShownLoc
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = boolFromChat ? UIColor._182182182() : UIColor._898989()
        uiviewTopBar.addSubview(lblSearchContent)
        uiviewTopBar.addConstraintsWithFormat("H:|-72-[v0]-15-|", options: [], views: lblSearchContent)
        uiviewTopBar.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblSearchContent)
        
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        uiviewTopBar.addSubview(btnClearSearchRes)
        uiviewTopBar.addConstraintsWithFormat("H:[v0(36.45)]-10-|", options: [], views: btnClearSearchRes)
        uiviewTopBar.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnClearSearchRes)
        
        let btn = UIButton()
        uiviewTopBar.addSubview(btn)
        uiviewTopBar.addConstraintsWithFormat("H:|-40-[v0]-0-|", options: [], views: btn)
        uiviewTopBar.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btn)
        btn.addTarget(self, action: #selector(actionTapTopBar(_:)), for: .touchUpInside)
    }
    
    private func loadButtons() {
        btnLocat = FMLocateSelf()
        btnLocat.removeTarget(nil, action: nil, for: .touchUpInside)
        btnLocat.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        view.addSubview(btnLocat)
        if !boolFromExplore {
            view.addConstraintsWithFormat("H:|-21-[v0(60)]", options: [], views: btnLocat)
        } else {
            view.addConstraintsWithFormat("H:[v0(60)]-21-|", options: [], views: btnLocat)
        }
        view.addConstraintsWithFormat("V:[v0(60)]-\(13+device_offset_bot)-|", options: [], views: btnLocat)
        
        btnSelect = FMDistIndicator()
        btnSelect.frame.origin.y = screenHeight - 74 - device_offset_bot
        btnSelect.lblDistance.text = "Select"
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
        view.addSubview(btnSelect)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        btnSelect.addGestureRecognizer(tapGesture)
        
        btnZoom = FMZoomButton()
        btnZoom.frame.origin.y = screenHeight - 60 - device_offset_bot - 13
        btnZoom.mapView = faeMapView
        view.addSubview(btnZoom)
        btnZoom.isHidden = boolFromExplore
        
        faeMapView.compassOffset = 73 + device_offset_bot - device_offset_bot_main //134
        faeMapView.layoutSubviews()
    }
}

// MARK: - Actions

extension NewSelectLocationViewController {
    
    private func renewSelfLocation() {
        DispatchQueue.global(qos: .default).async {
            guard CLLocationManager.locationServicesEnabled() else { return }
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                FaeMap.shared.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
                FaeMap.shared.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
                FaeMap.shared.renewCoordinate {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        // print("Successfully renew self position")
                    } else {
                        print("[renewSelfLocation] fail")
                    }
                }
            }
        }
    }
    
    @objc private func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func actionSelfPosition(_ sender: UIButton!) {
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        faeMapView.setCamera(camera, animated: false)
    }
    
    @objc private func actionTapTopBar(_ sender: UIButton) {
        switch previousVC {
        case .board:
            break
        case .chat:
            let mapSearchVC = MapSearchViewController()
            mapSearchVC.faeMapView = faeMapView
            mapSearchVC.delegate = self
            mapSearchVC.previousVC = .chat
            if let text = lblSearchContent.text {
                mapSearchVC.strSearchedPlace = text
            } else {
                mapSearchVC.strSearchedPlace = ""
            }
            navigationController?.pushViewController(mapSearchVC, animated: false)
            /*
             guard var arrVCs = navigationController?.viewControllers else { return }
             arrVCs.removeLast()
             arrVCs.append(mapSearchVC)
             navigationController?.setViewControllers(arrVCs, animated: false)
             */
        case .explore:
            break
        }
    }
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        switch previousVC {
        case .board:
            let location = CLLocation(latitude: faeMapView.centerCoordinate.latitude,
                                      longitude: faeMapView.centerCoordinate.longitude)
            delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mb_iconBeforeCurtLoc"), searchText: strRawLoc_board, location: location)
            navigationController?.popViewController(animated: false)
        case .chat:
            if selectedLocation != nil {
                let address = RouteAddress(name: selectedLocation!.address_1, coordinate: selectedLocation!.coordinate)
                navigationController?.popViewController(animated: false)
                delegate?.sendLocationBack?(address: address)
            }
            if selectedPlace != nil {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
                navigationController?.popViewController(animated: false)
                delegate?.sendPlaceBack?(placeData: placeData)
            }
        case .explore:
            let address = RouteAddress(name: strRawLoc_explore, coordinate: faeMapView.centerCoordinate)
            delegate?.sendLocationBack?(address: address)
            navigationController?.popViewController(animated: false)
        }
    }
    
    @objc private func actionClearSearchResults(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if modeLocCreating == .on {
            modeLocCreating = .off
            return
        }
        PLACE_ENABLE = true
        
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        
        btnClearSearchRes.isHidden = true
        btnZoom.isHidden = false
        
        tblPlaceResult.searchState = .map
        swipingState = .map
        tblPlaceResult.hide(animated: false)
        hideTableResultsExpandingIndicator()
        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        
        tblPlaceResult.alpha = 0
        
        faeMapView.mapGesture(isOn: true)
        deselectAllPlaceAnnos()
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch) {
            self.pinsFromSearch.removeAll(keepingCapacity: true)
            self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
            })
        }
    }
    
    @objc private func actionShowResultTbl(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.expand {
                let iphone_x_offset: CGFloat = 70
                self.btnTapToShowResultTbl.center.y = screenHeight - 164 * screenHeightFactor + 15 + 68 + device_offset_top - iphone_x_offset
            }
            btnZoom.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            sender.tag = 0
            tblPlaceResult.shrink {
                self.btnTapToShowResultTbl.center.y = 181 + device_offset_top
            }
            btnZoom.isHidden = false
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
        }
    }
}

extension NewSelectLocationViewController: MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer {
    
    // MARK: - Cluster Delegates
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, coordinateForAnnotations annotations: Set<AnyHashable>!, in mapRect: MKMapRect) -> IsSelectedCoordinate {
        for annotation in annotations {
            guard let pin = annotation as? FaePinAnnotation else { continue }
            if pin.isSelected {
                return IsSelectedCoordinate(isSelected: true, coordinate: pin.coordinate)
            }
        }
        guard let firstAnn = annotations.first as? FaePinAnnotation else {
            return IsSelectedCoordinate(isSelected: false, coordinate: CLLocationCoordinate2DMake(0, 0))
        }
        return IsSelectedCoordinate(isSelected: false, coordinate: firstAnn.coordinate)
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.superview?.sendSubview(toBack: anView)
                if PLACE_INSTANT_SHOWUP { // immediatelly show up
                    anView.imgIcon.frame = CGRect(x: -8, y: -5, width: 56, height: 56)
                    anView.alpha = 1
                } else {
                    anView.alpha = 0
                    anView.imgIcon.frame = CGRect(x: 20, y: 46, width: 0, height: 0)
                    let delay: Double = Double(arc4random_uniform(50)) / 100 // Delay 0-1 seconds, randomly
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.75, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                            anView.imgIcon.frame = CGRect(x: -8, y: -5, width: 56, height: 56)
                            anView.alpha = 1
                        }, completion: nil)
                    }
                }
            } else if let anView = annotationView as? UserPinAnnotationView {
                anView.superview?.bringSubview(toFront: anView)
                anView.alpha = 0
                let delay: Double = Double(arc4random_uniform(50)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: delay, animations: {
                        anView.alpha = 1
                    })
                }
            } else if let anView = annotationView as? LocPinAnnotationView {
                if LOC_INSTANT_SHOWUP {
                    anView.alpha = 1
                } else {
                    anView.alpha = 0
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            anView.alpha = 1
                        })
                    }
                }
            } else if let anView = annotationView as? MKAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, animations: {
                        anView.alpha = 1
                    })
                }
            }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willRemoveAnnotations annotations: [Any]!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        
        if (mapClusterController == placeClusterManager && PLACE_INSTANT_REMOVE) || (mapClusterController == locationPinClusterManager && LOC_INSTANT_REMOVE) { // immediatelly remove
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
            if completionHandler != nil { completionHandler() }
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
        }) { _ in
            if completionHandler != nil { completionHandler() }
        }
        
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        
        switch mapClusterController {
        case placeClusterManager:
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                var found = false
                for annotation in mapClusterAnnotation.annotations {
                    guard let pin = annotation as? FaePinAnnotation else { continue }
                    guard let sPlace = selectedPlace else { continue }
                    if faeBeta.coordinateEqual(pin.coordinate, sPlace.coordinate) {
                        found = true
                        anView.assignImage(pin.icon)
                    }
                }
                if !found {
                    let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
                    anView.assignImage(firstAnn.icon)
                }
                anView.superview?.bringSubview(toFront: anView)
            }
        case locationPinClusterManager:
            break
        default:
            break
        }
        
        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
        if firstAnn.type == .location {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? LocPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
        if selectedPlaceAnno != nil {
            selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
            selectedPlaceAnno?.layer.zPosition = 199
        }
    }
    
    // MARK: - MapView Delegates
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard boolCanOpenPin else { return }
        
        if view is PlacePinAnnotationView {
            tapPlacePin(didSelect: view)
        } else if view is SelfAnnotationView {
            boolCanOpenPin = false
            faeMapView.mapGesture(isOn: false)
            guard let anView = view as? SelfAnnotationView else { return }
            anView.mapAvatar = Key.shared.userMiniAvatar
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let identifier = "self"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
                selfAnView = anView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                selfAnView = anView
            }
            anView.changeAvatar()
            if Key.shared.onlineStatus == 5 {
                anView.invisibleOn()
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .user {
                return nil
            } else {
                return viewForLocation(annotation: annotation, first: firstAnn)
            }
        } else if annotation is AddressAnnotation {
            guard let addressAnno = annotation as? AddressAnnotation else { return nil }
            let identifier = addressAnno.isStartPoint ? "start_point" : "destination"
            var anView: AddressAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AddressAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = AddressAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            anView.assignImage(addressAnno.isStartPoint ? #imageLiteral(resourceName: "icon_startpoint") : #imageLiteral(resourceName: "icon_destination"))
            return anView
        } else if annotation is FaePinAnnotation {
            guard let firstAnn = annotation as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForSelectedPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .location {
                return viewForLocation(annotation: annotation, first: firstAnn)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if previousVC == .board {
            LocManager.shared.locToSearch_board = mapView.centerCoordinate
        } else if previousVC == .explore {
            LocManager.shared.locToSearch_explore = mapView.centerCoordinate
        }
        
        calculateDistanceOffset()
        
        if swipingState == .multipleSearch && tblPlaceResult.altitude == 0 {
            tblPlaceResult.altitude = mapView.camera.altitude
        }
        
        if tblPlaceResult.tag > 0 && PLACE_ENABLE { tblPlaceResult.annotations = visiblePlaces() }
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        switch mode {
        case .full:
            General.shared.getAddress(location: location) { [weak self] address in
                guard let `self` = self else { return }
                guard let addr = address as? String else { return }
                DispatchQueue.main.async {
                    //self.lblSearchContent.text = addr
                    self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
                }
            }
        case .part:
            // .chat or .explore
            guard previousVC == .board || previousVC == .explore else { return }
            General.shared.getAddress(location: location, original: false, full: false, detach: true) { [weak self]  (address) in
                guard let `self` = self else { return }
                if let addr = address as? String {
                    let new = addr.split(separator: "@")
                    guard new.count > 0 else { return }
                    if new.count == 2 {
                        self.strRawLoc_board = String(new[0]) + "@" + String(new[1])
                        self.strRawLoc_explore = String(new[0]) + "," + String(new[1])
                        self.processAddress(String(new[0]), String(new[1]))
                    } else if new.count == 1 {
                        self.strRawLoc_board = String(new[0]) + "@" + ""
                        self.strRawLoc_explore = String(new[0]) + "@" + ""
                        self.processAddress(String(new[0]), "")
                    }
                    DispatchQueue.main.async {
                        self.btnSelect.lblDistance.textColor = UIColor._2499090()
                        self.btnSelect.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    private func processAddress(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: FaeFont(fontType: .medium, size: 18)]
        let title_0_attr = NSMutableAttributedString(string: city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: FaeFont(fontType: .medium, size: 18)]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        DispatchQueue.main.async {
            self.lblSearchContent.attributedText = fullAttrStr
        }
    }
    
    func animateToCoordinate(type: Int, coordinate: CLLocationCoordinate2D, animated: Bool) {
        var offset: CGFloat = 0
        if type == 0 { // Map pin
            offset = 530 * screenHeightFactor - screenHeight / 2 // 488 530
        } else if type == 1 { // Map pin
            offset = 465 * screenHeightFactor - screenHeight / 2 // 458 500
        } else if type == 2 { // Place pin
            offset = 492 * screenHeightFactor - screenHeight / 2 // offset: 42
        }
        
        var curPoint = faeMapView.convert(coordinate, toPointTo: nil)
        curPoint.y -= offset
        let newCoordinate = faeMapView.convert(curPoint, toCoordinateFrom: nil)
        let point: MKMapPoint = MKMapPointForCoordinate(newCoordinate)
        var rect: MKMapRect = faeMapView.visibleMapRect
        rect.origin.x = point.x - rect.size.width * 0.5
        rect.origin.y = point.y - rect.size.height * 0.5
        
        faeMapView.setVisibleMapRect(rect, animated: animated)
    }
    
    private func deselectAllPlaceAnnos(full: Bool = true) {
        
        uiviewPinActionDisplay.hide()
        boolCanOpenPin = true
        
        if let idx = selectedPlace?.category_icon_id {
            if full {
                selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
                selectedPlace?.isSelected = false
                guard let img = selectedPlace?.icon else { return }
                selectedPlaceAnno?.assignImage(img)
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
                selectedPlaceAnno?.zPos = 7
                selectedPlaceAnno?.optionsReady = false
                selectedPlaceAnno?.optionsOpened = false
                selectedPlaceAnno = nil
                selectedPlace = nil
            } else {
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.optionsOpened = false
            }
        }
    }
    
    private func deselectAllLocAnnos() {
        uiviewLocationBar.hide()
        uiviewPinActionDisplay.hide()
        boolCanOpenPin = true
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno = nil
        selectedLocation = nil
    }
    
    private func calculateDistanceOffset() {
        DispatchQueue.global(qos: .userInitiated).async {
            let curtMapCenter = self.faeMapView.camera.centerCoordinate
            let point_a = MKMapPointForCoordinate(self.prevMapCenter)
            let point_b = MKMapPointForCoordinate(curtMapCenter)
            let distance = MKMetersBetweenMapPoints(point_a, point_b)
            guard distance >= self.screenWidthInMeters() else { return }
            self.prevMapCenter = curtMapCenter
            DispatchQueue.main.async {
                self.updatePlacePins()
            }
        }
    }
    
    private func screenWidthInMeters() -> CLLocationDistance {
        let cgpoint_a = CGPoint(x: 0, y: 0)
        let cgpoint_b = CGPoint(x: screenWidth, y: 0)
        let coor_a = faeMapView.convert(cgpoint_a, toCoordinateFrom: nil)
        let coor_b = faeMapView.convert(cgpoint_b, toCoordinateFrom: nil)
        let point_a = MKMapPointForCoordinate(coor_a)
        let point_b = MKMapPointForCoordinate(coor_b)
        let distance = MKMetersBetweenMapPoints(point_a, point_b)
        return distance * 0.6
    }
    
    public func mapGesture(isOn: Bool) {
        faeMapView.mapGesture(isOn: isOn)
    }
}

// MARK: - Search

extension NewSelectLocationViewController: MapSearchDelegate {
    
    // MapSearchDelegate
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        PLACE_ENABLE = false
        updateUI(searchText: searchText)
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        cancelAllPinLoading()
        btnTapToShowResultTbl.isHidden = places.count <= 1
        if let _ = places.first {
            swipingState = .multipleSearch
            tblPlaceResult.places = tblPlaceResult.updatePlacesArray(places: places)
            tblPlaceResult.loading(current: places[0])
            pinsFromSearch = tblPlaceResult.places.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
            removePlacePins({
                
                self.PLACE_INSTANT_SHOWUP = true
                self.placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                    if let first = places.first {
                        self.goTo(annotation: nil, place: first, animated: true)
                    }
                    self.PLACE_INSTANT_SHOWUP = false
                })
                faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                           places: self.tblPlaceResult.arrPlaces,
                                           edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
            }, otherThan: nil)
            placeClusterManager.maxZoomLevelForClustering = 0
        } else {
            swipingState = .map
            tblPlaceResult.hide(animated: false)
            hideTableResultsExpandingIndicator()
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        }
    }
    
    func selectLocation(location: CLLocation) {
        createLocPin(location)
        let camera = faeMapView.camera
        camera.centerCoordinate = location.coordinate
        camera.altitude = 15000
        faeMapView.setCamera(camera, animated: false)
    }
    
    // MapSearchDelegate End
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
}

// MARK: - Place Bar & Table

extension NewSelectLocationViewController: PlaceViewDelegate, FMPlaceTableDelegate {
    
    // FMPlaceTableDelegate
    func selectPlaceFromTable(_ placeData: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeData
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // FMPlaceTableDelegate
    func reloadPlacesOnMap(places: [PlacePin]) {
        self.PLACE_INSTANT_SHOWUP = true
        //self.placeClusterManager.marginFactor = 10000
        let camera = faeMapView.camera
        camera.altitude = tblPlaceResult.altitude
        faeMapView.setCamera(camera, animated: false)
        reloadPlacePinsOnMap(places: places) {
            self.goTo(annotation: nil, place: self.tblPlaceResult.getGroupLastSelectedPlace(), animated: true)
            self.PLACE_INSTANT_SHOWUP = false
        }
    }
    
    private func loadPlaceDetail() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPlaceBar))
        tblPlaceResult.addGestureRecognizer(tapGesture)
        
        tblPlaceResult.tblDelegate = self
        tblPlaceResult.barDelegate = self
        view.addSubview(tblPlaceResult)
        
        btnTapToShowResultTbl = UIButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = 181 + device_offset_top
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    private func hideTableResultsExpandingIndicator() {
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.tag = 1
        btnTapToShowResultTbl.sendActions(for: .touchUpInside)
    }
    
    @objc private func handleTapPlaceBar() {
        
    }
    
    // PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil, animated: Bool = true) {
        
        func findAnnotation() {
            if let placeData = place {
                swipingState = .multipleSearch
                var desiredAnno: CCHMapClusterAnnotation!
                for anno in faeMapView.annotations {
                    guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                    guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                    guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                    if placeInfo == placeData {
                        desiredAnno = cluster
                        break
                    }
                }
                if animated {
                    faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: placeData.coordinate)
                }
                if desiredAnno != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                }
            }
        }
        
        deselectAllPlaceAnnos()
        if let anno = annotation {
            swipingState = .map
            boolPreventUserPinOpen = true
            faeMapView.selectAnnotation(anno, animated: false)
            boolPreventUserPinOpen = false
            if animated {
                faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: anno.coordinate)
            }
        }
        
        // If going to prev or next group
        if tblPlaceResult.goingToNextGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: true)
            self.PLACE_INSTANT_SHOWUP = true
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToNextGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else if tblPlaceResult.goingToPrevGroup {
            self.PLACE_INSTANT_SHOWUP = true
            tblPlaceResult.configureCurrentPlaces(goingNext: false)
            reloadPlacePinsOnMap(places: tblPlaceResult.places) {
                findAnnotation()
                self.tblPlaceResult.goingToPrevGroup = false
                self.PLACE_INSTANT_SHOWUP = false
            }
            return
        } else {
            findAnnotation()
        }
        if let placePin = place { // 必须放在最末尾
            tblPlaceResult.loading(current: placePin)
        }
    }
}

// MARK: - Place Pin

extension NewSelectLocationViewController {
    
    private func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.iconIndex = first.category_icon_id
        if swipingState == .multipleSearch {
            if let placePin = first.pinInfo as? PlacePin {
                let tag = tblPlaceResult.tblResults.tag
                if let lastSelected = tblPlaceResult.groupLastSelected[tag] {
                    if placePin == lastSelected {
                        let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
                        anView.assignImage(icon)
                        tapPlacePin(didSelect: anView)
                    } else {
                        anView.assignImage(first.icon)
                    }
                } else {
                    anView.assignImage(first.icon)
                }
            } else {
                anView.assignImage(first.icon)
            }
        } else {
            anView.assignImage(first.icon)
        }
        if first.isSelected {
            let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
            anView.assignImage(icon)
            anView.optionsReady = true
            anView.optionsOpened = false
            selectedPlaceAnno = anView
        }
        
        return anView
    }
    
    private func viewForSelectedPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place_selected"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        return anView
    }
    
    private func visiblePlaces(full: Bool = false) -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        if !full {
            mapRect.origin.y += mapRect.size.height * 0.3
            mapRect.size.height = mapRect.size.height * 0.7
        }
        let visibleAnnos = faeMapView.annotations(in: mapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard faeMapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == .place else { continue }
                places.append(place)
            } else {
                continue
            }
        }
        return places
    }
    
    private func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        let idx = firstAnn.category_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48s")
        firstAnn.isSelected = true
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceAnno = anView
        faeMapView.selectedPlaceAnno = anView
        selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
        selectedPlaceAnno?.zPos = 199
        guard firstAnn.type == .place else { return }
        guard let placePin = firstAnn.pinInfo as? PlacePin else { return }
        tblPlaceResult.show()
        tblPlaceResult.resetSubviews()
        tblPlaceResult.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: false)
        if swipingState == .map {
            tblPlaceResult.loadingData(current: cluster)
        } else if swipingState == .multipleSearch {
            tblPlaceResult.loading(current: placePin)
        }
    }
    
    private func updatePlacePins() {
        let coorDistance = cameraDiagonalDistance(mapView: faeMapView)
        refreshPlacePins(radius: coorDistance)
    }
    
    private func refreshPlacePins(radius: Int) {
        func getDelay(prevTime: DispatchTime) -> Double {
            let standardInterval: Double = 1
            let nowTime = DispatchTime.now()
            let timeDiff = Double(nowTime.uptimeNanoseconds - prevTime.uptimeNanoseconds)
            var delay: Double = 0
            if timeDiff / Double(NSEC_PER_SEC) < standardInterval {
                delay = standardInterval - timeDiff / Double(NSEC_PER_SEC)
            } else {
                delay = timeDiff / Double(NSEC_PER_SEC) - standardInterval
            }
            return delay
        }
        
        
        guard PLACE_ENABLE else {
            
            return
        }
        guard boolCanUpdatePlaces else {
            
            return
        }
        boolCanUpdatePlaces = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        
        FaeMap.shared.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        FaeMap.shared.whereKey("radius", value: "\(radius)")
        FaeMap.shared.whereKey("type", value: "place")
        FaeMap.shared.whereKey("max_count", value: "200")
        FaeMap.shared.getMapInformation { [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
            guard status / 100 == 2 && message != nil else {
                
                self.boolCanUpdatePlaces = true
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                
                self.boolCanUpdatePlaces = true
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                
                self.boolCanUpdatePlaces = true
                return
            }
            self.placeAdderQueue.cancelAllOperations()
            let adder = PlacePinFetcher(cluster: self.placeClusterManager, arrPlaceJSON: mapPlaceJsonArray, idSet: self.setPlacePins)
            adder.completionBlock = {
                DispatchQueue.main.async {
                    if adder.isCancelled {
                        return
                    }
                    self.placeClusterManager.addAnnotations(adder.placePins, withCompletionHandler: {
                        self.setPlacePins = self.setPlacePins.union(Set(adder.ids))
                        self.faePlacePins += adder.placePins
                    })
                }
            }
            self.placeAdderQueue.addOperation(adder)
            self.boolCanUpdatePlaces = true
            
        }
    }
    
    // MARK: - Reload Place Pins
    private func reloadPlacePinsOnMap(places: [PlacePin], completion: @escaping () -> Void) {
        placeClusterManager.isForcedRefresh = true
        placeClusterManager.removeAnnotations(pinsFromSearch) {
            self.pinsFromSearch = places.map({ FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0 as AnyObject) })
            self.placeClusterManager.addAnnotations(self.pinsFromSearch, withCompletionHandler: {
                self.placeClusterManager.isForcedRefresh = false
                completion()
            })
        }
    }
}

// MARK: - Location Pin

extension NewSelectLocationViewController: LocDetailDelegate {
    
    // MARK: - LocDetailDelegate
    func jumpToViewLocation(coordinate: CLLocationCoordinate2D, created: Bool) {
        if !created {
            createLocationPin(coordinate: coordinate)
            modeLocation = .on_create
        } else {
            selectedLocAnno?.hideButtons(animated: false)
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            modeLocation = .on
        }
    }
    
    private func tapLocationPin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? LocPinAnnotationView else { return }
        anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
        selectedLocation = firstAnn
        selectedLocAnno = anView
        faeMapView.selectedLocAnno = anView
        selectedLocAnno?.zPos = 299
        guard firstAnn.type == .location else { return }
        guard let locationData = firstAnn.pinInfo as? LocationPin else { return }
        if !anView.optionsReady {
            let cllocation = CLLocation(latitude: locationData.coordinate.latitude, longitude: locationData.coordinate.longitude)
            uiviewLocationBar.updateLocationInfo(location: cllocation) { [weak self] (address_1, address_2) in
                guard let `self` = self else { return }
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
            }
        }
        mapView(faeMapView, regionDidChangeAnimated: false)
    }
    
    private func loadLocInfoBar() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocInfoBarTap))
        uiviewLocationBar.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLocInfoBarTap() {
        
    }
    
    private func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        selectedLocAnno = anView
        anView.assignImage(first.icon)
        if first.isSelected {
            // when back from routing, re-select the location
            anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
            anView.optionsReady = true
            anView.optionsOpened = false
        }
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        if let locationData = first.pinInfo as? LocationPin {
            anView.optionsReady = locationData.optionsReady
        }
        return anView
    }
    
    private func createLocationPin(point: CGPoint) {
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        createLocPin(location)
    }
    
    private func createLocationPin(location: CLLocation) {
        createLocPin(location)
    }
    
    private func createLocationPin(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        createLocPin(location)
    }
    
    private func createLocPin(_ location: CLLocation) {
        guard modeLocation == .off else { return }
        modeLocCreating = .on
        
        func createLoc() {
            tblPlaceResult.hide()
            hideTableResultsExpandingIndicator()
            selectedLocAnno?.hideButtons()
            selectedLocAnno?.optionsReady = false
            selectedLocAnno?.optionsOpened = false
            selectedLocAnno?.optionsOpeing = false
            selectedLocAnno?.removeFromSuperview()
            selectedLocAnno = nil
            deselectAllPlaceAnnos()
            let pinData = LocationPin(position: location.coordinate)
            pinData.optionsReady = true
            selectedLocation = FaePinAnnotation(type: .location, data: pinData as AnyObject)
            selectedLocation?.isSelected = true
            selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            locationPinClusterManager.addAnnotations([self.selectedLocation!], withCompletionHandler: nil)
            uiviewLocationBar.updateLocationInfo(location: location) { (address_1, address_2) in
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
            }
        }
        
        if selectedLocation != nil {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: {
                self.selectedLocation = nil
                createLoc()
            })
        } else {
            createLoc()
        }
    }
}

// MARK: - MapAction Protocol
extension NewSelectLocationViewController: MapAction {
    func iconStyleChange(action: Int, isPlace: Bool) {
        if isPlace {
            guard let anView = selectedPlaceAnno else { return }
            switch action {
            case 1:
                anView.action(anView.btnDetail, animated: true)
            case 2:
                anView.action(anView.btnCollect, animated: true)
            case 3:
                anView.action(anView.btnRoute, animated: true)
            case 4:
                anView.action(anView.btnShare, animated: true)
            default:
                anView.optionsToNormal()
                break
            }
        } else {
            guard let anView = selectedLocAnno else { return }
            switch action {
            case 1:
                anView.action(anView.btnDetail, animated: true)
            case 2:
                anView.action(anView.btnCollect, animated: true)
            case 3:
                anView.action(anView.btnRoute, animated: true)
            case 4:
                anView.action(anView.btnShare, animated: true)
            default:
                anView.optionsToNormal()
                break
            }
        }
        if action == 0 {
            uiviewPinActionDisplay.hide()
        } else {
            uiviewPinActionDisplay.changeStyle(action: PlacePinAction(rawValue: action)!, isPlace)
        }
    }
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
    }
    
    func locPinTap(view: MKAnnotationView) {
        tapLocationPin(didSelect: view)
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos(full: full)
    }
    
    func singleElsewhereTap() {
        btnZoom.tapToSmallMode()
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        if swipingState != .multipleSearch {
            tblPlaceResult.hide()
            hideTableResultsExpandingIndicator()
        }
        deselectAllPlaceAnnos(full: swipingState == .map)
    }
    
    func locPinCreating(point: CGPoint) {
        createLocationPin(point: point)
    }
    
    func locPinCreatingCancel() {
        if modeLocCreating == .on {
            if modeLocation == .off {
                modeLocCreating = .off
            }
        } else if modeLocCreating == .off {
            selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            deselectAllLocAnnos()
        }
    }
    
    func singleTapAllTimeControl() {

    }
    
    func doubleElsewhereTap() {
        faeMapView.mapGesture(isOn: true)
    }
    
    func doubleTapAllTimeControl() {

    }
    
    func longPressAllTimeCtrlWhenBegan() {

    }
}
