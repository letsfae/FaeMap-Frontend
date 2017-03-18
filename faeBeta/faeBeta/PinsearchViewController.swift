//
//  PinsearchViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 02/12/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON



class PinsearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, FaeSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource{

    var willAppearFirstLoad = false
    
    var buttonClearSearchBar: UIButton!
    
    var blurViewMainScreenSearch: UIVisualEffectView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [[String: AnyObject]]()
    var filteredArray = [[String: AnyObject]]()
    var tableTypeName: String = ""
    var searchController: UISearchController!
    var faeSearchController: FaeSearchController!
    var searchBarSubview: UIView!
    var keyboardHeight: CGFloat = 0
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
        loadFaeSearchController()
        loadNavBarUnderLine()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PinsearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PinsearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: ({
            self.searchBarSubview.center.y += self.searchBarSubview.frame.size.height
            self.blurViewMainScreenSearch.effect = UIBlurEffect(style: .light)
        }), completion: { (done: Bool) in
            if done {
                self.faeSearchController.faeSearchBar.becomeFirstResponder()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadNavBarUnderLine() {
        let uiviewUnderLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewUnderLine.layer.borderWidth = screenWidth
        uiviewUnderLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewUnderLine.layer.zPosition = 5
        self.searchBarSubview.addSubview(uiviewUnderLine)
    }
    
    func loadBlurView() {
        blurViewMainScreenSearch = UIVisualEffectView()
        blurViewMainScreenSearch.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(blurViewMainScreenSearch)
        
        //为了一个事件加个假button并不好，用UITapGestureRecognizer来做
//        let buttonBackToMapSubview = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
//        blurViewMainScreenSearch.addSubview(buttonBackToMapSubview)
// dismiss this view when tap the blur view
//        buttonBackToMapSubview.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
        
        //Let the searchbar regisn the responser when tap outside(this view) of searchbar
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionResignResponserofSearchbar(_:)))
        blurViewMainScreenSearch.addGestureRecognizer(tap)
        
    }
    
    func loadFunctionButtons() {
        searchBarSubview = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        searchBarSubview.layer.zPosition = 1
        self.view.addSubview(searchBarSubview)
        self.searchBarSubview.center.y -= self.searchBarSubview.frame.size.height
        let backSubviewButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.searchBarSubview.addSubview(backSubviewButton)
        backSubviewButton.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
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
    
    func loadFaeSearchController() {
        faeSearchController = FaeSearchController(searchResultsController: self,
                                                        searchBarFrame: CGRect(x: 18, y: 24, width: resultTableWidth, height: 36),
                                                        searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!,
                                                        searchBarTextColor: UIColor.faeAppInputTextGrayColor(),
                                                        searchBarTintColor: UIColor.white)
        faeSearchController.faeSearchBar.placeholder = "Search Keywords                                       "//blanks for keeping the placeholder not jump during the animation
        faeSearchController.faeDelegate = self
        faeSearchController.faeSearchBar.layer.borderWidth = 2.0
        faeSearchController.faeSearchBar.layer.borderColor = UIColor.white.cgColor
        faeSearchController.faeSearchBar.tintColor = UIColor.faeAppRedColor()
        
        searchBarSubview.addSubview(faeSearchController.faeSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        
        let buttonBackToFaeMap = UIButton(frame: CGRect(x: 15, y: 32, width: 10.5, height: 18))
        buttonBackToFaeMap.setImage(UIImage(named: "mainScreenSearchToFaeMap"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonBackToFaeMap)
        buttonBackToFaeMap.addTarget(self, action: #selector(PinsearchViewController.actionDimissSearchBar(_:)), for: .touchUpInside)
        buttonBackToFaeMap.layer.zPosition = 3
        
        buttonClearSearchBar = UIButton()
        buttonClearSearchBar.setImage(UIImage(named: "mainScreenSearchClearSearchBar"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonClearSearchBar)
        buttonClearSearchBar.addTarget(self,
                                       action: #selector(PinsearchViewController.actionClearSearchBar(_:)),
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
        faeSearchController.faeSearchBar.text = ""
        filteredArray = []
        buttonClearSearchBar.isHidden = true
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()

    }
    
    
    func actionResignResponserofSearchbar(_ sender: UIButton){
        faeSearchController.faeSearchBar.resignFirstResponder()
    
    }
    
    
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: FaeSearchControllerDelegate functions
    func didStartSearching() {
        tblSearchResults.reloadData()
        faeSearchController.faeSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
//        if !shouldShowSearchResults {
//            shouldShowSearchResults = true
//            tblSearchResults.reloadData()
//        }
    }
    
    //resize the height of the view when the keyboard will show
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.uiviewTableSubview.frame.width, height: screenHeight-keyboardHeight-66)
            
            switch tableTypeName {
                
            case "My Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-keyboardHeight-66)
            case "Saved Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-keyboardHeight-66)
                
            default:
                self.uiviewTableSubview.frame = CGRect(x: 0, y: 66, width: screenWidth, height: screenHeight-keyboardHeight-66)
            }
            
        }
        
    }
        //resize the height of the view when the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.uiviewTableSubview.frame.width, height: screenHeight-66)
            
            switch tableTypeName {
                
            case "My Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-66)
            case "Saved Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-66)
                
            default:
                self.uiviewTableSubview.frame = CGRect(x: 0, y: 66, width: screenWidth, height: screenHeight-66)
            }

        }
    }
    
    
    
    
    func didTapOnCancelButton() {
        filteredArray.removeAll()
        buttonClearSearchBar.isHidden = true
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()
    }
    
    
    func didChangeSearchText(_ searchText: String) {
        if(searchText != "") {
            buttonClearSearchBar.isHidden = false
            filteredArray = dataArray.filter { (pinArr:[String: AnyObject]) -> Bool in
                if(pinArr["type"]?.description != "comment"){
                    return (pinArr["description"]?.lowercased.contains(searchText.lowercased()))!
                }
                else{
                    return (pinArr["content"]?.lowercased.contains(searchText.lowercased()))!
                }
            }
            if filteredArray.count > 0{
                searchBarTableShowAnimation()
            }
            tblSearchResults.reloadData()

        }
        else {
            filteredArray.removeAll()
            buttonClearSearchBar.isHidden = true
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.uiviewTableSubview.frame.width, height: 0)

            switch self.tableTypeName {
                
            case "My Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: 0)
            case "Saved Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: 0)
                
            default:
                self.uiviewTableSubview.frame = CGRect(x: 0, y: 66, width: screenWidth, height: 0)
            }
            
            
            
            
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({

            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.uiviewTableSubview.frame.width, height:screenHeight-66-self.keyboardHeight)
            
            switch self.tableTypeName {
                
            case "My Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-66-self.keyboardHeight)
                

            case "Saved Pins":
                self.uiviewTableSubview.frame = CGRect(x: 8, y: 66, width: self.resultTableWidth, height: screenHeight-66-self.keyboardHeight)
                

                
            default:
                self.uiviewTableSubview.frame = CGRect(x: 0, y: 66, width: screenWidth, height: screenHeight-66-self.keyboardHeight)
                

            }

            
                        

        }), completion: nil)
    }
    
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        
        switch tableTypeName {
            
        case "My Pins":
            uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 66, width: resultTableWidth, height: 0))
            
            tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        case "Saved Pins":
            uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 66, width: resultTableWidth, height: 0))
            
            tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
            
        default:
            uiviewTableSubview = UIView(frame: CGRect(x: 0, y: 66, width: screenWidth, height: 0))
            
            tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        }
        
        
//        tblSearchResults.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tblSearchResults.register(PinTableViewCell.self, forCellReuseIdentifier: "PinCell")
        tblSearchResults.register(PlaceAndLocationTableViewCell.self, forCellReuseIdentifier: "PlaceAndLocationCell")
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.showsVerticalScrollIndicator = false
        tblSearchResults.backgroundColor = .clear
        //for auto layout
        tblSearchResults.rowHeight = UITableViewAutomaticDimension
        tblSearchResults.estimatedRowHeight = 340
        
        uiviewTableSubview.addSubview(tblSearchResults)
        self.view.addSubview(uiviewTableSubview)
        
        //Let the searchbar regisn the responser when tap outside(this view) of searchbar
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionResignResponserofSearchbar(_:)))
        uiviewTableSubview.addGestureRecognizer(tap)
        
        // Clear out the empty cells
        tblSearchResults.tableFooterView = UIView()
        
        
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return filteredArray.count
        
    }
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch tableTypeName {
            
        case "My Pins":
            tblSearchResults.backgroundColor = .clear
            uiviewTableSubview = UIView(frame: CGRect(x: 0, y: 66, width: resultTableWidth, height: 0))
            return 10
        case "Saved Pins":
            tblSearchResults.backgroundColor = .clear
            return 10
            
        default:
            tblSearchResults.backgroundColor = .white
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableTypeName {
            
        case "My Pins":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinTableViewCell
            cell.setValueForCell(_: filteredArray[indexPath.section])
            // Hide the separator line
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.layer.cornerRadius = 10.0
            cell.selectionStyle = .none
            return cell
        case "Saved Pins":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinTableViewCell
            cell.setValueForCell(_: filteredArray[indexPath.section])
            // Hide the separator line
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.layer.cornerRadius = 10.0
            cell.selectionStyle = .none
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceAndLocationCell", for: indexPath) as! PlaceAndLocationTableViewCell
            cell.setValueForCell(_: filteredArray[indexPath.section])
            // Hide the separator line
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 89.5, bottom: 0, right: 0)
            return cell
        }
    }
    
     
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("Your choice is \(filteredArray[indexPath.section])")
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if(tableView == self.tblSearchResults) {
////            let placesClient = GMSPlacesClient()
////            placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
////                (place, error) -> Void in
////                // Get place.coordinate
////                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
////                    (response, error) -> Void in
////                    if let selectedAddress = place?.coordinate {
////                        self.delegate?.animateToCameraFromMainScreenSearch(selectedAddress)
////                        self.dismiss(animated: false, completion: nil)
////                    }
////                })
////            })
////            self.faeSearchController.faeSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
//            self.faeSearchController.faeSearchBar.resignFirstResponder()
//            self.searchBarTableHideAnimation()
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }


}
