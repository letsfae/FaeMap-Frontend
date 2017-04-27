//
//  PinSearchViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/22/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PinSearchViewController: CollectionSearchViewController, PinTableViewCellDelegate, UIGestureRecognizerDelegate, UITableViewDataSource {
    
    // initialize the cellInGivenId
    var cellCurrSwiped = PinsTableViewCell()
    var gesturerecognizerTouch: TouchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSearchResults.register(CreatedPinsTableViewCell.self, forCellReuseIdentifier: "CreatedPinCell")
        tblSearchResults.register(SavedPinsTableViewCell.self, forCellReuseIdentifier: "SavedPinCell")
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self

        blurViewMainScreenSearch.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        // initialize the touch gesture
        gesturerecognizerTouch = TouchGestureRecognizer(target: self, action: #selector(handleAfterTouch))
        gesturerecognizerTouch.delegate = self

        
    }
    
    func handleAfterTouch(recognizer: TouchGestureRecognizer) {
        //remove the gesture after cell backs, or the gesture will always collect touches in the table
        tblSearchResults.removeGestureRecognizer(gesturerecognizerTouch)
    }
    
    // only the buttons in the siwped cell don't respond to the gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: cellCurrSwiped.uiviewSwipedBtnsView))! {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : PinsTableViewCell
        if tableTypeName == "Created Pins" {
            cell = tableView.dequeueReusableCell(withIdentifier: "CreatedPinCell", for: indexPath) as! CreatedPinsTableViewCell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "SavedPinCell", for: indexPath) as! SavedPinsTableViewCell
        }
        cell.setValueForCell(_: filteredArray[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredArray.count
    }
    

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Your choice is \(filteredArray[indexPath.section])")
    }
    
    // PinTableViewCellDelegate protocol required function
    func itemSwiped(indexCell: Int){
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        if tableTypeName == "Created Pins" {
        cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! CreatedPinsTableViewCell
        }else{
        cellCurrSwiped = tblSearchResults.cellForRow(at: path) as! SavedPinsTableViewCell
        }
        tblSearchResults.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){}
    
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){}
    
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String){}
    
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String){}
    
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String){}
    
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String){}
    

    
}
