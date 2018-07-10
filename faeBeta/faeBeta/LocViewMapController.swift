//
//  LocViewMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 6/4/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class LocViewMapController: BasicMapController {
    
    public var coordinate: CLLocationCoordinate2D?
    private var uiviewLocationBar: FMLocationInfoBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullyLoaded = false
        loadTopBar()
        loadLocInfoBar()
        addLocToMap()
        faeMapView.singleTap.isEnabled = false
        faeMapView.doubleTap.isEnabled = false
        faeMapView.longPress.isEnabled = false
        let edgeView = LeftMarginToEnableNavGestureView()
        view.addSubview(edgeView)
        fullyLoaded = true
    }
    
    override func loadTopBar() {
        super.loadTopBar()
        lblTopBarCenter = FaeLabel(.zero, .center, .medium, 18, ._898989())
        lblTopBarCenter.text = "View Location"
        uiviewTopBar.addSubview(lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("H:|-50-[v0]-50-|", options: [], views: lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("V:|-13-[v0(25)]", options: [], views: lblTopBarCenter)
    }
    
    private func addLocToMap() {
        if let coor = coordinate {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, 3000, 3000)
            faeMapView.setRegion(coordinateRegion, animated: false)
            let addressPin = AddressAnnotation()
            addressPin.coordinate = coor
            faeMapView.addAnnotation(addressPin)
        } else {
            showAlert(title: "Cannot Load Location", message: "please try again", viewCtrler: self) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func loadLocInfoBar() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        // single pin loading, so disable its user interaction
        uiviewLocationBar.isUserInteractionEnabled = false
        guard let coor = coordinate else {
            return
        }
        let locToLoad = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
        uiviewLocationBar.updateLocationInfo(location: locToLoad) { (_, _) in
            
        }
    }
    
}
