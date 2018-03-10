//
//  FMPlacesTable.swift
//  faeBeta
//
//  Created by Yue Shen on 8/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol FMPlaceTableDelegate: class {
    func selectPlaceFromTable(_ placeData: PlacePin)
}

class FMPlacesTable: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var tblDelegate: FMPlaceTableDelegate?
    weak var barDelegate: PlaceViewDelegate?
    
    var arrPlaces = [PlacePin]()
    var showed = false
    
    // Table
    var uiviewTblBckg: UIView!
    var tblResults: UITableView!
    var lblNumResults: UILabel!
    var grayLine: UIView!
    var btnPrevPage: UIButton!
    var btnNextPage: UIButton!
    
    // Bar
    var imgBack_0 = PlaceView()
    var imgBack_1 = PlaceView()
    var imgBack_2 = PlaceView()
    
    var boolLeft = true
    var boolRight = true
    
    var annotations = [CCHMapClusterAnnotation]()
    
    var places = [PlacePin]()
    
    var prevAnnotation: CCHMapClusterAnnotation!
    var nextAnnotation: CCHMapClusterAnnotation!
    
    var prevPlacePin: PlacePin!
    var nextPlacePin: PlacePin!
    
    var boolDisableSwipe = false
    
    var state: PlaceInfoBarState = .map {
        didSet {
//            boolLeft = annotations.count > 1 || places.count > 1
//            boolRight = annotations.count > 1 || places.count > 1
        }
    }
    
    internal var tblVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewTblBckg.removeConstraints(oldValue)
            }
            if tblVConstraint.count != 0 {
                uiviewTblBckg.addConstraints(tblVConstraint)
            }
        }
    }
    
    internal var lineVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewTblBckg.removeConstraints(oldValue)
            }
            if lineVConstraint.count != 0 {
                uiviewTblBckg.addConstraints(lineVConstraint)
            }
        }
    }
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 76 + device_offset_top, width: screenWidth, height: 90))
        loadContent()
        loadBar()
        alpha = 0
        layer.zPosition = 605
        //addShadow(view: self, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load Bar
    
    fileprivate func loadBar() {
        addSubview(imgBack_0)
        uiviewTblBckg.addSubview(imgBack_1)
        imgBack_1.frame.origin.x = 0
        addSubview(imgBack_2)
        addShadow(view: imgBack_0, opa: 0.5, offset: CGSize.zero, radius: 3)
        //addShadow(view: imgBack_1, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_2, opa: 0.5, offset: CGSize.zero, radius: 3)
        resetSubviews()
    }
    
    func resetSubviews() {
        imgBack_0.frame.origin.x = -screenWidth + 7
        //imgBack_1.frame.origin.x = 7
        uiviewTblBckg.frame.origin.x = 7
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
    
    func panToPrev(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgBack_0.frame.origin.x = 7
            self.uiviewTblBckg.frame.origin.x += screenWidth + 7
        }, completion: {_ in
            if self.state == .map {
                self.barDelegate?.goTo(annotation: self.prevAnnotation, place: nil)
            } else if self.state == .multipleSearch {
                self.barDelegate?.goTo(annotation: nil, place: self.prevPlacePin)
            }
            self.resetSubviews()
        })
    }
    
    func panToNext(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewTblBckg.frame.origin.x = -screenWidth + 7
            self.imgBack_2.frame.origin.x = 7
        }, completion: { _ in
            if self.state == .map {
                self.barDelegate?.goTo(annotation: self.nextAnnotation, place: nil)
            } else if self.state == .multipleSearch {
                self.barDelegate?.goTo(annotation: nil, place: self.nextPlacePin)
            }
            self.resetSubviews()
        })
    }
    
    func panBack(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.resetSubviews()
        }, completion: nil)
    }
    
    var end: CGFloat = 0
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
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
                uiviewTblBckg.center.x = uiviewTblBckg.center.x + translation.x
                imgBack_2.center.x = imgBack_2.center.x + translation.x
                pan.setTranslation(CGPoint.zero, in: self)
            }
        }
    }
    
    // MARK: - Load Table
    
    fileprivate func loadContent() {
        uiviewTblBckg = UIView(frame: CGRect(x: 7, y: 0, width: screenWidth - 14, height: 90))
        uiviewTblBckg.backgroundColor = .white
        addSubview(uiviewTblBckg)
        addShadow(view: uiviewTblBckg, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        tblResults = UITableView()
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        tblResults.tableFooterView = UIView()
        tblResults.layer.cornerRadius = 2
        //tblResults.backgroundColor = .white
        uiviewTblBckg.addSubview(tblResults)
        uiviewTblBckg.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tblResults)
        tblVConstraint = returnConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: tblResults)
        
        let footView = UIView()
        footView.clipsToBounds = true
        footView.layer.cornerRadius = 2
        footView.backgroundColor = .white
        uiviewTblBckg.addSubview(footView)
        uiviewTblBckg.sendSubview(toBack: footView)
        uiviewTblBckg.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: footView)
        uiviewTblBckg.addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: footView)
        
        lblNumResults = UILabel()
        lblNumResults.textAlignment = .center
        lblNumResults.textColor = UIColor._107105105()
        lblNumResults.font = UIFont(name: "AvenirNext-Medium", size: 16)
        footView.addSubview(lblNumResults)
        footView.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblNumResults)
        footView.addConstraintsWithFormat("V:|-20-[v0(21)]", options: [], views: lblNumResults)
        lblNumResults.isHidden = true
        
        btnPrevPage = UIButton()
        btnPrevPage.setImage(#imageLiteral(resourceName: "navigationBack_light"), for: .normal)
        btnPrevPage.setImage(#imageLiteral(resourceName: "navigationBack"), for: .selected)
        footView.addSubview(btnPrevPage)
        footView.addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: btnPrevPage)
        footView.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnPrevPage)
        
        btnNextPage = UIButton()
        btnNextPage.setImage(#imageLiteral(resourceName: "navigationBack_right_light"), for: .normal)
        btnNextPage.setImage(#imageLiteral(resourceName: "navigationBack_right"), for: .selected)
        footView.addSubview(btnNextPage)
        footView.addConstraintsWithFormat("H:[v0(40.5)]-0-|", options: [], views: btnNextPage)
        footView.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnNextPage)
        
        grayLine = UIView()
        grayLine.backgroundColor = UIColor._200199204()
        uiviewTblBckg.addSubview(grayLine)
        uiviewTblBckg.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: grayLine)
        lineVConstraint = returnConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayLine)
    }
    
    func updatePlacesArray(places: [PlacePin]) -> [PlacePin] {
        arrPlaces.removeAll()
        for i in 0..<50 {
            if i >= places.count { break }
            let place = places[i]
            place.name = "\(i+1). " + place.name
            arrPlaces.append(place)
        }
        tblResults.reloadData()
        lblNumResults.text = arrPlaces.count == 1 ? "1 Result" : "\(arrPlaces.count) Results"
        return arrPlaces
    }
    
    // MARK: - Table Animation
    
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
    
    func expand(_ completion: @escaping () -> Void) {
        self.frame.size.height = 90
        self.uiviewTblBckg.frame.size.height = 90
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.frame.size.height = screenHeight == 812 ? 587 : 556 * screenHeightFactor
            self.tblResults.alpha = 1
            self.imgBack_1.alpha = 0
            self.uiviewTblBckg.frame.size.height = screenHeight == 812 ? 587 : 556 * screenHeightFactor
            self.tblVConstraint = self.returnConstraintsWithFormat("V:|-0-[v0]-48-|", options: [], views: self.tblResults)
            self.lineVConstraint = self.returnConstraintsWithFormat("V:[v0(1)]-48-|", options: [], views: self.grayLine)
            self.layoutIfNeeded()
            completion()
        }, completion: { _ in
            self.showed = true
        })
    }
    
    func shrink(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.frame.size.height = 90
            self.uiviewTblBckg.frame.size.height = 90
            self.tblResults.alpha = 0
            self.imgBack_1.alpha = 1
            self.tblVConstraint = self.returnConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: self.tblResults)
            self.lineVConstraint = self.returnConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: self.grayLine)
            self.layoutIfNeeded()
            completion()
        }, completion: { _ in
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
//                Key.shared.FMVCtrler?.uiviewPlaceBar.alpha = 1
//                self.alpha = 0
//            })
            self.showed = false
        })
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeData = arrPlaces[indexPath.row]
        tblDelegate?.selectPlaceFromTable(placeData)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeResultBarCell", for: indexPath) as! FMPlaceResultBarCell
        let data = arrPlaces[indexPath.row]
        cell.setValueForPlace(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

class FMPlaceResultBarCell: UITableViewCell {
    
    var class_2_icon_id = 0
    var imgSavedItem: UIImageView!
    var lblItemName: UILabel!
    var lblItemAddr: UILabel!
    var lblHours: UILabel!
    var lblPrice: UILabel!
    var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    var arrHour = [String]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        backgroundColor = .clear
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForPlace(_ placeInfo: PlacePin) {
        lblItemName.text = placeInfo.name
        lblItemAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        imgSavedItem.backgroundColor = .white
        lblPrice.text = placeInfo.price
        // TODO: Yue - Hours update
//        lblHours.text = placeInfo.hours
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
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgSavedItem)
    }
    
    fileprivate func loadContent() {
        imgSavedItem = UIImageView()
        imgSavedItem.layer.cornerRadius = 5
        imgSavedItem.clipsToBounds = true
        addSubview(imgSavedItem)
        addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgSavedItem)
        addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgSavedItem)
        
        lblItemName = UILabel()
        addSubview(lblItemName)
        lblItemName.textAlignment = .left
        lblItemName.textColor = UIColor._898989()
        lblItemName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblItemName)
        addConstraintsWithFormat("V:|-17-[v0(20)]", options: [], views: lblItemName)
        
        lblItemAddr = UILabel()
        addSubview(lblItemAddr)
        lblItemAddr.textAlignment = .left
        lblItemAddr.textColor = UIColor._107107107()
        lblItemAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblItemAddr)
        addConstraintsWithFormat("V:|-40-[v0(16)]", options: [], views: lblItemAddr)
        
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
        addConstraintsWithFormat("V:|-66-[v0(12)]", options: [], views: lblPrice)
        lblPrice.text = ""
    }
}

