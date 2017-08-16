//
//  PlaceDetailTableView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-15.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? uiviewSubHeader.frame.size.height : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? uiviewSubHeader : nil
//        return uiviewSubHeader
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section < 2 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tblPlaceDetail.rowHeight = UITableViewAutomaticDimension
        tblPlaceDetail.estimatedRowHeight = 60
        return indexPath.section == 3 ? 222 : tblPlaceDetail.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:   // place address
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection1Cell", for: indexPath) as! PlaceDetailSection1Cell
            cell.setValueForCell(place: place)
            return cell
        case 1:   // place opening hour
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection2Cell", for: indexPath) as! PlaceDetailSection2Cell
            cell.setValueForCell(place: place)
            return cell
        case 2:   // place website & place phone number
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection3Cell", for: indexPath) as! PlaceDetailSection3Cell
            cell.row = indexPath.row
            cell.setValueForCell(place: place)
            return cell
        case 3:   // similar / nearby places
            let cell = tableView.dequeueReusableCell(withIdentifier: "MBPlacesCell", for: indexPath) as! MBPlacesCell
            var places = [PlacePin]()
            places.append(place)
            places.append(place)
            
            cell.setValueForCell(title: arrTitle[indexPath.row], places: places)
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
            cell.imgDownArrow.image = cell.imgDownArrow.image == #imageLiteral(resourceName: "arrow_down") ? #imageLiteral(resourceName: "arrow_up") : #imageLiteral(resourceName: "arrow_down")
            cell.setCellContraints()
            tableView.reloadData()
        }
        
    }
    
}
