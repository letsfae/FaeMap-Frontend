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
    var nameCard = FMNameCardView()
    var faeMapCtrler: FaeMapViewController?
    var savedTransform: CGAffineTransform!
    var boolLowPos = false
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: screenWidth - 81.5, y: screenHeight - 153, width: 60, height: 60))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "main_map_zoom_sm"), for: .normal)
        addTarget(self, action: #selector(actionToNorth(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionToNorth(_ sender: UIButton) {
        let camera = mapView.camera
        camera.heading = 0
        mapView.setCamera(camera, animated: true)
        transform = CGAffineTransform.identity
        nameCard.hide() {
            self.faeMapCtrler?.mapGesture(isOn: true)
        }
    }
    
    func rotateCompass() {
        if boolLowPos {
            self.transform = CGAffineTransform.identity
            self.frame.origin.y = 664 * screenHeightFactor
        }
        let angle = CGFloat(Double.pi * -self.mapView.camera.heading) / 180.0
        let newTransform = CGAffineTransform.identity.rotated(by: angle)
        self.transform = newTransform
        UIView.animate(withDuration: 0.25) {
            
        }
    }
}

class FMLocateSelf: UIButton {
    
    var mapView: MKMapView!
    var nameCard = FMNameCardView()
    var faeMapCtrler: FaeMapViewController?
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 21.5, y: screenHeight - 153, width: 60, height: 60))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenLocateSelf_new"), for: .normal)
        addTarget(self, action: #selector(actionLocateSelf(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionLocateSelf(_ sender: UIButton) {
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
        nameCard.hide() {
            self.faeMapCtrler?.mapGesture(isOn: true)
        }
    }
}
