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
//import CCHMapClusterController

// An enum type to return different geo -> address
enum SelectLoctionMode {
    case full
    case part
}

class SelectLocationViewController: UIViewController, MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer, PlaceViewDelegate, MapSearchDelegate {
    
    // MARK: - Variables Declarations
    weak var delegate: GeneralLocationSearchDelegate?
    
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
    private var selectedPlaceView: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation? {
        didSet {
            if selectedPlace != nil {
                selectedLocation = nil
            }
        }
    }
    private var uiviewPlaceBar = FMPlaceInfoBar()
    private var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // Boolean values
    private var fullyLoaded = false // if all ui components are fully loaded
    var boolFromBoard = false
    var boolSearchEnabled = false
    var boolFromExplore = false
    var boolFromChat = false
    
    private var placesFromSearch = [FaePinAnnotation]()
    
    public var strShownLoc: String = ""
    private var strRawLoc: String = ""
    
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
    
    let mapSearchVC = MapSearchViewController()
    
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
                        self.deselectAllLocations()
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
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadTopBar()
        loadButtons()
        loadLocationView()
        loadPlaceInfoBar()
        loadPinIcon()
        fullyLoaded = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePlacePins()
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
        faeMapView.singleTap.isEnabled = !boolFromExplore
        faeMapView.doubleTap.isEnabled = !boolFromExplore
        faeMapView.longPress.isEnabled = !boolFromExplore
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
        if let loc = LocManager.shared.locToSearch_board {
            camera.centerCoordinate = loc
        } else {
            camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
            if previousVC == .board {
                if previousLabelText == "Current Location" {
                    camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
                } else {
                    if let locToSearch = LocManager.shared.locToSearch_board {
                        camera.centerCoordinate = locToSearch
                    }
                }
            }
        }
        camera.altitude = 35000
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
        
        faeMapView.cgfloatCompassOffset = 73 + device_offset_bot - device_offset_bot_main //134
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
    
    private func loadPlaceInfoBar() {
        view.addSubview(uiviewPlaceBar)
        uiviewPlaceBar.delegate = self
        uiviewPlaceBar.boolDisableSwipe = true
    }
    
    // MARK: - MKMapDelegate
    
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
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .location {
                return viewForLocation(annotation: annotation, first: firstAnn)
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard previousVC == .board || previousVC == .explore else { return }
        guard btnSelect != nil else { return }
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        LocManager.shared.locToSearch_board = mapView.centerCoordinate
        
        if uiviewPlaceBar.tag > 0 { uiviewPlaceBar.annotations = visiblePlaces() }
        
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
                    self.strRawLoc = String(new[0]) + "@" + String(new[1])
                    self.processAddress(String(new[0]), String(new[1]))
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
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: FaeFont(fontType: .medium, size: 18)]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        DispatchQueue.main.async {
            self.lblSearchContent.attributedText = fullAttrStr
        }
    }
    
    // MARK: - CCHMapClusterDelegate
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.alpha = 0
                anView.imgIcon.frame = CGRect(x: 28, y: 56, width: 0, height: 0)
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                        anView.alpha = 1
                    }, completion: nil)
                }
            } else if let anView = annotationView as? LocPinAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        anView.alpha = 1
                    })
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
        UIView.animate(withDuration: 0.4, animations: {
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
        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
        if firstAnn.type == .place {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        } else if firstAnn.type == .location {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? LocPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, coordinateForAnnotations annotations: Set<AnyHashable>!, in mapRect: MKMapRect) -> IsSelectedCoordinate {
        guard let firstAnn = annotations.first as? FaePinAnnotation else {
            return IsSelectedCoordinate(isSelected: false, coordinate: CLLocationCoordinate2DMake(0, 0))
        }
        return IsSelectedCoordinate(isSelected: false, coordinate: firstAnn.coordinate)
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
        anView.assignImage(first.icon)
        return anView
    }
    
    private func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        let idx = firstAnn.class_2_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceView = anView
        guard firstAnn.type == .place else { return }
        uiviewPlaceBar.show()
        uiviewPlaceBar.resetSubviews()
        uiviewPlaceBar.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: false)
        uiviewPlaceBar.loadingData(current: cluster)
        btnSelect.lblDistance.textColor = UIColor._2499090()
        btnSelect.isUserInteractionEnabled = true
        if selectedLocation != nil { // TODO:
            selectedLocation = nil
        }
    }
    
    private func updatePlacePins() {
        let coorDistance = faeBeta.cameraDiagonalDistance(mapView: faeMapView)
        refreshPlacePins(radius: coorDistance)
    }
    
    private func refreshPlacePins(radius: Int) {
        if boolFromBoard || boolFromExplore { return }
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
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        FaeMap.shared.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        FaeMap.shared.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        FaeMap.shared.whereKey("radius", value: "\(radius)")
        FaeMap.shared.whereKey("type", value: "place")
        FaeMap.shared.whereKey("max_count", value: "200")
        FaeMap.shared.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                return
            }
            self.placeAdderQueue.cancelAllOperations()
            let adder = PlacesAdder(cluster: self.placeClusterManager, arrPlaceJSON: mapPlaceJsonArray, idSet: self.setPlacePins)
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
        }
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
    
    private func createLocationPin(point: CGPoint) {
        guard modeLocation == .off else { return }
        modeLocCreating = .on
        
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        func createLoc() {
            self.uiviewPlaceBar.hide()
            self.selectedLocAnno?.hideButtons()
            self.selectedLocAnno?.optionsReady = false
            self.selectedLocAnno?.optionsOpened = false
            self.selectedLocAnno?.optionsOpeing = false
            self.selectedLocAnno?.removeFromSuperview()
            self.selectedLocAnno = nil
            self.deselectAllPlaceAnnos()
            let pinData = LocationPin(position: coordinate)
            pinData.optionsReady = true
            self.selectedLocation = FaePinAnnotation(type: .location, data: pinData as AnyObject)
            self.selectedLocation?.icon = #imageLiteral(resourceName: "icon_destination")
            self.locationPinClusterManager.addAnnotations([self.selectedLocation!], withCompletionHandler: nil)
            self.uiviewLocationBar.updateLocationInfo(location: cllocation) { (address_1, address_2) in
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
    
    // MARK: - Actions in Controller
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        switch previousVC {
        case .board:
            let location = CLLocation(latitude: faeMapView.centerCoordinate.latitude,
                                      longitude: faeMapView.centerCoordinate.longitude)
            delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mb_iconBeforeCurtLoc"), searchText: strRawLoc, location: location)
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
            let address = RouteAddress(name: strRawLoc, coordinate: faeMapView.centerCoordinate)
            delegate?.sendLocationBack?(address: address)
            navigationController?.popViewController(animated: false)
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
    
    // MARK: - PlaceViewDelegate
    
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?, animated: Bool) {
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
                    break
                }
            }
            if desiredAnno != nil {
                faeMapView.selectAnnotation(desiredAnno, animated: false)
            }
        }
    }
    
    // MARK: - Auxiliary Map Functions
    
    private func deselectAllPlaceAnnos() {
        if let idx = selectedPlace?.class_2_icon_id {
            selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            guard let img = selectedPlace?.icon else { return }
            selectedPlaceView?.layer.zPosition = CGFloat(selectedPlaceView?.tag ?? 7)
            selectedPlaceView?.assignImage(img)
            selectedPlaceView?.hideButtons()
            selectedPlaceView?.optionsReady = false
            selectedPlaceView?.optionsOpened = false
            selectedPlaceView = nil
            selectedPlace = nil
        }
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
    }
    
    private func deselectAllLocations() {
        uiviewLocationBar.hide()
        
        selectedLocAnno?.hideButtons()
        selectedLocAnno?.zPos = 8.0
        selectedLocAnno?.optionsReady = false
        selectedLocAnno?.optionsOpened = false
        selectedLocAnno?.removeFromSuperview()
        selectedLocAnno = nil
        selectedLocation = nil
    }
    
    private func visiblePlaces() -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.3
        mapRect.size.height = mapRect.size.height * 0.7
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
    
    @objc private func actionSearch(_ sender: UIButton) {
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = faeMapView
        searchVC.delegate = self
        searchVC.boolFromChat = true
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @objc func jumpToOnePlace(searchText: String, place: PlacePin) { // TODO
        let pin = FaePinAnnotation(type: .place, cluster: placeClusterManager, data: place)
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
        btnClearSearchRes.isHidden = false
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: false)
        uiviewPlaceBar.load(for: place)
        placesFromSearch.append(pin)
        removePlacePins({
            self.placeClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        })
        selectedPlace = pin
        btnSelect.lblDistance.textColor = UIColor._2499090()
        btnSelect.isUserInteractionEnabled = true
    }
    
    private func removePlacePins(_ completion: (() -> ())? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        placeClusterManager.removeAnnotations(faePlacePins) {
            completion?()
        }
    }
    
    @objc private func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "Search Place or Address"
        lblSearchContent.textColor = UIColor._182182182()
        btnClearSearchRes.isHidden = true
        uiviewPlaceBar.alpha = 0
        uiviewPlaceBar.state = .map
        deselectAllPlaceAnnos()
        placeClusterManager.removeAnnotations(placesFromSearch) {
            self.placesFromSearch.removeAll(keepingCapacity: true)
        }
        placeClusterManager.addAnnotations(faePlacePins, withCompletionHandler: nil)
    }
    
    @objc private func actionTapTopBar(_ sender: UIButton) {
        switch previousVC {
        case .board:
            break
        case .chat:
            mapSearchVC.boolNoCategory = true
            mapSearchVC.boolFromChat = true
            if let text = lblSearchContent.text {
                mapSearchVC.strSearchedPlace = text
            } else {
                mapSearchVC.strSearchedPlace = ""
            }
            guard var arrVCs = navigationController?.viewControllers else { return }
            arrVCs.removeLast()
            arrVCs.append(mapSearchVC)
            navigationController?.setViewControllers(arrVCs, animated: false)
        case .explore:
            break
        }
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
            deselectAllLocations()
        }

    }
    
    func singleElsewhereTapExceptInfobar() {
        uiviewPlaceBar.hide()
    }
}
