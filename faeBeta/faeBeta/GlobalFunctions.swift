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
func calculateRegion(miles: Double, coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
    let scalingFactor = abs( (cos(2 * .pi * coordinate.latitude / 360.0) ));
    let span = MKCoordinateSpan(latitudeDelta: miles/69.0, longitudeDelta: miles/(scalingFactor * 69.0))
    let region = MKCoordinateRegion(center: coordinate, span: span)
    return region
}

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

func zoomToFitAllLocations(mapView: MKMapView, locations: [LocationPin], edgePadding: UIEdgeInsets) {
    guard let first = locations.first else { return }
    let point = MKMapPointForCoordinate(first.coordinate)
    var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
    for location in locations {
        let annotationPoint = MKMapPointForCoordinate(location.coordinate)
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

func visiblePins(mapView: MKMapView, type: FaePinType, returnAll: Bool = false) -> [CCHMapClusterAnnotation] {
    
    var annos = [CCHMapClusterAnnotation]()
    
    if returnAll == false {
        var mapRect = mapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.3
        mapRect.size.height = mapRect.size.height * 0.7
        let visibleAnnos = mapView.annotations(in: mapRect)
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let annoPin = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = annoPin.annotations.first as? FaePinAnnotation else { continue }
                switch type {
                case .place:
                    guard mapView.view(for: annoPin) is PlacePinAnnotationView else { continue }
                    guard firstAnn.type == type else { continue }
                    annos.append(annoPin)
                case .location:
                    guard mapView.view(for: annoPin) is LocPinAnnotationView else { continue }
                    guard firstAnn.type == type else { continue }
                    annos.append(annoPin)
                default:
                    break
                }
            } else {
                continue
            }
        }
    } else {
        let visibleAnnos = mapView.annotations
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let annoPin = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = annoPin.annotations.first as? FaePinAnnotation else { continue }
                switch type {
                case .place:
                    guard mapView.view(for: annoPin) is PlacePinAnnotationView else { continue }
                    guard firstAnn.type == type else { continue }
                    annos.append(annoPin)
                case .location:
                    guard mapView.view(for: annoPin) is LocPinAnnotationView else { continue }
                    guard firstAnn.type == type else { continue }
                    annos.append(annoPin)
                default:
                    break
                }
            } else {
                continue
            }
        }
    }
    
    return annos
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

func calculateRadius(mapView: MKMapView?) -> Int {
    guard let map = mapView else { return 8000 }
    let from: CLLocationCoordinate2D = map.convert(CGPoint(x: 0, y: screenHeight/2), toCoordinateFrom: nil)
    // init center location from center coordinate
    let from_loc = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to: CLLocationCoordinate2D = map.convert(CGPoint(x: screenWidth/6, y: screenHeight/2), toCoordinateFrom: nil)
    let to_loc = CLLocation(latitude: to.latitude, longitude: to.longitude)
    let radius: CLLocationDistance = from_loc.distance(from: to_loc)
    return Int(radius * 1.5)
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

func processLocationName(separator: Character, text: String, size: CGFloat = 16, size2: CGFloat = 16) -> NSAttributedString? {
    var arrNames = text.split(separator: separator)
    var array = [String]()
    guard arrNames.count >= 1 else { return nil }
    for i in 0..<arrNames.count {
        let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
        array.append(name)
    }
    if array.count >= 3 {
        return reloadBottomText(array[0], array[1] + ", " + array[2], size, size2)
    } else if array.count == 1 {
        return reloadBottomText(array[0], "", size, size2)
    } else if array.count == 2 {
        return reloadBottomText(array[0], array[1], size, size2)
    }
    return nil
}

func reloadBottomText(_ city: String, _ state: String, _ size: CGFloat = 16, _ size2: CGFloat = 16) -> NSAttributedString {
    let fullAttrStr = NSMutableAttributedString()

    let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: size)!]
    let title_0_attr = NSMutableAttributedString(string: city + " ", attributes: attrs_0)
    
    let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: size2)!]
    let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
    
    fullAttrStr.append(title_0_attr)
    fullAttrStr.append(title_1_attr)
    
    return fullAttrStr
}

func showAlert(title: String, message: String, viewCtrler: UIViewController?, handler: ((UIAlertAction) -> Void)? = nil) {
    guard let viewCtrler = viewCtrler else { return }
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    let okAction = UIAlertAction(title: "OK", style: .destructive)
    let okAction = UIAlertAction(title: "OK", style: .destructive, handler: handler)
    alertController.addAction(okAction)
    viewCtrler.present(alertController, animated: true, completion: nil)
}
