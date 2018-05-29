//
//  GlobalFunctions.swift
//  faeBeta
//
//  Created by Yue Shen on 1/15/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import MapKit

// MARK: -

func createActivityIndicator(large: Bool) -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView()
    view.activityIndicatorViewStyle = large ? .whiteLarge : .white
    view.hidesWhenStopped = true
    view.color = UIColor._2499090()
    return view
}

// MARK: - Map View
func zoomToFitAllAnnotations(mapView: MKMapView, annotations: [MKPointAnnotation], edgePadding: UIEdgeInsets) {
    guard let firstAnn = annotations.first else { return }
    let point = MKMapPointForCoordinate(firstAnn.coordinate)
    var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
    for annotation in annotations {
        let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
    }
    let edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
    mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
}

func zoomToFitAllPlaces(mapView: MKMapView, places: [PlacePin], edgePadding: UIEdgeInsets) {
    guard let first = places.first else { return }
    let point = MKMapPointForCoordinate(first.coordinate)
    var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
    for place in places {
        let annotationPoint = MKMapPointForCoordinate(place.coordinate)
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
    }
    let edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
    mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
}

func coordinateEqual(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
    return doubleEqual(a.latitude, b.latitude) && doubleEqual(a.longitude, b.longitude)
}

func doubleEqual(_ a: Double, _ b: Double) -> Bool {
    return fabs(a - b) < Double.ulpOfOne
}

func animateToCoordinate(mapView: MKMapView, coordinate: CLLocationCoordinate2D, animated: Bool = true) {
    let point = MKMapPointForCoordinate(coordinate)
    var rect = mapView.visibleMapRect
    rect.origin.x = point.x - rect.size.width * 0.5
    rect.origin.y = point.y - rect.size.height * 0.5
    mapView.setVisibleMapRect(rect, animated: animated)
}

func visiblePlaces(mapView: MKMapView, returnAll: Bool = false) -> [CCHMapClusterAnnotation] {
    
    var places = [CCHMapClusterAnnotation]()
    
    if returnAll == false {
        var mapRect = mapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.3
        mapRect.size.height = mapRect.size.height * 0.7
        let visibleAnnos = mapView.annotations(in: mapRect)
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard mapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == .place else { continue }
                places.append(place)
            } else {
                continue
            }
        }
    } else {
        let visibleAnnos = mapView.annotations
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard mapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == .place else { continue }
                places.append(place)
            } else {
                continue
            }
        }
    }
    
    return places
}

func cameraDiagonalDistance(mapView: MKMapView?) -> Int {
    guard let map = mapView else { return 8000 }
    let centerCoor: CLLocationCoordinate2D = getCenterCoordinate(mapView: map)
    // init center location from center coordinate
    let centerLocation = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
    let topCenterCoor: CLLocationCoordinate2D = getTopCenterCoordinate(mapView: map)
    let topCenterLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
    let radius: CLLocationDistance = centerLocation.distance(from: topCenterLocation)
    return Int(radius * 4)
}

func getCenterCoordinate(mapView: MKMapView) -> CLLocationCoordinate2D {
    return mapView.centerCoordinate
}

func getTopCenterCoordinate(mapView: MKMapView) -> CLLocationCoordinate2D {
    // to get coordinate from CGPoint of your map
    return mapView.convert(CGPoint(x: screenWidth / 2, y: 0), toCoordinateFrom: nil)
}

func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
    
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.sizeToFit()
    
    return label.frame.height
}

func addShadow(view: UIView, opa: Float, offset: CGSize, radius: CGFloat, color: UIColor = .black) {
    view.layer.shadowOpacity = opa
    view.layer.shadowOffset = offset
    view.layer.shadowRadius = radius
    view.layer.shadowColor = color.cgColor
}

func addBorder(_ view: UIView, color: UIColor = .black) {
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = 1
}

func vibrate(type: Int) {
    
    if #available(iOS 10.0, *) {
        switch type {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    } else {
        // Fallback on earlier versions
    }
    
}

func showAlert(title: String, message: String, viewCtrler: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .destructive)
    alertController.addAction(okAction)
    viewCtrler.present(alertController, animated: true, completion: nil)
}
