//
//  FMActions.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func renewSelfLocation() {
        guard LocManager.shared.curtLoc != nil else { return }
        
        DispatchQueue.global(qos: .background).async {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
            selfLocation.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
            selfLocation.renewCoordinate {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    // print("Successfully renew self position")
                } else {
                    print("[renewSelfLocation] fail")
                }
            }
        }
    }
    
    func actionTrueNorth(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        let camera = faeMapView.camera
        camera.heading = 0
        faeMapView.setCamera(camera, animated: true)
        btnCompass.transform = CGAffineTransform.identity
    }
    
    // Jump to pin menu view controller
    func actionCreatePin(_ sender: UIButton) {
        /*
        btnCardClose.sendActions(for: .touchUpInside)
        let mapCenter_point = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenter_coor = faeMapView.convert(mapCenter_point, toCoordinateFrom: nil)
        invalidateAllTimer()
        let pinMenuVC = PinMenuViewController()
        pinMenuVC.modalPresentationStyle = .overCurrentContext
        Key.shared.dblAltitude = faeMapView.camera.altitude
        Key.shared.selectedLoc = mapCenter_coor
        pinMenuVC.delegate = self
        self.present(pinMenuVC, animated: false, completion: nil)
         */
    }
    
    func actionSelfPosition(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        faeMapView.setCamera(camera, animated: true)
    }
    
    func actionMainScreenSearch(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
        let mainScreenSearchVC = MainScreenSearchViewController()
        mainScreenSearchVC.modalPresentationStyle = .overCurrentContext
        mainScreenSearchVC.delegate = self
        self.present(mainScreenSearchVC, animated: false, completion: nil)
    }
    
    func actionLeftWindowShow(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.displayName = Key.shared.nickname ?? "someone"
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        self.present(leftMenuVC, animated: false, completion: nil)
    }
    
    func actionChatWindowShow(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        self.present(UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
    }
    
    func actionReportThisPin(_ sender: UIButton) {
        btnCardClose.sendActions(for: .touchUpInside)
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        self.present(reportPinVC, animated: true, completion: nil)
    }
}
