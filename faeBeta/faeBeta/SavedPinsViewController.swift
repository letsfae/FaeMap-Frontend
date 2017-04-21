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


class SavedPinsViewController: PinsViewController, UITableViewDataSource{
    
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
                    self.hideOrShowTable(true)
                }else{
                    self.hideOrShowTable(false)
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

        imgEmptyTbl.image = #imageLiteral(resourceName: "empty_savedpins_bg")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrPinData.count
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
    
    // PinTableViewCellDelegate protocol required function
    override func itemSwiped(indexCell: Int){
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        cellCurrSwiped = tblPinsData.cellForRow(at: path) as! SavedPinsTableViewCell
        tblPinsData.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    override func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String) {
        let deleteMyPin = FaeMap()
        deleteMyPin.unsavePin(type: pinType, pinId: pinId.description) {(status: Int, message: Any?) in
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
        if(self.arrPinData.count == 0){
            hideOrShowTable(false)
        }
    }
    
    
    override func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    
    override func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
}



