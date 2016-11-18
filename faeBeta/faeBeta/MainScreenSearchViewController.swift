//
//  MainScreenSearchViewController.swift
//  faeBeta
//
//  Created by Yue on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol MainScreenSearchDelegate: class {
    // Cancel marker's shadow when back to Fae Map
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D)
}

class MainScreenSearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: MainScreenSearchDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    let fontColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
    
    var mapSelectLocation: GMSMapView!
    var imagePinOnMap: UIImageView!
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonClearSearchBar: UIButton!
    
    var blurViewMainScreenSearch: UIVisualEffectView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    var searchBarSubview: UIView!
    var placeholder = [GMSAutocompletePrediction]()
    
    var resultTableWidth: CGFloat {
        if UIScreen.main.bounds.width == 414 { // 5.5
            return 398
        }
        else if UIScreen.main.bounds.width == 320 { // 4.0
            return 308
        }
        else if UIScreen.main.bounds.width == 375 { // 4.7
            return 360.5
        }
        return 308
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlurView()
        loadFunctionButtons()
        loadTableView()
        loadCustomSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25, animations: ({
            self.searchBarSubview.center.y += self.searchBarSubview.frame.size.height
            self.blurViewMainScreenSearch.alpha = 1.0
        }), completion: { (done: Bool) in
            if done {
                self.customSearchController.customSearchBar.becomeFirstResponder()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurViewMainScreenSearch = UIVisualEffectView(effect: blurEffect)
        blurViewMainScreenSearch.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        blurViewMainScreenSearch.alpha = 0.0
        self.view.addSubview(blurViewMainScreenSearch)
    }
    
    func loadFunctionButtons() {
        searchBarSubview = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        searchBarSubview.layer.zPosition = 1
        self.view.addSubview(searchBarSubview)
        self.searchBarSubview.center.y -= self.searchBarSubview.frame.size.height
        let backSubviewButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.searchBarSubview.addSubview(backSubviewButton)
        backSubviewButton.addTarget(self, action: #selector(MainScreenSearchViewController.actionDimissSearchBar(_:)), for: .touchUpInside)
        backSubviewButton.layer.zPosition = 0
        
        let viewToHideLeftSideSearchBar = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
        viewToHideLeftSideSearchBar.backgroundColor = UIColor.white
        self.searchBarSubview.addSubview(viewToHideLeftSideSearchBar)
        viewToHideLeftSideSearchBar.layer.zPosition = 2
        
        let viewToHideRightSideSearchBar = UIView()
        viewToHideRightSideSearchBar.backgroundColor = UIColor.white
        self.searchBarSubview.addSubview(viewToHideRightSideSearchBar)
        viewToHideRightSideSearchBar.layer.zPosition = 2
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: viewToHideRightSideSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-0-[v0(64)]", options: [], views: viewToHideRightSideSearchBar)
    }
    
    func loadCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self,
                                                        searchBarFrame: CGRect(x: 18, y: 24, width: resultTableWidth, height: 36),
                                                        searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!,
                                                        searchBarTextColor: fontColor,
                                                        searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search Fae Map                                         "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.white.cgColor
        customSearchController.customSearchBar.tintColor = colorFae
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        
        let buttonBackToFaeMap = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        buttonBackToFaeMap.setImage(UIImage(named: "mainScreenSearchToFaeMap"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonBackToFaeMap)
        buttonBackToFaeMap.addTarget(self, action: #selector(MainScreenSearchViewController.actionDimissSearchBar(_:)), for: .touchUpInside)
        buttonBackToFaeMap.layer.zPosition = 3
        
        buttonClearSearchBar = UIButton()
        buttonClearSearchBar.setImage(UIImage(named: "mainScreenSearchClearSearchBar"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonClearSearchBar)
        buttonClearSearchBar.addTarget(self,
                                       action: #selector(MainScreenSearchViewController.actionClearSearchBar(_:)),
                                       for: .touchUpInside)
        buttonClearSearchBar.layer.zPosition = 3
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(17)]-15-|", options: [], views: buttonClearSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-33-[v0(17)]", options: [], views: buttonClearSearchBar)
        buttonClearSearchBar.isHidden = true
        
        let uiviewCommentPinUnderLine = UIView(frame: CGRect(x: 0, y: 63, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine.layer.borderWidth = 1
        uiviewCommentPinUnderLine.layer.borderColor = UIColor(red: 196/255, green: 195/255, blue: 200/255, alpha: 1.0).cgColor
        uiviewCommentPinUnderLine.layer.zPosition = 4
        self.searchBarSubview.addSubview(uiviewCommentPinUnderLine)
    }
    
    func actionDimissSearchBar(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionClearSearchBar(_ sender: UIButton) {
        customSearchController.customSearchBar.text = ""
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: CustomSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        customSearchController.customSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        if placeholder.count > 0 {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[0].placeID!, callback: {
                (place, error) -> Void in
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        self.delegate?.animateToCameraFromMainScreenSearch(selectedAddress)
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[0].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
        
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(_ searchText: String) {
        if(searchText != "") {
            buttonClearSearchBar.isHidden = false
            ///
            let placeClient = GMSPlacesClient()
            /*
            let filter = GMSAutocompleteFilter()
            filter.type = .establishment
             */
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
                (results, error : Error?) -> Void in
                if let error = error{
                    print("DEBUG GooglePlaces Error")
                    print(error)
                }
                self.placeholder.removeAll()
                if results == nil {
                    return
                } else {
                    for result in results! {
                        self.placeholder.append(result)
                    }
                    self.tblSearchResults.reloadData()
                }
                if self.placeholder.count > 0 {
                    self.searchBarTableShowAnimation()
                }
            }
        }
        else {
            buttonClearSearchBar.isHidden = true
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 0)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 300*screenWidthFactor)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 300*screenWidthFactor)
        }), completion: nil)
    }
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 76, width: resultTableWidth, height: 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.register(CustomCellForMainScreenSearch.self, forCellReuseIdentifier: "customCellForMainScreenSearch")
        tblSearchResults.isScrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsets.zero
        tblSearchResults.layoutMargins = UIEdgeInsets.zero
        uiviewTableSubview.layer.borderColor = UIColor.white.cgColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 2.5
        uiviewTableSubview.layer.shadowColor = UIColor.black.cgColor
        uiviewTableSubview.addSubview(tblSearchResults)
        self.view.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults) {
            return placeholder.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblSearchResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCellForMainScreenSearch", for: indexPath) as! CustomCellForMainScreenSearch
            cell.labelTitle.text = placeholder[indexPath.row].attributedPrimaryText.string
            if let secondaryText = placeholder[indexPath.row].attributedSecondaryText {
                cell.labelSubTitle.text = secondaryText.string
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.tblSearchResults) {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
                (place, error) -> Void in
                // Get place.coordinate
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        self.delegate?.animateToCameraFromMainScreenSearch(selectedAddress)
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults) {
            return 60 * screenWidthFactor
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
}
