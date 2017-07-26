//
//  PinSearchViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/22/17.
//  Edited by Sophie Wang
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PinSearchViewController: CollectionSearchViewController, PinTableViewCellDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, PinDetailCollectionsDelegate {
    
    // initialize the cellInGivenId
    var cellCurrSwiped = PinsTableViewCell()
    var gesturerecognizerTouch: TouchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSearchResults.register(CreatedPinsTableViewCell.self, forCellReuseIdentifier: "CreatedPinCell")
        tblSearchResults.register(SavedPinsTableViewCell.self, forCellReuseIdentifier: "SavedPinCell")
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self

        uiviewBlurMainScreenSearch.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        // initialize the touch gesture
        gesturerecognizerTouch = TouchGestureRecognizer(target: self, action: #selector(handleAfterTouch))
        gesturerecognizerTouch.delegate = self
    }
    
    func handleAfterTouch(recognizer: TouchGestureRecognizer) {
        //remove the gesture after cell backs, or the gesture will always collect touches in the table
        tblSearchResults.removeGestureRecognizer(gesturerecognizerTouch)
    }
    
    // only the buttons in the siwped cell don't respond to the gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: cellCurrSwiped.uiviewSwipedBtnsView))! {
            return false
        }
        return true
    }
    
    //full pin detail delegate
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool, feelingArray: [Int]) {
//        if self.indexCurrSelectRowAt != nil {
//            var cellCurrSelect : PinsTableViewCell
//            if strTableTypeName == "Created Pins" {
//                cellCurrSelect = tblSearchResults.cellForRow(at: self.indexCurrSelectRowAt) as! CreatedPinsTableViewCell
//            }
//            else {
//                cellCurrSelect = tblSearchResults.cellForRow(at: self.indexCurrSelectRowAt) as! SavedPinsTableViewCell
//            }
//            cellCurrSelect.lblComment.text = commentCount
//            cellCurrSelect.lblLike.text = likeCount
//            if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
//                cellCurrSelect.imgHot.isHidden = false
//            }
//            else {
//                cellCurrSelect.imgHot.isHidden = true
//            }
//            arrFiltered[self.indexCurrSelectRowAt.section]["liked_count"] = Int(likeCount) as AnyObject
//            arrFiltered[self.indexCurrSelectRowAt.section]["comment_count"] = Int(commentCount) as AnyObject
//        }
    }
    
    func reloadPinContent(_ coordinate: CLLocationCoordinate2D) {
        //getPinsData()
    }
    
    //click cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!gesturerecognizerTouch.isCellSwiped) {
            tableView.deselectRow(at: indexPath, animated: false)
            
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.colDelegate = self
            PinDetailViewController.selectedMarkerPosition = arrMapPinFiltered[indexPath.section].position
            if strTableTypeName == "Created Pins" {
                PinDetailViewController.pinUserId = user_id
            }
            else {
                PinDetailViewController.pinUserId = arrMapPinFiltered[indexPath.section].userId
            }
            PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: arrMapPinFiltered[indexPath.section].type)!
            vcPinDetail.strTextViewText = arrMapPinFiltered[indexPath.section].content
            vcPinDetail.strPinId = "\(arrMapPinFiltered[indexPath.section].pinId)"
            vcPinDetail.enterMode = .collections
            
            self.present(vcPinDetail, animated: false, completion: {
                self.indexCurrSelectRowAt = indexPath
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if strTableTypeName == "Created Pins" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedPinCell", for: indexPath) as! CreatedPinsTableViewCell
            cell.delegate = self
            cell.indexForCurrentCell = indexPath.section
            cell.setValueForCell(arrMapPinFiltered[indexPath.section])
            cell.setImageConstraint()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPinCell", for: indexPath) as! SavedPinsTableViewCell
            cell.delegate = self
            cell.indexForCurrentCell = indexPath.section
            cell.setValueForCell(arrMapPinFiltered[indexPath.section])
            cell.setImageConstraint()
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMapPinFiltered.count
    }
    

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    // PinTableViewCellDelegate protocol required function
    func itemSwiped(indexCell: Int) {
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        if strTableTypeName == "Created Pins" {
//          cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! CreatedPinsTableViewCell
        }
        else {
            cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! SavedPinsTableViewCell
        }
        tblSearchResults.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String) {

    }
    
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String) {

    }
    
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String) {
        
    }
    
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String) {
        
    }
    
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String) {
        
    }
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String) {
    }

    
}
