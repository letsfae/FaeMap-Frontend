//
//  PlacesAndLocationsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 3/24/17.
//  Edited by Zixin Wang
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PlacesAndLocationsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MemoDelegate {
    // background view
    var uiviewBackground: UIView!
    // Table bar
    var tblResult: UITableView!
    var uiviewSearchBarCover: UIView! // Transparent view to cover the searchbar for detect the click event
    var searchBar: UISearchBar!
    var imgEmptyTbl: UIImageView!
    var imgEmptySavedTbl: UIImageView!
    var arrSelectedItem = [Int]() // Store the id of selected cell when the table is editing
    
    // Edit bar, show when the table is editable
    var uiviewEditbar: UIView!
    var btnShare: UIButton!
    var btnMemo: UIButton!
    var btnRemove: UIButton!
    
    // searchbar
    var tap: UITapGestureRecognizer!
    var tapdisable: UITapGestureRecognizer!
    
    // Nagivation Bar Init
    var uiviewNavBar: UIView!
    var strTableTitle: String!
    var btnEdit: UIButton!
    
    // The set of pin data
    
//    var placeAndLocationDataArr = [["name": "325 W ADAMS BLVD", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "< 0.1 km", "memo": "WOWOWOWOWOWOWOWOWOWOWOWOWWOWOWOWOWOWOWOWOWOWOWOWOW"], ["name": "3335 S Figueroa St", "address": "LOS ANGELES, CA 90006 UNITED STATES", "distance": "1.6 km", "memo": ""], ["name": "925 W 34th St", "address": "LOS ANGELES, CA 90089 UNITED STATES", "distance": "2.2 km", "memo": ""], ["name": "saved place test", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "> 999 km", "memo": ""], ["name": "325 W ADAMS BLVD", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "< 0.1 km", "memo": ""], ["name": "325 W ADAMS BLVD", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "< 0.1 km", "memo": ""], ["name": "3335 S Figueroa St", "address": "LOS ANGELES, CA 90006 UNITED STATES", "distance": "1.6 km", "memo": ""], ["name": "925 W 34th St", "address": "LOS ANGELES, CA 90089 UNITED STATES", "distance": "2.2 km", "memo": ""], ["name": "saved place test saved place test saved place test", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "> 999 km", "memo": ""], ["name": "325 W ADAMS BLVD", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "< 0.1 km", "memo": ""]]
    var placeAndLocationDataArr = [["name": "325 W ADAMS BLVD", "address": "LOS ANGELES, CA 90007 UNITED STATES", "distance": "< 0.1 km", "memo": "WOWOWOWOWOWOWOWOWOWOWOWOWWOWOWOWOWOWOWOWOWOWOWOWOW"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadTblResult()
        loadNavBar()
        loadEditBar()
        
        switch strTableTitle {
            
        case "Saved Places":
            getSavedPlaces()
            
        case "Saved Locations":
            getSavedLocations()
            
        default: break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Dismiss current View
    @objc func actionDismissCurrentView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 注释掉 留着之后改成location 与 place的获取
    // get the Saved Places
    func getSavedPlaces() {
        //        let getCreatedPinsData = FaeMap()
        //        getCreatedPinsData.getCreatedPins() {(status: Int, message: Any?) in
        //            if status == 200 {
        //                print("Successfully get Created pins!")
        //                self.CreatedPinDataArr.removeAll()
        //                let PinsOfCreatedPinsJSON = JSON(message!)
        //
        //                if PinsOfCreatedPinsJSON.count > 0 {
        //                    for i in 0...(PinsOfCreatedPinsJSON.count-1) {
        //                        var dicCell = [String: AnyObject]()
        //
        //                        if let time = PinsOfCreatedPinsJSON[i]["created_at"].string {
        //                            dicCell["created_at"] = time as AnyObject?
        //                        }
        //
        //                        if let type = PinsOfCreatedPinsJSON[i]["type"].string{
        //                            dicCell["type"] = type as AnyObject?
        //                        }
        //                        let pinObject = PinsOfCreatedPinsJSON[i]["pin_object"]
        //
        //                        if  pinObject != JSON.null{
        //                            //comment tab里面存的不叫description 叫content
        //                            if let content = pinObject["content"].string {
        //                                dicCell["content"] = content as AnyObject?
        //                            }
        //                            //media tab里面存的不叫content 叫description
        //                            if let description = pinObject["description"].string {
        //                                dicCell["description"] = description as AnyObject?
        //                            }
        //
        //                            if let liked_count = pinObject["liked_count"].int {
        //                                dicCell["liked_count"] = liked_count as AnyObject?
        //                            }
        //
        //                            if let comment_count = pinObject["comment_count"].int {
        //                                dicCell["comment_count"] = comment_count as AnyObject?
        //                            }
        //
        //                            if let mediaImgArr = pinObject["file_ids"].array {
        //                                dicCell["file_ids"] = mediaImgArr as AnyObject?
        //                            }
        //                        }
        //
        //                        self.CreatedPinDataArr.append(dicCell)
        //
        //                    }
        //
        //                    /*有数据代表空表，要显示控件*/
        //                    self.emptyTblImgView.isHidden = true
        //                    self.emptySavedTblImgView.isHidden = true
        //                    self.SearchBar.isHidden = false
        //                    self.TblResult.isHidden = false
        //                }
        //                else{
        //                    /*没有数据代表空表，要隐藏控件*/
        //
        //                    self.emptyTblImgView.isHidden = false
        //                    self.emptySavedTblImgView.isHidden = true
        //                    self.SearchBar.isHidden = true
        //                    self.TblResult.isHidden = true
        //                }
        //
        //                // reload the table when get the data
        //                self.TblResult.reloadData()
        //            }
        //            else {
        //                print("Fail to get Created pins!")
        //            }
        //        }
        
        // API 能用后删掉下面的代码
        if placeAndLocationDataArr.count != 0 {
            btnEdit.isHidden = false
        }
        if placeAndLocationDataArr.count == 0 {
            imgEmptySavedTbl.isHidden = false
            searchBar.isHidden = true
            tblResult.isHidden = true
        } else {
            imgEmptySavedTbl.isHidden = true
            searchBar.isHidden = false
            tblResult.isHidden = false
        }
    }
    
    // get the Saved Locations
    func getSavedLocations() {
        //        let getSavedPinsData = FaeMap()
        //        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
        //            if status == 200 {
        //                print("Successfully get saved pins!")
        //                self.savedPinDataArr.removeAll()
        //                let PinsOfSavedPinsJSON = JSON(message!)
        //
        //                if PinsOfSavedPinsJSON.count > 0 {
        //                    for i in 0...(PinsOfSavedPinsJSON.count-1) {
        //                        var dicCell = [String: AnyObject]()
        //
        //                        if let time = PinsOfSavedPinsJSON[i]["created_at"].string {
        //                            dicCell["created_at"] = time as AnyObject?
        //                        }
        //
        //                        if let type = PinsOfSavedPinsJSON[i]["type"].string {
        //                            dicCell["type"] = type as AnyObject?
        //                        }
        //                        let pinObject = PinsOfSavedPinsJSON[i]["pin_object"]
        //
        //                        if  pinObject != JSON.null {
        //                            //comment tab里面存的不叫description 叫content
        //                            if let content = pinObject["content"].string {
        //                                dicCell["content"] = content as AnyObject?
        //                            }
        //                            //media tab里面存的不叫content 叫description
        //                            if let description = pinObject["description"].string {
        //                                dicCell["description"] = description as AnyObject?
        //                            }
        //
        //                            if let liked_count = pinObject["liked_count"].int {
        //                                dicCell["liked_count"] = liked_count as AnyObject?
        //                            }
        //
        //                            if let comment_count = pinObject["comment_count"].int {
        //                                dicCell["comment_count"] = comment_count as AnyObject?
        //                            }
        //
        //                            if let mediaImgArr = pinObject["file_ids"].array {
        //                                dicCell["file_ids"] = mediaImgArr as AnyObject?
        //                            }
        //                        }
        //
        //                        self.savedPinDataArr.append(dicCell)
        //
        //                    }
        //                    /*有数据代表空表，要显示控件*/
        //                    self.emptySavedTblImgView.isHidden = true
        //                    self.emptyTblImgView.isHidden = true
        //                    self.SearchBar.isHidden = false
        //                    self.TblResult.isHidden = false
        //
        //                }else{
        //                    /*没有数据代表空表，要隐藏控件*/
        //
        //                    self.emptySavedTblImgView.isHidden = false
        //                    self.emptyTblImgView.isHidden = true
        //                    self.SearchBar.isHidden = true
        //                    self.TblResult.isHidden = true
        //                }
        //
        //                // reload the table when get the data
        //                self.TblResult.reloadData()
        //            }
        //            else {
        //                print("Fail to get saved pins!")
        //            }
        //        }
        
        // API 能用后删掉下面的代码
        if placeAndLocationDataArr.count != 0 {
            btnEdit.isHidden = false
        }
        if placeAndLocationDataArr.count == 0 {
            imgEmptySavedTbl.isHidden = false
            searchBar.isHidden = true
            tblResult.isHidden = true
        } else {
            imgEmptySavedTbl.isHidden = true
            searchBar.isHidden = false
            tblResult.isHidden = false
        }
        
    }
    
    func loadEditBar() {
        uiviewEditbar = UIView(frame: CGRect(x: 0, y: screenHeight - 56, width: screenWidth, height: 56))
        uiviewEditbar.backgroundColor = UIColor._234234234()
        uiviewBackground.addSubview(uiviewEditbar)
        
        btnShare = UIButton()
        btnShare.setTitle("Share", for: .normal)
        btnShare.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnShare.setTitleColor(UIColor.white, for: .normal)
        btnShare.backgroundColor = UIColor(red: 174 / 255, green: 226 / 255, blue: 118 / 255, alpha: 1)
        btnShare.layer.cornerRadius = 8
        
        btnRemove = UIButton()
        btnRemove.setTitle("Remove", for: .normal)
        btnRemove.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnRemove.setTitleColor(UIColor.white, for: .normal)
        btnRemove.backgroundColor = UIColor._2499090()
        btnRemove.layer.cornerRadius = 8
        
        btnMemo = UIButton()
        btnMemo.setTitle("Memo", for: .normal)
        btnMemo.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnMemo.setTitleColor(UIColor.white, for: .normal)
        btnMemo.backgroundColor = UIColor(r: 194, g: 166, b: 217, alpha: 100)
        btnMemo.layer.cornerRadius = 8
        
        btnShare.addTarget(self, action: #selector(actionBtnShare(_:)), for: .touchUpInside)
        btnRemove.addTarget(self, action: #selector(actionBtnRemove(_:)), for: .touchUpInside)
        btnMemo.addTarget(self, action: #selector(actionBtnMemo(_:)), for: .touchUpInside)
        
        uiviewEditbar.addSubview(btnShare)
        uiviewEditbar.addSubview(btnRemove)
        uiviewEditbar.addSubview(btnMemo)
        
        uiviewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views: btnShare)
        uiviewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views: btnMemo)
        uiviewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views: btnRemove)
        uiviewEditbar.addConstraintsWithFormat("H:|-10-[v0(\(screenWidth / 3 - 12))]-[v1(\(screenWidth / 3 - 12))]-[v2(\(screenWidth / 3 - 12))]-10-|", options: [], views: btnShare, btnMemo, btnRemove)
        
        btnShare.isEnabled = false
        btnMemo.isEnabled = false
        btnRemove.isEnabled = false
        btnShare.alpha = 0.6
        btnMemo.alpha = 0.6
        btnRemove.alpha = 0.6
        uiviewEditbar.isHidden = true
        
    }
    
    func loadNavBar() {
        
        uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth + 2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        uiviewBackground.addSubview(uiviewNavBar)
        
        let btnBack = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        btnBack.addTarget(self, action: #selector(actionDismissCurrentView(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBack)
        
        let lblNavBarTitle = UILabel(frame: CGRect(x: screenWidth / 2 - 100, y: 28, width: 200, height: 27))
        lblNavBarTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblNavBarTitle.textAlignment = .center
        lblNavBarTitle.textColor = UIColor._107107107()
        lblNavBarTitle.text = strTableTitle
        uiviewNavBar.addSubview(lblNavBarTitle)
        
        // button for edit, show only for saved locations and places page
        btnEdit = UIButton(type: .custom)
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnEdit.setTitleColor(UIColor._2499090(), for: .normal)
        btnEdit.backgroundColor = .clear
        btnEdit.addTarget(self, action: #selector(self.actionEditCurrentTable(_:)), for: .touchUpInside)
        btnEdit.isHidden = true
        uiviewNavBar.addSubview(btnEdit)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(46)]-15-|", options: [], views: btnEdit)
        uiviewNavBar.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: btnEdit)
    }
    
    // Action fuction when the edit button is tapped
    @objc func actionEditCurrentTable(_ sender: UIButton) {
        if !tblResult.isEditing {
            btnEdit.setTitle("Done", for: .normal)
            //            isbtnEdittaped = true
            tblResult.isEditing = true
            tblResult.reloadData()
            uiviewEditbar.isHidden = false
            tblResult.frame = CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65 - 56)
            arrSelectedItem.removeAll()
            
            uiviewSearchBarCover.removeGestureRecognizer(tap)
            uiviewSearchBarCover.addGestureRecognizer(tapdisable)
        } else {
            btnEdit.setTitle("Edit", for: .normal)
            tblResult.isEditing = false
            tblResult.reloadData()
            uiviewEditbar.isHidden = true
            tblResult.frame = CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65)
            arrSelectedItem.removeAll()
            uiviewSearchBarCover.removeGestureRecognizer(tapdisable)
            uiviewSearchBarCover.addGestureRecognizer(tap)
        }
    }
    private func loadSearchBar() {
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 50)
        
        switch strTableTitle {
        case "Saved Places":
            searchBar.placeholder = "Search Places"
            
        case "Saved Locations":
            searchBar.placeholder = "Search Locations"
            
        default: break
        }
        searchBar.barTintColor = UIColor._234234234()
        // hide cancel button
        searchBar.showsCancelButton = false
        // hide bookmark button
        searchBar.showsBookmarkButton = false
        // set Default bar status.
        searchBar.searchBarStyle = UISearchBarStyle.prominent
        // Get rid of the black line
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        
        // Add a view to cover the searchbar, this view is used for detect the click event
        uiviewSearchBarCover = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewSearchBarCover.backgroundColor = .clear
        searchBar.addSubview(uiviewSearchBarCover)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(searchBarTapDown(_:)))
        tapdisable = UITapGestureRecognizer(target: self, action: #selector(searchBarTapDownDisable(_:)))
        
        uiviewSearchBarCover.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    private func loadTblResult() {
        
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor._234234234()
        tblResult = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65), style: UITableViewStyle.plain)
        tblResult.backgroundColor = .white
        tblResult.register(PlaceAndLocationTableViewCell.self, forCellReuseIdentifier: "PlaceAndLocationCell")
        tblResult.delegate = self
        tblResult.dataSource = self
        tblResult.showsVerticalScrollIndicator = false
        
        // for auto layout
        tblResult.rowHeight = UITableViewAutomaticDimension
        tblResult.estimatedRowHeight = 90
        view.addSubview(uiviewBackground)
        
        imgEmptyTbl = UIImageView(frame: CGRect(x: (screenWidth - 252) / 2, y: (screenHeight - 209) / 2 - 106, width: 252, height: 209))
        imgEmptyTbl.image = #imageLiteral(resourceName: "empty_mypins_bg")
        imgEmptyTbl.isHidden = true
        
        imgEmptySavedTbl = UIImageView(frame: CGRect(x: (screenWidth - 252) / 2, y: (screenHeight - 209) / 2 - 106, width: 252, height: 209))
        imgEmptySavedTbl.image = #imageLiteral(resourceName: "empty_savedpins_bg")
        imgEmptySavedTbl.isHidden = true
        
        uiviewBackground.addSubview(imgEmptyTbl)
        uiviewBackground.addSubview(imgEmptySavedTbl)
        uiviewBackground.addSubview(tblResult)
        
        // load searchbar at the head of table
        loadSearchBar()
        tblResult.tableHeaderView = searchBar
    }
    
    // Creat the search view when tap the fake searchbar
    @objc func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let vcSearch = CollectionSearchViewController()
        vcSearch.modalPresentationStyle = .overCurrentContext
        present(vcSearch, animated: false, completion: nil)
        vcSearch.strTableTypeName = strTableTitle
        vcSearch.arrData = placeAndLocationDataArr as [[String: AnyObject]]
    }
    
    @objc func searchBarTapDownDisable(_ sender: UITapGestureRecognizer) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function is the action function for the select button in the cell when the table is editable
    @objc func actionSelectBtnInCell(_ sender: UIButton) {
        
        let sectionId = sender.tag
        let path: IndexPath = IndexPath(row: 0, section: sectionId)
        let cellInGivenId: PlaceAndLocationTableViewCell = tblResult.cellForRow(at: path) as! PlaceAndLocationTableViewCell
        if !arrSelectedItem.contains(sectionId) {
            if arrSelectedItem.count == 0 {
                btnShare.isEnabled = true
                btnMemo.isEnabled = true
                btnRemove.isEnabled = true
                btnShare.alpha = 1
                btnMemo.alpha = 1
                btnRemove.alpha = 1
            } else {
                btnShare.isEnabled = false
                btnMemo.isEnabled = false
                btnShare.alpha = 0.6
                btnMemo.alpha = 0.6
            }
            arrSelectedItem.append(sectionId)
            cellInGivenId.btnSelected.layer.borderColor = UIColor._2499090().cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor._2499090().cgColor
        } else {
            arrSelectedItem.remove(at: arrSelectedItem.index(of: sectionId)!)
            cellInGivenId.btnSelected.layer.borderColor = UIColor(red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1).cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1).cgColor
            
            if arrSelectedItem.count == 0 {
                btnShare.isEnabled = false
                btnMemo.isEnabled = false
                btnRemove.isEnabled = false
                btnShare.alpha = 0.6
                btnMemo.alpha = 0.6
                btnRemove.alpha = 0.6
            }
            if arrSelectedItem.count == 1 {
                btnShare.isEnabled = true
                btnMemo.isEnabled = true
                btnShare.alpha = 1
                btnMemo.alpha = 1
            }
        }
        
    }
    
    @objc func actionBtnShare(_ sender: UIButton) {
        // share
    }
    
    @objc func actionBtnMemo(_ sender: UIButton) {
        // memo
        let memoVC = MemoViewController()
        memoVC.modalPresentationStyle = .overCurrentContext
        memoVC.delegate = self
        present(memoVC, animated: false, completion: nil)
    }
    // delegate func(transfer the memo data from memoVC to current VC)
    func memoContent(save: Bool, content: String) {
        if save {
            for item in arrSelectedItem {
                placeAndLocationDataArr[item]["memo"] = content
            }
            tblResult.reloadData()
            arrSelectedItem.removeAll()
            btnShare.isEnabled = false
            btnMemo.isEnabled = false
            btnRemove.isEnabled = false
            btnShare.alpha = 0.6
            btnMemo.alpha = 0.6
            btnRemove.alpha = 0.6
        }
    }
    
    @objc func actionBtnRemove(_ sender: UIButton) {
        // Remove
        arrSelectedItem.sort { $0 > $1 } // 倒序排序，这样保证原数据删除的时候是倒着删 不打乱顺序
        
        for item in arrSelectedItem {
            //            let path : IndexPath = IndexPath(row: 0, section: item)
            //            let  cellInGivenId : PlaceAndLocationTableViewCell = TblResult.cellForRow(at: path) as!   PlaceAndLocationTableViewCell
            //
            //            cellInGivenId.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
            //            cellInGivenId.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
            placeAndLocationDataArr.remove(at: item)
        }
        tblResult.reloadData()
        arrSelectedItem.removeAll()
        btnShare.isEnabled = false
        btnMemo.isEnabled = false
        btnRemove.isEnabled = false
        btnShare.alpha = 0.6
        btnMemo.alpha = 0.6
        btnRemove.alpha = 0.6
    }
    
    // below is the construction of table
    func numberOfSections(in tableView: UITableView) -> Int {
        return placeAndLocationDataArr.count
    }
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceAndLocationCell", for: indexPath) as! PlaceAndLocationTableViewCell
        cell.setValueForCell(_: placeAndLocationDataArr[indexPath.section] as [String: AnyObject])
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 89.5, bottom: 0, right: 0)
        
        if tableView.isEditing && self.tableView(tableView, canEditRowAt: indexPath) {
            cell.lblDistance.isHidden = true
            cell.btnSelected.isHidden = false
            cell.btnSelected.tag = indexPath.section // 因为每个section只有一个row
            cell.btnSelected.addTarget(self, action: #selector(actionSelectBtnInCell(_:)), for: .touchUpInside)
            if arrSelectedItem.contains(indexPath.section) {
                cell.btnSelected.layer.borderColor = UIColor._2499090().cgColor
                cell.btnSelected.layer.backgroundColor = UIColor._2499090().cgColor
            } else {
                cell.btnSelected.layer.borderColor = UIColor(red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1).cgColor
                cell.btnSelected.layer.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1).cgColor
            }
            
            // 每次刷新都把选中的button清空成灰色
            cell.btnSelected.layer.borderColor = UIColor(red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1).cgColor
            cell.btnSelected.layer.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1).cgColor
        } else {
            cell.lblDistance.isHidden = false
            cell.btnSelected.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Your choice is \(placeAndLocationDataArr[indexPath.section])")
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
