//
//  PlaceResultView.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import MapKit
//import CCHMapClusterController

protocol PlaceViewDelegate: class {
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?, animated: Bool)
}

enum PlaceInfoBarState: String {
    case singleSearch
    case multipleSearch
    case map
}

class FMPlaceInfoBar: UIView {
    
    weak var delegate: PlaceViewDelegate?
    
    private var imgBack_0 = PlaceView()
    private var imgBack_1 = PlaceView()
    private var imgBack_2 = PlaceView()
    
    private var boolLeft = false
    private var boolRight = false
    
    var places = [PlacePin]()
    var annotations = [CCHMapClusterAnnotation]()
    
    private var prevAnnotation: CCHMapClusterAnnotation!
    private var nextAnnotation: CCHMapClusterAnnotation!
    
    private var prevPlacePin: PlacePin!
    private var nextPlacePin: PlacePin!
    
    var boolDisableSwipe = false
    
    var state: PlaceInfoBarState = .map {
        didSet {
            boolLeft = annotations.count > 1 || places.count > 1
            boolRight = annotations.count > 1 || places.count > 1
        }
    }
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 76 + device_offset_top, width: screenWidth, height: 102))
        loadContent()
        tag = 0
        alpha = 0
        let panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        backgroundColor = .clear
        layer.zPosition = 605
        addSubview(imgBack_0)
        addSubview(imgBack_1)
        addSubview(imgBack_2)
        addShadow(view: imgBack_0, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_1, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_2, opa: 0.5, offset: CGSize.zero, radius: 3)
        resetSubviews()
    }
    
    func resetSubviews() {
        imgBack_0.frame.origin.x = -screenWidth + 7
        imgBack_1.frame.origin.x = 7
        imgBack_2.frame.origin.x = screenWidth + 7
    }
    
    func load(for placeInfo: PlacePin) {
        state = .singleSearch
        imgBack_1.setValueForPlace(placeInfo: placeInfo)
        self.alpha = 1
        boolLeft = false
        boolRight = false
    }
    
    func loading(current: PlacePin) {
        state = .multipleSearch
        imgBack_1.setValueForPlace(placeInfo: current)
        self.alpha = 1
        guard places.count > 0 else { return }
        var prev_idx = places.count - 1
        var next_idx = 0
        for i in 0..<places.count {
            if places[i] == current {
                // joshprint("[loading], find equals")
                prev_idx = (i - 1) < 0 ? places.count - 1 : i - 1
                next_idx = (i + 1) >= places.count ? 0 : i + 1
                // joshprint("[loading], count = \(places.count)")
                // joshprint("[loading],     i = \(i)")
                // joshprint("[loading],  prev = \(prev_idx)")
                // joshprint("[loading],  next = \(next_idx)")
                break
            } else {
                continue
            }
        }
        prevPlacePin = places[prev_idx]
        nextPlacePin = places[next_idx]
        imgBack_0.setValueForPlace(placeInfo: prevPlacePin)
        imgBack_2.setValueForPlace(placeInfo: nextPlacePin)
    }
    
    func loadingData(current: CCHMapClusterAnnotation) {
        state = .map
        if let place = current.annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_1.setValueForPlace(placeInfo: placeInfo)
            }
        }
        guard annotations.count > 0 else { return }
        var prev_idx = annotations.count - 1
        var next_idx = 0
        for i in 0..<annotations.count {
            if annotations[i] == current {
//                joshprint("[loadingData], find equals")
                prev_idx = (i - 1) < 0 ? annotations.count - 1 : i - 1
                next_idx = (i + 1) >= annotations.count ? 0 : i + 1
//                joshprint("[loadingData], count = \(annotations.count)")
//                joshprint("[loadingData],     i = \(i)")
//                joshprint("[loadingData],  prev = \(prev_idx)")
//                joshprint("[loadingData],  next = \(next_idx)")
                break
            } else {
                continue
            }
        }
        prevAnnotation = annotations[prev_idx]
        nextAnnotation = annotations[next_idx]
        if let place = annotations[prev_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_0.setValueForPlace(placeInfo: placeInfo)
            }
        }
        if let place = annotations[next_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_2.setValueForPlace(placeInfo: placeInfo)
            }
        }
    }
    
    func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func hide(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
            })
        } else {
            self.alpha = 0
            self.isHidden = true
        }
    }
    
    private func panToPrev(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgBack_0.frame.origin.x = 7
            self.imgBack_1.frame.origin.x += screenWidth + 7
        }, completion: {_ in
            if self.state == .map {
                self.delegate?.goTo(annotation: self.prevAnnotation, place: nil, animated: true)
            } else if self.state == .multipleSearch {
                self.delegate?.goTo(annotation: nil, place: self.prevPlacePin, animated: true)
            }
            self.resetSubviews()
        })
    }
    
    private func panToNext(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgBack_1.frame.origin.x = -screenWidth + 7
            self.imgBack_2.frame.origin.x = 7
        }, completion: { _ in
            if self.state == .map {
                self.delegate?.goTo(annotation: self.nextAnnotation, place: nil, animated: true)
            } else if self.state == .multipleSearch {
                self.delegate?.goTo(annotation: nil, place: self.nextPlacePin, animated: true)
            }
            self.resetSubviews()
        })
    }
    
    private func panBack(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.resetSubviews()
        }, completion: nil)
    }
    
    private var end: CGFloat = 0
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            end = pan.location(in: self).x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: self)
            let location = pan.location(in: self)
            let distanceMoved = end - location.x
            let percent = distanceMoved / screenWidth
            resumeTime = abs(Double(CGFloat(distanceMoved) / velocity.x))
            if resumeTime > 0.5 {
                resumeTime = 0.5
            } else if resumeTime < 0.3 {
                resumeTime = 0.3
            }
            let absPercent: CGFloat = 0.1
            guard boolDisableSwipe == false else { return }
            if percent < -absPercent {
                panToPrev(resumeTime)
            } else if percent > absPercent {
                panToNext(resumeTime)
            } else {
                panBack(resumeTime)
            }
        } else if pan.state == .changed {
            if boolLeft || boolRight {
                let translation = pan.translation(in: self)
                imgBack_0.center.x = imgBack_0.center.x + translation.x
                imgBack_1.center.x = imgBack_1.center.x + translation.x
                imgBack_2.center.x = imgBack_2.center.x + translation.x
                pan.setTranslation(CGPoint.zero, in: self)
            }
        }
    }
}

class PlaceView: UIView {
    
    private var class_2_icon_id = 0
    private var imgType: UIImageView!
    private var lblName: UILabel!
    private var lblAddr: UILabel!
    private var lblHours: UILabel!
    private var lblPrice: UILabel!
    private var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    private var arrHour = [String]()
    private var indicator: UIActivityIndicatorView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 7, y: 0, width: screenWidth - 14, height: 90))
        loadContent()
    }
    
    private func loadContent() {
        self.clipsToBounds = true
        
        let uiviewBkgd = UIView()
        uiviewBkgd.layer.cornerRadius = 2
        uiviewBkgd.backgroundColor = .white
        uiviewBkgd.clipsToBounds = true
        addSubview(uiviewBkgd)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBkgd)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewBkgd)
        
        imgType = UIImageView()
        imgType.layer.cornerRadius = 5
        imgType.clipsToBounds = true
        imgType.backgroundColor = UIColor._2499090()
        imgType.alpha = 0
        addSubview(imgType)
        addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-17-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-40-[v0(16)]", options: [], views: lblAddr)
        
        lblHours = UILabel()
        addSubview(lblHours)
        lblHours.textAlignment = .left
        lblHours.textColor = UIColor._107107107()
        lblHours.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblHours)
        addConstraintsWithFormat("V:|-57-[v0(16)]", options: [], views: lblHours)
        lblHours.text = ""
        
        lblPrice = UILabel()
        addSubview(lblPrice)
        lblPrice.textAlignment = .right
        lblPrice.textColor = UIColor._107107107()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addConstraintsWithFormat("H:[v0(32)]-12-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:|-63-[v0(18)]", options: [], views: lblPrice)
        
        indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .white
        indicator.center.x = 45
        indicator.center.y = 45
        indicator.hidesWhenStopped = true
        indicator.color = UIColor._2499090()
        addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForPlace(placeInfo: PlacePin) {
        lblName.text = placeInfo.name
        lblAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        lblPrice.text = placeInfo.price
        imgType.backgroundColor = .clear
        if placeInfo.hours.count > 0 {
            arrHour.removeAll()
            for day in arrDay {
                if placeInfo.hours.index(forKey: day) == nil {
                    arrHour.append("N/A")
                } else {
                    arrHour.append(placeInfo.hours[day]!)
                }
            }
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday], from: date)
            
            if let weekday = components.weekday {
                if weekday == 7 {
                    lblHours.text = arrDay[0] + ": " + arrHour[0]
                } else if weekday == 8 {
                    lblHours.text = arrDay[1] + ": " + arrHour[1]
                } else {
                    lblHours.text = arrDay[weekday] + ": " + arrHour[weekday]
                }
            } else {
                lblHours.text = nil
            }
        } else {
            lblHours.text = nil
        }
        loadPlaceImage(placeInfo: placeInfo)
//        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgType)
    }
    
    private func loadPlaceImage(placeInfo: PlacePin) {
        imgType.alpha = 0
        indicator.startAnimating()
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgType) {
            self.imgType.alpha = 1
            self.indicator.stopAnimating()
        }
    }
    
}

class FMLocationInfoBar: UIView {
    
    private var imgType: UIImageView!
    var lblName: UILabel!
    var lblAddr: UILabel!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 70 + device_offset_top, width: 414 * screenWidthFactor, height: 80))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        layer.zPosition = 605
        
        let imgBack = UIImageView(frame: CGRect(x: 2, y: 0, width: 410 * screenWidthFactor, height: 80))
        imgBack.contentMode = .scaleAspectFit
        imgBack.image = #imageLiteral(resourceName: "location_bar_shadow")
        addSubview(imgBack)
        
        imgType = UIImageView()
        imgType.clipsToBounds = true
        imgType.image = #imageLiteral(resourceName: "location_bar_type")
        imgType.contentMode = .scaleAspectFit
        imgType.alpha = 0
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
    
    func updateLocationBar(name: String, address: String) {
        lblName.text = name
        lblAddr.text = address
        imgType.alpha = 1
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.imgType.alpha = 0
        })
    }
}
