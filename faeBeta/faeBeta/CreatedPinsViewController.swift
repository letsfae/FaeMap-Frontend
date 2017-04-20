//
//  CreatedPinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIKit.UIGestureRecognizerSubclass
//import SDWebImage
//import RealmSwift

class TouchGestureRecognizer : UIGestureRecognizer {
    // initialize the cellInGivenId
    var cellInGivenId = PinsTableViewCell()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        // This assignment is very importment for custom gesture
        self.state = UIGestureRecognizerState.began
        
        let frame = cellInGivenId.uiviewCellView.frame
        let originalFrame = CGRect(x: -screenWidth, y: frame.origin.y, width: frame.width, height: frame.height)
        UIView.animate(withDuration: 0.3, animations: {self.cellInGivenId.uiviewCellView.frame = originalFrame})
    }
}


class CreatedPinsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,PinTableViewCellDelegate, UIGestureRecognizerDelegate{
    var isFirstAppear = true
    // initialize the cellInGivenId
    var cellCurrSwiped = CreatedPinsTableViewCell()
    var gesturerecognizerTouch: TouchGestureRecognizer!
    //background view
    var uiviewBackground: UIView!
    var tblPinsData: UITableView!
    //Transparent view to cover the searchbar for detect the click event
    var uiviewSearchBarCover: UIView!
    var schbarPin: UISearchBar!
    var imgEmptyTbl: UIImageView!
    //Nagivation Bar Init
    var uiviewNavBar: UIView!
    //Title for current table
    var strTableTitle : String!
    //The set of pin data
    var arrPinData = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The background of this controller, all subviews are added to this view
        uiviewBackground = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        self.view.addSubview(uiviewBackground)
        uiviewBackground.center.x = 1.5 * screenWidth
        loadtblPinsData()
        loadNavBar()
    }
    
    
    func handleAfterTouch(recognizer: TouchGestureRecognizer) {
        //remove the gesture after cell backs, or the gesture will always collect touches in the table
        tblPinsData.removeGestureRecognizer(gesturerecognizerTouch)
    }
    
    
    // only the buttons in the siwped cell don't respond to the gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: cellCurrSwiped.uiviewSwipedBtnsView))!{
            return false
        }
        return true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isFirstAppear){
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.3, animations: ({
                self.uiviewBackground.center.x = screenWidth/2
            }))
            isFirstAppear = false
        }
    }
    
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            self.uiviewBackground.center.x = 1.5 * screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    
    // get the Created Pins
    func getCreatedPins() {
        let getCreatedPinsData = FaeMap()
        getCreatedPinsData.getCreatedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get Created pins!")
                self.arrPinData.removeAll()
                let PinsOfCreatedPinsJSON = JSON(message!)
                if PinsOfCreatedPinsJSON.count > 0 {
                    for i in 0...(PinsOfCreatedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        if let time = PinsOfCreatedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject
                        }
                        if let pinId = PinsOfCreatedPinsJSON[i]["pin_id"].int{
                            dicCell["pin_id"] = pinId as AnyObject
                        }
                        if let type = PinsOfCreatedPinsJSON[i]["type"].string{
                            dicCell["type"] = type as AnyObject
                        }
                        let pinObject = PinsOfCreatedPinsJSON[i]["pin_object"]
                        if  pinObject != JSON.null{
                            //comment tab里面存的不叫description 叫content
                            if let content = pinObject["content"].string {
                                dicCell["content"] = content as AnyObject
                            }
                            //media tab里面存的不叫content 叫description
                            if let description = pinObject["description"].string {
                                dicCell["description"] = description as AnyObject
                            }
                            
                            if let liked_count = pinObject["liked_count"].int {
                                dicCell["liked_count"] = liked_count as AnyObject
                            }
                            
                            if let comment_count = pinObject["comment_count"].int {
                                dicCell["comment_count"] = comment_count as AnyObject?
                            }
                            
                            if let mediaImgArr = pinObject["file_ids"].array {
                                dicCell["file_ids"] = mediaImgArr as AnyObject?
                            }
                        }
                        self.arrPinData.append(dicCell)
                    }
                    /*有数据代表不是空表，要显示控件*/
                    self.hideOrShowTable(true)
                }
                else{
                    /*没有数据代表空表，要隐藏控件*/
                    self.hideOrShowTable(false)
                }
                // reload the table when get the data
                self.tblPinsData.reloadData()
            }
            else {
                print("Fail to get Created pins!")
            }
        }
    }
    
    func hideOrShowTable(_ willShow : Bool){
        if(willShow){
            self.imgEmptyTbl.isHidden = true
            self.tblPinsData.isHidden = false
        }else{
            self.imgEmptyTbl.isHidden = false
            self.tblPinsData.isHidden = true
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        uiviewBackground.addSubview(uiviewNavBar)
        let btnBack = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        btnBack.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBack)
        let labelNavBarTitle = UILabel(frame: CGRect(x: screenWidth/2-100, y: 28, width: 200, height: 27))
        labelNavBarTitle.font = UIFont(name: "AvenirNext-Medium",size: 20)
        labelNavBarTitle.textAlignment = NSTextAlignment.center
        labelNavBarTitle.textColor = UIColor.faeAppTimeTextBlackColor()
        labelNavBarTitle.text = strTableTitle
        uiviewNavBar.addSubview(labelNavBarTitle)
    }
    
    
    private func loadSearchBar(){
        schbarPin = UISearchBar()
        schbarPin.frame = CGRect(x: 0,y: 0,width: screenWidth,height: 50)
        schbarPin.placeholder = "Search Pins"
        schbarPin.barTintColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        // hide cancel button
        schbarPin.showsCancelButton = false
        // hide bookmark button
        schbarPin.showsBookmarkButton = false
        // set Default bar status.
        schbarPin.searchBarStyle = UISearchBarStyle.prominent
        // Get rid of the black line
        schbarPin.isTranslucent = false
        schbarPin.backgroundImage = UIImage()
        // Add a view to cover the searchbar, this view is used for detect the click event
        uiviewSearchBarCover = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: 50))
        uiviewSearchBarCover.backgroundColor = .clear
        schbarPin.addSubview(uiviewSearchBarCover)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDown(_:)))
        uiviewSearchBarCover.addGestureRecognizer(tapRecognizer)
        uiviewSearchBarCover.isUserInteractionEnabled = true
    }
    
    
    private func loadtblPinsData(){
        uiviewBackground.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        tblPinsData = UITableView(frame: CGRect(x: 0,y: 65,width: screenWidth,height: screenHeight-65), style: UITableViewStyle.plain)
        tblPinsData.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        tblPinsData.register(CreatedPinsTableViewCell.self, forCellReuseIdentifier: "CreatedPinCell")
        tblPinsData.delegate = self
        tblPinsData.dataSource = self
        tblPinsData.showsVerticalScrollIndicator = false
        //for auto layout
        tblPinsData.rowHeight = UITableViewAutomaticDimension
        tblPinsData.estimatedRowHeight = 340
        
        imgEmptyTbl = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        imgEmptyTbl.isHidden = true
        uiviewBackground.addSubview(imgEmptyTbl)
        uiviewBackground.addSubview(tblPinsData)

        getCreatedPins()
        imgEmptyTbl.image = #imageLiteral(resourceName: "empty_savedpins_bg")
        
        // initialize the touch gesture
        gesturerecognizerTouch = TouchGestureRecognizer(target: self, action: #selector(handleAfterTouch))
        gesturerecognizerTouch.delegate = self
        
        loadSearchBar()
        tblPinsData.tableHeaderView = schbarPin
    }
    
    
    // Creat the search view when tap the fake searchbar
    func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let searchVC = CollectionSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: false, completion: nil)
        searchVC.tableTypeName = strTableTitle
        searchVC.dataArray = arrPinData
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //以下代码是table的构造
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrPinData.count
    }
    
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    // Only one row for one section in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedPinCell", for: indexPath) as! CreatedPinsTableViewCell
        cell.setValueForCell(_: arrPinData[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Your choice is \(arrPinData[indexPath.section])")
    }
    
    
    // PinTableViewCellDelegate protocol required function
    func itemSwiped(indexCell: Int){
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        cellCurrSwiped = tblPinsData.cellForRow(at: path) as! CreatedPinsTableViewCell
        tblPinsData.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String) {
        let deleteMyPin = FaeMap()
        deleteMyPin.deletePin(type: pinType, pinId: pinId.description) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully delete the pin!")
            }
        }
        self.arrPinData.remove(at: indexCell)
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexCell)
        self.tblPinsData.performUpdate({
            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
        }, completion: {
            self.tblPinsData.reloadData()
        })
        if(self.arrPinData.count == 0){
            hideOrShowTable(false)
        }
    }
    
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String){
        let deleteMyPin = FaeMap()
        deleteMyPin.deletePin(type: pinType, pinId: pinId.description) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully delete the pin!")
            }
        }
        self.arrPinData.remove(at: indexCell)
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexCell)
        self.tblPinsData.performUpdate({
            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
        }, completion: {
            self.tblPinsData.reloadData()
        })
        if(self.arrPinData.count == 0){
            hideOrShowTable(false)
        }
    }
    
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
}


extension UITableView {
    /// Perform a series of method calls that insert, delete, or select rows and sections of the table view.
    /// This is equivalent to a beginUpdates() / endUpdates() sequence,
    /// with a completion closure when the animation is finished.
    /// Parameter update: the update operation to perform on the tableView.
    /// Parameter completion: the completion closure to be executed when the animation is completed.
    
    func performUpdate(_ update: ()->Void, completion: (()->Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        // Table View update on row / section
        beginUpdates()
        update()
        endUpdates()
        CATransaction.commit()
    }
}
