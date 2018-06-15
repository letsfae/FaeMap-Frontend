//
//  MapBoardTableView.swift
//  FaeMapBoard
//
//  Created by vicky on 4/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension MapBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tblMapBoard.rowHeight = UITableViewAutomaticDimension
//        tblMapBoard.estimatedRowHeight = 200
        
        if tableMode == .people {
//            tblMapBoard.estimatedRowHeight = 90
            return 90
        } else if tableMode == .places {
            tblMapBoard.estimatedRowHeight = placeTableMode == .recommend ? 222 : 90
            return placeTableMode == .recommend ? 222 : 90
        }
        
        return 0 // tblMapBoard.rowHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableMode {
        case .people:
            return mbPeople.count
        case .places:
            if placeTableMode == .recommend {
                return testArrPlaces.count
            } else {
                return mbPlaces.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableMode == .people {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbPeopleCell", for: indexPath) as! MBPeopleCell
            
            let people = mbPeople[indexPath.row]
            
            var location: CLLocationCoordinate2D!
            if let loc = self.chosenLoc {
                location = loc
            } else {
                location = LocManager.shared.curtLoc.coordinate
            }
            let curtPos = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            cell.setValueForCell(people: people, curtLoc: curtPos)
            
            return cell
        } else if tableMode == .places {
            if placeTableMode == . recommend {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mbPlacesCell", for: indexPath) as! MBPlacesCell
                cell.delegate = self
                let title = arrTitle[indexPath.row]
                let placeCategory = testArrPlaces[indexPath.row]
                cell.places = placeCategory
//                cell.tableCellIndexPath = indexPath
                cell.setValueForCell(title: title, places: placeCategory)//, place: place, curtLoc: LocManager.shared.curtLoc)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
                let place = mbPlaces[indexPath.row]
                cell.setValueForCell(place: place) //, curtLoc: LocManager.shared.curtLoc)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.tblMapBoard.backgroundColor = .clear
        
        if tableMode == .people {
        } else if tableMode == .places {
            if placeTableMode == .search {
                let vcPlaceDetail = PlaceDetailViewController()
                vcPlaceDetail.place = mbPlaces[indexPath.row]
                navigationController?.pushViewController(vcPlaceDetail, animated: true)
            }
        }
    }
}
