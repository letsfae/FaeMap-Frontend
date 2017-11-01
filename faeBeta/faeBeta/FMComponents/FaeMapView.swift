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
    var slcMapCtrler: SelectLocationViewController?
    var blockTap = false
    var cgfloatCompassOffset: CGFloat = 215 // 134 & 215
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let compassView = self.subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!)}).first {
            compassView.frame = CGRect(x: 21, y: screenHeight - cgfloatCompassOffset, width: 60, height: 60)
            if let imgView = compassView.subviews.first as? UIImageView {
                imgView.image = #imageLiteral(resourceName: "mainScreenNorth")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        
        let singleTapTwo = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapTwo(_:)))
        singleTapTwo.numberOfTapsRequired = 1
        singleTapTwo.numberOfTouchesRequired = 2
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        
        addGestureRecognizer(singleTap)
        addGestureRecognizer(longPress)
        addGestureRecognizer(singleTapTwo)
        guard let subview = self.subviews.first else { return }
        subview.addGestureRecognizer(doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelCreatingLocationPin() {
        if Key.shared.FMVCtrler?.createLocation == .create {
            Key.shared.FMVCtrler?.createLocation = .cancel
        } else {
            Key.shared.FMVCtrler?.locAnnoView?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            Key.shared.FMVCtrler?.deselectAllLocations()
        }
        if slcMapCtrler?.createLocation == .create {
            slcMapCtrler?.createLocation = .cancel
        }
    }
    
    @objc func handleSingleTapTwo(_ tapGesture: UITapGestureRecognizer) {
        
    }
    
    @objc func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        guard slcMapCtrler == nil else { return }
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        Key.shared.FMVCtrler?.uiviewNameCard.hide() {
            Key.shared.FMVCtrler?.mapGesture(isOn: true)
        }
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if Key.shared.FMVCtrler?.mapMode != .routing {
                if let anView = v as? PlacePinAnnotationView {
                    if !anView.optionsOpened {
                        Key.shared.FMVCtrler?.deselectAllAnnotations()
                        Key.shared.FMVCtrler?.tapPlacePin(didSelect: anView)
                        anView.showButtons()
                        anView.optionsReady = true
                        anView.optionsOpened = true
                    }
                } else if let anView = v as? UserPinAnnotationView {
                    Key.shared.FMVCtrler?.deselectAllAnnotations()
                    Key.shared.FMVCtrler?.uiviewPlaceBar.hide()
                    Key.shared.FMVCtrler?.tapUserPin(didSelect: anView)
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
            Key.shared.FMVCtrler?.mapGesture(isOn: true)
            
        }
        block = false
        guard Key.shared.FMVCtrler?.uiviewFilterMenu != nil else { return }
        Key.shared.FMVCtrler?.uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
    }
    
    @objc func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        
        guard Key.shared.FMVCtrler?.mapMode != .routing || slcMapCtrler != nil else { return }
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if let anView = v as? PlacePinAnnotationView {
                Key.shared.FMVCtrler?.uiviewNameCard.hide() {
                    Key.shared.FMVCtrler?.mapGesture(isOn: true)
                }
                cancelCreatingLocationPin()
                if anView.optionsReady == false {
                    Key.shared.FMVCtrler?.deselectAllAnnotations()
                    Key.shared.FMVCtrler?.tapPlacePin(didSelect: anView)
                    slcMapCtrler?.deselectAllAnnotations()
                    slcMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.optionsReady = slcMapCtrler == nil
                } else if anView.optionsReady && !anView.optionsOpened {
                    anView.showButtons()
                    anView.optionsOpened = true
                    Key.shared.FMVCtrler?.tapPlacePin(didSelect: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            } else if let anView = v as? UserPinAnnotationView {
                cancelCreatingLocationPin()
                Key.shared.FMVCtrler?.uiviewPlaceBar.hide()
                Key.shared.FMVCtrler?.tapUserPin(didSelect: anView)
            } else if let anView = v as? LocPinAnnotationView {
                Key.shared.FMVCtrler?.uiviewNameCard.hide() {
                    Key.shared.FMVCtrler?.mapGesture(isOn: true)
                }
                if slcMapCtrler == nil {
                    if anView.optionsReady == false {
                        Key.shared.FMVCtrler?.deselectAllLocations()
                        Key.shared.FMVCtrler?.tapLocationPin(didSelect: anView)
                        anView.optionsReady = true
                    } else if anView.optionsReady && !anView.optionsOpened {
                        anView.showButtons()
                        anView.optionsOpened = true
                    } else if anView.optionsReady && anView.optionsOpened {
                        anView.hideButtons()
                        anView.optionsOpened = false
                    }
                }
            }
        } else {
            Key.shared.FMVCtrler?.uiviewNameCard.hide() {
                Key.shared.FMVCtrler?.mapGesture(isOn: true)
            }
            Key.shared.FMVCtrler?.uiviewSavedList.hide()
            Key.shared.FMVCtrler?.btnZoom.tapToSmallMode()
            if v is FMLocationInfoBar {
                
            } else {
                cancelCreatingLocationPin()
                Key.shared.FMVCtrler?.mapGesture(isOn: true)
                if Key.shared.FMVCtrler?.mapMode != .pinDetail {
                    Key.shared.FMVCtrler?.uiviewPlaceBar.hide()
                }
                slcMapCtrler?.uiviewPlaceBar.hide()
                Key.shared.FMVCtrler?.deselectAllAnnotations()
                slcMapCtrler?.deselectAllAnnotations()
                slcMapCtrler?.selectedPlace = nil
            }
        }
        block = false
        guard Key.shared.FMVCtrler?.uiviewFilterMenu != nil else { return }
        Key.shared.FMVCtrler?.uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard Key.shared.FMVCtrler?.mapMode != .routing || slcMapCtrler != nil else { return }
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
                    Key.shared.FMVCtrler?.deselectAllAnnotations()
                    Key.shared.FMVCtrler?.tapPlacePin(didSelect: anView)
                    anView.showButtons()
                }
            } else if let _ = v as? UserPinAnnotationView {
                block = true
                cancelCreatingLocationPin()
            } else if let anView = v as? LocPinAnnotationView {
                if anView.arrBtns.count == 0 {
                    Key.shared.FMVCtrler?.deselectAllAnnotations()
                    anView.showButtons()
                }
            } else {
                if !(v is UIButton) {
                    Key.shared.FMVCtrler?.createLocationPin(point: tapPoint)
                    slcMapCtrler?.createLocationPin(point: tapPoint)
                }
            }
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
                Key.shared.FMVCtrler?.selectedPlaceView?.hideButtons()
            }
            if let anView = Key.shared.FMVCtrler?.selectedPlaceView {
                anView.chooseAction()
                Key.shared.FMVCtrler?.uiviewPinActionDisplay.hide()
            } else if Key.shared.FMVCtrler?.createLocation == .create {
                guard let anView = Key.shared.FMVCtrler?.locAnnoView else { return }
                guard anView.arrBtns.count == 4 else { return }
                anView.chooseAction()
                Key.shared.FMVCtrler?.uiviewPinActionDisplay.hide()
            }
            let delayInSeconds: Double = 0.1
            let popTime = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                self.block = false
            }
        } else if sender.state == .changed {
            if let anView = Key.shared.FMVCtrler?.selectedPlaceView {
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnDetail, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .detail)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnCollect, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .collect)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnRoute, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .route)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnShare, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .share)
                } else {
                    anView.optionsToNormal()
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.hide()
                }
            } else if Key.shared.FMVCtrler?.createLocation == .create {
                guard let anView = Key.shared.FMVCtrler?.locAnnoView else { return }
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnDetail, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .detail, .create)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnCollect, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .collect, .create)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    anView.action(anView.btnRoute, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .route, .create)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    anView.action(anView.btnShare, animated: true)
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.changeStyle(action: .share, .create)
                } else {
                    anView.optionsToNormal()
                    Key.shared.FMVCtrler?.uiviewPinActionDisplay.hide()
                }
            }
            
        }
    }
}
