//
//  PinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 1/31/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
//import SDWebImage
//import RealmSwift


class PinsViewController: UIViewController, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate {
    
    var firstAppear = true
    
    //background view
    var viewBackground: UIView!
    
    // Table bar
    var TblResult: UITableView!
    var viewSearchBarCover: UIView! //Transparent view to cover the searchbar for detect the click event
    var SearchBar: UISearchBar!
    var emptyTblImgView: UIImageView!
    var emptySavedTblImgView: UIImageView!
    //var arrSelectedItem = [Int]() // Store the id of selected cell when the table is editing
    
    
    //Nagivation Bar Init******
    var uiviewNavBar: UIView!
    var tblTitle : String!
    
    //The set of pin data
    
    var pinDataArr = [[String: AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewBackground = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        self.view.addSubview(viewBackground)
        viewBackground.center.x += screenWidth
        loadTblResult()
        loadNavBar()
        switch tblTitle {
            
        case "Created Pins":
            getCreatedPins()
            
        case "Saved Pins":
            getSavedPins()
            
        default: break
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if(firstAppear){
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.5, animations: ({
                self.viewBackground.center.x -= screenWidth
            }))
            firstAppear = false
            
        }
    }
    
    
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: ({
            self.viewBackground.center.x += screenWidth
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
                self.pinDataArr.removeAll()
                let PinsOfCreatedPinsJSON = JSON(message!)
                
                if PinsOfCreatedPinsJSON.count > 0 {
                    for i in 0...(PinsOfCreatedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        
                        if let time = PinsOfCreatedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject?
                        }
                        
                        if let type = PinsOfCreatedPinsJSON[i]["type"].string{
                            dicCell["type"] = type as AnyObject?
                        }
                        let pinObject = PinsOfCreatedPinsJSON[i]["pin_object"]
                        
                        if  pinObject != JSON.null{
                            //comment tab里面存的不叫description 叫content
                            if let content = pinObject["content"].string {
                                dicCell["content"] = content as AnyObject?
                            }
                            //media tab里面存的不叫content 叫description
                            if let description = pinObject["description"].string {
                                dicCell["description"] = description as AnyObject?
                            }
                            
                            if let liked_count = pinObject["liked_count"].int {
                                dicCell["liked_count"] = liked_count as AnyObject?
                            }
                            
                            if let comment_count = pinObject["comment_count"].int {
                                dicCell["comment_count"] = comment_count as AnyObject?
                            }
                            
                            if let mediaImgArr = pinObject["file_ids"].array {
                                dicCell["file_ids"] = mediaImgArr as AnyObject?
                            }
                        }
                        
                        self.pinDataArr.append(dicCell)
                        
                    }
                    
                    /*有数据代表空表，要显示控件*/
                    self.emptyTblImgView.isHidden = true
                    self.emptySavedTblImgView.isHidden = true
                    self.SearchBar.isHidden = false
                    self.TblResult.isHidden = false
                }
                else{
                    /*没有数据代表空表，要隐藏控件*/
                    
                    self.emptyTblImgView.isHidden = false
                    self.emptySavedTblImgView.isHidden = true
                    self.SearchBar.isHidden = true
                    self.TblResult.isHidden = true
                }
                
                // reload the table when get the data
                self.TblResult.reloadData()
            }
            else {
                print("Fail to get Created pins!")
            }
        }
    }
    
    // get the Saved Pins
    func getSavedPins() {
        let getSavedPinsData = FaeMap()
        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get saved pins!")
                self.pinDataArr.removeAll()
                let PinsOfSavedPinsJSON = JSON(message!)
                
                if PinsOfSavedPinsJSON.count > 0 {
                    for i in 0...(PinsOfSavedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        
                        if let time = PinsOfSavedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject?
                        }
                        
                        if let type = PinsOfSavedPinsJSON[i]["type"].string {
                            dicCell["type"] = type as AnyObject?
                        }
                        let pinObject = PinsOfSavedPinsJSON[i]["pin_object"]
                        
                        if  pinObject != JSON.null {
                            //comment tab里面存的不叫description 叫content
                            if let content = pinObject["content"].string {
                                dicCell["content"] = content as AnyObject?
                            }
                            //media tab里面存的不叫content 叫description
                            if let description = pinObject["description"].string {
                                dicCell["description"] = description as AnyObject?
                            }
                            
                            if let liked_count = pinObject["liked_count"].int {
                                dicCell["liked_count"] = liked_count as AnyObject?
                            }
                            
                            if let comment_count = pinObject["comment_count"].int {
                                dicCell["comment_count"] = comment_count as AnyObject?
                            }
                            
                            if let mediaImgArr = pinObject["file_ids"].array {
                                dicCell["file_ids"] = mediaImgArr as AnyObject?
                            }
                        }
                        
                        self.pinDataArr.append(dicCell)
                        
                    }
                    /*有数据代表空表，要显示控件*/
                    self.emptySavedTblImgView.isHidden = true
                    self.emptyTblImgView.isHidden = true
                    self.SearchBar.isHidden = false
                    self.TblResult.isHidden = false
                    
                }else{
                    /*没有数据代表空表，要隐藏控件*/
                    
                    self.emptySavedTblImgView.isHidden = false
                    self.emptyTblImgView.isHidden = true
                    self.SearchBar.isHidden = true
                    self.TblResult.isHidden = true
                }
                
                // reload the table when get the data
                self.TblResult.reloadData()
            }
            else {
                print("Fail to get saved pins!")
            }
        }
    }
    
    
    func loadNavBar() {
        
        
        uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        
        
        
        viewBackground.addSubview(uiviewNavBar)
        
        
        let btnBack = UIButton(frame: CGRect(x: 16, y: 33, width: 10.5, height: 18))
        
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        
        btnBack.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        
        uiviewNavBar.addSubview(btnBack)
        
        
        let navBarTitle = UILabel(frame: CGRect(x: screenWidth/2-100, y: 28, width: 200, height: 27))
        navBarTitle.font = UIFont(name: "AvenirNext-Medium",size: 20)
        navBarTitle.textAlignment = NSTextAlignment.center
        navBarTitle.textColor = UIColor.faeAppTimeTextBlackColor()
        navBarTitle.text = tblTitle
        uiviewNavBar.addSubview(navBarTitle)
        
    }
    
    
    private func loadSearchBar(){
        
        SearchBar = UISearchBar()
        SearchBar.frame = CGRect(x: 0,y: 0,width: screenWidth,height: 50)
        SearchBar.placeholder = "Search Pins"
        SearchBar.barTintColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        
        // hide cancel button
        SearchBar.showsCancelButton = false
        
        // hide bookmark button
        SearchBar.showsBookmarkButton = false
        
        // set Default bar status.
        SearchBar.searchBarStyle = UISearchBarStyle.prominent
        // Get rid of the black line
        SearchBar.isTranslucent = false
        SearchBar.backgroundImage = UIImage()
        
        // Add a view to cover the searchbar, this view is used for detect the click event
        viewSearchBarCover = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: 50))
        viewSearchBarCover.backgroundColor = .clear
        
        SearchBar.addSubview(viewSearchBarCover)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDown(_:)))
        
        viewSearchBarCover.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
    }
    
    
    private func loadTblResult(){
        
        viewBackground.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        TblResult = UITableView(frame: CGRect(x: 0,y: 65,width: screenWidth,height: screenHeight-65), style: UITableViewStyle.plain)
        TblResult.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        TblResult.register(PinTableViewCell.self, forCellReuseIdentifier: "PinCell")
        TblResult.delegate = self
        TblResult.dataSource = self
        TblResult.showsVerticalScrollIndicator = false
        
        
        //for auto layout
        TblResult.rowHeight = UITableViewAutomaticDimension
        TblResult.estimatedRowHeight = 340
        
        
        emptyTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptyTblImgView.image = #imageLiteral(resourceName: "empty_table_bg")
        emptyTblImgView.isHidden = true
        
        emptySavedTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptySavedTblImgView.image = #imageLiteral(resourceName: "empty_savedtable_bg")
        emptySavedTblImgView.isHidden = true
        
        
        viewBackground.addSubview(emptyTblImgView)
        viewBackground.addSubview(emptySavedTblImgView)
        viewBackground.addSubview(TblResult)
        loadSearchBar()
        TblResult.tableHeaderView = SearchBar
    }
    
    // Creat the search view when tap the fake searchbar
    func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let searchVC = CollectionSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: false, completion: nil)
        searchVC.tableTypeName = tblTitle
        searchVC.dataArray = pinDataArr
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
        
        return pinDataArr.count
        
    }
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinTableViewCell
        cell.setValueForCell(_: pinDataArr[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        
        cell.layer.cornerRadius = 10.0
        cell.selectionStyle = .none
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Your choice is \(pinDataArr[indexPath.section])")
        
    }
    
    
    //    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    //        return UITableViewCellEditingStyle.none
    //    }
    //    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    //
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    
    
    
    
    
    
}


