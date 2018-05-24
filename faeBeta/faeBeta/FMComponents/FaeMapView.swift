//
//  FaeMapView.swift
//  faeBeta
//
//  Created by Yue Shen on 8/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

@objc protocol MapAction: class {
    @objc optional func changeIconStyle(action: Int, isPlace: Bool)
    @objc optional func hideNameCard()
    @objc optional func placePinTap(view: MKAnnotationView)
    @objc optional func deselectAllPlaces(_ full: Bool)
}

class FaeMapView: MKMapView {

    var mapDelegate: MapAction?
    private var isPlaceAnno = true
    private var block = false
    var faeMapCtrler: FaeMapViewController?
    var slcMapCtrler: SelectLocationViewController?
    var bscMapCtrler: BasicMapController?
    var blockTap = false
    var cgfloatCompassOffset: CGFloat = 215 // 134 & 215
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    var longPress: UILongPressGestureRecognizer!
    
    var selectedPlaceAnno: PlacePinAnnotationView?
    var selectedLocAnno: LocPinAnnotationView?
    
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
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
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
            faeMapCtrler?.selectedLocAnno?.assignImage(#imageLiteral(resourceName: "icon_destination"))
            faeMapCtrler?.deselectAllLocations()
        }
        if slcMapCtrler?.createLocation == .on {
            slcMapCtrler?.createLocation = .off
        }
    }
    
    @objc func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if let anView = v as? PlacePinAnnotationView {
                mapDelegate?.hideNameCard?()
                cancelCreatingLocationPin()
                if anView.optionsReady == false {   // first tap place pin
                    mapDelegate?.deselectAllPlaces?(true)
                    mapDelegate?.placePinTap?(view: anView)
                    slcMapCtrler?.deselectAllAnnotations()
                    slcMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.optionsReady = slcMapCtrler == nil
                } else if anView.optionsReady && !anView.optionsOpened {   // second tap place pin
                    anView.showButtons()
                    anView.optionsOpened = true
                    mapDelegate?.placePinTap?(view: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            } else if let anView = v as? UserPinAnnotationView {
                cancelCreatingLocationPin()
                mapDelegate?.deselectAllPlaces?(true)
                faeMapCtrler?.tblPlaceResult.hide()
                faeMapCtrler?.tapUserPin(didSelect: anView)
            } else if let anView = v as? LocPinAnnotationView {
                mapDelegate?.hideNameCard?()
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
            mapDelegate?.hideNameCard?()
            faeMapCtrler?.uiviewSavedList.hide()
            faeMapCtrler?.btnZoom.tapToSmallMode()
            if v is FMLocationInfoBar {
                
            } else {
                cancelCreatingLocationPin()
                faeMapCtrler?.mapGesture(isOn: true)
                if (faeMapCtrler?.mapMode != .pinDetail || faeMapCtrler?.modePinDetail == .off) && faeMapCtrler?.swipingState != .multipleSearch {
                    faeMapCtrler?.tblPlaceResult.hide()
                }
                slcMapCtrler?.uiviewPlaceBar.hide()
                if faeMapCtrler == nil {
                    mapDelegate?.deselectAllPlaces?(true)
                } else {
                    mapDelegate?.deselectAllPlaces?(faeMapCtrler?.swipingState == .map)
                }
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
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        mapDelegate?.hideNameCard?()
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            if faeMapCtrler?.mapMode != .routing {
                if let anView = v as? PlacePinAnnotationView {
                    if !anView.optionsOpened {
//                        faeMapCtrler?.deselectAllPlaceAnnos()
                        mapDelegate?.deselectAllPlaces?(true)
                        anView.optionsReady = true
                        anView.optionsOpened = true
                        mapDelegate?.placePinTap?(view: anView)
                        anView.showButtons()
                    }
                } else if let anView = v as? UserPinAnnotationView {
//                    faeMapCtrler?.deselectAllPlaceAnnos()
                    mapDelegate?.deselectAllPlaces?(true)
                    faeMapCtrler?.tblPlaceResult.hide()
                    faeMapCtrler?.tapUserPin(didSelect: anView)
                }
            }
        } else {
            faeMapCtrler?.mapGesture(isOn: true)
        }
        block = false
        guard faeMapCtrler?.uiviewDropUpMenu != nil else { return }
        faeMapCtrler?.uiviewDropUpMenu.hide()
        faeMapCtrler?.btnDropUpMenu.isSelected = false
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard blockTap == false else { return }
        let tapPoint = sender.location(in: self)
        let numberOfTouches = sender.numberOfTouches
        guard numberOfTouches == 1 else { return }
        if sender.state == .began {
            let v: Any? = hitTest(tapPoint, with: nil)
            isPlaceAnno = false
            if let anView = v as? PlacePinAnnotationView {
                block = true
                isPlaceAnno = true
                cancelCreatingLocationPin()
                if anView.arrBtns.count == 0 {
//                    faeMapCtrler?.deselectAllPlaceAnnos()
                    mapDelegate?.deselectAllPlaces?(true)
                    anView.optionsOpened = true
                    mapDelegate?.placePinTap?(view: anView)
                    anView.showButtons()
                }
            } else if let _ = v as? UserPinAnnotationView {
                block = true
                cancelCreatingLocationPin()
            } else if let anView = v as? LocPinAnnotationView {
                if anView.arrBtns.count == 0 {
//                    faeMapCtrler?.deselectAllPlaceAnnos()
                    mapDelegate?.deselectAllPlaces?(true)
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
                if anView.optionsOpened {
                    anView.hideButtons()
                }
                anView.optionsReady = true
            } else if let anView = v as? LocPinAnnotationView {
                if !anView.optionsOpened {
                    anView.hideButtons()
                }
                anView.optionsReady = true
            } else {
                faeMapCtrler?.selectedPlaceAnno?.hideButtons()
            }
            if let anView = faeMapCtrler?.selectedPlaceAnno {
                anView.chooseAction()
                faeMapCtrler?.uiviewPinActionDisplay.hide()
            } else if faeMapCtrler?.modeLocCreating == .on {
                guard let anView = faeMapCtrler?.selectedLocAnno else { return }
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
            if isPlaceAnno {
                guard let anView = selectedPlaceAnno else { return }
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    mapDelegate?.changeIconStyle?(action: 1, isPlace: true)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    mapDelegate?.changeIconStyle?(action: 2, isPlace: true)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    mapDelegate?.changeIconStyle?(action: 3, isPlace: true)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    mapDelegate?.changeIconStyle?(action: 4, isPlace: true)
                } else {
                    mapDelegate?.changeIconStyle?(action: 0, isPlace: true)
                }
            } else {
                guard let anView = selectedLocAnno else { return }
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    mapDelegate?.changeIconStyle?(action: 1, isPlace: false)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    mapDelegate?.changeIconStyle?(action: 2, isPlace: false)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    mapDelegate?.changeIconStyle?(action: 3, isPlace: false)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    mapDelegate?.changeIconStyle?(action: 4, isPlace: false)
                } else {
                    mapDelegate?.changeIconStyle?(action: 0, isPlace: false)
                }
            }
            
        }
    }
}
