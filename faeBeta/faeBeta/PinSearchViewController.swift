//
//  PinSearchViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/22/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PinSearchViewController: CollectionSearchViewController, PinTableViewCellDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, EditPinViewControllerDelegate, PinDetailCollectionsDelegate {
    
    // initialize the cellInGivenId
    var cellCurrSwiped = PinsTableViewCell()
    var gesturerecognizerTouch: TouchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSearchResults.register(CreatedPinsTableViewCell.self, forCellReuseIdentifier: "CreatedPinCell")
        tblSearchResults.register(SavedPinsTableViewCell.self, forCellReuseIdentifier: "SavedPinCell")
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self

        blurViewMainScreenSearch.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
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
    func backToCollections(likeCount: String, commentCount: String){
        if self.indexCurrSelectRowAt != nil {
            var cellCurrSelect : PinsTableViewCell
            if strTableTypeName == "Created Pins" {
                cellCurrSelect = tblSearchResults.cellForRow(at: self.indexCurrSelectRowAt) as! CreatedPinsTableViewCell
            }else{
                cellCurrSelect = tblSearchResults.cellForRow(at: self.indexCurrSelectRowAt) as! SavedPinsTableViewCell
            }
            cellCurrSelect.lblComment.text = commentCount
            cellCurrSelect.lblLike.text = likeCount
            if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
                cellCurrSelect.imgHot.isHidden = false
            }else{
                cellCurrSelect.imgHot.isHidden = true
            }
            arrFiltered[self.indexCurrSelectRowAt.section]["liked_count"] = Int(likeCount) as AnyObject
            arrFiltered[self.indexCurrSelectRowAt.section]["comment_count"] = Int(commentCount) as AnyObject
        }
    }
    
    func reloadPinContent(_ coordinate: CLLocationCoordinate2D, zoom: Float) {
        //getPinsData()
    }
    
    //click cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!gesturerecognizerTouch.isCellSwiped){
            tableView.deselectRow(at: indexPath, animated: false)
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.colDelegate = self
            PinDetailViewController.selectedMarkerPosition = CLLocationCoordinate2DMake(arrFiltered[indexPath.section]["latitude"] as! CLLocationDegrees, arrFiltered[indexPath.section]["longitude"] as! CLLocationDegrees)
            if strTableTypeName == "Created Pins" {
                PinDetailViewController.pinUserId = user_id as Int
            }else{
                if let user_id = arrFiltered[indexPath.section]["user_id"]{
                    PinDetailViewController.pinUserId = user_id as! Int
                }
            }
            PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: arrFiltered[indexPath.section]["type"] as! String)!
            
            if let content = arrFiltered[indexPath.section]["content"] {
                pinDetailVC.strTextViewText = content as! String
            }
            //media tab里面存的不叫content 叫description
            if let description = arrFiltered[indexPath.section]["description"] {
                pinDetailVC.strTextViewText = description as! String
            }
            
            if let pinID = arrFiltered[indexPath.section]["pin_id"] {
                pinDetailVC.strPinId = "\(pinID)"
            }
            
            pinDetailVC.enterMode = .collections
            self.present(pinDetailVC, animated: false, completion: {
                self.indexCurrSelectRowAt = indexPath
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : PinsTableViewCell
        if strTableTypeName == "Created Pins" {
            cell = tableView.dequeueReusableCell(withIdentifier: "CreatedPinCell", for: indexPath) as! CreatedPinsTableViewCell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "SavedPinCell", for: indexPath) as! SavedPinsTableViewCell
        }
        cell.setValueForCell(_: arrFiltered[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrFiltered.count
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
    func itemSwiped(indexCell: Int){
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        if strTableTypeName == "Created Pins" {
        cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! CreatedPinsTableViewCell
        }else{
        cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! SavedPinsTableViewCell
        }
        tblSearchResults.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String){
//        let deleteMyPin = FaeMap()
//        deleteMyPin.deletePin(type: pinType, pinId: pinId.description) {(status: Int, message: Any?) in
//            if status / 100 == 2 {
//                print("Successfully delete the pin!")
//            }
//        }
//        self.arrPinData.remove(at: indexCell)
//        let indexSet = NSMutableIndexSet()
//        indexSet.add(indexCell)
//        self.tblPinsData.performUpdate({
//            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
//        }, completion: {
//            self.tblPinsData.reloadData()
//        })
//        if self.arrPinData.count == 0 {
//            self.tblPinsData.isHidden = true
//        }
    }
    
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String){
//        if pinId == -999 {
//            return
//        }
//        let editPinVC = EditPinViewController()
//        //        editPinVC.zoomLevel = zoomLevel
//        editPinVC.delegate = self
//        
//        if(pinType == "comment"){
//            editPinVC.previousCommentContent = arrPinData[indexCell]["content"] as! String
//            editPinVC.editPinMode = .comment
//        }
//        if(pinType == "media"){
//            editPinVC.previousCommentContent = arrPinData[indexCell]["description"] as! String
//            
//            var mediaIdArray : [Int] = []
//            let fileIDs = arrPinData[indexCell]["file_ids"] as! NSArray
//            for index in 0...fileIDs.count-1 {
//                mediaIdArray.append(Int(String(describing: fileIDs[index]))!)
//            }
//            editPinVC.mediaIdArray = mediaIdArray
//            
//            editPinVC.editPinMode = .media
//        }
//        editPinVC.pinID = "\(pinId)"
//        editPinVC.pinType = pinType
//        editPinVC.pinMediaImageArray = cellCurrSwiped.arrImgPinPic
//        editPinVC.pinGeoLocation = CLLocationCoordinate2D(latitude: arrPinData[indexCell]["latitude"] as! CLLocationDegrees, longitude: arrPinData[indexCell]["longitude"] as! CLLocationDegrees)
//        
//        
//        
//        self.present(editPinVC, animated: true, completion: {
//            self.tblPinsData.reloadData()
//        })
    }
    
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){
        
    }
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String){
    }

    
}
