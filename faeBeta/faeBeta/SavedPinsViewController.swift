//
//  SavedPinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIKit.UIGestureRecognizerSubclass

class SavedPinsViewController: PinsViewController, UITableViewDataSource, PinDetailCollectionsDelegate {
    
    override func viewDidLoad() {
        strTableTitle = "Saved Pins"
        super.viewDidLoad()
    }
    
    override func loadTblPinsData() {
        super.loadTblPinsData()
        tblPinsData.register(SavedPinsTableViewCell.self, forCellReuseIdentifier: "savedPinCell")
        tblPinsData.delegate = self
        tblPinsData.dataSource = self
        getPinsData()
        lblEmptyTbl.text = "There are no Pins saved. Explore some more and save the Pins you like. :)"
    }
    
    func getPinsData() {
        let getSavedPinsData = FaeMap()
        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get saved pins!")
                self.arrMapPin.removeAll()
                let savedPinsJSON = JSON(message!)
                guard let arrSavedPins = savedPinsJSON.array else {
                    print("[savedPinsJSON] fail to parse saved pin!")
                    return
                }
                self.arrMapPin = arrSavedPins.map{MapPinCollections(json: $0)}
                self.tblPinsData.isHidden = !(self.arrMapPin.count > 0)
                self.tblPinsData.reloadData()
            }
            else {
                print("Fail to get saved pins!")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMapPin.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !gesturerecognizerTouch.isCellSwiped {
            tableView.deselectRow(at: indexPath, animated: false)
            
            let vcPinDetail = PinDetailViewController()
            vcPinDetail.modalPresentationStyle = .overCurrentContext
            vcPinDetail.colDelegate = self
            vcPinDetail.enterMode = .collections
            vcPinDetail.strPinId = "\(arrMapPin[indexPath.section].pinId)"
            vcPinDetail.strTextViewText = arrMapPin[indexPath.section].content
            PinDetailViewController.selectedMarkerPosition = arrMapPin[indexPath.section].position
            PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: arrMapPin[indexPath.section].type)!
            PinDetailViewController.pinUserId = arrMapPin[indexPath.section].userId
            
            self.indexCurrSelectRowAt = indexPath
            self.navigationController?.pushViewController(vcPinDetail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedPinCell", for: indexPath) as! SavedPinsTableViewCell
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        cell.setValueForCell(arrMapPin[indexPath.section])
        cell.setImageConstraint()
        return cell
    }
    
    // PinDetailCollectionsDelegate
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool) {
        
        if likeCount == "" || commentCount == "" || self.indexCurrSelectRowAt == nil {
            return
        }
        
        let cellCurrSelect = tblPinsData.cellForRow(at: self.indexCurrSelectRowAt) as! SavedPinsTableViewCell
        cellCurrSelect.lblCommentCount.text = commentCount
        cellCurrSelect.lblLikeCount.text = likeCount
        cellCurrSelect.imgLike.image = pinLikeStatus ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
        if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
            cellCurrSelect.imgHot.isHidden = false
        }
        else {
            cellCurrSelect.imgHot.isHidden = true
        }
        arrMapPin[self.indexCurrSelectRowAt.section].likeCount = Int(likeCount)!
        arrMapPin[self.indexCurrSelectRowAt.section].commentCount = Int(commentCount)!
        arrMapPin[self.indexCurrSelectRowAt.section].isLiked = pinLikeStatus
    }
    
    // PinTableViewCellDelegate protocol required function
    override func itemSwiped(indexCell: Int) {
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        cellCurrSwiped = tblPinsData.cellForRow(at: path) as! SavedPinsTableViewCell
        tblPinsData.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
        gesturerecognizerTouch.isCellSwiped = true
    }
    
    override func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String) {
        let unsaveSavedPin = FaePinAction()
        unsaveSavedPin.unsaveThisPin(pinType, pinID: pinId.description) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully unsave the pin!")
            }
        }
        self.arrPinData.remove(at: indexCell)
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexCell)
        self.tblPinsData.performUpdate( {
            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
        }, completion: {
            self.tblPinsData.reloadData()
        })
        if self.arrPinData.count == 0 {
            self.tblPinsData.isHidden = true
        }
    }
    
    override func toDoItemShared(indexCell: Int, pinId: Int, pinType: String) {
        
    }
    
    
    override func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String) {

    }
    
}
