//
//  MainScreenSearchViewController.swift
//  faeBeta
//
//  Created by Yue on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit

protocol MainScreenSearchDelegate: class {
    // Cancel marker's shadow when back to Fae Map
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D)
}

class MainScreenSearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, FaeSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
    
    weak var delegate: MainScreenSearchDelegate?
    
    var imagePinOnMap: UIImageView!
    
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonClearSearchBar: UIButton!
    
    var uiviewBlurMainScreenSearch: UIVisualEffectView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var faeSearchController: FaeSearchController!
    var searchBarSubview: UIView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var resultTableWidth: CGFloat {
        if UIScreen.main.bounds.width == 414 { // 5.5
            return 398
        } else if UIScreen.main.bounds.width == 320 { // 4.0
            return 308
        } else if UIScreen.main.bounds.width == 375 { // 4.7
            return 360.5
        }
        return 308
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlurView()
        loadFunctionButtons()
        loadTableView()
        loadFaeSearchController()
        loadNavBarUnderLine()
        searchCompleter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: ({
            self.searchBarSubview.center.y += self.searchBarSubview.frame.size.height
            self.uiviewBlurMainScreenSearch.effect = UIBlurEffect(style: .light)
        }), completion: { (done: Bool) in
            if done {
                self.faeSearchController.faeSearchBar.becomeFirstResponder()
            }
        })
    }
    
    func loadNavBarUnderLine() {
        let uiviewUnderLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewUnderLine.layer.borderWidth = screenWidth
        uiviewUnderLine.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        uiviewUnderLine.layer.zPosition = 5
        searchBarSubview.addSubview(uiviewUnderLine)
    }
    
    func loadBlurView() {
        uiviewBlurMainScreenSearch = UIVisualEffectView()
        uiviewBlurMainScreenSearch.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.addSubview(uiviewBlurMainScreenSearch)
        let buttonBackToMapSubview = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBlurMainScreenSearch.addSubview(buttonBackToMapSubview)
        buttonBackToMapSubview.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
    }
    
    func loadFunctionButtons() {
        searchBarSubview = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        searchBarSubview.layer.zPosition = 1
        view.addSubview(searchBarSubview)
        searchBarSubview.center.y -= searchBarSubview.frame.size.height
        let backSubviewButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        searchBarSubview.addSubview(backSubviewButton)
        backSubviewButton.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
        backSubviewButton.layer.zPosition = 0
        
        let viewToHideLeftSideSearchBar = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
        viewToHideLeftSideSearchBar.backgroundColor = UIColor.white
        searchBarSubview.addSubview(viewToHideLeftSideSearchBar)
        viewToHideLeftSideSearchBar.layer.zPosition = 2
        
        let viewToHideRightSideSearchBar = UIView()
        viewToHideRightSideSearchBar.backgroundColor = UIColor.white
        searchBarSubview.addSubview(viewToHideRightSideSearchBar)
        viewToHideRightSideSearchBar.layer.zPosition = 2
        searchBarSubview.addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: viewToHideRightSideSearchBar)
        searchBarSubview.addConstraintsWithFormat("V:|-0-[v0(64)]", options: [], views: viewToHideRightSideSearchBar)
    }
    
    func loadFaeSearchController() {
        faeSearchController = FaeSearchController(searchResultsController: self,
                                                  searchBarFrame: CGRect(x: 18, y: 24, width: resultTableWidth, height: 36),
                                                  searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!,
                                                  searchBarTextColor: UIColor.faeAppInputTextGrayColor(),
                                                  searchBarTintColor: UIColor.white)
        faeSearchController.faeSearchBar.placeholder = "Fly to Somewhere                               "
        faeSearchController.faeDelegate = self
        faeSearchController.faeSearchBar.layer.borderWidth = 2.0
        faeSearchController.faeSearchBar.layer.borderColor = UIColor.white.cgColor
        faeSearchController.faeSearchBar.tintColor = UIColor.faeAppRedColor()
        
        searchBarSubview.addSubview(faeSearchController.faeSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        
        let btnBackToFaeMap = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        btnBackToFaeMap.setImage(UIImage(named: "mainScreenSearchToFaeMap"), for: UIControlState())
        searchBarSubview.addSubview(btnBackToFaeMap)
        btnBackToFaeMap.addTarget(self, action: #selector(MainScreenSearchViewController.actionDimissSearchBar(_:)), for: .touchUpInside)
        btnBackToFaeMap.layer.zPosition = 3
        
        buttonClearSearchBar = UIButton()
        buttonClearSearchBar.setImage(UIImage(named: "mainScreenSearchClearSearchBar"), for: UIControlState())
        searchBarSubview.addSubview(buttonClearSearchBar)
        buttonClearSearchBar.addTarget(self,
                                       action: #selector(MainScreenSearchViewController.actionClearSearchBar(_:)),
                                       for: .touchUpInside)
        buttonClearSearchBar.layer.zPosition = 3
        searchBarSubview.addConstraintsWithFormat("H:[v0(17)]-15-|", options: [], views: buttonClearSearchBar)
        searchBarSubview.addConstraintsWithFormat("V:|-33-[v0(17)]", options: [], views: buttonClearSearchBar)
        buttonClearSearchBar.isHidden = true
        
        let uiviewCommentPinUnderLine = UIView(frame: CGRect(x: 0, y: 63, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine.layer.borderWidth = 1
        uiviewCommentPinUnderLine.layer.borderColor = UIColor(red: 196 / 255, green: 195 / 255, blue: 200 / 255, alpha: 1.0).cgColor
        uiviewCommentPinUnderLine.layer.zPosition = 4
        searchBarSubview.addSubview(uiviewCommentPinUnderLine)
    }
    
    func actionDimissSearchBar(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    func actionClearSearchBar(_ sender: UIButton) {
        faeSearchController.faeSearchBar.text = ""
    }
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.tblSearchResults.reloadData()
        if self.searchResults.count > 0 {
            self.searchBarTableShowAnimation()
        }
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: FaeSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        faeSearchController.faeSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        if searchResults.count > 0 {
            let address = searchResults[0].title + searchResults[0].subtitle
            General.shared.getLocation(address: address) { (coordinate) in
                if let coor = coordinate {
                    self.delegate?.animateToCameraFromMainScreenSearch(coor)
                    self.dismiss(animated: false, completion: nil)
                }
            }
            faeSearchController.faeSearchBar.text = address
            faeSearchController.faeSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
 
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(_ searchText: String) {
        if searchText != "" {
            searchCompleter.queryFragment = searchText
            buttonClearSearchBar.isHidden = false
        } else {
            buttonClearSearchBar.isHidden = true
            searchResults.removeAll()
            searchBarTableHideAnimation()
            tblSearchResults.reloadData()
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
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 300 * screenWidthFactor)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 300 * screenWidthFactor)
        }), completion: nil)
    }
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 76, width: resultTableWidth, height: 0))
        tblSearchResults = UITableView(frame: uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.register(FaeCellForMainScreenSearch.self, forCellReuseIdentifier: "faeCellForMainScreenSearch")
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
        view.addSubview(uiviewTableSubview)
    }
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faeCellForMainScreenSearch", for: indexPath) as! FaeCellForMainScreenSearch
        cell.labelTitle.text = searchResults[indexPath.row].title
        cell.labelSubTitle.text = searchResults[indexPath.row].subtitle
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = searchResults[indexPath.row].title + searchResults[indexPath.row].subtitle
        General.shared.getLocation(address: address) { (coordinate) in
            if let coor = coordinate {
                self.delegate?.animateToCameraFromMainScreenSearch(coor)
                self.dismiss(animated: false, completion: nil)
            }
        }

        faeSearchController.faeSearchBar.text = address
        faeSearchController.faeSearchBar.resignFirstResponder()
        searchBarTableHideAnimation()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61 * screenWidthFactor
    }
}
