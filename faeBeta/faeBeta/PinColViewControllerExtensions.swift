//
//  ViewControllerExtensions.swift
//  faeBeta
//
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinColViewController: UITableViewDataSource,UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height = 153 + 40*indexPath
//        getTextHeight()
//        return CGFloat(height)
//        self.datasource
//    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        switch currentTitle {
            
        case "My Pins":

            filteredArr = myPinDataArr

        case "Saved Pins":

            filteredArr = savedPinDataArr

        case "Saved Places":

            filteredArr = placeDataArr

        case "Saved Locations":

            filteredArr = locationDataArr
            
        // default is required, but never to be called here
        default:

            filteredArr = myPinDataArr

        }
            return filteredArr.count

    }
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch currentTitle {
            
        case "My Pins":
            TblResult.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
            return 10
        case "Saved Pins":
            TblResult.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
            return 10

        default:
            TblResult.backgroundColor = .white
            return 0
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        switch currentTitle {
        
        case "My Pins":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinTableViewCell
            cell.setValueForCell(_: filteredArr[indexPath.section])
            // Hide the separator line
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.layer.cornerRadius = 10.0
            cell.selectionStyle = .none
            return cell
        case "Saved Pins":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinTableViewCell
            cell.setValueForCell(_: filteredArr[indexPath.section])
            // Hide the separator line
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            cell.layer.cornerRadius = 10.0
            cell.selectionStyle = .none
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceAndLocationCell", for: indexPath) as! PlaceAndLocationTableViewCell
            cell.setValueForCell(_: filteredArr[indexPath.section])
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 89.5, bottom: 0, right: 0)
            
            if(tableView.isEditing && self.tableView(tableView, canEditRowAt: indexPath))
            {
                cell.distance.isHidden = true
                cell.btnSelected.isHidden = false
                cell.btnSelected.tag = indexPath.section //因为每个section只有一个row
                cell.btnSelected.addTarget(self, action: #selector(self.actionSelectBtnInCell(_:)), for: .touchUpInside)
                if(arrSelectedItem.contains(indexPath.section)){
                    cell.btnSelected.layer.borderColor = UIColor.faeAppRedColor().cgColor
                    cell.btnSelected.layer.backgroundColor = UIColor.faeAppRedColor().cgColor
                }
                else{
                    cell.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
                    cell.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
                    
                }

            }
            else
            {
                cell.distance.isHidden = false
                cell.btnSelected.isHidden = true
            }
            
            return cell
        }
    }
    
    
    // This function is the action function for the select button in the cell when the table is editable
    func actionSelectBtnInCell(_ sender: UIButton){
        
        let sectionId = sender.tag

        let path : IndexPath = IndexPath(row: 0, section: sectionId)
        let  cellInGivenId : PlaceAndLocationTableViewCell = TblResult.cellForRow(at: path) as!   PlaceAndLocationTableViewCell
        
        if(!arrSelectedItem.contains(sectionId)){
            arrSelectedItem.append(sectionId)
            cellInGivenId.btnSelected.layer.borderColor = UIColor.faeAppRedColor().cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor.faeAppRedColor().cgColor
        }
        else{
        arrSelectedItem.remove(at: arrSelectedItem.index(of: sectionId)!)
            cellInGivenId.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
        
        }
        
    }
    func actionBtnShare(_ sender: UIButton){
        // share
    
    
    }
    func actionBtnRemove(_ sender: UIButton){
        //Remove
        arrSelectedItem.sort {$0 > $1}  //倒序排序，这样保证原数据删除的时候是倒着删 不打乱顺序
    
        for item in arrSelectedItem{
            
            switch currentTitle {
                
            case "Saved Places":
                placeDataArr.remove(at: item)
                arrSelectedItem.removeLast()
                
            case "Saved Locations":
                locationDataArr.remove(at: item)
                arrSelectedItem.removeLast()
                
            default: break
                
            }

            
            
            filteredArr.remove(at: item)
        }
        TblResult.reloadData()
        
        
    }
    
    
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("Your choice is \(filteredArr[indexPath.section])")
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
}
