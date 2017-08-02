//
//  FMCustomComponents.swift
//  faeBeta
//
//  Created by Yue Shen on 8/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMCompass: UIButton {
    
    var mapView: MKMapView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 22, y: 582 * screenWidthFactor, width: 59, height: 59))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenNorth"), for: .normal)
        addTarget(self, action: #selector(actionToNorth(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionToNorth(_ sender: UIButton) {
        //        btnCardClose.sendActions(for: .touchUpInside)
        let camera = mapView.camera
        camera.heading = 0
        mapView.setCamera(camera, animated: true)
        transform = CGAffineTransform.identity
    }
    
    func rotateCompass() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -self.mapView.camera.heading) / 180.0)
        })
    }
}

class FMLocateSelf: UIButton {
    
    var mapView: MKMapView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59))
        loadContent()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.addTarget(self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenSelfCenter"), for: .normal)
        addTarget(self, action: #selector(actionLocateSelf(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionLocateSelf(_ sender: UIButton) {
        //        btnCardClose.sendActions(for: .touchUpInside)
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
    }
    
    func handleTap() {
        let curLoc2D = CLLocationCoordinate2DMake(LocManager.shared.curtLat, LocManager.shared.curtLong)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(curLoc2D, 3000, 3000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
