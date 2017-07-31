//
//  PlaceResultView.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import MapKit
import CCHMapClusterController

protocol PlaceViewDelegate: class {
    func animateTo(annotation: CCHMapClusterAnnotation?)
    func goToNext(annotation: CCHMapClusterAnnotation?)
    func goToPrev(annotation: CCHMapClusterAnnotation?)
}

class PlaceResultView: UIView {
    
    weak var delegate: PlaceViewDelegate?
    
    var imgBack_0 = PlaceView()
    var imgBack_1 = PlaceView()
    var imgBack_2 = PlaceView()
    
    var offset: CGFloat = 0
    
    var boolLeft = true
    var boolRight = true
    
    var annotations = [CCHMapClusterAnnotation]() {
        didSet {
            boolLeft = annotations.count > 1
            boolRight = annotations.count > 1
        }
    }
    
    var prevAnnotation: CCHMapClusterAnnotation!
    var nextAnnotation: CCHMapClusterAnnotation!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 70, width: screenWidth, height: 68))
        loadContent()
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
        tag = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        layer.zPosition = 605
        addSubview(imgBack_0)
        addSubview(imgBack_1)
        addSubview(imgBack_2)
//        imgBack_0.layer.borderColor = UIColor.red.cgColor
//        imgBack_1.layer.borderColor = UIColor.green.cgColor
//        imgBack_2.layer.borderColor = UIColor.blue.cgColor
        resetSubviews()
    }
    
    func resetSubviews() {
        imgBack_0.frame.origin.x = -screenWidth + 2
        imgBack_1.frame.origin.x = 0 + 2
        imgBack_2.frame.origin.x = screenWidth + 2
        
//        imgBack_0.frame.origin.y = 0
//        imgBack_1.frame.origin.y = 80
//        imgBack_2.frame.origin.y = 160
    }
    
    func loadingData(current: CCHMapClusterAnnotation) {
        if let place = current.annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_1.imgType.image = UIImage(named: "place_result_\(placeInfo.class_two_idx)") ?? UIImage(named: "place_result_48")
                imgBack_1.lblName.text = placeInfo.name
                imgBack_1.lblAddr.text = placeInfo.address1 + ", " + placeInfo.address2
            }
        }
        var prev_idx = 0
        var next_idx = 0
        guard annotations.count > 0 else { return }
        for i in 0..<annotations.count {
            if annotations[i] == current {
                joshprint("[loadingData], find equals")
                prev_idx = (i - 1) < 0 ? annotations.count - 1 : i - 1
                next_idx = (i + 1) >= annotations.count ? 0 : i + 1
                joshprint("[loadingData], count = \(annotations.count)")
                joshprint("[loadingData],     i = \(i)")
                joshprint("[loadingData],  prev = \(prev_idx)")
                joshprint("[loadingData],  next = \(next_idx)")
                break
            } else {
                continue
            }
        }
        prevAnnotation = annotations[prev_idx]
        nextAnnotation = annotations[next_idx]
        if let place = annotations[prev_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_0.imgType.image = UIImage(named: "place_result_\(placeInfo.class_two_idx)") ?? UIImage(named: "place_result_48")
                imgBack_0.lblName.text = placeInfo.name
                imgBack_0.lblAddr.text = placeInfo.address1 + ", " + placeInfo.address2
            }
        }
        if let place = annotations[next_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_2.imgType.image = UIImage(named: "place_result_\(placeInfo.class_two_idx)") ?? UIImage(named: "place_result_48")
                imgBack_2.lblName.text = placeInfo.name
                imgBack_2.lblAddr.text = placeInfo.address1 + ", " + placeInfo.address2
            }
        }
    }
    
    func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: self)
        if pan.state == .began {
            offset = location.x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let percent_1 = imgBack_1.center.x / screenWidth
            joshprint("[handlePanGesture]", percent_1)
            if percent_1 > 0.7 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgBack_0.frame.origin.x = 2
                    self.imgBack_1.frame.origin.x += screenWidth + 2
                }, completion: {_ in
                    self.delegate?.goToPrev(annotation: self.prevAnnotation)
                    self.resetSubviews()
                })
            } else if percent_1 < 0.3 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgBack_1.frame.origin.x = -screenWidth + 2
                    self.imgBack_2.frame.origin.x = 2
                }, completion: {_ in
                    self.delegate?.goToNext(annotation: self.nextAnnotation)
                    self.resetSubviews()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.resetSubviews()
                }, completion: nil)
            }
        } else {
            let off = location.x - offset
            if off >= 0 && boolLeft {
                imgBack_0.frame.origin.x += off
                imgBack_1.frame.origin.x += off
            } else if off < 0 && boolRight {
                imgBack_1.frame.origin.x += off
                imgBack_2.frame.origin.x += off
            }
            offset = location.x
        }
    }
}

class PlaceView: UIImageView {
    
    var class_two_idx = 0
    var imgType: UIImageView!
    var lblName: UILabel!
    var lblAddr: UILabel!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 2, y: 0, w: 410, h: 80))
        loadContent()
//        layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        contentMode = .scaleAspectFit
        image = #imageLiteral(resourceName: "placeResult_shadow")
        
        imgType = UIImageView()
        addSubview(imgType)
        addConstraintsWithFormat("H:|-15-[v0(58)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-11-[v0(58)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-83-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-22-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-83-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-43-[v0(16)]", options: [], views: lblAddr)
    }
}
