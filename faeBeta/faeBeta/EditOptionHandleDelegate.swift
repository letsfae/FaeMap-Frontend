//
//  EditOptionHandleDelegate.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension EditMoreOptionsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreOption", for: indexPath) as! EditOptionTableViewCell
        if pinType == "comments" {
            return loadCellForComment(cell: cell, indexPath: indexPath)
        }else if pinType == "medias" {
            return loadCellForMedia(cell: cell, indexPath: indexPath)
        }else if pinType == "chat_rooms" {
            return loadCellForChat(cell: cell, indexPath: indexPath)
        }else {
            return cell
        }
    }
    
    func loadCellForChat(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.labelMiddle.text = "pinLocation"
            cell.imageRight01.isHidden = false
        case 1:
            cell.labelMiddle.text = "Add Tags"
            cell.imageRight02.isHidden = false
        case 2:
            cell.labelMiddle.text = "Room Capacity"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "50"
        case 3:
            cell.labelMiddle.text = "Duration on Map"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "3HR"
        case 4:
            cell.labelMiddle.text = "Interaction Radius"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
        case 5:
            cell.labelMiddle.text = "Pin Promotions"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
        default:
            print("Wrong Row")
        }
        cell.imageLeft.image = UIImage(named: "EditOption\(self.optionImageArray[indexPath.row])")
        return cell
    }
    
    func loadCellForComment(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.labelMiddle.text = "pinLocation"
            cell.imageRight01.isHidden = false
        case 1:
            cell.labelMiddle.text = "Duration on Map"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "3HR"
        case 2:
            cell.labelMiddle.text = "Interaction Radius"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
        case 3:
            cell.labelMiddle.text = "Pin Promotions"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
        default:
            print("Wrong Row")
        }
        cell.imageLeft.image = UIImage(named: "EditOption\(self.optionImageArray[indexPath.row])")
        return cell
    }
    
    func loadCellForMedia(cell: EditOptionTableViewCell, indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            cell.labelMiddle.text = "pinLocation"
            cell.imageRight01.isHidden = false
        case 1:
            cell.labelMiddle.text = "Tags"
            cell.imageRight02.isHidden = false
        case 2:
            cell.labelMiddle.text = "Duration on Map"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "3HR"
        case 3:
            cell.labelMiddle.text = "Interaction Radius"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
        case 4:
            cell.labelMiddle.text = "Pin Promotions"
            cell.labelRight.isHidden = false
            cell.labelRight.text = "C.S"
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
}
