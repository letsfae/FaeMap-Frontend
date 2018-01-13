//
//  BoardsSearchViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces

// TODO: Yue
@objc protocol BoardsSearchDelegate: class {
    //    func backToPlaceSearchView()
    //    func backToLocationSearchView()
    @objc optional func jumpToPlaceSearchResult(searchText: String, places: [PlacePin])
    @objc optional func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation)
    @objc optional func chooseLocationOnMap()
    @objc optional func sendLocationBack(address: RouteAddress)
    @objc optional func sendPlaceBack(placeData: PlacePin)
}

enum EnterMode: String {
    case place = "place"
    case location = "location"
}

class BoardsSearchViewController: UIViewController, FaeSearchBarTestDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
    var enterMode: CollectionTableMode!
    weak var delegate: BoardsSearchDelegate?
    var arrCurtLocList = ["Use my Current Location", "Choose Location on Map"]
    
    var searchedPlaces = [PlacePin]()
    var filteredPlaces = [PlacePin]()
    //    var searchedLocations = [String]()   有location数据后使用
    var filteredLocations = [String]()
    var searchedLoc: CLLocation!
    
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var uiviewPics: UIView!
    var schBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var btnPlaces = [UIButton]()
    var lblPlaces = [UILabel]()
    var imgPlaces: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    var arrPlaceNames: [String] = ["Restaurants", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    var strSearchedPlace: String! = ""
    var strSearchedLocation: String! = ""
    var strPlaceholder: String! = ""
    
    // uiviews with shadow under table views
    var uiviewSchResBg: UIView!
    var uiviewSchLocResBg: UIView!
    // table tblSearchRes used for search places & display table "use current location"
    var tblPlacesRes: UITableView!
    // table tblLocationRes used for search locations
    var tblLocationRes: UITableView!
    
    var uiviewNoResults: UIView!
    var lblNoResults: UILabel!
    
    // Joshua: Send label text back to start point or destination
    static var boolToDestination = false
    var boolCurtLocSelected = false
    var boolFromRouting = false
    
    // MapKit address autocompletion
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    // Google address autocompletion
    var googleFilter = GMSAutocompleteFilter()
    var googlePredictions = [GMSAutocompletePrediction]()
    
    // Switch between two google city search or address search
    var isCitySearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor._241241241()
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        joshprint("BoardVC is called")
        schBar.txtSchField.becomeFirstResponder()
        searchedLoc = LocManager.shared.curtLoc
        
        searchCompleter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var delay: Double = 0
        
        for i in 0..<6 {
            UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.btnPlaces[i].frame.size = CGSize(width: 58, height: 58)
                self.btnPlaces[i].alpha = 1
                self.lblPlaces[i].center.y += 43
                self.lblPlaces[i].alpha = 1
                if i >= 3 {
                    self.btnPlaces[i].frame.origin.y = 117
                } else {
                    self.btnPlaces[i].frame.origin.y = 20
                }
                if i == 1 || i == 4 {
                    self.btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2
                } else if i == 2 || i == 5 {
                    self.btnPlaces[i].frame.origin.x = screenWidth - 126
                } else {
                    self.btnPlaces[i].frame.origin.x = 52
                }
            }, completion: nil)
            delay += 0.1
        }
    }
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        filteredLocations = searchResults.map({ $0.title + ", " + $0.subtitle })
        self.tblLocationRes.reloadData()
        if self.searchResults.count > 0 {
            showOrHideViews(searchText: completer.queryFragment)
        }
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
    // shows "no results"
    func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124 - 48 + device_offset_top, width: screenWidth - 16, height: 100))
        uiviewNoResults.backgroundColor = .white
        view.addSubview(uiviewNoResults)
        lblNoResults = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResults.addSubview(lblNoResults)
        lblNoResults.center = CGPoint(x: screenWidth / 2, y: 50)
        lblNoResults.numberOfLines = 0
        lblNoResults.text = "No Results Found...\nTry a Different Search!"
        lblNoResults.textAlignment = .center
        lblNoResults.textColor = UIColor._115115115()
        lblNoResults.font = UIFont(name: "AvenirNext-Medium", size: 15)
        uiviewNoResults.layer.cornerRadius = 2
        addShadow(uiviewNoResults)
    }
    
    func loadSearchBar() {
        uiviewSearch = UIView()
        view.addSubview(uiviewSearch)
        uiviewSearch.backgroundColor = .white
        view.addConstraintsWithFormat("H:|-8-[v0]-8-|", options: [], views: uiviewSearch)
        view.addConstraintsWithFormat("V:|-\(23+device_offset_top)-[v0(48)]", options: [], views: uiviewSearch)
        uiviewSearch.layer.cornerRadius = 2
        addShadow(uiviewSearch)
        
        btnBack = UIButton(frame: CGRect(x: 3, y: 0, width: 34.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToBoards(_:)), for: .touchUpInside)
        uiviewSearch.addSubview(btnBack)
        
        schBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 0, width: screenWidth - 38, height: 48))
        schBar.delegate = self
//        schBar.txtSchField.placeholder = "All Places"
        if enterMode == .place {
            schBar.txtSchField.placeholder = "All Places"
            if strSearchedPlace != "All Places" {
                schBar.txtSchField.text = strSearchedPlace
                schBar.btnClose.isHidden = false
            }
        } else if enterMode == .location {
            schBar.txtSchField.placeholder = strSearchedLocation
            schBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
//            if strSearchedLocation != "Current Location" {
//                schBar.txtSchField.text = strSearchedLocation
//                schBar.btnClose.isHidden = false
//            }
        }
        if boolFromRouting {
            schBar.txtSchField.placeholder = BoardsSearchViewController.boolToDestination ? "Choose Destination..." : "Choose Starting Point..."
        }
        uiviewSearch.addSubview(schBar)
    }
    
    // load six buttons
    func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124 - 48 + device_offset_top, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        
        for _ in 0..<6 {
            btnPlaces.append(UIButton(frame: CGRect(x: 52 + 29, y: 20 + 29, width: 0, height: 0)))
            lblPlaces.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            btnPlaces[i].alpha = 0
            if i >= 3 {
                btnPlaces[i].frame.origin.y = 117 + 29
            }
            if i == 1 || i == 4 {
                btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2 + 29
            } else if i == 2 || i == 5 {
                btnPlaces[i].frame.origin.x = screenWidth - 126 + 29
            }
            
            lblPlaces[i].center = CGPoint(x: btnPlaces[i].center.x, y: btnPlaces[i].center.y)
            lblPlaces[i].alpha = 0
            
            uiviewPics.addSubview(btnPlaces[i])
            uiviewPics.addSubview(lblPlaces[i])
            
            btnPlaces[i].layer.borderColor = UIColor._225225225().cgColor
            btnPlaces[i].layer.borderWidth = 2
            btnPlaces[i].layer.cornerRadius = 8.0
            btnPlaces[i].contentMode = .scaleAspectFit
            btnPlaces[i].layer.masksToBounds = true
            btnPlaces[i].setImage(imgPlaces[i], for: .normal)
            btnPlaces[i].tag = i
            btnPlaces[i].addTarget(self, action: #selector(searchByCategories(_:)), for: .touchUpInside)
            
            lblPlaces[i].text = arrPlaceNames[i]
            lblPlaces[i].textAlignment = .center
            lblPlaces[i].textColor = UIColor._138138138()
            lblPlaces[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
    }
    
    func loadTable() {
        // background view with shadow of table tblPlacesRes
        uiviewSchResBg = UIView(frame: CGRect(x: 8, y: 124 - 48 + device_offset_top, width: screenWidth - 16, height: screenHeight - 139 - device_offset_top)) // 124 + 15
        view.addSubview(uiviewSchResBg)
        addShadow(uiviewSchResBg)
        
        tblPlacesRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 139 - device_offset_top))
        tblPlacesRes.dataSource = self
        tblPlacesRes.delegate = self
        uiviewSchResBg.addSubview(tblPlacesRes)
        tblPlacesRes.separatorStyle = .none
        tblPlacesRes.backgroundColor = .white
        tblPlacesRes.layer.masksToBounds = true
        tblPlacesRes.layer.cornerRadius = 2
        tblPlacesRes.register(PlacesListCell.self, forCellReuseIdentifier: "SearchPlaces")
        tblPlacesRes.register(LocationListCell.self, forCellReuseIdentifier: "MyFixedCell")
        
        // background view with shadow of table tblLocationRes
        uiviewSchLocResBg = UIView(frame: CGRect(x: 8, y: 124 - 48 + device_offset_top, width: screenWidth - 16, height: screenHeight - 240 - device_offset_top)) // 124 + 20 + 2 * 48
        uiviewSchLocResBg.backgroundColor = .clear
        view.addSubview(uiviewSchLocResBg)
        addShadow(uiviewSchLocResBg)
        
        tblLocationRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 240))
        tblLocationRes.dataSource = self
        tblLocationRes.delegate = self
        uiviewSchLocResBg.addSubview(tblLocationRes)
        tblLocationRes.layer.cornerRadius = 2
        tblLocationRes.layer.masksToBounds = true
        tblLocationRes.separatorStyle = .none
        tblLocationRes.backgroundColor = .white
        tblLocationRes.register(LocationListCell.self, forCellReuseIdentifier: "SearchLocation")
    }
    
    // FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        switch enterMode {
        case .place:
            if searchBar.txtSchField.text == "" {
                showOrHideViews(searchText: searchBar.txtSchField.text!)
            } else {
                getPlaceInfo(content: searchBar.txtSchField.text!)
            }
        case .location:
            showOrHideViews(searchText: searchBar.txtSchField.text!)
            //            if searchBar.txtSchField.text == "Current Location" {
            //                searchBar.txtSchField.placeholder = searchBar.txtSchField.text
            //                searchBar.txtSchField.text = ""
            //                searchBar.btnClose.isHidden = true
            //            }
        default: break
        }
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        switch enterMode {
        case .place:
            getPlaceInfo(content: searchBar.txtSchField.text!)
//            filteredPlaces.removeAll()
//            for searchedPlace in searchedPlaces {
//                if searchedPlace.name.lowercased().range(of: searchText.lowercased()) != nil {
//                    filteredPlaces.append(searchedPlace)
//                }
//            }
        case .location:
            if searchText == "" {
                showOrHideViews(searchText: searchText)
                return
            }
            if isCitySearch {
                placeAutocomplete(searchText)
            } else {
                searchCompleter.queryFragment = searchText
                showOrHideViews(searchText: searchText)
            }
        default: break
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.resignFirstResponder()
        
        switch enterMode {
        case .place:
            delegate?.jumpToPlaceSearchResult?(searchText: searchBar.txtSchField.text!, places: filteredPlaces)
            navigationController?.popViewController(animated: false)
        case .location:
            break
        default:
            break
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    // End of FaeSearchBarTestDelegate
    
    func getPlaceInfo(content: String = "", source: String = "name") {
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "99999999")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.search { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                self.showOrHideViews(searchText: content)
                return
            }
            self.filteredPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            
            if source == "name" {
                self.showOrHideViews(searchText: content)
            } else {
                self.delegate?.jumpToPlaceSearchResult?(searchText: content, places: self.filteredPlaces)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    func showOrHideViews(searchText: String) {
        // search places
        if enterMode == .place {
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            if searchText != "" && filteredPlaces.count != 0 {
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 - 48 + device_offset_top
                uiviewSchResBg.frame.size.height = min(screenHeight - 139, CGFloat(68 * filteredPlaces.count))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124 - 48 + device_offset_top
                } else {
                    uiviewPics.frame.origin.y = 124 - 48 + uiviewNoResults.frame.height + 5 + device_offset_top
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && filteredPlaces.count == 0 {
                uiviewNoResults.isHidden = false
            } else {
                uiviewNoResults.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        } else { // search location
            uiviewPics.isHidden = true
            uiviewNoResults.isHidden = true
            uiviewSchResBg.isHidden = false
            if boolCurtLocSelected {
                uiviewSchResBg.frame.size.height = 48
            } else {
                uiviewSchResBg.frame.size.height = CGFloat(arrCurtLocList.count * 48)
            }
            tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            
            let count = isCitySearch ? googlePredictions.count : filteredLocations.count
            
            if searchText == "" || count == 0 {
                uiviewSchResBg.frame.origin.y = 124 - 48 + device_offset_top
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewSchLocResBg.isHidden = false
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240, CGFloat(48 * count)) - device_offset_top - device_offset_bot
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 - 48 + uiviewSchLocResBg.frame.height + 5 + device_offset_top
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // search location
        if enterMode == .location {
            if tableView == tblLocationRes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath as IndexPath) as! LocationListCell
                if isCitySearch {
                    cell.lblLocationName.attributedText = googlePredictions[indexPath.row].faeSearchBarAttributedText()
                } else {
                    cell.lblLocationName.attributedText = nil
                    cell.lblLocationName.text = filteredLocations[indexPath.row]
                }
                cell.bottomLine.isHidden = false
                if indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
                if boolCurtLocSelected {
                    cell.lblLocationName.text = arrCurtLocList[1]
                    cell.bottomLine.isHidden = true
                    return cell
                }
                cell.lblLocationName.text = arrCurtLocList[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == arrCurtLocList.count - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        } else if enterMode == .place {
            // search places
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
            let place = filteredPlaces[indexPath.row]
            cell.setValueForPlace(place)
            cell.bottomLine.isHidden = false
            
            if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Joshua: 0829 Modified
        if enterMode == .place {
            return filteredPlaces.count
        } else {
            if tableView == tblLocationRes {
                return isCitySearch ? googlePredictions.count : filteredLocations.count
            } else {
                if boolCurtLocSelected {
                    return 1
                } else {
                    return arrCurtLocList.count
                }
            }
        }
        // End of Joshua: 0829 Modified
        //        return enterMode == .place ? filteredPlaces.count : (tableView == tblLocationRes ? filteredLocations.count : arrCurtLocList.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return enterMode == .place ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // search location
        if enterMode == .location {
            schBar.txtSchField.resignFirstResponder()
            if tableView == tblLocationRes {
                if isCitySearch {
                    let slctPred = googlePredictions[indexPath.row]
                    Key.shared.selectedPrediction = googlePredictions[indexPath.row]
                    General.shared.lookUpForCoordinate({ (place) in
                        let address = RouteAddress(name: slctPred.attributedFullText.string)
                        address.coordinate = place.coordinate
                        self.delegate?.sendLocationBack?(address: address)
                        self.delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mapSearchCurrentLocation"), searchText: slctPred.attributedFullText.string, location: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
                        self.navigationController?.popViewController(animated: false)
                    })
                } else {
                    let searchRequest = MKLocalSearchRequest(completion: searchResults[indexPath.row])
                    let search = MKLocalSearch(request: searchRequest)
                    search.start { (response, error) in
                        guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }
                        let address = RouteAddress(name: self.filteredLocations[indexPath.row])
                        address.coordinate = coordinate
                        self.delegate?.sendLocationBack?(address: address)
                        self.delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mapSearchCurrentLocation"), searchText: self.filteredLocations[indexPath.row], location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            } else { // fixed cell - "Use my Current Location", "Choose Location on Map"
                if indexPath.row == 0 {
                    Key.shared.selectedPrediction = nil
                    if boolCurtLocSelected {
                        navigationController?.popViewController(animated: false)
                        delegate?.chooseLocationOnMap?()
                        return
                    }
                    delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mb_iconBeforeCurtLoc"), searchText: "Current Location", location: LocManager.shared.curtLoc)
                    let address = RouteAddress(name: "Current Location")
                    delegate?.sendLocationBack?(address: address)
                    navigationController?.popViewController(animated: false)
                } else {
                    if boolFromRouting {
                        navigationController?.popViewController(animated: false)
                        delegate?.chooseLocationOnMap?()
                        return
                    }
                    //navigationController?.popViewController(animated: false)
                    //delegate?.chooseLocationOnMap?()
                    let vc = SelectLocationViewController()
                    Key.shared.selectedLoc = LocManager.shared.curtLoc.coordinate
                    //navigationController?.pushViewController(vc, animated: true)
                    var arrViewControllers = navigationController?.viewControllers
                    arrViewControllers!.removeLast()
                    if let lastVC = arrViewControllers?.last as? InitialPageController {
                        if let vcMB = lastVC.arrViewCtrl.last as? MapBoardViewController {
                            vc.delegate = vcMB
                            vc.boolFromBoard = true
                            vc.strShownLoc = strSearchedLocation
                            arrViewControllers!.append(vc)
                        } else if let vcFM = lastVC.arrViewCtrl.first as? FaeMapViewController {
                            // will never be excuted
                            // because FaeMapVC will reuse self to do location selecting
                            vc.delegate = vcFM
                            vc.boolFromBoard = true
                            vc.strShownLoc = strSearchedLocation
                            arrViewControllers!.append(vc)
                        }
                    } else if let lastVC = arrViewControllers?.last as? AllPlacesViewController {
                        vc.delegate = lastVC
                        vc.boolFromBoard = true
                        arrViewControllers!.append(vc)
                    } else if let vcExplore = arrViewControllers?.last as? ExploreViewController {
                        vc.delegate = vcExplore
                        vc.boolFromExplore = true
                        vc.strShownLoc = strSearchedLocation
                        arrViewControllers?.append(vc)
                    }
                    navigationController?.setViewControllers(arrViewControllers!, animated: true)
                }
            }
        } else if enterMode == .place { // search places
            let selectedPlace = filteredPlaces[indexPath.row]
            let vcPlaceDetail = PlaceDetailViewController()
            vcPlaceDetail.place = selectedPlace
            navigationController?.pushViewController(vcPlaceDetail, animated: true)
        }
    }
    
    func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    @objc func backToBoards(_ sender: UIButton) {
        //        if enterMode == .place {
        //            delegate?.backToPlaceSearchView()
        //        } else {
        //            delegate?.backToLocationSearchView()
        //        }
        navigationController?.popViewController(animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schBar.txtSchField.resignFirstResponder()
    }
    
    @objc func searchByCategories(_ sender: UIButton) {
        // tag = 0 - Restaurants - arrPlaceNames[0], 1 - Bars - arrPlaceNames[1],
        // 2 - Shopping - arrPlaceNames[2], 3 - Coffee Shop - arrPlaceNames[3],
        // 4 - Parks - arrPlaceNames[4], 5 - Hotels - arrPlaceNames[5]
        var content = ""
        switch sender.tag {
        case 0:
            content = "Restaurants"
        case 1:
            content = "Bars"
        case 2:
            content = "Shopping"
        case 3:
            content = "Coffee"
        case 4:
            content = "Parks"
        case 5:
            content = "Hotels"
        default: break
        }
        getPlaceInfo(content: content, source: "categories")
    }
    
    // MARK: - GMSAutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedPrediction = nil
        googleFilter.type = .city
        GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: googleFilter, callback: {(results, error) -> Void in
            if let error = error {
                joshprint("Autocomplete error \(error)")
                self.googlePredictions.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: searchText)
                return
            }
            if let results = results {
                self.googlePredictions = results
            }
            self.showOrHideViews(searchText: searchText)
        })
    }
}
