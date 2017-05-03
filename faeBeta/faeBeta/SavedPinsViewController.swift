//
//  SavedPinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIKit.UIGestureRecognizerSubclass
//import SDWebImage
//import RealmSwift

class SavedPinsViewController: PinsViewController, UITableViewDataSource, PinDetailCollectionsDelegate{

    override func viewDidLoad() {
        strTableTitle = "Saved Pins"
        super.viewDidLoad()
    }
    
    // get the Saved Pins
    func getPinsData() {
        let getSavedPinsData = FaeMap()
        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get saved pins!")
                self.arrPinData.removeAll()
                let PinsOfSavedPinsJSON = JSON(message!)
                if PinsOfSavedPinsJSON.count > 0 {
                    for i in 0...(PinsOfSavedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        if let time = PinsOfSavedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject?
                        }
                        if let pinId = PinsOfSavedPinsJSON[i]["pin_id"].int{
                            dicCell["pin_id"] = pinId as AnyObject?
                        }
                        if let type = PinsOfSavedPinsJSON[i]["type"].string {
                            dicCell["type"] = type as AnyObject?
                        }
                        let pinObject = PinsOfSavedPinsJSON[i]["pin_object"]
                        if  pinObject != JSON.null{
                            //comment tab里面存的不叫description 叫content
                            if let content = pinObject["content"].string {
                                dicCell["content"] = content as AnyObject
                            }
                            //media tab里面存的不叫content 叫description
                            if let description = pinObject["description"].string {
                                dicCell["description"] = description as AnyObject
                            }
                            // 是否anonymous
                            if let anonymous = pinObject["anonymous"].bool {
                                dicCell["anonymous"] = anonymous as AnyObject
                            }
                            // nick_name
                            if let nick_name = pinObject["nick_name"].string {
                                dicCell["nick_name"] = nick_name as AnyObject
                            }
                            // user_id
                            if let user_id = pinObject["user_id"].int {
                                dicCell["user_id"] = user_id as AnyObject
                            }
                            if let latitude = pinObject["geolocation"]["latitude"].double, let longitude = pinObject["geolocation"]["longitude"].double {
                                dicCell["latitude"] = latitude as AnyObject
                                dicCell["longitude"] = longitude as AnyObject
                            }
                            
                            if let liked_count = pinObject["liked_count"].int {
                                dicCell["liked_count"] = liked_count as AnyObject
                            }
                            
                            if let comment_count = pinObject["comment_count"].int {
                                dicCell["comment_count"] = comment_count as AnyObject
                            }
                            
                            if let mediaImgArr = pinObject["file_ids"].array {
                                dicCell["file_ids"] = mediaImgArr as AnyObject?
                            }
                        }
                        self.arrPinData.append(dicCell)
                    }
                    self.tblPinsData.isHidden = false
                }else{
                    self.tblPinsData.isHidden = true
                }
                // reload the table when get the data
                self.tblPinsData.reloadData()
            }
            else {
                print("Fail to get saved pins!")
            }
        }
    }
    
    override func loadtblPinsData(){
        super.loadtblPinsData()
        tblPinsData.register(SavedPinsTableViewCell.self, forCellReuseIdentifier: "SavedPinCell")
        tblPinsData.delegate = self
        tblPinsData.dataSource = self
        getPinsData()
        labelEmptyTbl.text = "There are no Pins saved. Explore some more and save the Pins you like. :)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrPinData.count
    }
    
    //click cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!gesturerecognizerTouch.isCellSwiped){
            tableView.deselectRow(at: indexPath, animated: false)
            
            let pinDetailVC = PinDetailViewController()
            pinDetailVC.modalPresentationStyle = .overCurrentContext
            pinDetailVC.colDelegate = self
            PinDetailViewController.selectedMarkerPosition = CLLocationCoordinate2DMake(arrPinData[indexPath.section]["latitude"] as! CLLocationDegrees, arrPinData[indexPath.section]["longitude"] as! CLLocationDegrees)
            
            PinDetailViewController.pinTypeEnum = PinDetailViewController.PinType(rawValue: arrPinData[indexPath.section]["type"] as! String)!
            if let user_id = arrPinData[indexPath.section]["user_id"]{
                PinDetailViewController.pinUserId = user_id as! Int
            }
            if let content = arrPinData[indexPath.section]["content"] {
                pinDetailVC.strTextViewText = content as! String
            }
            //media tab里面存的不叫content 叫description
            if let description = arrPinData[indexPath.section]["description"] {
                pinDetailVC.strTextViewText = description as! String
            }
            if let pinID = arrPinData[indexPath.section]["pin_id"] {
                pinDetailVC.strPinId = "\(pinID)"
            }
            pinDetailVC.enterMode = .collections
            self.present(pinDetailVC, animated: false, completion: {
                self.indexCurrSelectRowAt = indexPath
            })
            
        }
    }
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPinCell", for: indexPath) as! SavedPinsTableViewCell
        cell.setValueForCell(_: arrPinData[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        return cell
    }
    
    //full pin detail delegate
    func backToCollections(likeCount: String, commentCount: String){
        if self.indexCurrSelectRowAt != nil {
            let cellCurrSelect = tblPinsData.cellForRow(at: self.indexCurrSelectRowAt) as! SavedPinsTableViewCell
            cellCurrSelect.lblComment.text = commentCount
            cellCurrSelect.lblLike.text = likeCount
            if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
                cellCurrSelect.imgHot.isHidden = false
            }else{
                cellCurrSelect.imgHot.isHidden = true
            }
            arrPinData[self.indexCurrSelectRowAt.section]["liked_count"] = Int(likeCount) as AnyObject
            arrPinData[self.indexCurrSelectRowAt.section]["comment_count"] = Int(commentCount) as AnyObject
            
        }
    }
    
    // PinTableViewCellDelegate protocol required function
    override func itemSwiped(indexCell: Int){
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
        self.tblPinsData.performUpdate({
            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
        }, completion: {
            self.tblPinsData.reloadData()
        })
        if self.arrPinData.count == 0 {
            self.tblPinsData.isHidden = true
        }
    }
    
    
    override func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    
    override func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){

    }
    
}



