//
//  FMActions.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension FaeMapViewController {
    
    func renewSelfLocation() {
        if curLoc != nil {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(curLat)")
            selfLocation.whereKey("geo_longitude", value: "\(curLon)")
            selfLocation.renewCoordinate {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    // print("Successfully renew self position")
                }
                else {
                    print("[renewSelfLocation] fail")
                }
            }
        }
    }
    
    func actionTrueNorth(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        self.faeMapView.animate(toBearing: 0)
    }
    
    // Jump to pin menu view controller
    func actionCreatePin(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        let mapCenter_point = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenter_coor = faeMapView.projection.coordinate(for: mapCenter_point)
        invalidateAllTimer()
        let pinMenuVC = PinMenuViewController()
        pinMenuVC.modalPresentationStyle = .overCurrentContext
        pinMenuVC.currentLatitude = self.curLat
        pinMenuVC.currentLongitude = self.curLon
        pinMenuVC.currentLocation = mapCenter_coor
        pinMenuVC.zoomLevel = faeMapView.camera.zoom
        pinMenuVC.delegate = self
        self.present(pinMenuVC, animated: false, completion: nil)
    }
    
    func actionSelfPosition(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        let camera = GMSCameraPosition.camera(withLatitude: curLat, longitude: curLon, zoom: faeMapView.camera.zoom)
        faeMapView.camera = camera
    }
    
    func actionMainScreenSearch(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        let mainScreenSearchVC = MainScreenSearchViewController()
        mainScreenSearchVC.modalPresentationStyle = .overCurrentContext
        mainScreenSearchVC.delegate = self
        self.present(mainScreenSearchVC, animated: false, completion: nil)
    }
    
    func actionLeftWindowShow(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        let leftMenuVC = LeftSlidingMenuViewController()
        if let displayName = nickname {
            leftMenuVC.displayName = displayName
        }
        else {
            leftMenuVC.displayName = "someone"
        }
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        self.present(leftMenuVC, animated: false, completion: nil)
    }
    
    func actionChatWindowShow(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        self.present (UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!, animated: true,completion: nil )
    }
    
    func actionReportThisPin(_ sender: UIButton) {
        hideNameCard(btnTransparentClose)
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        self.present(reportPinVC, animated: true, completion: nil)
    }
}
