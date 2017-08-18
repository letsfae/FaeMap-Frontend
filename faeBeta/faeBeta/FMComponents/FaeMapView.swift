//
//  FaeMapView.swift
//  faeBeta
//
//  Created by Yue Shen on 8/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FaeMapView: MKMapView {

    private var blockTap = false
    var faeMapCtrler: FaeMapViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGesture_tps_1 = UITapGestureRecognizer(target: self, action: #selector(handleTap_1(_:)))
        tapGesture_tps_1.numberOfTapsRequired = 1
        
        let tapGesture_tps_2 = UITapGestureRecognizer(target: self, action: #selector(handleTap_2(_:)))
        tapGesture_tps_2.numberOfTapsRequired = 2
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        addGestureRecognizer(tapGesture_tps_1)
        addGestureRecognizer(longPressGesture)
        guard let subview = self.subviews.first else { return }
        subview.addGestureRecognizer(tapGesture_tps_2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap_2(_ tapGesture: UITapGestureRecognizer) {
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !blockTap else { return }
        blockTap = true
        faeMapCtrler?.uiviewNameCard.hide() {
            self.faeMapCtrler?.mapGesture(isOn: true)
        }
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView {
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
        blockTap = false
        guard faeMapCtrler?.uiviewFilterMenu != nil else { return }
        faeMapCtrler?.uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
    }
    
    func handleTap_1(_ tapGesture: UITapGestureRecognizer) {
        let tapPoint = tapGesture.location(in: self)
        let numberOfTouches = tapGesture.numberOfTouches
        guard numberOfTouches == 1 && tapGesture.state == .ended else { return }
        guard !blockTap else { return }
        blockTap = true
        faeMapCtrler?.uiviewNameCard.hide() {
            self.faeMapCtrler?.mapGesture(isOn: true)
        }
        let v: Any? = hitTest(tapPoint, with: nil)
        if v is MKAnnotationView {
            if let anView = v as? PlacePinAnnotationView {
                if anView.optionsReady == false {
                    faeMapCtrler?.deselectAllAnnotations()
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.optionsReady = true
                } else if anView.optionsReady && !anView.optionsOpened {
                    anView.showButtons()
                    anView.optionsOpened = true
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                } else if anView.optionsReady && anView.optionsOpened {
                    anView.hideButtons()
                    anView.optionsOpened = false
                }
            } else if let anView = v as? UserPinAnnotationView {
                faeMapCtrler?.uiviewPlaceBar.hide()
                faeMapCtrler?.tapUserPin(didSelect: anView)
            }
        } else {
            faeMapCtrler?.uiviewPlaceBar.hide()
            faeMapCtrler?.deselectAllAnnotations()
        }
        blockTap = false
        guard faeMapCtrler?.uiviewFilterMenu != nil else { return }
        faeMapCtrler?.uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
    }

    func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        blockTap = true
        let tapPoint = sender.location(in: self)
        let numberOfTouches = sender.numberOfTouches
        guard numberOfTouches == 1 else { return }
        if sender.state == .began {
            let v: Any? = hitTest(tapPoint, with: nil)
            if let anView = v as? PlacePinAnnotationView {
                if anView.arrBtns.count == 0 {
                    faeMapCtrler?.deselectAllAnnotations()
                    faeMapCtrler?.tapPlacePin(didSelect: anView)
                    anView.showButtons()
                }
            }
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            let v: Any? = hitTest(tapPoint, with: nil)
            if let anView = v as? PlacePinAnnotationView {
                if !anView.optionsOpened {
                    anView.hideButtons()
                }
                anView.optionsReady = true
            } else {
                faeMapCtrler?.selectedAnnView?.hideButtons()
            }
            if let anView = faeMapCtrler?.selectedAnnView {
                anView.chooseAction()
                faeMapCtrler?.btnPlacePinActionOnSrchBar.hide()
            }
            let delayInSeconds: Double = 0.1
            let popTime = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                self.blockTap = false
            }
        } else if sender.state == .changed {
            guard let anView = faeMapCtrler?.selectedAnnView else { return }
            let point = sender.location(in: anView)
            if point.x >= 0 && point.x <= 65 && point.y >= 43 && point.y <= 90 {
                anView.action(anView.btnDetail, animated: true)
                faeMapCtrler?.btnPlacePinActionOnSrchBar.changeStyle(action: .detail)
            }
            else if point.x >= 35 && point.x <= 87 && point.y >= 0 && point.y <= 60 {
                anView.action(anView.btnCollect, animated: true)
                faeMapCtrler?.btnPlacePinActionOnSrchBar.changeStyle(action: .collect)
            }
            else if point.x > 87 && point.x <= 139 && point.y >= 0 && point.y <= 60 {
                anView.action(anView.btnRoute, animated: true)
                faeMapCtrler?.btnPlacePinActionOnSrchBar.changeStyle(action: .route)
            }
            else if point.x >= 109 && point.x <= 174 && point.y >= 43 && point.y <= 90 {
                anView.action(anView.btnShare, animated: true)
                faeMapCtrler?.btnPlacePinActionOnSrchBar.changeStyle(action: .share)
            } else {
                anView.optionsToNormal()
                faeMapCtrler?.btnPlacePinActionOnSrchBar.hide()
            }
        }
    }

}
