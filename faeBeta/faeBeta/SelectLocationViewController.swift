//
//  SelectLocationViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import Alamofire

// An enum type to return different geo -> address
enum SelectLoctionMode {
    case full
    case part
}

@objc protocol SelectLocationDelegate: class {
    @objc optional func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation)
    @objc optional func sendLocationBack(address: RouteAddress)
    @objc optional func sendPlaceBack(placeData: PlacePin)
    @objc optional func chooseLocationOnMap()
}

class SelectLocationViewController: UIViewController, MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer, PlaceViewDelegate, FMPlaceTableDelegate {
    
    // MARK: - Variables Declarations
    weak var delegate: SelectLocationDelegate?
    
    // Screen Buttons
    private var uiviewTopBar: UIView!
    private var btnBack: UIButton!
    private var faeMapView: FaeMapView!
    private var btnLocat: FMLocateSelf!
    private var btnZoom: FMZoomButton!
    private var btnSelect: FMDistIndicator!
    private var btnRefreshIcon: FMRefreshIcon!
    
    // Address parsing & display
    private var lblSearchContent: UILabel!
    private var btnSearch: UIButton!
    private var btnClearSearchRes: UIButton!
    private var routeAddress: RouteAddress!
    public var mode: SelectLoctionMode = .full
    
    // Place pins data management
    private var isForcedRefresh: Bool = false
    private var placeClusterManager: CCHMapClusterController!
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    private var arrPlaceData = [PlacePin]()
    private var selectedPlaceAnno: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation? {
        didSet {
            if selectedPlace != nil {
                selectedLocation = nil
            }
        }
    }
    private var placePinFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "placePinFetchQueue_select_location"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // Results from Search
    private var btnTapToShowResultTbl: FMTableExpandButton!
    private var tblPlaceResult = FMPlacesTable()
    private var placesFromSearch = [PlacePin]()
    private var locationsFromSearch = [LocationPin]()
    private var pinsFromSearch = [FaePinAnnotation]()
    private var strSearchedText: String = ""
    private var searchState: PlaceInfoBarState = .map
    
    // Boolean values
    private var fullyLoaded = false // if all ui components are fully loaded
    private var PLACE_ENABLE = true
    var boolFromBoard = false
    var boolSearchEnabled = false
    var boolFromExplore = false
    var boolFromChat = false
    private var PLACE_FETCH_ENABLE = true
    private var PLACE_INSTANT_SHOWUP = false
    private var PLACE_INSTANT_REMOVE = false
    private var LOC_INSTANT_SHOWUP = false
    private var LOC_INSTANT_REMOVE = false
    private var boolCanUpdatePlaces = true
    private var isGeoCoding: Bool = false
    
    public var strShownLoc: String = "Loading......"
    private var strRawLoc_board: String = ""
    private var strRawLoc_explore: String = ""
    
    // Place Pin Control
    private var placePinRequests = [Int: DataRequest]()
    private var rawPlaceJSONs = [JSON]()
    private var placeFetchesCount = 0 {
        didSet {
            guard placeFetchesCount == 24 else { return }
            doneFetchingAreaPlaceData()
        }
    }
    private var mapViewPanningFetchesCount = 0 {
        didSet {
            guard mapViewPanningFetchesCount == numberOfAreasWithNoPins else { return }
            doneFetchingAreaPlaceData()
        }
    }
    private var numberOfAreasWithNoPins = 48
    private var time_start: DispatchTime!
    var point_centers = [CGPoint]()
    var coordinates = [CLLocationCoordinate2D]()
    
    // Location Pin Control
    private var selectedLocation: FaePinAnnotation? {
        didSet {
            if selectedLocation != nil {
                selectedPlace = nil
            }
        }
    }
    private var uiviewLocationBar: FMLocationInfoBar!
    private var selectedLocAnno: LocPinAnnotationView?
    private var activityIndicatorLocPin: UIActivityIndicatorView!
    private var locationPinClusterManager: CCHMapClusterController!
    
    private var chosenLocation: CLLocationCoordinate2D?
    
    private var modeLocation: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            if modeLocation != .off {

            } else {
                
            }
        }
    }
    
    private var modeLocCreating: FaeMode = .off {
        didSet {
            guard fullyLoaded else { return }
            if modeLocCreating == .off {
                uiviewLocationBar.hide()
                activityIndicatorLocPin.stopAnimating()
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
    
    enum PreviousViewControlerType {
        case board
        case chat
        case explore
    }
    
    public var previousVC = PreviousViewControlerType.board
    public var previousLabelText = ""
    
    // MapView Offset Control
    private var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var prevAltitude: CLLocationDistance = 0
    
    private var isLoadingMapCenterCityInfoDisabled: Bool = false
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadTopBar()
        loadButtons()
        loadLocationView()
        loadPlaceDetailTable()
        loadPinIcon()
        loadRefreshButton()
        let edgeView = LeftMarginToEnableNavGestureView()
        view.addSubview(edgeView)
        
        initScreenPointCenters()
        
        fullyLoaded = true
        mapView(faeMapView, regionDidChangeAnimated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePlacePins()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapFilterAnimationRestart"), object: nil)
    }
    
    // MARK: - Loading Parts
    
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
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = false
        faeMapView.longPress.isEnabled = true
        faeMapView.isShowFourIconsEnabled = false
        faeMapView.isOnlyCreatingLocationPin = true
        faeMapView.mapAction = self
        view.addSubview(faeMapView)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = Double(screenWidth / 5)
        //placeClusterManager.minUniqueLocationsForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        placeClusterManager.marginFactor = 1
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 60
        locationPinClusterManager.animator = self
        locationPinClusterManager.clusterer = self
        locationPinClusterManager.forPlacePin = false
        
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
        prevMapCenter = camera.centerCoordinate
        faeMapView.setCamera(camera, animated: false)
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
        uiviewTopBar.addConstraintsWithFormat("H:|-40-[v0]-50-|", options: [], views: btn)
        uiviewTopBar.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btn)
        btn.addTarget(self, action: #selector(actionTapTopBar(_:)), for: .touchUpInside)
    }
    
    private func loadButtons() {
        btnLocat = FMLocateSelf()
        btnLocat.removeTarget(nil, action: nil, for: .touchUpInside)
        btnLocat.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        btnLocat.frame.size = CGSize(width: 60, height: 60)
        view.addSubview(btnLocat)
        if previousVC != .explore {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionSelect(_:)))
        btnSelect.addGestureRecognizer(tapGesture)
        
        btnZoom = FMZoomButton()
        btnZoom.frame.origin.y = screenHeight - 60 - device_offset_bot - 13
        btnZoom.mapView = faeMapView
        view.addSubview(btnZoom)
        btnZoom.isHidden = previousVC == .explore
        btnZoom.disableMapViewDidChange = { [weak self] (disabled) in
            guard let `self` = self else { return }
            self.isLoadingMapCenterCityInfoDisabled = disabled
            if !disabled {
                self.mapView(self.faeMapView, regionDidChangeAnimated: true)
            }
        }
        btnZoom.enableClusterManager = { [weak self] (enabled, isForcedRefresh) in
            guard let `self` = self else { return }
            self.placeClusterManager.canUpdate = enabled
            if let shouldRefresh = isForcedRefresh {
                self.placeClusterManager.isForcedRefresh = shouldRefresh
                self.placeClusterManager.manuallyCallRegionDidChange()
                self.placeClusterManager.isForcedRefresh = false
            }
        }
        
        faeMapView.compassOffset = 73 + device_offset_bot - device_offset_bot_main //134
        faeMapView.layoutSubviews()
    }
    
    private func loadLocationView() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        loadActivityIndicator()
    }
    
    private func loadActivityIndicator() {
        activityIndicatorLocPin = UIActivityIndicatorView()
        activityIndicatorLocPin.activityIndicatorViewStyle = .gray
        activityIndicatorLocPin.center = CGPoint(x: screenWidth / 2, y: 110 + device_offset_top)
        activityIndicatorLocPin.hidesWhenStopped = true
        activityIndicatorLocPin.color = UIColor._2499090()
        activityIndicatorLocPin.layer.zPosition = 2000
        view.addSubview(activityIndicatorLocPin)
    }
    
    private func loadPlaceDetailTable() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPlaceBar))
        tblPlaceResult.addGestureRecognizer(tapGesture)
        
        tblPlaceResult.tblDelegate = self
        tblPlaceResult.barDelegate = self
        if previousVC == .chat {
            tblPlaceResult.currentVC = .chat
        }
        view.addSubview(tblPlaceResult)
        tblPlaceResult.reloadVisibleAnnotations = { [unowned self] in
            self.reloadPlaceTableAnnotations()
        }
        
        btnTapToShowResultTbl = FMTableExpandButton()
        btnTapToShowResultTbl.setImage(#imageLiteral(resourceName: "tapToShowResultTbl"), for: .normal)
        btnTapToShowResultTbl.frame.size = CGSize(width: 58, height: 30)
        btnTapToShowResultTbl.center.x = screenWidth / 2
        btnTapToShowResultTbl.center.y = btnTapToShowResultTbl.before
        view.addSubview(btnTapToShowResultTbl)
        btnTapToShowResultTbl.alpha = 0
        btnTapToShowResultTbl.addTarget(self, action: #selector(self.actionShowResultTbl(_:)), for: .touchUpInside)
    }
    
    // MARK: - FMPlaceTableDelegate
    // FMPlaceTableDelegate
    func selectPlaceFromTable(_ placeData: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeData
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // FMPlaceTableDelegate
    func reloadPlacesOnMap(places: [PlacePin], animated: Bool) {
        self.PLACE_INSTANT_SHOWUP = true
        //self.placeClusterManager.marginFactor = 10000
        let camera = faeMapView.camera
        camera.altitude = tblPlaceResult.altitude
        faeMapView.setCamera(camera, animated: false)
        reloadPlacePinsOnMap(places: places) {
            self.goTo(annotation: nil, place: places[0], animated: animated)
            self.PLACE_INSTANT_SHOWUP = false
        }
    }
    
    // MARK: - Reload Place Pins
    private func reloadPlacePinsOnMap(places: [PlacePin], completion: @escaping () -> Void) {
        var pinsToReAdd = pinsFromSearch
        removePlaceAnnotations(with: pinsToReAdd, forced: true, instantly: true) {
            pinsToReAdd = places.map({ FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0 as AnyObject) })
            self.pinsFromSearch = pinsToReAdd
            self.addPlaceAnnotations(with: pinsToReAdd, forced: true, instantly: true) {
                completion()
            }
        }
    }
    
    // MARK: - MKMapDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view is PlacePinAnnotationView {
            tapPlacePin(didSelect: view)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "self_selected_mode"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard var firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                if let sPlace = selectedPlace {
                    if faeBeta.coordinateEqual(clusterAnn.coordinate, sPlace.coordinate) {
                        firstAnn = sPlace
                    }
                }
                clusterAnn.representative = firstAnn
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .location {
                return viewForLocation(annotation: annotation, first: firstAnn)
            } else {
                return nil
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        switch previousVC {
        case .board, .explore:
            guard btnSelect != nil else { return }
            btnSelect.lblDistance.textColor = UIColor._255160160()
            btnSelect.isUserInteractionEnabled = false
        case .chat:
            cancelPlacePinsFetch()
        }
    }
    
    private var isMapWillChange: Bool = false
    private var PLACES_RELOADED = true
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard fullyLoaded else { return }
        
        isMapWillChange = false
        let level = getZoomLevel(longitudeCenter: mapView.region.center.longitude, longitudeDelta: mapView.region.span.longitudeDelta, width: mapView.bounds.size.width)
        if level <= 5 {
            PLACE_FETCH_ENABLE = false
            let pinsToAdd = faePlacePins + pinsFromSearch
            removePlaceAnnotations(with: pinsToAdd, forced: true, instantly: true) {
                self.PLACES_RELOADED = false
            }
        } else {
            if PLACES_RELOADED == false {
                PLACES_RELOADED = true
                PLACE_FETCH_ENABLE = true
                let pinsToAdd = faePlacePins + pinsFromSearch
                addPlaceAnnotations(with: pinsToAdd, forced: true, instantly: false) {
                    
                }
            }
        }
        
        chosenLocation = mapView.centerCoordinate
        
        if !isLoadingMapCenterCityInfoDisabled {
            fetchAreaDataWhenRegionDidChange()
        }
        
        if searchState == .multipleSearch && tblPlaceResult.altitude == 0 {
            tblPlaceResult.altitude = mapView.camera.altitude
        }
        
        reloadPlaceTableAnnotations()
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        switch mode {
        case .full:
            break
        case .part:
            // .chat or .explore
            guard !isGeoCoding else { return }
            guard !isLoadingMapCenterCityInfoDisabled else { return }
            guard previousVC == .board || previousVC == .explore else { return }
            joshprint("[General.shared.getAddress]")
            isGeoCoding = true
            btnSelect.indicatorStartAnimating(isOn: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                General.shared.getAddress(location: location, original: false, full: false, detach: true) { [weak self] (status, address) in
                    guard let `self` = self else { return }
                    guard status != 400 else {
                        DispatchQueue.main.async {
                            self.lblSearchContent.text = "Querying for location too fast!"
                        }
                        self.btnSelect.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                        return
                    }
                    guard let addr = address as? String else {
                        self.btnSelect.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                        return
                    }
                    let new = addr.split(separator: "@")
                    guard new.count > 0 else {
                        self.btnSelect.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
                        return
                    }
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
                        self.btnSelect.indicatorStartAnimating(isOn: false)
                        self.isGeoCoding = false
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
    
    func reloadPlaceTableAnnotations() {
        if tblPlaceResult.tag > 0 && PLACE_FETCH_ENABLE { tblPlaceResult.visibleAnnotations = visiblePlaces(full: true) }
        if selectedPlaceAnno != nil {
            if searchState == .map {
                tblPlaceResult.loadingData(current: tblPlaceResult.curtAnnotation)
            } else if searchState == .multipleSearch {
                
            }
        }
    }
    
    // MARK: - CCHMapClusterDelegate
    
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
                if PLACE_INSTANT_SHOWUP || searchState == .multipleSearch { // immediatelly show up
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
        
        if (mapClusterController == placeClusterManager && PLACE_INSTANT_REMOVE) || (mapClusterController == locationPinClusterManager && LOC_INSTANT_REMOVE) || searchState == .multipleSearch { // immediatelly remove
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
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!, fullAnnotationSet annotations: Set<AnyHashable>!, findSelectedPin found: Bool) {
        
        switch mapClusterController {
        case placeClusterManager:
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                var pinFound = false
                if found {
                    for annotation in annotations {
                        guard let pin = annotation as? FaePinAnnotation else { continue }
                        guard let sPlace = selectedPlace else { continue }
                        if faeBeta.coordinateEqual(pin.coordinate, sPlace.coordinate) {
                            pinFound = true
                            let icon = UIImage(named: "place_map_\(pin.category_icon_id)s") ?? #imageLiteral(resourceName: "place_map_48s")
                            anView.assignImage(icon)
                        }
                    }
                    if !pinFound {
                        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
                        anView.assignImage(firstAnn.icon)
                    }
                } else {
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
                if firstAnn.isSelected {
                    anView.assignImage(#imageLiteral(resourceName: "icon_destination"))
                } else {
                    anView.assignImage(firstAnn.icon)
                }
            }
        }
        if selectedPlaceAnno != nil {
            selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
            selectedPlaceAnno?.layer.zPosition = 199
        }
    }
    
    // MARK: - Place & Location Managements
    
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
        anView.assignImage(first.icon)
        if first.isSelected {
            let icon = UIImage(named: "place_map_\(anView.iconIndex)s") ?? #imageLiteral(resourceName: "place_map_48s")
            anView.assignImage(icon)
            anView.optionsReady = true
            anView.optionsOpened = false
            selectedPlaceAnno = anView
            anView.superview?.bringSubview(toFront: anView)
            anView.zPos = 199
        }
        //anView.delegate = self
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
        //anView.delegate = self
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        return anView
    }
    
    private func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard var firstAnn = cluster.representative as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        if let sPlace = selectedPlace {
            if faeBeta.coordinateEqual(cluster.coordinate, sPlace.coordinate) {
                firstAnn = sPlace
            }
        }
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
        tblPlaceResult.curtAnnotation = cluster
        reloadPlaceTableAnnotations()
        if searchState == .map {
            
        } else if searchState == .multipleSearch {
            tblPlaceResult.loading(current: placePin, isSwitchingPage: !tblPlaceResult.isShrinked)
        }
        btnSelect.lblDistance.textColor = UIColor._2499090()
        btnSelect.isUserInteractionEnabled = true
        if selectedLocation != nil { // TODO:
            selectedLocation = nil
        }
    }
    
    private func updatePlacePins() {
        
    }
    
    private func fetchPlacePins() {
        guard previousVC == .chat else { return }
        startFetchingAreaData()
//        func getDelay(prevTime: DispatchTime) -> Double {
//            let standardInterval: Double = 1
//            let nowTime = DispatchTime.now()
//            let timeDiff = Double(nowTime.uptimeNanoseconds - prevTime.uptimeNanoseconds)
//            var delay: Double = 0
//            if timeDiff / Double(NSEC_PER_SEC) < standardInterval {
//                delay = standardInterval - timeDiff / Double(NSEC_PER_SEC)
//            } else {
//                delay = timeDiff / Double(NSEC_PER_SEC) - standardInterval
//            }
//            return delay
//        }
//
//        guard PLACE_FETCH_ENABLE else {
//            return
//        }
//
//        guard boolCanUpdatePlaces else {
//            return
//        }
//        boolCanUpdatePlaces = false
//
//        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
//        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
//        FaeMap.shared.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
//        FaeMap.shared.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
//        FaeMap.shared.whereKey("radius", value: "\(radius)")
//        FaeMap.shared.whereKey("type", value: "place")
//        FaeMap.shared.whereKey("max_count", value: "1000")
//        FaeMap.shared.getMapPins { [weak self] (status: Int, message: Any?) in
//            guard let `self` = self else { return }
//            guard status / 100 == 2 else {
//                self.boolCanUpdatePlaces = true
//                return
//            }
//            guard message != nil else {
//                self.boolCanUpdatePlaces = true
//                return
//            }
//            let mapPlaceJSON = JSON(message!)
//            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
//                self.boolCanUpdatePlaces = true
//                return
//            }
//            guard mapPlaceJsonArray.count > 0 else {
//                self.boolCanUpdatePlaces = true
//                return
//            }
//
//            self.placePinFetchQueue.cancelAllOperations()
//            let adder = PlacePinFetcher(cluster: self.placeClusterManager, arrPlaceJSON: mapPlaceJsonArray, idSet: self.setPlacePins)
//            adder.completionBlock = {
//                DispatchQueue.main.async {
//                    if adder.isCancelled {
//                        return
//                    }
//                    guard self.PLACE_FETCH_ENABLE else { return }
//                    guard self.searchState == .map else { return }
//                    self.placeClusterManager.addAnnotations(adder.placePins, withCompletionHandler: {
//                        self.setPlacePins = self.setPlacePins.union(Set(adder.ids))
//                        self.faePlacePins += adder.placePins
//                    })
//                }
//            }
//            self.placePinFetchQueue.addOperation(adder)
//            self.boolCanUpdatePlaces = true
//        }
    }
    
    // MARK: - Location Pin Managements
    
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
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        anView.optionsReady = true
        return anView
    }
    
    private func createLocationPin(_ location: CLLocation) {
        guard previousVC == .chat else { return }
        guard modeLocation == .off else { return }
        modeLocCreating = .on
        
        func createLoc() {
            self.tblPlaceResult.hide()
            self.selectedLocAnno?.hideButtons()
            self.selectedLocAnno?.optionsReady = false
            self.selectedLocAnno?.optionsOpened = false
            self.selectedLocAnno?.optionsOpeing = false
            self.selectedLocAnno?.removeFromSuperview()
            self.selectedLocAnno = nil
            self.deselectAllPlaceAnnos()
            let pinData = LocationPin(position: location.coordinate)
            pinData.optionsReady = true
            self.selectedLocation = FaePinAnnotation(type: .location, data: pinData as AnyObject)
            self.selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            self.locationPinClusterManager.addAnnotations([self.selectedLocation!], withCompletionHandler: nil)
            self.uiviewLocationBar.updateLocationInfo(location: location) { (address_1, address_2) in
                self.selectedLocation?.address_1 = address_1
                self.selectedLocation?.address_2 = address_2
                self.btnSelect.lblDistance.textColor = UIColor._2499090()
                self.btnSelect.isUserInteractionEnabled = true
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
    
    private func createLocationPin(point: CGPoint) {
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        createLocationPin(cllocation)
    }
    
    // MARK: - Actions in Controller
    
    @objc private func actionSelect(_ tap: UITapGestureRecognizer) {
        switch previousVC {
        case .board:
            LocManager.shared.locToSearch_board = faeMapView.centerCoordinate
            let location = CLLocation(latitude: faeMapView.centerCoordinate.latitude,
                                      longitude: faeMapView.centerCoordinate.longitude)
            delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "place_location"), searchText: strRawLoc_board, location: location)
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
            LocManager.shared.locToSearch_explore = faeMapView.centerCoordinate
            let address = RouteAddress(name: strRawLoc_explore, coordinate: faeMapView.centerCoordinate)
            delegate?.sendLocationBack?(address: address)
            navigationController?.popViewController(animated: false)
        }
    }
    
    @objc private func handleTapPlaceBar() {
        guard let placeData = selectedPlace?.pinInfo as? PlacePin else {
            return
        }
        let vc = PlaceDetailViewController()
        vc.place = placeData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func actionSelfPosition(_ sender: UIButton!) {
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        faeMapView.setCamera(camera, animated: false)
    }
    
    @objc private func actionShowResultTbl(_ sender: UIButton) {
        guard tblPlaceResult.currentGroupOfPlaces.count > 0 else { return }
        guard tblPlaceResult.canExpandOrShrink() else { return }
        btnZoom.tapToSmallMode()
        if sender.tag == 0 {
            sender.tag = 1
            tblPlaceResult.expand {
                self.btnTapToShowResultTbl.center.y = self.btnTapToShowResultTbl.after
            }
            btnZoom.isHidden = true
            btnTapToShowResultTbl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            showOrHideBottomButtons(show: false)
        } else {
            sender.tag = 0
            tblPlaceResult.shrink {
                self.btnTapToShowResultTbl.center.y = self.btnTapToShowResultTbl.before
            }
            btnZoom.isHidden = false
            btnTapToShowResultTbl.transform = CGAffineTransform.identity
            showOrHideBottomButtons(show: true)
        }
    }
    
    private func showOrHideBottomButtons(show: Bool) {
        guard previousVC == .chat else { return }
        self.btnLocat.isHidden = !show
        self.btnZoom.isHidden = !show
        self.btnSelect.isHidden = !show
    }
    
    // MARK: - PlaceViewDelegate
    func goTo(annotation: CCHMapClusterAnnotation? = nil, place: PlacePin? = nil, animated: Bool = true) {
        func findAnnotation() {
            if let placeData = place {
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
                } else {
                    let camera = faeMapView.camera
                    camera.centerCoordinate = placeData.coordinate
                    faeMapView.setCamera(camera, animated: false)
                }
                if desiredAnno != nil {
                    //print("[goto] anno found")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                    }
                } else {
                    //print("![goto] anno not found")
                }
            }
        }
        
        deselectAllPlaceAnnos()
        if let anno = annotation {
            searchState = .map
            faeMapView.selectAnnotation(anno, animated: false)
            if animated {
                faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: anno.coordinate)
            }
        }
        
        // If going to prev or next group
        if tblPlaceResult.goingToNextGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: true)
            reloadPlacePinsOnMap(places: tblPlaceResult.currentGroupOfPlaces) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    findAnnotation()
                })
            }
        } else if tblPlaceResult.goingToPrevGroup {
            tblPlaceResult.configureCurrentPlaces(goingNext: false)
            reloadPlacePinsOnMap(places: tblPlaceResult.currentGroupOfPlaces) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    findAnnotation()
                })
            }
        } else {
            findAnnotation()
            if let placePin = place { // 必须放在最末尾
                tblPlaceResult.loading(current: placePin, isSwitchingPage: !tblPlaceResult.isShrinked)
            }
        }
    }
    /*
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?, animated: Bool) {
        findPlaceDataInCurrentSet = false
        deselectAllPlaceAnnos()
        if let anno = annotation {
            faeMapView.selectAnnotation(anno, animated: false)
        }
        if let placePin = place {
            var desiredAnno: CCHMapClusterAnnotation!
            for anno in faeMapView.annotations {
                guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                if placeInfo == placePin {
                    desiredAnno = cluster
                    findPlaceDataInCurrentSet = true
                    break
                }
            }
            if desiredAnno != nil {
                faeMapView.selectAnnotation(desiredAnno, animated: false)
            }
        }
    }
 */
    
    // MARK: - Auxiliary Map Functions
    
    private func deselectAllPlaceAnnos() {
        if let idx = selectedPlace?.category_icon_id {
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
        }
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
    }
    
    private func deselectAllLocAnnos() {
        uiviewLocationBar.hide()
        
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno = nil
        selectedLocation = nil
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
    
    // MARK: - MapSearchDelegate
    
    private func removePlacePins(_ completion: (() -> ())? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        placeClusterManager.removeAnnotations(faePlacePins) {
            completion?()
        }
    }
    
    @objc private func actionClearSearchResults(_ sender: UIButton) {
        btnZoom.tapToSmallMode()
        PLACE_FETCH_ENABLE = true
        
        lblSearchContent.text = "Search Place or Address"
        lblSearchContent.textColor = UIColor._182182182()
        
        btnClearSearchRes.isHidden = true
        
        tblPlaceResult.searchState = .map
        searchState = .map
        tblPlaceResult.hide(animated: false)
        showOrHideTableResultsExpandingIndicator()
        placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        
        deselectAllPlaceAnnos()
        removePlaceAnnotations(with: pinsFromSearch, forced: true, instantly: true) {
            self.pinsFromSearch.removeAll(keepingCapacity: true)
            self.addPlaceAnnotations(with: self.faePlacePins, forced: true, instantly: true)
        }
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
}

extension SelectLocationViewController {
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
    
    private func cancelPlacePinsFetch() {
        FaeMap.shared.placePinsRequest?.cancel()
        for (_, request) in placePinRequests {
            request.cancel()
        }
        placePinFetchQueue.cancelAllOperations()
    }
    
    private func addPlaceAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        PLACE_INSTANT_SHOWUP = instantly
        placeClusterManager.isForcedRefresh = forced
        placeClusterManager.addAnnotations(annos) {
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.PLACE_INSTANT_SHOWUP = false
            completion?()
        }
    }
    
    private func removePlaceAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        PLACE_INSTANT_REMOVE = instantly
        placeClusterManager.isForcedRefresh = forced
        placeClusterManager.removeAnnotations(annos) {
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            self.PLACE_INSTANT_REMOVE = false
            completion?()
        }
    }
    
    private func addLocationAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        LOC_INSTANT_SHOWUP = instantly
        locationPinClusterManager.isForcedRefresh = forced
        locationPinClusterManager.addAnnotations(annos) {
            self.locationPinClusterManager.manuallyCallRegionDidChange()
            self.locationPinClusterManager.isForcedRefresh = false
            self.LOC_INSTANT_SHOWUP = false
            completion?()
        }
    }
    
    private func removeLocationAnnotations(with annos: [FaePinAnnotation], forced: Bool, instantly: Bool, _ completion: (() -> ())? = nil) {
        LOC_INSTANT_REMOVE = instantly
        locationPinClusterManager.isForcedRefresh = forced
        locationPinClusterManager.removeAnnotations(annos) {
            self.locationPinClusterManager.manuallyCallRegionDidChange()
            self.locationPinClusterManager.isForcedRefresh = false
            self.LOC_INSTANT_REMOVE = false
            completion?()
        }
    }
    
    private func showOrHideTableResultsExpandingIndicator(show: Bool = false, animated: Bool = false) {
        if animated {
            if show {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.btnTapToShowResultTbl.alpha = 1
                }, completion: nil)
            } else {
                btnTapToShowResultTbl.tag = 1
                btnTapToShowResultTbl.sendActions(for: .touchUpInside)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.btnTapToShowResultTbl.alpha = 0
                }, completion: nil)
            }
        } else {
            if show {
                btnTapToShowResultTbl.alpha = 1
            } else {
                btnTapToShowResultTbl.alpha = 0
                btnTapToShowResultTbl.tag = 1
                btnTapToShowResultTbl.sendActions(for: .touchUpInside)
            }
        }
    }
    
}

extension SelectLocationViewController: MapSearchDelegate {
    
    func continueSearching(searchText: String, zoomToFit: Bool) {
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        updateUI(searchText: searchText)
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        tblPlaceResult.changeState(isLoading: true, isNoResult: nil)
        let pinsToRemove = faePlacePins + pinsFromSearch
        removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: false) {
            self.searchState = .multipleSearch
            self.PLACE_INSTANT_SHOWUP = true
            // search and show results
            var locationToSearch = self.faeMapView.centerCoordinate
            if let locToSearch = LocManager.shared.locToSearch_chat {
                locationToSearch = locToSearch
            }
            let searchAgent = FaeSearch()
            searchAgent.whereKey("content", value: searchText)
            searchAgent.whereKey("source", value: "\(Key.shared.searchSource_chat)")
            searchAgent.whereKey("type", value: "place")
            searchAgent.whereKey("size", value: "20")
            searchAgent.whereKey("radius", value: "\(Key.shared.radius_chat)")
            searchAgent.whereKey("offset", value: "0")
            searchAgent.whereKey("sort", value: [["_score": "desc"], ["geo_location": "asc"]])
            searchAgent.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                     "longitude": locationToSearch.longitude])
            searchAgent.search { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                joshprint("map searched places fetched")
                if status / 100 != 2 || message == nil {
                    self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    return
                }
                let placeInfoJSON = JSON(message!)
                guard let placeInfoJsonArray = placeInfoJSON.array else {
                    self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    return
                }
                let searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
                guard searchedPlaces.count > 0 else {
                    self.tblPlaceResult.changeState(isLoading: false, isNoResult: true)
                    return
                }
                self.tblPlaceResult.dataOffset = searchedPlaces.count
                self.tblPlaceResult.currentGroupOfPlaces = self.tblPlaceResult.updatePlacesArray(places: searchedPlaces)
                self.tblPlaceResult.loading(current: searchedPlaces[0])
                self.pinsFromSearch = self.tblPlaceResult.currentGroupOfPlaces.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
                self.placeClusterManager.maxZoomLevelForClustering = 0
                self.addPlaceAnnotations(with: self.pinsFromSearch, forced: self.isForcedRefresh, instantly: true, {
                    self.isForcedRefresh = false
                    if let first = searchedPlaces.first {
                        self.goTo(annotation: nil, place: first, animated: true)
                    }
                })
                if zoomToFit {
                    faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                               places: self.tblPlaceResult.currentGroupOfPlaces,
                                               edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
                }
                self.tblPlaceResult.changeState(isLoading: false, isNoResult: false)
                self.stopIconSpin(delay: 0)
            }
        }
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin]) {
        PLACE_FETCH_ENABLE = false
        cancelPlacePinsFetch()
        let isNumbered = true
        strSearchedText = searchText
        updateUI(searchText: searchText)
        placesFromSearch = places
        searchState = .multipleSearch
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        if let first = places.first {
            tblPlaceResult.dataOffset = places.count
            tblPlaceResult.changeState(isLoading: false, isNoResult: false)
            tblPlaceResult.currentGroupOfPlaces = tblPlaceResult.updatePlacesArray(places: places, numbered: isNumbered)
            tblPlaceResult.loading(current: places[0])
            let pinsToAdd = tblPlaceResult.currentGroupOfPlaces.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
            pinsFromSearch = pinsToAdd
            removePlaceAnnotations(with: faePlacePins, forced: true, instantly: false) {
                self.addPlaceAnnotations(with: pinsToAdd, forced: true, instantly: true, {
                    self.showOrHideTableResultsExpandingIndicator(show: true, animated: true)
                    self.goTo(annotation: nil, place: first, animated: true)
                })
                faeBeta.zoomToFitAllPlaces(mapView: self.faeMapView,
                                           places: self.tblPlaceResult.currentGroupOfPlaces,
                                           edgePadding: UIEdgeInsetsMake(240, 40, 100, 40))
            }
            placeClusterManager.maxZoomLevelForClustering = 0
        } else {
            searchState = .map
            tblPlaceResult.changeState(isLoading: false, isNoResult: true)
            showOrHideTableResultsExpandingIndicator()
            placeClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
        }
    }
    
    func selectPlace(place: PlacePin) {
        deselectAllPlaceAnnos()
        deselectAllLocAnnos()
        removePlacePins {
            self.placeClusterManager.isForcedRefresh = true
            self.placeClusterManager.manuallyCallRegionDidChange()
            self.placeClusterManager.isForcedRefresh = false
            let pin = FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: place)
            pin.isSelected = true
            animateToCoordinate(mapView: self.faeMapView, coordinate: place.coordinate)
            self.placeClusterManager.addAnnotations([pin]) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.placeClusterManager.addAnnotations(self.faePlacePins, withCompletionHandler: {
                        
                    })
                })
            }
        }
    }
    
    func selectLocation(location: CLLocation) {
        createLocationPin(location)
    }
    
}

extension SelectLocationViewController: MapAction {
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos()
    }
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
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
    
    func singleElsewhereTapExceptInfobar() {
        if searchState != .multipleSearch {
            tblPlaceResult.hide()
            showOrHideTableResultsExpandingIndicator()
        }
        uiviewLocationBar.hide()
        deselectAllPlaceAnnos()
    }
}

extension SelectLocationViewController {
    
    func initScreenPointCenters() {
        for i in [1,3,5,7,9,11,13,15] {
            for j in [1,3,5] {
                let point = CGPoint(x: screenWidth / 6 * CGFloat(j), y: screenHeight / 16 * CGFloat(i))
                point_centers.append(point)
            }
        }
    }
    
    func startFetchingAreaData() {
        time_start = DispatchTime.now()
        guard PLACE_FETCH_ENABLE else {
            stopIconSpin(delay: getDelay(prevTime: time_start))
            return
        }
        guard boolCanUpdatePlaces else {
            stopIconSpin(delay: getDelay(prevTime: time_start))
            return
        }
        boolCanUpdatePlaces = false
        placeFetchesCount = 0
        General.shared.renewSelfLocation()
        rawPlaceJSONs.removeAll()
        coordinates.removeAll(keepingCapacity: true)
        var count = 0
        for point in point_centers {
            let coordinate = faeMapView.convert(point, toCoordinateFrom: nil)
            coordinates.append(coordinate)
            fetchPlacePinsPartly(center: coordinate, number: count)
            count += 1
        }
    }
    
    func doneFetchingAreaPlaceData() {
        self.placePinFetchQueue.cancelAllOperations()
        let fetcher = PlacePinFetcher(cluster: placeClusterManager, arrPlaceJSON: rawPlaceJSONs, idSet: setPlacePins)
        fetcher.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.stopIconSpin(delay: 0)
                if fetcher.isCancelled {
                    //joshprint("[fetchPlacePins] operation cancelled")
                    return
                }
                guard self.PLACE_FETCH_ENABLE else { return }
                guard self.searchState == .map else { return }
                //joshprint("[fetchPlacePins] fetched")
                self.addPlaceAnnotations(with: fetcher.placePins, forced: self.isForcedRefresh, instantly: false, {
                    self.isForcedRefresh = false
                    self.setPlacePins = self.setPlacePins.union(Set(fetcher.ids))
                    self.faePlacePins += fetcher.placePins
                    self.reloadPlaceTableAnnotations()
                })
            }
        }
        self.placePinFetchQueue.addOperation(fetcher)
    }
    
    func fetchAreaDataWhenRegionDidChange() {
        guard PLACE_FETCH_ENABLE else { return }
        mapViewPanningFetchesCount = 0
        numberOfAreasWithNoPins = 0
        General.shared.renewSelfLocation()
        rawPlaceJSONs.removeAll()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now()) {
            for i in 0...23 {
                self.fetchDataInCertainMapRect(number: i)
            }
        }
    }
    
    func fetchPlacePinsPartly(center: CLLocationCoordinate2D, number: Int) {
        let radius = calculateRadius(mapView: faeMapView)
        let placeAgent = FaeMap()
        placeAgent.whereKey("geo_latitude", value: "\(center.latitude)")
        placeAgent.whereKey("geo_longitude", value: "\(center.longitude)")
        placeAgent.whereKey("radius", value: "\(radius)")
        placeAgent.whereKey("type", value: "place")
        placeAgent.whereKey("max_count", value: "15")
        placePinRequests[number] = placeAgent.getMapPins { [weak self] (status, message) in
            guard let `self` = self else { return }
            joshprint("No.\(number) fetched")
            guard status / 100 == 2 else {
                self.placeFetchesCount += 1
                self.mapViewPanningFetchesCount += 1
                return
            }
            guard message != nil else {
                self.placeFetchesCount += 1
                self.mapViewPanningFetchesCount += 1
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                self.placeFetchesCount += 1
                self.mapViewPanningFetchesCount += 1
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                self.placeFetchesCount += 1
                self.mapViewPanningFetchesCount += 1
                return
            }
            self.rawPlaceJSONs += mapPlaceJsonArray
            self.placeFetchesCount += 1
            self.mapViewPanningFetchesCount += 1
        }
    }
    
    func fetchDataInCertainMapRect(number: Int) {
        var mapRect = faeMapView.visibleMapRect
        let map_width = mapRect.size.width
        let map_height = mapRect.size.height
        mapRect.origin.x += Double(number % 3) * (map_width / 3)
        mapRect.origin.y += Double(number / 3) * (map_height / 8)
        mapRect.size.width = map_width / 3
        mapRect.size.height = map_height / 8
        let annos = faeMapView.annotations(in: mapRect)
        var userAnnoFound = false
        for anno in annos {
            if anno is MKUserLocation {
                userAnnoFound = true
                break
            }
        }
        guard (annos.count == 0 && !userAnnoFound) || (annos.count == 1 && userAnnoFound) else { return }
        numberOfAreasWithNoPins += 1
        joshprint("no annos found in area \(number)");
        guard point_centers.count == 24 else { return }
        let coordinate = faeMapView.convert(point_centers[number], toCoordinateFrom: nil)
        fetchPlacePinsPartly(center: coordinate, number: number)
    }
}

extension SelectLocationViewController {
    
    private func loadRefreshButton() {
        guard previousVC == .chat else { return }
        btnRefreshIcon = FMRefreshIcon()
        btnRefreshIcon.addTarget(self, action: #selector(self.actionRefreshIcon(_:)), for: .touchUpInside)
        btnRefreshIcon.layer.zPosition = 601
        btnRefreshIcon.frame.origin.y = screenHeight - 125 - device_offset_bot
        view.addSubview(btnRefreshIcon)
        view.bringSubview(toFront: btnRefreshIcon)
    }
    
    @objc private func actionRefreshIcon(_ sender: UIButton) {
        if searchState == .map {
            cancelPlacePinsFetch()
            guard searchState == .map else { return }
            PLACE_FETCH_ENABLE = true
            if btnRefreshIcon.isSpinning {
                btnRefreshIcon.stopIconSpin()
                boolCanUpdatePlaces = true
                return
            }
            guard boolCanUpdatePlaces else { return }
            btnRefreshIcon.startIconSpin()
            let pinsToRemove = faePlacePins + pinsFromSearch
            removePlaceAnnotations(with: pinsToRemove, forced: true, instantly: false) {
                self.faePlacePins.removeAll(keepingCapacity: true)
                self.setPlacePins.removeAll(keepingCapacity: true)
                if self.selectedPlace != nil {
                    self.faePlacePins.append(self.selectedPlace!)
                    self.setPlacePins.insert(self.selectedPlace!.id)
                }
                self.isForcedRefresh = true
                self.fetchPlacePins()
            }
        } else if searchState == .multipleSearch {
            btnRefreshIcon.startIconSpin()
            guard let searchText = lblSearchContent.text else {
                self.stopIconSpin(delay: 0)
                return
            }
            Key.shared.radius_map = Int(faeMapView.region.span.latitudeDelta * 111045)
            self.isForcedRefresh = true
            continueSearching(searchText: searchText, zoomToFit: false)
        }
    }
    
    func stopIconSpin(delay: Double) {
        boolCanUpdatePlaces = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.btnRefreshIcon.stopIconSpin()
        })
    }
    
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
    
}
