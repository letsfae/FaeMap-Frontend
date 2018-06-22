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
        switch tableView {
        case tblPeople:
            return viewModelPeople.hasUsers ? 90 : tableView.frame.size.height
        case tblPlaceLeft:
            return 222
        case tblPlaceRight:
            return viewModelPlaces.hasPlaces ? 90 : tableView.frame.size.height
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tblPeople:
            
            return viewModelPeople.hasUsers ? viewModelPeople.numberOfUsers : 1
        case tblPlaceLeft:
                return viewModelCategories.numberOfCategories
        case tblPlaceRight:
            return viewModelPlaces.hasPlaces ? viewModelPlaces.numberOfPlaces : 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case tblPeople:
            if !boolUsrVisibleIsOn {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BoardNoResultCell", for: indexPath) as! BoardNoResultCell
                let hint = "Oops, you are invisible right now, turn off invisibility to discover :)"
                cell.setValueForCell(hint: hint)
                return cell
            }
            
            if !viewModelPeople.hasUsers {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BoardNoResultCell", for: indexPath) as! BoardNoResultCell
                let hint = "We couldn't find any matches nearby. Please try a different setting! :)"
                cell.setValueForCell(hint: hint)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPeopleCell", for: indexPath) as! BoardPeopleCell
                if let people = viewModelPeople.viewModel(for: indexPath.row) {
                    cell.setValueForCell(people: people)
                }
                return cell
            }
        case tblPlaceLeft:
            if viewModelCategories.numberOfCategories <= 0 {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "BoardPlacesCell", for: indexPath) as! BoardPlacesCell
            cell.delegate = self
            
            let title = ""//viewModelCategories.arrTitle[indexPath.row]
            
            if let placeCategory = viewModelCategories.viewModel(for: indexPath.row) {
                cell.setValueForCell(title: title, viewModelPlaces: placeCategory)
            }
            
//            let title = arrTitle[indexPath.row]
//            let placeCategory = testArrPlaces[indexPath.row]
//            cell.places = placeCategory
            //                cell.tableCellIndexPath = indexPath
//            cell.setValueForCell(title: title, places: placeCategory)//, place: place, curtLoc: LocManager.shared.curtLoc)
            return cell
        case tblPlaceRight:
            if !viewModelPlaces.hasPlaces {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BoardNoResultCell", for: indexPath) as! BoardNoResultCell
                let hint = "Sorry! We couldn't find any matching Results. Please try a different search!"
                cell.setValueForCell(hint: hint)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
                if let place = viewModelPlaces?.viewModel(for: indexPath.row) {
                    cell.setValueForCell(place: place)
                }
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.backgroundColor = .clear
        
        switch tableView {
        case tblPeople:
            if !viewModelPeople.hasUsers {
                break
            }
            if let viewModelUserInfo = viewModelPeople?.viewModel(for: indexPath.row) {
                uiviewNameCard.userId = viewModelUserInfo.people.userId
            }
            uiviewNameCard.show {}
            break
        case tblPlaceRight:
            if !viewModelPlaces.hasPlaces {
                break
            }
            let vcPlaceDetail = PlaceDetailViewController()
            if let viewModelPlace = viewModelPlaces?.viewModel(for: indexPath.row) {
                vcPlaceDetail.place = viewModelPlace.place
            }
            
            navigationController?.pushViewController(vcPlaceDetail, animated: true)
            break
        default:
            break
        }
    }
}