//
//  LocationPickerMini.swift
//  faeBeta
//
//  Created by User on 14/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

protocol LocationPickerMiniDelegate: class {
    func showFullLocationView()
    func sendLocationMessageFromMini(_ locationPickerMini: LocationPickerMini)
}

protocol LocationMiniPickerDelegate: class {
    func showFullLocationView(_ locationMiniPicker: LocationMiniPicker)
    func selectLocation(_ locationMiniPicker: LocationMiniPicker, location: CLLocation)
    func selectPlacePin(_ locationMiniPicker: LocationMiniPicker, placePin: PlacePin)
}

class LocationMiniPicker: UIView, MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer, PlaceViewDelegate, MapSearchDelegate, MapAction  {
    
    weak var delegate: LocationMiniPickerDelegate?
    private var faeMapView: FaeMapView!
    
    // Place pins data management
    private var placeClusterManager: CCHMapClusterController!
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    private var arrPlaceData = [PlacePin]()
    private var selectedPlaceView: PlacePinAnnotationView?
    private var selectedPlace: FaePinAnnotation?
    private var uiviewPlaceBar = FMPlaceInfoBar()
    private var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    // Location Pin Control
    private var selectedLocation: FaePinAnnotation?
    private var uiviewLocationBar: FMLocationInfoBar!
    private var selectedLocAnno: LocPinAnnotationView?
    private var activityIndicatorLocPin: UIActivityIndicatorView!
    private var locationPinClusterManager: CCHMapClusterController!
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadMapView()
        updatePlacePins()
        loadPin()
        loadButtons()
        addObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "InputBarTopPinViewClose"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Loading Parts
    private func loadMapView() {
        faeMapView = FaeMapView(frame: frame)
        faeMapView.showsUserLocation = true
        faeMapView.delegate = self
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.tintColor = UIColor._2499090()
        faeMapView.mapAction = self
        faeMapView.isShowFourIconsEnabled = false
        faeMapView.longPress.isEnabled = false
        faeMapView.isRotateEnabled = false
        addSubview(faeMapView)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        placeClusterManager.minUniqueLocationsForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        let viewDistance: CLLocationDistance = 800
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(camera.centerCoordinate, viewDistance, viewDistance)
        faeMapView.setRegion(coordinateRegion, animated: false)
    }
    
    private func loadPin() {
        let pinImage = UIImageView(frame: CGRect(x: screenWidth / 2 - 19, y: 89, width: 38, height: 42))
        pinImage.image = UIImage(named: "locationMiniPin")
        pinImage.layer.zPosition = 101
        faeMapView.addSubview(pinImage)
    }
    
    private func loadButtons() {
        let btnSearch = UIButton(frame: CGRect(x: 20, y: frame.height - 67 - device_offset_bot, width: 51, height: 51))
        btnSearch.setImage(UIImage(named: "locationSearch"), for: .normal)
        btnSearch.layer.zPosition = 101
        addSubview(btnSearch)
        btnSearch.addTarget(self, action: #selector(showFullLocationView), for: .touchUpInside)
        
        let btnSend = UIButton(frame: CGRect(x: screenWidth - 71, y: frame.height - 67 - device_offset_bot, width: 51, height: 51))
        btnSend.setImage(UIImage(named: "locationSend"), for: .normal)
        btnSend.layer.zPosition = 101
        addSubview(btnSend)
        btnSend.addTarget(self, action: #selector(selectLocation), for: .touchUpInside)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(topPinViewClose), name: NSNotification.Name(rawValue: "InputBarTopPinViewClose"), object: nil)
    }
    
    @objc
    private func showFullLocationView() {
        delegate?.showFullLocationView(self)
    }
    
    @objc
    private func selectLocation() {
        let center = faeMapView.camera.centerCoordinate
        delegate?.selectLocation(self, location: CLLocation(latitude: center.latitude, longitude: center.longitude))
    }
    
    @objc
    private func topPinViewClose() {
        deselectAllPlaceAnnos()
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
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        //Key.shared.lastChosenLoc = mapView.centerCoordinate
        
        updatePlacePins()
        
        
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
        let idx = firstAnn.category_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48s")
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceView = anView
        guard firstAnn.type == .place else { return }
        //mapView(faeMapView, regionDidChangeAnimated: false)
        if let placePin = selectedPlace?.pinInfo as? PlacePin {
            delegate?.selectPlacePin(self, placePin: placePin)
        }
    }
    
    private func updatePlacePins() {
        let coorDistance = faeBeta.cameraDiagonalDistance(mapView: faeMapView)
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
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: frame.height / 2)
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
        }
    }
    
    // MARK: - Location Pin Managements

    
    // MARK: - Actions in Controller

    
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
        if let idx = selectedPlace?.category_icon_id {
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
        
    }
    
    private func removePlacePins(_ completion: (() -> ())? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        placeClusterManager.removeAnnotations(faePlacePins) {
            completion?()
        }
    }
    
    @objc private func actionClearSearchResults(_ sender: UIButton) {
        
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllPlaceAnnos()
    }
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
    }
    
    func locPinCreating(point: CGPoint) {
        //createLocationPin(point: point)
    }
    
    func locPinCreatingCancel() {
        
        
    }
    
    func singleElsewhereTapExceptInfobar() {
        
    }
}

class LocationPickerMini: UIView, MKMapViewDelegate {
    // MARK: - Properties
    var mapView: MKMapView!
    private var btnSearch: UIButton!
    private var btnSend: UIButton!
    weak var delegate: LocationPickerMiniDelegate?
    
    // MARK: - init
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271 + device_offset_bot))
        loadMapView()
        loadButton()
        loadPin()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    func loadMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 271 + device_offset_bot))
        mapView.layer.zPosition = 100
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.tintColor = UIColor._2499090()
        addSubview(mapView)
        let selfLoc = CLLocationCoordinate2D(latitude: LocManager.shared.curtLat, longitude: LocManager.shared.curtLong)
        let camera = mapView.camera
        camera.centerCoordinate = selfLoc
        mapView.setCamera(camera, animated: false)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 800, 800)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func loadPin() {
        let pinImage = UIImageView(frame: CGRect(x: screenWidth / 2 - 19, y: 89, width: 38, height: 42))
        pinImage.image = UIImage(named: "locationMiniPin")
        pinImage.layer.zPosition = 101
        mapView.addSubview(pinImage)
    }
    
    func loadButton() {
        btnSearch = UIButton(frame: CGRect(x: 20, y: 204, width: 51, height: 51))
        btnSearch.setImage(UIImage(named: "locationSearch"), for: .normal)
        btnSearch.layer.zPosition = 101
        addSubview(btnSearch)
        btnSearch.addTarget(self, action: #selector(showFullLocationView), for: .touchUpInside)
        
        btnSend = UIButton(frame: CGRect(x: screenWidth - 71, y: 204, width: 51, height: 51))
        btnSend.setImage(UIImage(named: "locationSend"), for: .normal)
        btnSend.layer.zPosition = 101
        addSubview(btnSend)
        btnSend.addTarget(self, action: #selector(sendLocationMessageFromMini), for: .touchUpInside)
    }
    
    // MARK: - MKMapViewDelegate
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
        }
        return nil
    }
    
    // MARK: - Button actions
    @objc func showFullLocationView() {
        delegate?.showFullLocationView()
    }
    
    @objc func sendLocationMessageFromMini() {
        delegate?.sendLocationMessageFromMini(self)
    }
    
    func actionSelfPosition(_ sender: UIButton) {
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
    }
}
