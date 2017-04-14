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

extension OpenedPinListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableOpenedPin {
            return OpenedPlaces.openedPlaces.count
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableOpenedPin {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openedPinCell", for: indexPath) as! OPLTableViewCell
            
            cell.delegate = self
            cell.pinID = OpenedPlaces.openedPlaces[indexPath.row].pinId
            cell.indexPathInCell = indexPath
            cell.content.text = OpenedPlaces.openedPlaces[indexPath.row].title
            cell.time.text = OpenedPlaces.openedPlaces[indexPath.row].pinTime
            cell.location = OpenedPlaces.openedPlaces[indexPath.row].position
            cell.deleteButton.isEnabled = true
            cell.jumpToDetail.isEnabled = true
            cell.imageViewAvatar.image = placeCategory(placeType: OpenedPlaces.openedPlaces[indexPath.row].category)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    fileprivate func placeCategory(placeType: String) -> UIImage? {
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
            return nil
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
