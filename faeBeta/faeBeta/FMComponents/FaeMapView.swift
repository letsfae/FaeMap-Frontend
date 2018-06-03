//
//  FaeMapView.swift
//  faeBeta
//
//  Created by Yue Shen on 8/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

@objc protocol MapAction: class {
    
    @objc optional func iconStyleChange(action: Int, isPlace: Bool)
    
    @objc optional func allPlacesDeselect(_ full: Bool)
    
    @objc optional func placePinTap(view: MKAnnotationView)
    @objc optional func userPinTap(view: MKAnnotationView)
    @objc optional func locPinTap(view: MKAnnotationView)
    @objc optional func locPinCreatingCancel()
    @objc optional func locPinCreating(point: CGPoint)
    
    @objc optional func singleElsewhereTap()
    @objc optional func singleElsewhereTapExceptInfobar()
    @objc optional func singleTapAllTimeControl()
    
    @objc optional func doubleElsewhereTap()
    @objc optional func doubleTapAllTimeControl()
    
    @objc optional func longPressAllTimeCtrlWhenBegan()
}

class FaeMapView: MKMapView {

    weak var mapAction: MapAction?
    
    private var isPlaceAnno = true
    private var block = false
    public var blockTap = false
    
    public var cgfloatCompassOffset: CGFloat = 215 // 134 & 215
    
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    var longPress: UILongPressGestureRecognizer!
    
    var selectedPlaceAnno: PlacePinAnnotationView?
    var selectedLocAnno: LocPinAnnotationView?
    
    public var uiviewNameCard: FMNameCardView?
    public var uiviewPinActionDisplay: FMPinActionDisplay?
    
    public var isSingleTapOnLocPinEnabled: Bool = false
    public var isDoubleTapOnMKAnnoViewEnabled: Bool = true
    public var isSingleTapToShowFourIconsEnabled: Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // customize the compass view in the way our app's ui
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
    
    @objc private func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            // Place Pin Tap
            if let anView = v as? PlacePinAnnotationView {
                nameCardHide(gestureEnabled: true)
                mapAction?.locPinCreatingCancel?()
                if anView.optionsReady == false {  // first tap place pin
                    mapAction?.allPlacesDeselect?(true)
                    mapAction?.placePinTap?(view: anView)
                    anView.optionsReady = true
                } else if anView.optionsReady && !anView.optionsOpened {  // second tap place pin
                    guard isSingleTapToShowFourIconsEnabled else { return }
                    anView.showButtons()
                    anView.optionsOpened = true
                    mapAction?.placePinTap?(view: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            } else
            // User Pin Tap
            if let anView = v as? UserPinAnnotationView {
                mapAction?.locPinCreatingCancel?()
                mapAction?.allPlacesDeselect?(true)
                mapAction?.userPinTap?(view: anView)
            } else
            // Location Pin Tap
            if let anView = v as? LocPinAnnotationView {
                nameCardHide(gestureEnabled: true)
                guard isSingleTapOnLocPinEnabled else { return }
                if anView.optionsReady == false {
                    mapAction?.allPlacesDeselect?(true)
                    mapAction?.locPinTap?(view: anView)
                    anView.optionsReady = true
                } else if anView.optionsReady && !anView.optionsOpened {
                    anView.showButtons()
                    anView.optionsOpened = true
                    mapAction?.locPinTap?(view: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            }
        } else {
            mapAction?.singleElsewhereTap?()
            nameCardHide(gestureEnabled: true)
            if !(v is FMLocationInfoBar) {
                mapAction?.singleElsewhereTapExceptInfobar?()
                mapAction?.locPinCreatingCancel?()
            }
        }
        block = false
        mapAction?.singleTapAllTimeControl?()
    }
    
    @objc private func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !block else { return }
        block = true
        nameCardHide(gestureEnabled: true)
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView && blockTap == false {
            guard isDoubleTapOnMKAnnoViewEnabled else { return }
            if let anView = v as? PlacePinAnnotationView {
                if !anView.optionsOpened {
                    mapAction?.allPlacesDeselect?(true)
                    anView.optionsReady = true
                    anView.optionsOpened = true
                    mapAction?.placePinTap?(view: anView)
                    anView.showButtons()
                }
            } else if let anView = v as? UserPinAnnotationView {
                mapAction?.allPlacesDeselect?(true)
                mapAction?.userPinTap?(view: anView)
            }
        } else {
            mapAction?.doubleElsewhereTap?()
        }
        block = false
        mapAction?.doubleTapAllTimeControl?()
    }

    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
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
                mapAction?.locPinCreatingCancel?()
                if anView.arrBtns.count == 0 {
                    mapAction?.allPlacesDeselect?(true)
                    anView.optionsOpened = true
                    mapAction?.placePinTap?(view: anView)
                    anView.showButtons()
                }
            } else if let _ = v as? UserPinAnnotationView {
                block = true
                mapAction?.locPinCreatingCancel?()
            } else if let anView = v as? LocPinAnnotationView {
                if anView.arrBtns.count == 0 {
                    mapAction?.allPlacesDeselect?(true)
                    anView.showButtons()
                }
            } else {
                if !(v is UIButton) {
                    mapAction?.locPinCreating?(point: tapPoint)
                }
            }
            mapAction?.longPressAllTimeCtrlWhenBegan?()
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
                selectedPlaceAnno?.hideButtons()
            }
            if let anView = selectedPlaceAnno {
                anView.chooseAction()
                uiviewPinActionDisplay?.hide()
            } else if let anView = selectedLocAnno {
                anView.chooseAction()
                uiviewPinActionDisplay?.hide()
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
                    mapAction?.iconStyleChange?(action: 1, isPlace: true)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    mapAction?.iconStyleChange?(action: 2, isPlace: true)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    mapAction?.iconStyleChange?(action: 3, isPlace: true)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    mapAction?.iconStyleChange?(action: 4, isPlace: true)
                } else {
                    mapAction?.iconStyleChange?(action: 0, isPlace: true)
                }
            } else {
                guard let anView = selectedLocAnno else { return }
                guard anView.arrBtns.count == 4 else { return }
                let point = sender.location(in: anView)
                if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                    mapAction?.iconStyleChange?(action: 1, isPlace: false)
                }
                else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                    mapAction?.iconStyleChange?(action: 2, isPlace: false)
                }
                else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                    mapAction?.iconStyleChange?(action: 3, isPlace: false)
                }
                else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                    mapAction?.iconStyleChange?(action: 4, isPlace: false)
                } else {
                    mapAction?.iconStyleChange?(action: 0, isPlace: false)
                }
            }
        }
    }
    
    // MARK: - 辅助函数
    func nameCardHide(gestureEnabled: Bool) {
        uiviewNameCard?.hide {
            self.mapGesture(isOn: gestureEnabled)
        }
    }
    
    func mapGesture(isOn: Bool) {
        isZoomEnabled = isOn
        isPitchEnabled = isOn
        isRotateEnabled = isOn
        isScrollEnabled = isOn
    }
}
