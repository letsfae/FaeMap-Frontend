//
//  TableViewDelegateFile.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate {
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRectMake(0, 0, 398, 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.registerClass(CustomCellForAddressSearch.self, forCellReuseIdentifier: "customCellForAddressSearch")
        tblSearchResults.scrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsetsZero
        tblSearchResults.layoutMargins = UIEdgeInsetsZero
        uiviewTableSubview.layer.borderColor = UIColor.whiteColor().CGColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 5.0
        uiviewTableSubview.layer.shadowColor = UIColor.blackColor().CGColor
        uiviewTableSubview.addSubview(tblSearchResults)
        UIApplication.sharedApplication().keyWindow?.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == tableviewMore {
            return 1
        }
        else if tableView == tableviewWindbell{
            return 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults) {
            return placeholder.count
        }
        else if(tableView == self.mapChatTable) {
            return 10
        }
        else if tableView == tableviewMore {
            return 7
        }
        else if tableView == tableviewWindbell {
            return tableWindbellData.count
        }
        else if tableView == tableCommentsForComment {
            return numberOfCommentTableCells
        }
        else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tblSearchResults {
            let cell = tableView.dequeueReusableCellWithIdentifier("customCellForAddressSearch", forIndexPath: indexPath) as! CustomCellForAddressSearch
            cell.labelCellContent.text = placeholder[indexPath.row].attributedFullText.string
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else if tableView == self.tableCommentsForComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentPinCommentsCell", forIndexPath: indexPath) as! CommentPinCommentsCell
            let dictCell = JSON(dictCommentsOnCommentDetail[indexPath.row])
            if let username = dictCell["user_id"].int {
                cell.labelUsername.text = "\(username)"
            }
            if let date = dictCell["date"].string {
                cell.labelTimestamp.text = date
            }
            if let content = dictCell["content"].string {
                cell.textViewComment.text = content
            }
            cell.imageViewAvatar.image = UIImage(named: "Eddie Gelfen")
            
//            if indexPath.row == 0 {
//                cell.labelUsername.text = "The Kid"
//                cell.labelTimestamp.text = "September 23, 2015"
//                cell.textViewComment.text = "LOL what are you talking abouta???"
//                cell.imageViewAvatar.image = UIImage(named: "Eddie Gelfen")
//            }
//            else if indexPath.row == 1 {
//                cell.labelUsername.text = "Boogie Woogie Woogie"
//                cell.labelTimestamp.text = "September 23, 2015"
//                cell.textViewComment.text = "I understand perfectly @___@"
//                cell.imageViewAvatar.image = UIImage(named: "Ted Logan")
//            }
//            else if indexPath.row == 2 {
//                cell.labelUsername.text = "Boogie Woogie Woogie"
//                cell.labelTimestamp.text = "September 23, 2015"
//                cell.textViewComment.text = "HI HI HI"
//                cell.imageViewAvatar.image = UIImage(named: "Ted Logan")
//            }
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else if tableView == self.mapChatTable {
            let cell = tableView.dequeueReusableCellWithIdentifier("mapChatTableCell", forIndexPath: indexPath) as! MapChatTableCell
            cell.layoutMargins = UIEdgeInsetsMake(0, 84, 0, 0)
            return cell
        }
        else if tableView == tableviewMore {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellTableViewMore, forIndexPath: indexPath)as! MoreVisibleTableViewCell
            cell.selectionStyle = .None
            if indexPath.row == 0 {
                cell.switchInvisible.hidden = false
                cell.labelTitle.text = "Go Invisible"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell0")
                
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Mood Avatar"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell1")
                
            } else if indexPath.row == 2 {
                cell.labelTitle.text = "My Pins"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell2")
            } else if indexPath.row == 3 {
                cell.labelTitle.text = "Saved"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell3")
            } else if indexPath.row == 4 {
                cell.labelTitle.text = "Name Cards"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell4")
            } else if indexPath.row == 5 {
                cell.labelTitle.text = "Map Board"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell5")
            } else if indexPath.row == 6 {
                cell.labelTitle.text = "Account Settings"
                cell.imageViewTitle.image = UIImage(named: "tableViewMoreCell6")
            }
            return cell
            
        }
        else if tableView == self.tableviewWindbell{
            let cell = tableView.dequeueReusableCellWithIdentifier("windbelltablecell", forIndexPath: indexPath)as! WindBellTableViewCell
            cell.selectionStyle = .None
            cell.labelTitle.text = tableWindbellData[indexPath.row]["Title"]
            cell.labelContent.text = tableWindbellData[indexPath.row]["Content"]
            cell.labelTime.text = tableWindbellData[indexPath.row]["Time"]
            return cell
            
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == self.tblSearchResults){
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
                (place, error) -> Void in
                // Get place.coordinate
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        let camera = GMSCameraPosition.cameraWithTarget(selectedAddress, zoom: self.faeMapView.camera.zoom)
                        self.faeMapView.animateToCameraPosition(camera)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if mainScreenSearchActive {
                animationMainScreenSearchHide(self.mainScreenSearchSubview)
            }
        }
        else if tableView == tableviewMore {
            if indexPath.row == 1 {
                animationMoreHide(nil)
                jumpToMoodAvatar()
            }
            if indexPath.row == 2 {
                animationMoreHide(nil)
                jumpToMyPins()
            }
            if indexPath.row == 4 {
                animationMoreHide(nil)
                jumpToNameCard()
            }
            if indexPath.row == 6 {
                animationMoreHide(nil)
                jumpToAccount()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults){
            return 48.0
        }
        else if tableView == self.mapChatTable {
            return 75.0
        }
        else if tableView == tableviewMore {
            return 60
        }
        else if tableView == tableviewWindbell{
            return 82
        }
        else if tableView == self.tableCommentsForComment {
            return 140
        }
        else{
            return 0
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func configureCustomSearchController() {
        searchBarSubview = UIView(frame: CGRectMake(8, 23, 398, 48.0))
        
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0, 5, 398, 38.0), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18.0)!, searchBarTextColor: colorFae, searchBarTintColor: UIColor.whiteColor())
        customSearchController.customSearchBar.placeholder = "Search Address or Place                                  "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(searchBarSubview)
        
        searchBarSubview.layer.borderColor = UIColor.whiteColor().CGColor
        searchBarSubview.layer.borderWidth = 1.0
        searchBarSubview.layer.cornerRadius = 2.0
        searchBarSubview.layer.shadowOpacity = 0.5
        searchBarSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        searchBarSubview.layer.shadowRadius = 5.0
        searchBarSubview.layer.shadowColor = UIColor.blackColor().CGColor
        
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: CustomSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        customSearchController.customSearchBar.becomeFirstResponder()
        if middleTopActive {
            UIView.animateWithDuration(0.25, animations: ({
                self.blurViewMainScreenSearch.alpha = 1.0
            }))
            middleTopActive = false
        }
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
                        let camera = GMSCameraPosition.cameraWithTarget(selectedAddress, zoom: self.faeMapView.camera.zoom)
                        self.faeMapView.animateToCameraPosition(camera)
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
    
    func didChangeSearchText(searchText: String) {
        if(searchText != "") {
            let placeClient = GMSPlacesClient()
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
                (results, error : NSError?) -> Void in
                if(error != nil) {
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
            }
            if placeholder.count > 0 {
                searchBarTableShowAnimation()
            }
        }
        else {
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
}
