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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let tapPoint: CGPoint = tapGesture.location(in: self)
        let numberOfTouches: Int = tapGesture.numberOfTouches
        if numberOfTouches == 1 && tapGesture.state == .ended {
            if !blockTap {
                blockTap = true
                faeMapCtrler?.uiviewNameCard.hide() {
                    self.faeMapCtrler?.mapGesture(isOn: true)
                }
                let v: Any? = hitTest(tapPoint, with: nil)
                if v is MKAnnotationView {
                    if let anView = v as? PlacePinAnnotationView {
                        if anView.boolBtnsReadyToOpened == false {
                            faeMapCtrler?.deselectAllAnnotations()
                            faeMapCtrler?.tapPlacePin(didSelect: anView)
                            anView.boolBtnsReadyToOpened = true
                        } else if anView.boolBtnsReadyToOpened && !anView.boolOptionsOpened {
                            anView.showButtons()
                            anView.boolOptionsOpened = true
                            faeMapCtrler?.tapPlacePin(didSelect: anView)
                        } else if anView.boolBtnsReadyToOpened && anView.boolOptionsOpened {
                            anView.hideButtons()
                            anView.boolOptionsOpened = false
                        }
                    } else if let anView = v as? UserPinAnnotationView {
                        faeMapCtrler?.placeResultBar.fadeOut()
                        faeMapCtrler?.tapUserPin(didSelect: anView)
                    }
                } else {
                    faeMapCtrler?.placeResultBar.fadeOut()
                    faeMapCtrler?.deselectAllAnnotations()
                }
                blockTap = false
                guard faeMapCtrler?.uiviewFilterMenu != nil else { return }
                faeMapCtrler?.uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
            }
        }
    }

    func handleLongPress(_ sender: UILongPressGestureRecognizer) {
//        joshprint("state:")
//        joshprint(1, sender.state == .began)
//        joshprint(2, sender.state == .cancelled)
//        joshprint(3, sender.state == .changed)
//        joshprint(4, sender.state == .ended)
//        joshprint(5, sender.state == .failed)
//        joshprint(6, sender.state == .possible)
//        joshprint(7, sender.state == .recognized)
        blockTap = true
        let tapPoint: CGPoint = sender.location(in: self)
        let numberOfTouches: Int = sender.numberOfTouches
        
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
                anView.hideButtons()
                anView.boolBtnsReadyToOpened = true
            }
            let delayInSeconds: Double = 0.1
            let popTime = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                self.blockTap = false
            }
        }
    }

}
