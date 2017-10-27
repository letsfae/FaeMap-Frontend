//
//  PlaceDetailTableView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-15.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate, PlaceDetailSmallMapCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {
            return 1
        } else if section == 2 {
            return 2
        } else {
            return 2  //arrRelatedPlaces.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tblPlaceDetail.rowHeight = UITableViewAutomaticDimension
        tblPlaceDetail.estimatedRowHeight = 60
        return indexPath.section == 3 ? 222 : tblPlaceDetail.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:   // place address
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection1Cell", for: indexPath) as! PlaceDetailMapCell
            cell.delegate = self
            cell.setValueForCell(place: place)
            return cell
        case 1:   // place opening hour
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection2Cell", for: indexPath) as! PlaceDetailHoursCell
            cell.setValueForCell(place: place)
            return cell
        case 2:   // place website & place phone number
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection3Cell", for: indexPath) as! PlaceDetailSection3Cell
            cell.row = indexPath.row
            cell.setValueForCell(place: place)
            return cell
        case 3:   // similar / nearby places
             let cell = tableView.dequeueReusableCell(withIdentifier: "MBPlacesCell", for: indexPath) as! MBPlacesCell
            if arrRelatedPlaces.count != 0 {
                cell.delegate = self
                let places = arrRelatedPlaces[indexPath.row]
                cell.setValueForCell(title: arrTitle[indexPath.row], places: places)
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 || section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! PlaceDetailCell
            PlaceDetailCell.boolFold = cell.imgDownArrow.image == #imageLiteral(resourceName: "arrow_up")
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        } else if section == 2 {   // open place website / call place phone number
            let phoneNum = "2098299986"
            let strURL = indexPath.row == 0 ? "https://www.faemaps.com/" : "tel://\(phoneNum)"
            if let url = URL(string: strURL), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func jumpToMainMapWithPlace() {
        delegate?.jumpToOnePlace?(searchText: "fromPlaceDetail", place: self.place)
        navigationController?.popViewController(animated: false)
    }
}
