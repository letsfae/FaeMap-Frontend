//
//  EditOptionHandleDelegate.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension EditMoreOptionsViewController: UITableViewDelegate, UITableViewDataSource, SelectLocationViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreOption", for: indexPath) as! EditOptionTableViewCell
        if pinType == "comment" {
            return loadCellForComment(cell: cell, indexPath: indexPath)
        }else if pinType == "media" {
            return loadCellForMedia(cell: cell, indexPath: indexPath)
        }else if pinType == "chat_room" {
            return loadCellForChat(cell: cell, indexPath: indexPath)
        }else {
            return cell
        }
    }
    
    func loadCellForChat(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.setup(middleText: "Location", trailingText: nil, trailingImagePlus: false)
        case 1:
            cell.setup(middleText: "Add Tags", trailingText: nil, trailingImagePlus: true)
        case 2:
            cell.setup(middleText: "Room Capacity", trailingText: "50", trailingImagePlus: nil)
        case 3:
            cell.setup(middleText: "Duration on Map", trailingText: "3HR", trailingImagePlus: nil)
        case 4:
            cell.setup(middleText: "Interaction Radius", trailingText: "C.S", trailingImagePlus: nil)
        case 5:
            cell.setup(middleText: "Pin Promotions", trailingText: "C.S", trailingImagePlus: nil)
        default:
            print("Wrong Row")
        }
        cell.imageLeft.image = UIImage(named: "EditOption\(self.optionImageArray[indexPath.row])")
        return cell
    }
    
    func loadCellForComment(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.setup(middleText: "Location", trailingText: nil, trailingImagePlus: false)
        case 1:
            cell.setup(middleText: "Duration on Map", trailingText: "3HR", trailingImagePlus: nil)
        case 2:
            cell.setup(middleText: "Interaction Radius", trailingText: "C.S", trailingImagePlus: nil)
        case 3:
            cell.setup(middleText: "Pin Promotions", trailingText: "C.S", trailingImagePlus: nil)
        default:
            print("Wrong Row")
        }
        cell.imageLeft.image = UIImage(named: "EditOption\(self.optionImageArray[indexPath.row])")
        return cell
    }
    
    func loadCellForMedia(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.setup(middleText: "Location", trailingText: nil, trailingImagePlus: false)
        case 1:
            cell.setup(middleText: "Tags", trailingText: nil, trailingImagePlus: true)
        case 2:
            cell.setup(middleText: "Duration on Map", trailingText: "3HR", trailingImagePlus: nil)
        case 3:
            cell.setup(middleText: "Interaction Radius", trailingText: "C.S", trailingImagePlus: nil)
        case 4:
            cell.setup(middleText: "Pin Promotions", trailingText: "C.S", trailingImagePlus: nil)
        default:
            print("Wrong Row")
        }
        cell.imageLeft.image = UIImage(named: "EditOption\(self.optionImageArray[indexPath.row])")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionImageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableMoreOptions {
            switch pinType {
            case "comment":
                switch indexPath.row {
                case 0:
                    actionSelectLocation()
                    break
                case 1:
                    break
                case 2:
                    break
                case 3:
                    break
                default:
                    break
                }
            case "media":
                switch indexPath.row {
                case 0:
                    actionSelectLocation()
                    break
                case 1:
                    break
                case 2:
                    break
                case 3:
                    break
                case 4:
                    break
                default:
                    break
                }
            case "chat_room":
                switch indexPath.row {
                case 0:
                    actionSelectLocation()
                    break
                case 1:
                    break
                case 2:
                    break
                case 3:
                    break
                case 4:
                    break
                case 5:
                    break
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    //Select Location Delegate
    func sendAddress(_ value: String) {
        let index = NSIndexPath.init(row: 0, section: 0)
        let cell = tableMoreOptions.cellForRow(at: index as IndexPath) as! EditOptionTableViewCell
        cell.labelMiddle.text = value
    }
    
    func sendGeoInfo(_ latitude: String, longitude: String, zoom: Float) {
        self.pinGeoLocation = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        zoomLevel = zoom
        self.delegate?.sendMapCameraInfo(latitude: latitude, longitude: longitude, zoom: zoom)
    }
}
