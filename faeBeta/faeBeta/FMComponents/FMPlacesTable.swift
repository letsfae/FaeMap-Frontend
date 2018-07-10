//
//  FMPlacesTable.swift
//  faeBeta
//
//  Created by Yue Shen on 8/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol FMPlaceTableDelegate: class {
    func selectPlaceFromTable(_ placeData: PlacePin)
    func reloadPlacesOnMap(places: [PlacePin], animated: Bool)
}

class FMPlacesTable: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI's
    var showed = false
    private let height_before: CGFloat = 90
    private var height_after: CGFloat = {
        var height: CGFloat = 587
        switch screenHeight {
        case 736:
            height = 556
            break
        case 667:
            height = 490
            break
        case 568:
            height = 395
            break
        default:
            break
        }
        return height
    } ()
    
    // Table
    private var uiviewTblBckg: UIView!
    var tblResults: UITableView!
    private var lblNumResults: UILabel!
    private var grayLine: UIView!
    private var btnPrevPage: UIButton!
    private var btnNextPage: UIButton!
    
    // Bar
    private var imgBack_0 = PlaceView()
    private var imgBack_1 = PlaceView()
    private var imgBack_2 = PlaceView()
    
    private var tblVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewTblBckg.removeConstraints(oldValue)
            }
            if tblVConstraint.count != 0 {
                uiviewTblBckg.addConstraints(tblVConstraint)
            }
        }
    }
    
    private var lineVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewTblBckg.removeConstraints(oldValue)
            }
            if lineVConstraint.count != 0 {
                uiviewTblBckg.addConstraints(lineVConstraint)
            }
        }
    }
    
    // MARK: - Pan Gesture
    var panGesture: UIPanGestureRecognizer!
    var boolLeft = true
    var boolRight = true
    private var isSwipeDisabled = false {
        didSet {
            self.boolLeft = !isSwipeDisabled
            self.boolRight = !isSwipeDisabled
        }
    }
    
    private var dictOffset = [Int: CGPoint]()
    var groupLastSelected = [Int: PlacePin]()
    var altitude: CLLocationDistance = 0
    
    private var allPlaces = [[PlacePin]]()
    var currentGroupOfPlaces = [PlacePin]()
    var prevPlacePin: PlacePin!
    var nextPlacePin: PlacePin!
    
    var visibleAnnotations = [CCHMapClusterAnnotation]()
    private var prevAnnotation: CCHMapClusterAnnotation!
    private var nextAnnotation: CCHMapClusterAnnotation!
    
    private var currentIdx: Int = 0
    var goingToNextGroup: Bool = false
    var goingToPrevGroup: Bool = false
    private var isLoading: Bool = false
    private var isNoResult: Bool = false
    private var fullyLoaded = false

    var searchState: PlaceInfoBarState = .map {
        didSet {
            boolLeft = visibleAnnotations.count > 1 || currentGroupOfPlaces.count > 1
            boolRight = visibleAnnotations.count > 1 || currentGroupOfPlaces.count > 1
        }
    }

    // MARK: - Delegates
    weak var tblDelegate: FMPlaceTableDelegate?
    weak var barDelegate: PlaceViewDelegate?
    
    // MARK: - Pagination
    var dataOffset: Int = 0
    var totalPages: Int = 0
    var request: DataRequest?
    
    enum CurrentViewControllerType {
        case map, chat
    }
    var currentVC = CurrentViewControllerType.map
    
    // MARK: - Init
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 76 + device_offset_top, width: screenWidth, height: 90))
        loadContent()
        loadBar()
        alpha = 0
        layer.zPosition = 605
        
        panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
        
        resetSubviews()
        
        fullyLoaded = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Data Request
    func fetchMorePlaces() {
        request?.cancel()
        btnNextPage.isSelected = false
        var locationToSearch = LocManager.shared.curtLoc.coordinate
        if let locToSearch = LocManager.shared.locToSearch_map {
            locationToSearch = locToSearch
        }
        var searchContent = ""
        var searchSource = ""
        var radius = 0
        switch currentVC {
        case .map:
            searchContent = Key.shared.searchContent_map
            searchSource = Key.shared.searchSource_map
            radius = Key.shared.radius_map
        case .chat:
            searchContent = Key.shared.searchContent_chat
            searchSource = Key.shared.searchSource_chat
            radius = Key.shared.radius_chat
        }
        guard self.dataOffset % 20 == 0 else { return }
        let searchAgent = FaeSearch()
        searchAgent.whereKey("content", value: searchContent)
        searchAgent.whereKey("source", value: searchSource)
        searchAgent.whereKey("type", value: "place")
        searchAgent.whereKey("size", value: "20")
        searchAgent.whereKey("radius", value: "\(radius)")
        searchAgent.whereKey("offset", value: "\(dataOffset)")
        searchAgent.whereKey("sort", value: [["geo_location": "asc"]])
        searchAgent.whereKey("location", value: ["latitude": locationToSearch.latitude,
                                                 "longitude": locationToSearch.longitude])
        request = searchAgent.search { [weak self] (status: Int, message: Any?) in
            joshprint("[fetchMorePlaces] places fetched")
            joshprint("Content:", searchContent)
            joshprint("Source:", searchSource)
            joshprint("Radius:", radius)
            joshprint("offset:", self?.dataOffset as Any)
            guard let `self` = self else { return }
            guard status / 100 == 2 else {
                return
            }
            guard message != nil else {
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                
                return
            }
            let searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            joshprint("Count:", searchedPlaces.count)
            joshprint("[fetchMorePlaces] end")
            self.updateMorePlaces(places: searchedPlaces, numbered: true, start: self.dataOffset)
        }
    }
    
    private func updateMorePlaces(places: [PlacePin], numbered: Bool = true, start: Int = 0) {
        guard places.count > 0 else {
            btnNextPage.isSelected = false
            return
        }
        var groupPlaces = [PlacePin]()
        for i in 0..<places.count {
            let place = places[i]
            place.indexInTable = start + i + 1
//            if numbered {
//                place.name = "\(start+i+1). " + place.name
//            }
            groupPlaces.append(place)
            if groupPlaces.count % 20 == 0 {
                self.allPlaces.append(groupPlaces)
                groupPlaces.removeAll(keepingCapacity: true)
            }
        }
        if groupPlaces.count != 0 {
            allPlaces.append(groupPlaces)
        }
        btnNextPage.isSelected = places.count > 0
        totalPages += 1
        dataOffset += places.count
    }
    
    // MARK: - Table Actions
    
    @objc private func actionSwitchPage(_ sender: UIButton) {
        let prevTag = tblResults.tag
        if sender == btnPrevPage {
            tblResults.tag -= 1
            if tblResults.tag <= 0 {
                tblResults.tag = 0
                btnPrevPage.isSelected = false
                if tblResults.tag == prevTag {
                    return
                }
            }
            btnNextPage.isSelected = allPlaces.count > 1
        } else {
            tblResults.tag += 1
            if tblResults.tag >= allPlaces.count - 1 {
                tblResults.tag = allPlaces.count - 1
                btnNextPage.isSelected = false
                if tblResults.tag == prevTag {
                    return
                }
            }
            btnPrevPage.isSelected = true
            if tblResults.tag >= totalPages - 1 {
                fetchMorePlaces()
            }
        }
        self.currentGroupOfPlaces = self.allPlaces[tblResults.tag]
        //        self.loading(current: getGroupLastSelectedPlace())
        self.loading(current: self.currentGroupOfPlaces[0])
//        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            if let offset = self.dictOffset[self.tblResults.tag] {
//                self.tblResults.setContentOffset(offset, animated: false)
//            } else {
//                self.tblResults.setContentOffset(.zero, animated: false)
//            }
//            self.tblDelegate?.reloadPlacesOnMap(places: self.currentGroupOfPlaces)
//        }
        tblResults.setContentOffset(.zero, animated: false)
        tblResults.reloadData()
        tblDelegate?.reloadPlacesOnMap(places: self.currentGroupOfPlaces, animated: false)
//        CATransaction.commit()
    }
    
    func getGroupLastSelectedPlace() -> PlacePin {
        let tag = tblResults.tag
        if let place = groupLastSelected[tag] {
            return place
        } else {
            return self.currentGroupOfPlaces[0]
        }
    }
    
    // MARK: - No Result and Loading
    public func changeState(isLoading: Bool, isNoResult: Bool?, shouldShrink: Bool = true) {
        self.show()
        imgBack_1.showOrHideLoadingIndicator(show: isLoading)
        if let noResult = isNoResult {
            imgBack_1.showOrHideNoResultIndicator(show: noResult)
            self.isNoResult = noResult
            self.isSwipeDisabled = isLoading || noResult
        } else {
            self.isSwipeDisabled = isLoading
        }
        self.isLoading = isLoading
        if shouldShrink {
            shrink {}
        }
    }
    
    public func canExpandOrShrink() -> Bool {
        return !isLoading && !isNoResult
    }
    
    // MARK: - Reset
    private func reset() {
        groupLastSelected.removeAll(keepingCapacity: true)
        allPlaces.removeAll(keepingCapacity: true)
        dictOffset.removeAll(keepingCapacity: true)
        resetSubviews()
        currentIdx = 0
        goingToNextGroup = false
        goingToPrevGroup = false
        currentGroupOfPlaces.removeAll(keepingCapacity: true)
        tblResults.setContentOffset(.zero, animated: false)
        altitude = 0
        totalPages = 0
    }

    func resetSubviews() {
        imgBack_0.frame.origin.x = -screenWidth + 8
        uiviewTblBckg.frame.origin.x = 8
        imgBack_2.frame.origin.x = screenWidth + 8
    }
    
    // MARK: - Data Update
    func updatePlacesArray(places: [PlacePin], numbered: Bool = true) -> [PlacePin] {
        reset()
        var groupPlaces = [PlacePin]()
        for i in 0..<places.count {
            let place = places[i]
//            if numbered {
//                place.name = "\(i+1). " + place.name
//            }
            place.indexInTable = i + 1
            groupPlaces.append(place)
            if groupPlaces.count % 20 == 0 {
                self.allPlaces.append(groupPlaces)
                groupPlaces.removeAll(keepingCapacity: true)
            }
        }
        if groupPlaces.count != 0 {
            allPlaces.append(groupPlaces)
        }
        tblResults.tag = 0
        totalPages = 1
        btnPrevPage.isSelected = false
        btnNextPage.isSelected = allPlaces.count > 1
        tblResults.reloadData()
        
        fetchMorePlaces()
        
        if allPlaces.count > 0 {
            return allPlaces[0]
        }
        return []
    }
    
    func load(for placeInfo: PlacePin) {
        imgBack_1.setValueForPlace(placeInfo: placeInfo)
        self.alpha = 1
        boolLeft = false
        boolRight = false
    }
    
    func loading(current: PlacePin) {
        searchState = .multipleSearch
        imgBack_1.setValueForPlace(placeInfo: current)
        groupLastSelected[tblResults.tag] = current
        self.alpha = 1
        guard currentGroupOfPlaces.count > 0 else {
            return
        }
        var prev_idx = currentGroupOfPlaces.count - 1
        var next_idx = 0
        
        for i in 0..<currentGroupOfPlaces.count {
            if currentGroupOfPlaces[i] == current {
                prev_idx = (i - 1) < 0 ? currentGroupOfPlaces.count - 1 : i - 1
                next_idx = (i + 1) >= currentGroupOfPlaces.count ? 0 : i + 1
                currentIdx = i
                configureIndexForPanGes()
                break
            } else {
                continue
            }
        }
        prevPlacePin = currentGroupOfPlaces[prev_idx]
        nextPlacePin = currentGroupOfPlaces[next_idx]
        
        if currentIdx == 0 && boolLeft && tblResults.tag - 1 >= 0 {
            let places = allPlaces[tblResults.tag - 1]
            prev_idx = places.count - 1
            prevPlacePin = places[prev_idx]
        }
        
        if currentIdx == currentGroupOfPlaces.count - 1 && boolRight && tblResults.tag + 1 <= allPlaces.count - 1 {
            let places = allPlaces[tblResults.tag + 1]
            next_idx = 0
            nextPlacePin = places[next_idx]
        }
        
        imgBack_0.setValueForPlace(placeInfo: prevPlacePin)
        imgBack_2.setValueForPlace(placeInfo: nextPlacePin)
        resetSubviews()
        panGesture.isEnabled = true
        goingToNextGroup = false
        goingToPrevGroup = false
        //print("[loading] pan gesture enabled")
        //print("")
    }
    
    func loadingData(current: CCHMapClusterAnnotation) {
        searchState = .map
        if let place = current.annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_1.setValueForPlace(placeInfo: placeInfo)
            }
        }
        guard visibleAnnotations.count > 0 else { return }
        var prev_idx = visibleAnnotations.count - 1
        var next_idx = 0
        for i in 0..<visibleAnnotations.count {
            if visibleAnnotations[i] == current {
                prev_idx = (i - 1) < 0 ? visibleAnnotations.count - 1 : i - 1
                next_idx = (i + 1) >= visibleAnnotations.count ? 0 : i + 1
                break
            } else {
                continue
            }
        }
        prevAnnotation = visibleAnnotations[prev_idx]
        nextAnnotation = visibleAnnotations[next_idx]
        if let place = visibleAnnotations[prev_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_0.setValueForPlace(placeInfo: placeInfo)
            }
        }
        if let place = visibleAnnotations[next_idx].annotations.first as? FaePinAnnotation {
            if let placeInfo = place.pinInfo as? PlacePin {
                imgBack_2.setValueForPlace(placeInfo: placeInfo)
            }
        }
    }
    
    func configureCurrentPlaces(goingNext: Bool) {
        if goingNext {
            if tblResults.tag + 1 <= allPlaces.count - 1 {
                tblResults.tag += 1
                currentGroupOfPlaces = allPlaces[tblResults.tag]
                if tblResults.tag >= allPlaces.count - 1 {
                    tblResults.tag = allPlaces.count - 1
                    btnNextPage.isSelected = false
                }
                btnPrevPage.isSelected = true
            }
        } else if goingToPrevGroup {
            if tblResults.tag - 1 >= 0 {
                tblResults.tag -= 1
                currentGroupOfPlaces = allPlaces[tblResults.tag]
                if tblResults.tag <= 0 {
                    tblResults.tag = 0
                    btnPrevPage.isSelected = false
                }
                btnNextPage.isSelected = allPlaces.count > 1
            }
        }
        tblResults.reloadData()
    }
    
    // MARK: - Pan Gesture
    
    private func panToPrev(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgBack_0.frame.origin.x = 8
            self.uiviewTblBckg.frame.origin.x += screenWidth + 8
        }, completion: {_ in
            if self.searchState == .map {
                self.barDelegate?.goTo(annotation: self.prevAnnotation, place: nil, animated: true)
            } else if self.searchState == .multipleSearch {
                if self.currentIdx == 0 {
                    self.panGesture.isEnabled = false
                    //print("[panToPrev] pan gesture disabled")
                    self.goingToPrevGroup = true
                }
                self.barDelegate?.goTo(annotation: nil, place: self.prevPlacePin, animated: true)
            }
            //self.resetSubviews()
        })
    }
    
    private func panToNext(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewTblBckg.frame.origin.x = -screenWidth + 8
            self.imgBack_2.frame.origin.x = 8
        }, completion: { _ in
            if self.searchState == .map {
                self.barDelegate?.goTo(annotation: self.nextAnnotation, place: nil, animated: true)
            } else if self.searchState == .multipleSearch {
                if self.currentIdx == self.currentGroupOfPlaces.count - 1 {
                    self.panGesture.isEnabled = false
                    //print("[panToNext] pan gesture disabled")
                    self.goingToNextGroup = true
                    self.fetchMorePlaces()
                }
                self.barDelegate?.goTo(annotation: nil, place: self.nextPlacePin, animated: true)
            }
            //self.resetSubviews()
        })
    }
    
    private func panBack(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.resetSubviews()
        }, completion: { _ in
            self.panGesture.isEnabled = true
        })
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
            guard !isSwipeDisabled else { return }
            if percent < -absPercent {
                //guard boolLeft else { return }
                guard !imgBack_0.isHidden else {
                    panBack()
                    return
                }
                panToPrev(resumeTime)
            } else if percent > absPercent {
                //guard boolRight else { return }
                guard !imgBack_2.isHidden else {
                    panBack()
                    return
                }
                panToNext(resumeTime)
            } else {
                panBack(resumeTime)
            }
        } else if pan.state == .changed {
            guard !isSwipeDisabled else { return }
            let translation = pan.translation(in: self)
            imgBack_0.center.x = imgBack_0.center.x + translation.x
            uiviewTblBckg.center.x = uiviewTblBckg.center.x + translation.x
            imgBack_2.center.x = imgBack_2.center.x + translation.x
            pan.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    private func configureIndexForPanGes() {
        imgBack_0.isHidden = currentIdx == 0 && tblResults.tag == 0
        
        if tblResults.tag == allPlaces.count - 1 {
            imgBack_2.isHidden = currentIdx == allPlaces[tblResults.tag].count - 1
        } else {
            imgBack_2.isHidden = false
        }
    }
    
    // MARK: - Setup UI
    
    public func addGestureToImgBack_1(_ gesture: UITapGestureRecognizer) {
        // Add tap gesture to imgBack_1
        imgBack_1.addGestureRecognizer(gesture)
    }
    
    private func loadBar() {
        addSubview(imgBack_0)
        uiviewTblBckg.addSubview(imgBack_1)
        imgBack_1.frame.origin.x = 0
        imgBack_1.isLoadingIndicatorAndNoResultLabelEnabled = true
        imgBack_1.loadExtraParts()
        addSubview(imgBack_2)
        addShadow(view: imgBack_0, opa: 0.5, offset: CGSize.zero, radius: 3)
        addShadow(view: imgBack_2, opa: 0.5, offset: CGSize.zero, radius: 3)
    }
    
    private func loadContent() {
        uiviewTblBckg = UIView(frame: CGRect(x: 8, y: 0, width: screenWidth - 16, height: 90))
        uiviewTblBckg.backgroundColor = .clear
        addSubview(uiviewTblBckg)
        addShadow(view: uiviewTblBckg, opa: 0.5, offset: CGSize.zero, radius: 3)
        
        tblResults = UITableView()
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        tblResults.tableFooterView = UIView()
        tblResults.layer.cornerRadius = 2
        //tblResults.alwaysBounceVertical = false
        tblResults.bounces = false
        tblResults.clipsToBounds = true
        tblResults.layer.cornerRadius = 2
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
        btnPrevPage.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        footView.addSubview(btnPrevPage)
        footView.addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: btnPrevPage)
        footView.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnPrevPage)
        
        btnNextPage = UIButton()
        btnNextPage.setImage(#imageLiteral(resourceName: "navigationBack_right_light"), for: .normal)
        btnNextPage.setImage(#imageLiteral(resourceName: "navigationBack_right"), for: .selected)
        btnNextPage.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        footView.addSubview(btnNextPage)
        footView.addConstraintsWithFormat("H:[v0(40.5)]-0-|", options: [], views: btnNextPage)
        footView.addConstraintsWithFormat("V:[v0(48)]-0-|", options: [], views: btnNextPage)
        
        grayLine = UIView()
        grayLine.backgroundColor = UIColor._200199204()
        uiviewTblBckg.addSubview(grayLine)
        uiviewTblBckg.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: grayLine)
        lineVConstraint = returnConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayLine)
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
        self.dictOffset.removeAll()
        self.tblResults.contentOffset = .zero
        self.isSwipeDisabled = true
        self.panGesture.isEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.frame.size.height = self.height_after
            self.tblResults.alpha = 1
            self.imgBack_1.alpha = 0
            self.uiviewTblBckg.frame.size.height = self.height_after
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
            self.showed = false
            self.isSwipeDisabled = false || self.isNoResult || self.isLoading
            self.panGesture.isEnabled = true
        })
    }
    
    // MARK: - ScrollViwe Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dictOffset[tblResults.tag] = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dictOffset[tblResults.tag] = scrollView.contentOffset
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeData = allPlaces[tableView.tag][indexPath.row]
        tblDelegate?.selectPlaceFromTable(placeData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard allPlaces.count > 0 else { return 0 }
        return allPlaces[tableView.tag].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeResultBarCell", for: indexPath) as! FMPlaceResultBarCell
        guard tableView.tag >= 0 && tableView.tag < allPlaces.count else {
            return UITableViewCell()
        }
        guard indexPath.row < allPlaces[tableView.tag].count else {
            return UITableViewCell()
        }
        let placeData = allPlaces[tableView.tag][indexPath.row]
        cell.setValueForPlace(placeData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

class FMPlaceResultBarCell: UITableViewCell {
    
    private var category_icon_id = 0
    private var imgSavedItem: UIImageView!
    private var lblItemName: UILabel!
    private var lblItemAddr: UILabel!
    private var lblHours: UILabel!
    private var lblPrice: UILabel!
    private var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    private var arrHour = [[String]]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        backgroundColor = .clear
        loadContent()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgSavedItem.image = nil
        imgSavedItem.sd_cancelCurrentImageLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setValueForPlace(_ placeInfo: PlacePin) {
        if placeInfo.indexInTable == 0 {
            lblItemName.text = placeInfo.name
        } else {
            lblItemName.text = "\(placeInfo.indexInTable). " + placeInfo.name
        }
        if placeInfo.address1 != "" {
            lblItemAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        } else {
            General.shared.updateAddress(label: lblItemAddr, place: placeInfo)
        }
        lblPrice.text = placeInfo.price
        // TODO: Yue - Hours update
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
//        lblHours.text = placeInfo.hours
        /*if placeInfo.hours.count > 0 {
            arrHour.removeAll()
            for day in arrDay {
                if placeInfo.hours.index(forKey: day) == nil {
                    arrHour.append(["N/A"])
                } else {
                    // TODO: Vicky
                    arrHour.append(placeInfo.hours[day]!)
                }
            }
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday], from: date)
            
            // components.weekday 2 - Mon, 3 - Tue, 4 - Wed, 5 - Thur, 6 - Fri, 7 - Sat, 8 - Sun
            if let weekday = components.weekday {
                var dayIdx = weekday
                
                if weekday == 7 {
                    dayIdx = 0
                } else if weekday == 8 {
                    dayIdx = 1
                }
                
                var hour = arrHour[dayIdx][0]
                if arrHour[0].count > 1 {
                    for hourIdx in 1..<arrHour[dayIdx].count {
                        hour += ", " + arrHour[dayIdx][hourIdx]
                    }
                }
                lblHours.text = arrDay[dayIdx] + ": " + hour
            } else {
                lblHours.text = nil
            }
        } else {
            lblHours.text = nil
        }*/
        imgSavedItem.backgroundColor = ._210210210()
        imgSavedItem.image = nil
        imgSavedItem.sd_setImage(with: URL(string: placeInfo.imageURL), placeholderImage: nil, options: []) { [weak self] (img, err, _, _) in
            if img == nil || err != nil {
                self?.imgSavedItem.image = Key.shared.defaultPlace
            }
        }
    }
    
    private func loadContent() {
        imgSavedItem = UIImageView()
        imgSavedItem.layer.cornerRadius = 5
        imgSavedItem.clipsToBounds = true
        imgSavedItem.contentMode = .scaleAspectFill
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

