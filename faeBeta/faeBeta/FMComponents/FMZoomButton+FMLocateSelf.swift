//
//  FMZoomButton+FMLocateSelf.swift
//  faeBeta
//
//  Created by Yue Shen on 8/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMZoomButton: UIButton {
    
    var mapView: FaeMapView!
    var btnSmall: UIButton!
    var btnLarge: UIButton!
    var btnZoomIn: UIButton!
    var btnZoomOut: UIButton!
    var prevRegion: MKCoordinateRegion!
    var prev_y: CGFloat = 0
    var gesLongPress: UILongPressGestureRecognizer!
    var gesPan: UIPanGestureRecognizer!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: screenWidth - 82, y: screenHeight - 153 - device_offset_bot_main, width: 60, height: 60))
        loadContent()
        gesLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesLongPress.minimumPressDuration = 0.01
        addGestureRecognizer(gesLongPress)
        gesPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(gesPan)
        gesPan.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            largeMode()
            prevRegion = mapView.region
            guard prevRegion != nil else { return }
            Key.shared.FMVCtrler?.placeClusterManager.canUpdate = false
            Key.shared.FMVCtrler?.userClusterManager.canUpdate = false
            prev_y = sender.location(in: self).y
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            smallMode()
            if Key.shared.autoCycle {
                Key.shared.FMVCtrler?.placeClusterManager.canUpdate = true
                Key.shared.FMVCtrler?.userClusterManager.canUpdate = true
            }
            Key.shared.FMVCtrler?.placeClusterManager.manuallyCallRegionDidChange()
            Key.shared.FMVCtrler?.userClusterManager.manuallyCallRegionDidChange()
        } else if sender.state == .changed {
            let point = sender.location(in: self)
            let m = Double(point.y - prev_y)
            zoom(multiplier: m * 0.05)
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            prevRegion = mapView.region
            guard prevRegion != nil else { return }
            Key.shared.FMVCtrler?.placeClusterManager.canUpdate = false
            Key.shared.FMVCtrler?.userClusterManager.canUpdate = false
            prev_y = sender.location(in: self).y
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            Key.shared.FMVCtrler?.placeClusterManager.canUpdate = true
            Key.shared.FMVCtrler?.userClusterManager.canUpdate = true
            Key.shared.FMVCtrler?.placeClusterManager.manuallyCallRegionDidChange()
            Key.shared.FMVCtrler?.userClusterManager.manuallyCallRegionDidChange()
        } else if sender.state == .changed {
            let point = sender.location(in: self)
            let m = Double(point.y - prev_y)
            zoom(multiplier: m * 0.05)
        }
    }
    
    func zoom(multiplier: Double) {
        guard prevRegion != nil else { return }
        var region = prevRegion
        var span = prevRegion.span
        var lat = span.latitudeDelta * pow(2, multiplier)
        var lon = span.longitudeDelta * pow(2, multiplier)
        
        if lat > 140 {
            lat = 140
        } else if lat < 0.0006 {
            lat = 0.0006
        }
        if lon < 0.0006 {
            lon = 0.0006
        } else if lon > 140 {
            lon = 140
        }

        span.latitudeDelta = lat
        span.longitudeDelta = lon
        
        region?.span = span
        mapView.setRegion(region!, animated: false)
    }
    
    func makeZoom(_ timer: Timer) {
        guard let region = timer.userInfo as? MKCoordinateRegion else { return }
        mapView.setRegion(region, animated: false)
    }
    
    @objc func largeMode() {
        guard !self.isSelected else { return }
        self.isSelected = true
        UIView.animate(withDuration: 0.2) {
            self.btnSmall.alpha = 0
            self.btnLarge.alpha = 1
            let origin_y = self.frame.origin.y
            self.frame = CGRect(x: screenWidth - 82, y: origin_y - 63, width: 60, height: 122)
        }
    }
    
    func smallMode() {
        guard self.isSelected else { return }
        self.isSelected = false
        UIView.animate(withDuration: 0.2) {
            self.btnSmall.alpha = 1
            self.btnLarge.alpha = 0
            let origin_y = self.frame.origin.y
            self.frame = CGRect(x: screenWidth - 82, y: origin_y + 63, width: 60, height: 60)
        }
    }
    
    @objc func zoomIn() {
        var region = mapView.region
        var span = mapView.region.span
        span.latitudeDelta *= 0.5
        span.longitudeDelta *= 0.5
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomOut() {
        var region = mapView.region
        var span = mapView.region.span
        span.latitudeDelta *= 2
        span.longitudeDelta *= 2
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    @objc func tapToLargeMode() {
        gesLongPress.isEnabled = false
        gesPan.isEnabled = true
        largeMode()
    }
    
    @objc func tapToSmallMode() {
        gesLongPress.isEnabled = true
        gesPan.isEnabled = false
        smallMode()
    }
    
    private func loadContent() {
        layer.zPosition = 500
        adjustsImageWhenHighlighted = false
        
        btnSmall = UIButton()
        addSubview(btnSmall)
        btnSmall.alpha = 1
        btnSmall.addTarget(self, action: #selector(tapToLargeMode), for: [.touchUpInside])
        btnSmall.setImage(#imageLiteral(resourceName: "main_map_zoom_sm"), for: .normal)
        btnSmall.adjustsImageWhenHighlighted = false
        addConstraintsWithFormat("H:|-0-[v0(60)]", options: [], views: btnSmall)
        addConstraintsWithFormat("V:[v0(60)]-0-|", options: [], views: btnSmall)
        
        btnLarge = UIButton()
        addSubview(btnLarge)
        btnLarge.alpha = 0
        btnLarge.setImage(#imageLiteral(resourceName: "main_map_zoom_lg_new"), for: .normal)
        btnLarge.adjustsImageWhenHighlighted = false
        addConstraintsWithFormat("H:|-0-[v0(60)]", options: [], views: btnLarge)
        addConstraintsWithFormat("V:[v0(122)]-(-2)-|", options: [], views: btnLarge)
        
        btnZoomIn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 61))
        btnLarge.addSubview(btnZoomIn)
        btnZoomIn.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        
        btnZoomOut = UIButton(frame: CGRect(x: 0, y: 61, width: 60, height: 61))
        btnLarge.addSubview(btnZoomOut)
        btnZoomOut.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
    }
}

class FMLocateSelf: UIButton {
    
    var mapView: MKMapView!
    var nameCard = FMNameCardView()
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 21, y: screenHeight - 153 - device_offset_bot_main, width: 60, height: 60))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenLocateSelf"), for: .normal)
        addTarget(self, action: #selector(actionLocateSelf(_:)), for: .touchUpInside)
        layer.zPosition = 500
        adjustsImageWhenHighlighted = false
    }
    
    @objc func actionLocateSelf(_ sender: UIButton) {
        FaeSearch.shared.search { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
        }
        Key.shared.FMVCtrler?.btnZoom.smallMode()
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
        nameCard.hide() {
            Key.shared.FMVCtrler?.mapGesture(isOn: true)
        }
    }
}
