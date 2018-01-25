//
//  FaeMapView.swift
//  faeBeta
//
//  Created by Yue Shen on 8/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FaeMapView: MKMapView {

    private var block = false
    var faeMapCtrler: FaeMapViewController?
    var slcMapCtrler: SelectLocationViewController?
    var blockTap = false
    var cgfloatCompassOffset: CGFloat = 215 // 134 & 215
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let compassView = self.subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!)}).first {
            compassView.frame = CGRect(x: 21, y: screenHeight - cgfloatCompassOffset - device_offset_bot_main, width: 60, height: 60)
            if let imgView = compassView.subviews.first as? UIImageView {
                imgView.image = #imageLiteral(resourceName: "mainScreenNorth")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        
        addGestureRecognizer(singleTap)
        addGestureRecognizer(longPress)
        guard let subview = self.subviews.first else { return }
        subview.addGestureRecognizer(doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelCreatingLocationPin() {
        if faeMapCtrler?.modeLocCreating == .on {
            if faeMapCtrler?.modeLocation == .off {
                faeMapCtrler?.modeLocCreating = .off
            }
        } else if faeMapCtrler?.modeLocCreating == .off {
            faeMapCtrler?.locAnnoView?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            faeMapCtrler?.deselectAllLocations()
        }
        if slcMapCtrler?.createLocation == .on {
            slcMapCtrler?.createLocation = .off
        }
    }
    
    @objc func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        
        guard faeMapCtrler?.mapMode != .routing || slcMapCtrler != nil else { return }
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if let anView = v as? PlacePinAnnotationView {
                faeMapCtrler?.uiviewNameCard.hide() {
                    self.faeMapCtrler?.mapGesture(isOn: true)
                }
                cancelCreatingLocationPin()
                if anView.optionsReady == false {   // first tap place pin
                    faeMapCtrler?.deselectAllAnnotations()
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                    slcMapCtrler?.deselectAllAnnotations()
                    slcMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.optionsReady = slcMapCtrler == nil
                } else if anView.optionsReady && !anView.optionsOpened {   // second tap place pin
                    anView.showButtons()
                    anView.optionsOpened = true
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            } else if let anView = v as? UserPinAnnotationView {
                cancelCreatingLocationPin()
                faeMapCtrler?.deselectAllAnnotations()
                faeMapCtrler?.uiviewPlaceBar.hide()
                faeMapCtrler?.tapUserPin(didSelect: anView)
            } else if let anView = v as? LocPinAnnotationView {
                faeMapCtrler?.uiviewNameCard.hide() {
                    self.faeMapCtrler?.mapGesture(isOn: true)
                }
                if slcMapCtrler == nil {
                    if anView.optionsReady == false {
                        faeMapCtrler?.deselectAllLocations()
                        faeMapCtrler?.tapLocationPin(didSelect: anView)
                        anView.optionsReady = true
                    } else if anView.optionsReady && !anView.optionsOpened {
                        anView.showButtons()
                        anView.optionsOpened = true
                        faeMapCtrler?.tapLocationPin(didSelect: anView)
                    } else if anView.optionsReady && anView.optionsOpened {
                        anView.hideButtons()
                        anView.optionsOpened = false
                    }
                }
            }
        } else {
            faeMapCtrler?.uiviewNameCard.hide() {
                self.faeMapCtrler?.mapGesture(isOn: true)
            }
            faeMapCtrler?.uiviewSavedList.hide()
            faeMapCtrler?.btnZoom.tapToSmallMode()
            if v is FMLocationInfoBar {
                
            } else {
                cancelCreatingLocationPin()
                faeMapCtrler?.mapGesture(isOn: true)
                if faeMapCtrler?.mapMode != .pinDetail && faeMapCtrler?.swipingState != .multipleSearch {
                    faeMapCtrler?.uiviewPlaceBar.hide()
                }
                slcMapCtrler?.uiviewPlaceBar.hide()
                faeMapCtrler?.deselectAllAnnotations()
                slcMapCtrler?.deselectAllAnnotations()
                slcMapCtrler?.selectedPlace = nil
            }
        }
        block = false
        guard faeMapCtrler?.uiviewDropUpMenu != nil && faeMapCtrler?.mapMode == .normal else { return }
        faeMapCtrler?.uiviewDropUpMenu.hide()
        faeMapCtrler?.btnDropUpMenu.isSelected = false
    }
    
    @objc func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        guard slcMapCtrler == nil else { return }
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        faeMapCtrler?.uiviewNameCard.hide() {
            self.faeMapCtrler?.mapGesture(isOn: true)
        }
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if faeMapCtrler?.mapMode != .routing {
                if let anView = v as? PlacePinAnnotationView {
                    if !anView.optionsOpened {
                        faeMapCtrler?.deselectAllAnnotations()
                        faeMapCtrler?.tapPlacePin(didSelect: anView)
                        anView.showButtons()
                        anView.optionsReady = true
                        anView.optionsOpened = true
                    }
                } else if let anView = v as? UserPinAnnotationView {
                    faeMapCtrler?.deselectAllAnnotations()
                    faeMapCtrler?.uiviewPlaceBar.hide()
                    faeMapCtrler?.tapUserPin(didSelect: anView)
                }
            }
        } else {
            /**
            var region = self.region
            var span = self.region.span
            span.latitudeDelta *= 0.5
            span.longitudeDelta *= 0.5
            region.span = span
            self.setRegion(region, animated: false)
            */
            faeMapCtrler?.mapGesture(isOn: true)
            
        }
        block = false
        guard faeMapCtrler?.uiviewDropUpMenu != nil else { return }
        faeMapCtrler?.uiviewDropUpMenu.hide()
        faeMapCtrler?.btnDropUpMenu.isSelected = false
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard faeMapCtrler?.mapMode != .routing || slcMapCtrler != nil else { return }
        guard blockTap == false else { return }
        let tapPoint = sender.location(in: self)
        let numberOfTouches = sender.numberOfTouches
        guard numberOfTouches == 1 else { return }
        if sender.state == .began {
            let v: Any? = hitTest(tapPoint, with: nil)
            if let anView = v as? PlacePinAnnotationView {
                block = true
                cancelCreatingLocationPin()
                if anView.arrBtns.count == 0 {
                    faeMapCtrler?.deselectAllAnnotations()
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.showButtons()
                }
            } else if let _ = v as? UserPinAnnotationView {
                block = true
                cancelCreatingLocationPin()
            } else if let anView = v as? LocPinAnnotationView {
                if anView.arrBtns.count == 0 {
                    faeMapCtrler?.deselectAllAnnotations()
                    anView.showButtons()
                }
            } else {
                if !(v is UIButton) {
                    faeMapCtrler?.createLocationPin(point: tapPoint)
                    slcMapCtrler?.createLocationPin(point: tapPoint)
                }
            }
            guard faeMapCtrler?.uiviewDropUpMenu != nil else { return }
            faeMapCtrler?.uiviewDropUpMenu.hide()
            faeMapCtrler?.btnDropUpMenu.isSelected = false
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            let v: Any? = hitTest(tapPoint, with: nil)
            if let anView = v as? PlacePinAnnotationView {
                if !anView.optionsOpened {
                    anView.hideButtons()
                }
                anView.optionsReady = true
            } else if let anView = v as? LocPinAnnotationView {
                if !anView.optionsOpened {
                    anView.hideButtons()
                }
                anView.optionsReady = true
            } else {
                faeMapCtrler?.selectedPlaceView?.hideButtons()
            }
            if let anView = faeMapCtrler?.selectedPlaceView {
                anView.chooseAction()
                faeMapCtrler?.uiviewPinActionDisplay.hide()
            } else if faeMapCtrler?.modeLocCreating == .on {
                guard let anView = faeMapCtrler?.locAnnoView else { return }
                guard anView.arrBtns.count == 4 else { return }
                anView.chooseAction()
                faeMapCtrler?.uiviewPinActionDisplay.hide()
            }
            let delayInSeconds: Double = 0.1
            let popTime = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                self.block = false
            }
        } else if sender.state == .changed {
            if let anView = faeMapCtrler?.selectedPlaceView {
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnDetail, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .detail)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnCollect, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .collect)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnRoute, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .route(placeInfo: nil))
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnShare, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .share)
                } else {
                    anView.optionsToNormal()
                    faeMapCtrler?.uiviewPinActionDisplay.hide()
                }
            } else if faeMapCtrler?.modeLocCreating == .on {
                guard let anView = faeMapCtrler?.locAnnoView else { return }
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnDetail, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .detail, .on)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnCollect, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .collect, .on)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnRoute, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .route(placeInfo: nil), .on)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnShare, animated: true)
                    faeMapCtrler?.uiviewPinActionDisplay.changeStyle(action: .share, .on)
                } else {
                    anView.optionsToNormal()
                    faeMapCtrler?.uiviewPinActionDisplay.hide()
                }
            }
            
        }
    }
}
