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

class LocationMiniPicker: UIView, MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer {
    var faeMapView: FaeMapView!
    var placeClusterManager: CCHMapClusterController!
    var mapCenter: MapCenter = .currentUser
    var placePin: PlacePin?
    private var faePlacePins = [FaePinAnnotation]()
    private var setPlacePins = Set<Int>()
    private var arrPlaceData = [PlacePin]()
    var selectedPlaceAnno: PlacePinAnnotationView?
    var selectedPlace: FaePinAnnotation?
    private var placeAdderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "adder queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var prevMapCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadMapView()
        updatePlacePins()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadMapView() {
        faeMapView = FaeMapView(frame: frame)
        faeMapView.showsUserLocation = true
        faeMapView.delegate = self
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.tintColor = UIColor._2499090()
        addSubview(faeMapView)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        placeClusterManager.maxZoomLevelForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self

        setCamera(center: LocManager.shared.curtLoc.coordinate)
        prevMapCenter = LocManager.shared.curtLoc.coordinate

    }
    
    func setCamera(center: CLLocationCoordinate2D) {
        let camera = faeMapView.camera
        camera.centerCoordinate = center
        let viewDistance: CLLocationDistance = 800
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(camera.centerCoordinate, viewDistance, viewDistance)
        faeMapView.setRegion(coordinateRegion, animated: false)
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
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == .place {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == .location {
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
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        Key.shared.lastChosenLoc = mapView.centerCoordinate
        calculateDistanceOffset()
        
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
    
    func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
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
    
    func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        let idx = firstAnn.class_2_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceAnno = anView
        selectedPlaceAnno?.superview?.bringSubview(toFront: selectedPlaceAnno!)
        selectedPlaceAnno?.zPos = 199
        guard firstAnn.type == .place else { return }

        mapView(faeMapView, regionDidChangeAnimated: false)
        
    }
    
    // MARK: - Location Pin Managements
    
    func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        anView.optionsReady = true
        return anView
    }
    
    // MARK: - Auxiliary Map Functions
    
    func removePlacePins(pins: [FaePinAnnotation], _ completion: (() -> ())? = nil) {
        //let placesNeedToRemove = faePlacePins.filter({ $0 != selectedPlace })
        placeClusterManager.removeAnnotations(pins) {
            completion?()
        }
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
