//
//  OpenedPinTableViewControl.swift
//  faeBeta
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import RealmSwift

extension OpenedPinListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableOpenedPin {
//            print("number of cells is \(self.openedPinListArray.count)")
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
            let pinTypeID = openedPinListArray[indexPath.row]
            print("[OPLTableViewControl] pinInfo = \(pinTypeID) row = \(indexPath.row)")
            let pinID = pinTypeID.components(separatedBy: "%")[0]
            cell.pinID = pinID
            cell.indexPathInCell = indexPath
            
            let realm = try! Realm()
            if let opinListElem = realm.objects(OPinListElem.self).filter("pinTypeId == '\(pinID)'").first {
                cell.content.text = opinListElem.pinContent
                cell.time.text = opinListElem.pinTime
                cell.location = CLLocationCoordinate2DMake(opinListElem.pinLat+0.00148, opinListElem.pinLon)
                cell.deleteButton.isEnabled = true
                cell.jumpToDetail.isEnabled = true
            }
            let category = pinTypeID.components(separatedBy: "%")[1]
            cell.imageViewAvatar.image = placeCategory(placeType: category)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    fileprivate func placeCategory(placeType: String) -> UIImage {
        switch placeType {
        case "burgers":
            return #imageLiteral(resourceName: "openedPinBurger")
        case "pizza":
            return #imageLiteral(resourceName: "openedPinPizza")
        case "foodtrucks":
            return #imageLiteral(resourceName: "openedPinFoodtruck")
        case "coffee":
            return #imageLiteral(resourceName: "openedPinCoffee")
        case "desserts":
            return #imageLiteral(resourceName: "openedPinDessert")
        case "movietheaters":
            return #imageLiteral(resourceName: "openedPinCinema")
        case "beautysvc":
            return #imageLiteral(resourceName: "openedPinBeauty")
        case "playgrounds":
            return #imageLiteral(resourceName: "openedPinSport")
        case "museums":
            return #imageLiteral(resourceName: "openedPinArt")
        case "juicebars":
            return #imageLiteral(resourceName: "openedPinBoba")
        default:
            return UIImage()
        }
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
