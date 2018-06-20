//
//  GeneralLocationSearchViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol GeneralLocationSearchDelegate: class {
    @objc optional func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation)
    @objc optional func chooseLocationOnMap()
    @objc optional func sendLocationBack(address: RouteAddress)
    @objc optional func sendPlaceBack(placeData: PlacePin)
}

enum EnterMode: String {
    case place = "place"
    case location = "location"
}

class GeneralLocationSearchViewController: UIViewController, FaeSearchBarTestDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
    
    weak var delegate: GeneralLocationSearchDelegate?
    
    private var fixedLocOptions = ["Use my Current Location", "Choose Location on Map"]
    private var filteredLocations = [String]()
    
    private var btnBack: UIButton!
    private var uiviewSearch: UIView!
    private var schBar: FaeSearchBarTest!
    
    // uiviews with shadow under table views
    private var uiviewSchResBg: UIView!
    private var uiviewSchLocResBg: UIView!
    
    // table tblLocationRes used for search locations
    private var tblLocationRes: UITableView!
    private var tblPlacesRes: UITableView!
    
    private var uiviewNoResults: UIView!
    private var lblNoResults: UILabel!
    private var activityView: UIActivityIndicatorView!
    
    // Joshua: Send label text back to start point or destination
    static var boolToDestination = false
    var boolCurtLocSelected = false
    var boolFromRouting = false
    
    // MapKit address autocompletion
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    // Switch between two google city search or address search
    var isCitySearch = false
    
    // Geobytes City Data
    private var geobytesCityData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor._241241241()
        loadSearchBar()
        loadTable()
        loadNoResultsView()
        
        searchCompleter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        schBar.txtSchField.becomeFirstResponder()
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
    private func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124 - 48 + device_offset_top, width: screenWidth - 16, height: 100))
        uiviewNoResults.backgroundColor = .white
        uiviewNoResults.layer.cornerRadius = 2
        view.addSubview(uiviewNoResults)
        
        lblNoResults = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResults.addSubview(lblNoResults)
        lblNoResults.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        lblNoResults.numberOfLines = 0
        lblNoResults.text = "No Results Found...\nTry a Different Search!"
        lblNoResults.textAlignment = .center
        lblNoResults.textColor = UIColor._115115115()
        lblNoResults.font = UIFont(name: "AvenirNext-Medium", size: 15)
        
        activityView = createActivityIndicator(large: true)
        activityView.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        uiviewNoResults.addSubview(activityView)
        
        addShadow(uiviewNoResults)
    }
    
    private func loadSearchBar() {
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
        schBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        if boolFromRouting {
            schBar.txtSchField.placeholder = GeneralLocationSearchViewController.boolToDestination ? "Choose Destination..." : "Choose Starting Point..."
        }
        uiviewSearch.addSubview(schBar)
    }
    
    private func loadTable() {
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
        showOrHideViews(searchText: searchBar.txtSchField.text!)
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
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
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    // End of FaeSearchBarTestDelegate
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    private func showOrHideViews(searchText: String) {
        uiviewNoResults.isHidden = true
        uiviewSchResBg.isHidden = false
        if boolCurtLocSelected {
            uiviewSchResBg.frame.size.height = 48
        } else {
            uiviewSchResBg.frame.size.height = CGFloat(fixedLocOptions.count * 48)
        }
        tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
        
        let count = isCitySearch ? geobytesCityData.count : filteredLocations.count
        
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
        tblPlacesRes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblLocationRes {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath as IndexPath) as! LocationListCell
            let isLast = indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1
            if isCitySearch {
                cell.configureCell(geobytesCityData[indexPath.row], last: isLast)
            } else {
                cell.configureCellOption(filteredLocations[indexPath.row], last: isLast)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
            if boolCurtLocSelected {
                cell.configureCellOption(fixedLocOptions[1], last: true)
                return cell
            }
            let isLast = indexPath.row == fixedLocOptions.count - 1
            cell.configureCellOption(fixedLocOptions[indexPath.row], last: isLast)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblLocationRes {
            return isCitySearch ? geobytesCityData.count : filteredLocations.count
        } else {
            if boolCurtLocSelected {
                return 1
            } else {
                return fixedLocOptions.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        schBar.txtSchField.resignFirstResponder()
        if tableView == tblLocationRes {
            if isCitySearch {
                //                let slctPred = geobytesCityData[indexPath.row]
                //                Key.shared.selectedPrediction = googlePredictions[indexPath.row]
                //                General.shared.lookUpForCoordinate({ (place) in
                //                    let address = RouteAddress(name: slctPred.attributedFullText.string)
                //                    address.coordinate = place.coordinate
                //                    self.delegate?.sendLocationBack?(address: address)
                //                    self.delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mapSearchCurrentLocation"), searchText: slctPred.attributedFullText.string, location: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
                //                    self.navigationController?.popViewController(animated: false)
                //                })
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
        } else {
            // fixed cell - "Use my Current Location", "Choose Location on Map"
            if indexPath.row == 0 {
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
                        arrViewControllers!.append(vc)
                    } else if let vcFM = lastVC.arrViewCtrl.first as? FaeMapViewController {
                        // will never be excuted
                        // because FaeMapVC will reuse self to do location selecting
                        vc.delegate = vcFM
                        vc.boolFromBoard = true
                        arrViewControllers!.append(vc)
                    }
                }
                navigationController?.setViewControllers(arrViewControllers!, animated: true)
            }
        }
    }
    
    private func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    @objc private func backToBoards(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schBar.txtSchField.resignFirstResponder()
    }
    
    // MARK: -
    private func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedSearchedCity = nil
        CitySearcher.shared.cityAutoComplete(searchText) { (status, result) in
            self.geobytesCityData.removeAll()
            guard status / 100 == 2 else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            guard let result = result else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            let value = JSON(result)
            let citys = value.arrayValue
            for city in citys {
                if city.stringValue == "%s" || city.stringValue == "" {
                    break
                }
                self.geobytesCityData.append(city.stringValue)
                
            }
            self.showOrHideViews(searchText: searchText)
        }
    }
}
