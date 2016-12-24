//
//  OpenedPinTableViewControl.swift
//  faeBeta
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import CoreLocation
import SDWebImage

extension OpenedPinListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableOpenedPin {
            print("number of cells is \(self.openedPinListArray.count)")
            return self.openedPinListArray.count
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableOpenedPin {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openedPinCell", for: indexPath) as! OPLTableViewCell
            cell.delegate = self
            let pinInfo = openedPinListArray[indexPath.row]
            print("[OPLTableViewControl] pinInfo = \(pinInfo) row = \(indexPath.row)")
            let pinType = pinInfo.components(separatedBy: "%")[0]
            let pinID = pinInfo.components(separatedBy: "%")[1]
            cell.pinID = pinID
            cell.indexPathInCell = indexPath
            let getCommentById = FaeMap()
            // Bug: Currently, just comment
            getCommentById.getPin(type: pinType, pinId: pinID) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                if pinType == "comment"{
                    cell.imageViewAvatar.image = #imageLiteral(resourceName: "openedPinComment")
                }else if pinType == "media" {
                    cell.imageViewAvatar.image = #imageLiteral(resourceName: "openedPinMoment")
                }else if pinType == "chat_room" {
                    cell.imageViewAvatar.image = #imageLiteral(resourceName: "openedPinChat")
                }
                print("[OpenedPinListViewController tableView] json = \(pinInfoJSON), pinType = \(pinType), pinID = \(pinID)")
                if let time = pinInfoJSON["created_at"].string {
                    cell.time.text = time.formatFaeDate()
                }
                if let content = pinInfoJSON["content"].string {
                    cell.content.text = "\(content)"
                }else if let content = pinInfoJSON["description"].string {
                    cell.content.text = "\(content)"
                }else if (pinInfoJSON["description"].stringValue == "") && (pinInfoJSON["file_ids"].arrayValue.count != 0) {
                    cell.content.text = "\(pinInfoJSON["file_ids"].arrayValue.count) Photos"
                }
                if let latitudeInfo = pinInfoJSON["geolocation"]["latitude"].double {
                    if let longitudeInfo = pinInfoJSON["geolocation"]["longitude"].double {
                        cell.location = CLLocationCoordinate2DMake(latitudeInfo+0.00148, longitudeInfo)
                    }
                }
                cell.deleteButton.isEnabled = true
                cell.jumpToDetail.isEnabled = true
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
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableOpenedPin {
            return 76
        }
        else{
            return 0
        }
    }
}
