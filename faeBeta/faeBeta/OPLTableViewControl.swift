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
            let pinID = openedPinListArray[indexPath.row]
            cell.pinID = pinID
            cell.indexPathInCell = indexPath
            let getCommentById = FaeMap()
            // Bug: Currently, just comment
            getCommentById.getPin(type: "comment", pinId: "\(pinID)") {(status: Int, message: Any?) in
                let commentInfoJSON = JSON(message!)
                if let userid = commentInfoJSON["user_id"].int {
                    let stringHeaderURL = "\(baseURL)/files/users/\(userid)/avatar"
                    cell.imageViewAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
                }
                print(commentInfoJSON)
                if let time = commentInfoJSON["created_at"].string {
                    cell.time.text = time.formatFaeDate()
                }
                if let content = commentInfoJSON["content"].string {
                    cell.content.text = "\(content)"
                }
                if let latitudeInfo = commentInfoJSON["geolocation"]["latitude"].double {
                    if let longitudeInfo = commentInfoJSON["geolocation"]["longitude"].double {
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
