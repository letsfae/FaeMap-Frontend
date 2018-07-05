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

class NewFMPlaceInfoBar: UIScrollView, UIScrollViewDelegate {
    
    weak var action: PlaceViewDelegate?
    
    var viewObjects = [PlaceView]()
    var numPages: Int = 3
    var currentPage = 0
    var dataIndex = 0
    
    private var imgBack_0 = PlaceView()
    private var imgBack_1 = PlaceView()
    private var imgBack_2 = PlaceView()
    
    var places = [PlacePin]()
    var annotations = [CCHMapClusterAnnotation]()
    
    private var prevAnnotation: CCHMapClusterAnnotation!
    private var nextAnnotation: CCHMapClusterAnnotation!
    
    private var prevPlacePin: PlacePin!
    private var nextPlacePin: PlacePin!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 76 + device_offset_top, width: screenWidth, height: 102))

        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        
        tag = 0
        alpha = 0
        
        backgroundColor = .clear
        layer.zPosition = 605
        addShadow(view: imgBack_0, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_1, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_2, opa: 0.5, offset: CGSize.zero, radius: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setup() {
        
        guard places.count > 0 else {
            numPages = 1
            viewObjects.append(imgBack_1)
            loadScrollViewWithPage(0)
            return
        }
        
        contentSize = CGSize(width: (frame.size.width * (CGFloat(numPages) + 2)), height: frame.size.height)
        
        viewObjects.append(imgBack_0)
        viewObjects.append(imgBack_1)
        viewObjects.append(imgBack_2)
        
        loadScrollViewWithPage(0)
        loadScrollViewWithPage(1)
        loadScrollViewWithPage(2)
        
        var newFrame = frame
        newFrame.origin.x = newFrame.size.width
        newFrame.origin.y = 0
        scrollRectToVisible(newFrame, animated: false)
        
        layoutIfNeeded()
    }
    
    private func loadScrollViewWithPage(_ page: Int) {
        if page < 0 { return }
        if page >= numPages + 2 { return }
        
        var index = 0
//        var dataIdx = 0
        
        if page == 0 {
            index = numPages - 1 // the last view
        } else if page == numPages + 1 {
            index = 0 // the first view
        } else {
            index = page - 1
        }
        
        let view = viewObjects[index]
        
        
        
        var newFrame = frame
        newFrame.origin.x = frame.size.width * CGFloat(page)
        newFrame.origin.y = 0
        view.frame = newFrame
        
        if view.superview == nil {
            addSubview(view)
        }
        
        layoutIfNeeded()
    }
    
    func loadingData(current: CCHMapClusterAnnotation) {
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
                prev_idx = (i - 1) < 0 ? annotations.count - 1 : i - 1
                next_idx = (i + 1) >= annotations.count ? 0 : i + 1
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
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page = floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1
        currentPage = Int(page - 1)
        loadScrollViewWithPage(Int(page - 1))
        loadScrollViewWithPage(Int(page))
        loadScrollViewWithPage(Int(page + 1))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page : Int = Int(floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1)
        
        if page == 0 {
            contentOffset = CGPoint(x: pageWidth*(CGFloat(numPages)), y: 0)
        } else if page == numPages + 1 {
            contentOffset = CGPoint(x: pageWidth, y: 0)
        }
    }
    
    private func panToPrev(_ time: Double = 0.3) {
        self.action?.goTo(annotation: self.prevAnnotation, place: nil, animated: true)
    }
    
    private func panToNext(_ time: Double = 0.3) {
        self.action?.goTo(annotation: self.nextAnnotation, place: nil, animated: true)
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
}

protocol PlaceViewDelegate: class {
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?, animated: Bool)
}

enum PlaceInfoBarState: String {
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
        super.init(coder: aDecoder)
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
        imgBack_0.frame.origin.x = -screenWidth + 8
        imgBack_1.frame.origin.x = 8
        imgBack_2.frame.origin.x = screenWidth + 8
    }
    
    func load(for placeInfo: PlacePin) {
        imgBack_1.setValueForPlace(placeInfo: placeInfo)
        self.alpha = 1
        boolLeft = false
        boolRight = false
        imgBack_0.isHidden = true
        imgBack_2.isHidden = true
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
    
    func show(animated: Bool = true) {
        self.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.alpha = 1
            }, completion: nil)
        } else {
            alpha = 1
        }
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
            self.imgBack_0.frame.origin.x = 8
            self.imgBack_1.frame.origin.x += screenWidth + 8
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
            self.imgBack_1.frame.origin.x = -screenWidth + 8
            self.imgBack_2.frame.origin.x = 8
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
    
    private var category_icon_id = 0
    private var imgType: UIImageView!
    private var lblName: UILabel!
    private var lblAddr: UILabel!
    private var lblHours: UILabel!
    private var lblPrice: UILabel!
    private var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    private var arrHour = [[String]]()
    private var indicatorLoading: UIActivityIndicatorView!
    private var lblNoResult: UILabel!
    public var isLoadingIndicatorAndNoResultLabelEnabled: Bool = false
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 8, y: 0, width: screenWidth - 16, height: 90))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func loadExtraParts() {
        loadLoadingIndicator()
        loadNoResultLabel()
    }
    
    private func loadContent() {
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
        imgType.contentMode = .scaleAspectFill
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
        // TODO: Vicky
        lblHours.lineBreakMode = .byTruncatingTail
        
        lblPrice = UILabel()
        addSubview(lblPrice)
        lblPrice.textAlignment = .right
        lblPrice.textColor = UIColor._107107107()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addConstraintsWithFormat("H:[v0(32)]-12-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:|-63-[v0(18)]", options: [], views: lblPrice)
    }
    
    private func loadLoadingIndicator() {
        indicatorLoading = createActivityIndicator(large: true)
        indicatorLoading.center.x = screenWidth / 2 - 8
        indicatorLoading.center.y = 45
        addSubview(indicatorLoading)
    }
    
    private func loadNoResultLabel() {
        lblNoResult = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        addSubview(lblNoResult)
        lblNoResult.center.x = screenWidth / 2 - 8
        lblNoResult.center.y = 45
        lblNoResult.numberOfLines = 0
        lblNoResult.text = "No Results Found...\nTry a Different Search!"
        lblNoResult.textAlignment = .center
        lblNoResult.textColor = UIColor._115115115()
        lblNoResult.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblNoResult.isHidden = true
    }
    
    public func showOrHideLoadingIndicator(show: Bool) {
        guard isLoadingIndicatorAndNoResultLabelEnabled else { return }
        if show {
            indicatorLoading.startAnimating()
        } else {
            indicatorLoading.stopAnimating()
        }
        imgType.isHidden = show
        lblName.isHidden = show
        lblAddr.isHidden = show
        lblHours.isHidden = show
        lblPrice.isHidden = show
    }
    
    public func showOrHideNoResultIndicator(show: Bool) {
        guard isLoadingIndicatorAndNoResultLabelEnabled else { return }
        lblNoResult.isHidden = !show
        imgType.isHidden = show
        lblName.isHidden = show
        lblAddr.isHidden = show
        lblHours.isHidden = show
        lblPrice.isHidden = show
    }
    
    func setValueForPlace(placeInfo: PlacePin) {
        lblName.text = placeInfo.name
        var addr = placeInfo.address1 == "" ? "" : placeInfo.address1 + ", "
        addr += placeInfo.address2
//        var addr = "test "
//        if placeInfo.address1 == "" {
//            print("test \(placeInfo.address)")
//            addr = placeInfo.address
//        } else {
//            addr = placeInfo.address1 + ", " + placeInfo.address2
//        }
        
//        if placeInfo.address1 == "" {
//            General.shared.getAddress(location: placeInfo.loc_coordinate) {[weak self] (status, address) in
//                guard status != 400 else {
//                    self?.lblAddr.text = placeInfo.address2
//                    return
//                }
//                if let addr = address as? String {
//                    print("placepin \(addr)")
//                    self?.lblAddr.text = addr
//                }
//            }
//        } else {
//            lblAddr.text = placeInfo.address1 + ", " + placeInfo.address2
//            General.shared.getAddress(location: placeInfo.loc_coordinate) {[weak self] (status, address) in
//                guard status != 400 else {
//                    return
//                }
//                if let addr = address as? String {
//                    print("test placepin \(addr)")
//                }
//            }
//        }
        
        lblAddr.text = addr
        lblPrice.text = placeInfo.price
        imgType.backgroundColor = .clear
        let hoursToday = placeInfo.hoursToday
        let openOrClose = placeInfo.openOrClose
        if openOrClose == "N/A" {
            lblHours.text = "N/A"
        } else {
            var hours = " "
            for (index, hour) in hoursToday.enumerated() {
                if hour == "24 Hours" {
                    hours += hour
                    break
                } else {
                    if index == hoursToday.count - 1 {
                        hours += hour
                    } else {
                        hours += hour + ", "
                    }
                }
            }
            lblHours.text = openOrClose + hours
        }
        
        loadPlaceImage(placeInfo: placeInfo)
    }
    
    private func loadPlaceImage(placeInfo: PlacePin) {
        imgType.backgroundColor = .white
        imgType.alpha = 1
        imgType.sd_setShowActivityIndicatorView(true)
        imgType.sd_setImage(with: URL(string: placeInfo.imageURL), placeholderImage: nil, options: [.retryFailed]) { [weak self] (img, err, _, _) in
            if img == nil || err != nil {
                self?.imgType.image = Key.shared.defaultPlace
            }
            self?.imgType.sd_setShowActivityIndicatorView(false)
        }
    }
    
}

class FMLocationInfoBar: UIView {
    
    private var imgType: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var lblName: UILabel!
    var lblAddr: UILabel!
    var isShowed: Bool = false
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 8, y: 76 + device_offset_top, width: screenWidth - 16, height: 68))
        loadContent()
        loadActivityIndicator()
        addShadow(view: self, opa: 0.5, offset: CGSize.zero, radius: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadContent() {
        layer.zPosition = 605
        
        let uiviewBkgd = UIView()
        uiviewBkgd.layer.cornerRadius = 2
        uiviewBkgd.backgroundColor = .white
        uiviewBkgd.clipsToBounds = true
        addSubview(uiviewBkgd)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBkgd)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewBkgd)
        
        imgType = UIImageView()
        imgType.clipsToBounds = true
        imgType.image = #imageLiteral(resourceName: "location_bar_type")
        imgType.contentMode = .scaleAspectFit
        imgType.alpha = 0
        addSubview(imgType)
        addConstraintsWithFormat("H:|-9-[v0(58)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-5-[v0(58)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-77-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-16-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-77-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-37-[v0(16)]", options: [], views: lblAddr)
    }
    
    private func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        addSubview(activityIndicator)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: activityIndicator)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: activityIndicator)
    }
    
    func updateLocationBar(name: String, address: String) {
        lblName.text = name
        lblAddr.text = address
        imgType.alpha = 1
    }
    
    func show() {
        guard !isShowed else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.alpha = 1
        }, completion: { _ in
            self.isShowed = true
        })
    }
    
    func hide() {
        guard isShowed else { return}
        isShowed = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.alpha = 0
        }, completion: nil)
    }
    
    public func updateLocationInfo(location: CLLocation, _ completion: @escaping (String, String) -> Void) {
        show()
        updateLocationBar(name: "", address: "")
        imgType.alpha = 0
        activityIndicator.startAnimating()
        General.shared.getAddress(location: location, original: true) { [weak self] (status, original) in
            guard let `self` = self else { return }
            guard status != 400 else {
                DispatchQueue.main.async {
                    self.lblName.text = "Querying for location too fast!"
                    self.lblAddr.text = "please try again later"
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let first = original as? CLPlacemark else {
                completion("Invalid Address", "")
                return
            }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            
            var address_1 = ""
            var address_2 = ""
            
            if let n = first.name {
                name = n
                address_1 += n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += t
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                address_1 = name
            }
            
            if let l = first.locality {
                address_2 += l
            }
            if let a = first.administrativeArea {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += a
            }
            if let p = first.postalCode {
                address_2 += " " + p
            }
            if let c = first.country {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += c
            }
            
            DispatchQueue.main.async {
                self.updateLocationBar(name: address_1, address: address_2)
                self.activityIndicator.stopAnimating()
                completion(address_1, address_2)
            }
        }
    }
}
