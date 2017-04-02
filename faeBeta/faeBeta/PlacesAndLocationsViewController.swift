//
//  PlacesAndLocationsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 3/24/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PlacesAndLocationsViewController: UIViewController, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MemoDelegate {
    var firstAppear = true
    //background view
    var viewBackground: UIView!
    // Table bar
    var TblResult: UITableView!
    var viewSearchBarCover: UIView! //Transparent view to cover the searchbar for detect the click event
    var SearchBar: UISearchBar!
    var emptyTblImgView: UIImageView!
    var emptySavedTblImgView: UIImageView!
    var arrSelectedItem = [Int]() // Store the id of selected cell when the table is editing
    
    // Edit bar, show when the table is editable
    var viewEditbar:UIView!
    var btnShare: UIButton!
    var btnMemo: UIButton!
    var btnRemove: UIButton!
    
    //searchbar
    var tap : UITapGestureRecognizer!
    var tapdisable : UITapGestureRecognizer!
    
    //Nagivation Bar Init******
    var uiviewNavBar: UIView!
    var tblTitle : String!
    var btnEdit : UIButton!
    
    //The set of pin data
    
    var placeAndLocationDataArr = [["name":"325 W ADAMS BLVD","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"< 0.1 km", "memo":"WOWOWOWOWOWOWOWOWOWOWOWOWWOWOWOWOWOWOWOWOWOWOWOWOW"],["name":"3335 S Figueroa St","address":"LOS ANGELES, CA 90006 UNITED STATES","distance":"1.6 km", "memo":""],["name":"925 W 34th St","address":"LOS ANGELES, CA 90089 UNITED STATES","distance":"2.2 km", "memo":""],["name":"saved place test","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"> 999 km", "memo":""],["name":"325 W ADAMS BLVD","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"< 0.1 km", "memo":""],["name":"325 W ADAMS BLVD","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"< 0.1 km", "memo":""],["name":"3335 S Figueroa St","address":"LOS ANGELES, CA 90006 UNITED STATES","distance":"1.6 km", "memo":""],["name":"925 W 34th St","address":"LOS ANGELES, CA 90089 UNITED STATES","distance":"2.2 km", "memo":""],["name":"saved place test saved place test saved place test","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"> 999 km", "memo":""],["name":"325 W ADAMS BLVD","address":"LOS ANGELES, CA 90007 UNITED STATES","distance":"< 0.1 km", "memo":""]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadTblResult()
        loadNavBar()
        loadEditBar()
        
        switch tblTitle {
            
        case "Saved Places":
            getSavedPlaces()
            
        case "Saved Locations":
            getSavedLocations()
            
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
    
    
    
    //注释掉 留着之后改成location 与 place的获取
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
        
        //API 能用后删掉下面的代码
        if(placeAndLocationDataArr.count != 0){
            btnEdit.isHidden = false
        }
        
        
        if(self.placeAndLocationDataArr.count == 0){
            self.emptySavedTblImgView.isHidden = false
            self.SearchBar.isHidden = true
            self.TblResult.isHidden = true
        }
        else{
            self.emptySavedTblImgView.isHidden = true
            self.SearchBar.isHidden = false
            self.TblResult.isHidden = false
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
        
        
        //API 能用后删掉下面的代码
        if(placeAndLocationDataArr.count != 0){
            btnEdit.isHidden = false
        }
        
        
        if(self.placeAndLocationDataArr.count == 0){
            self.emptySavedTblImgView.isHidden = false
            self.SearchBar.isHidden = true
            self.TblResult.isHidden = true
        }
        else{
            self.emptySavedTblImgView.isHidden = true
            self.SearchBar.isHidden = false
            self.TblResult.isHidden = false
        }
        
        
        
    }
    
    
    func loadEditBar(){
        viewEditbar = UIView(frame: CGRect(x: 0, y: screenHeight-56, width: screenWidth, height: 56))
        viewEditbar.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        viewBackground.addSubview(viewEditbar)
        
        btnShare = UIButton()
        btnShare.setTitle("Share", for: .normal)
        btnShare.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 18)
        btnShare.setTitleColor(UIColor.white, for: .normal)
        btnShare.backgroundColor = UIColor(red:174/255, green:226/255, blue:118/255,alpha:1)
        btnShare.layer.cornerRadius = 8
        
        btnRemove = UIButton()
        btnRemove.setTitle("Remove", for: .normal)
        btnRemove.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 18)
        btnRemove.setTitleColor(UIColor.white, for: .normal)
        btnRemove.backgroundColor = UIColor.faeAppRedColor()
        btnRemove.layer.cornerRadius = 8
        
        btnMemo = UIButton()
        btnMemo.setTitle("Memo", for: .normal)
        btnMemo.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 18)
        btnMemo.setTitleColor(UIColor.white, for: .normal)
        btnMemo.backgroundColor = UIColor.faeAppPurpleColor()
        btnMemo.layer.cornerRadius = 8
        
        
        btnShare.addTarget(self, action: #selector(self.actionBtnShare(_:)), for: .touchUpInside)
        btnRemove.addTarget(self, action: #selector(self.actionBtnRemove(_:)), for: .touchUpInside)
        btnMemo.addTarget(self, action: #selector(self.actionBtnMemo(_:)), for: .touchUpInside)
        
        viewEditbar.addSubview(btnShare)
        viewEditbar.addSubview(btnRemove)
        viewEditbar.addSubview(btnMemo)
        
        viewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views:btnShare)
        viewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views:btnMemo)
        viewEditbar.addConstraintsWithFormat("V:[v0(38)]-10-|", options: [], views:btnRemove)
        viewEditbar.addConstraintsWithFormat("H:|-10-[v0(\(screenWidth/3-12))]-[v1(\(screenWidth/3-12))]-[v2(\(screenWidth/3-12))]-10-|", options: [], views:btnShare, btnMemo, btnRemove)
        
        btnShare.isEnabled = false
        btnMemo.isEnabled = false
        btnRemove.isEnabled = false
        btnShare.alpha = 0.6
        btnMemo.alpha = 0.6
        btnRemove.alpha = 0.6
        viewEditbar.isHidden = true
        
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
        
        // button for edit, show only for saved locations and places page
        btnEdit = UIButton(type: .custom)
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.titleLabel?.font = UIFont(name: "AvenirNext-Medium",size: 18)
        btnEdit.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnEdit.backgroundColor = .clear
        btnEdit.addTarget(self, action: #selector(self.actionEditCurrentTable(_:)), for: .touchUpInside)
        btnEdit.isHidden = true
        uiviewNavBar.addSubview(btnEdit)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(46)]-15-|", options: [], views: btnEdit)
        uiviewNavBar.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: btnEdit)
        
        
    }
    
    
    
    // Action fuction when the edit button is tapped
    func actionEditCurrentTable(_ sender: UIButton){
        if !TblResult.isEditing {
            btnEdit.setTitle("Done", for: .normal)
            //            isbtnEdittaped = true
            TblResult.isEditing = true
            TblResult.reloadData()
            viewEditbar.isHidden = false
            TblResult.frame = CGRect(x: 0,y: 65,width: screenWidth,height: screenHeight-65-56)
            arrSelectedItem.removeAll()
            
            viewSearchBarCover.removeGestureRecognizer(tap)
            viewSearchBarCover.addGestureRecognizer(tapdisable)
            
            
            
        }else{
            btnEdit.setTitle("Edit", for: .normal)
            TblResult.isEditing = false
            TblResult.reloadData()
            viewEditbar.isHidden = true
            TblResult.frame = CGRect(x: 0,y: 65,width: screenWidth,height: screenHeight-65)
            arrSelectedItem.removeAll()
            viewSearchBarCover.removeGestureRecognizer(tapdisable)
            viewSearchBarCover.addGestureRecognizer(tap)
            
        }
        
    }
    
    
    private func loadSearchBar(){
        
        SearchBar = UISearchBar()
        SearchBar.frame = CGRect(x: 0,y: 0,width: screenWidth,height: 50)
        
        switch tblTitle {
            
        case "Saved Places":
            SearchBar.placeholder = "Search Places"
            
        case "Saved Locations":
            SearchBar.placeholder = "Search Locations"
            
        default: break
        }
        
        
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
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDown(_:)))
        tapdisable = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDownDisable(_:)))
        
        viewSearchBarCover.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
    }
    
    
    private func loadTblResult(){
        
        viewBackground = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        viewBackground.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        
        viewBackground.center.x += screenWidth
        TblResult = UITableView(frame: CGRect(x: 0,y: 65,width: screenWidth,height: screenHeight-65), style: UITableViewStyle.plain)
        TblResult.backgroundColor = .white
        TblResult.register(PlaceAndLocationTableViewCell.self, forCellReuseIdentifier: "PlaceAndLocationCell")
        TblResult.delegate = self
        TblResult.dataSource = self
        TblResult.showsVerticalScrollIndicator = false
        
        //for auto layout
        TblResult.rowHeight = UITableViewAutomaticDimension
        TblResult.estimatedRowHeight = 90
        
        self.view.addSubview(viewBackground)
        
        emptyTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptyTblImgView.image = #imageLiteral(resourceName: "empty_table_bg")
        emptyTblImgView.isHidden = true
        
        emptySavedTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptySavedTblImgView.image = #imageLiteral(resourceName: "empty_savedtable_bg")
        emptySavedTblImgView.isHidden = true
        
        
        viewBackground.addSubview(emptyTblImgView)
        viewBackground.addSubview(emptySavedTblImgView)
        viewBackground.addSubview(TblResult)
        
        //load searchbar at the head of table
        loadSearchBar()
        TblResult.tableHeaderView = SearchBar
        
        
    }
    
    // Creat the search view when tap the fake searchbar
    func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let searchVC = CollectionSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: false, completion: nil)
        searchVC.tableTypeName = tblTitle
        searchVC.dataArray = placeAndLocationDataArr as [[String : AnyObject]]
        
    }
    
    
    func searchBarTapDownDisable(_ sender: UITapGestureRecognizer) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // This function is the action function for the select button in the cell when the table is editable
    func actionSelectBtnInCell(_ sender: UIButton){
        
        let sectionId = sender.tag
        
        let path : IndexPath = IndexPath(row: 0, section: sectionId)
        let  cellInGivenId : PlaceAndLocationTableViewCell = TblResult.cellForRow(at: path) as!   PlaceAndLocationTableViewCell
        
        if(!arrSelectedItem.contains(sectionId)){
            
            if(arrSelectedItem.count == 0){
                btnShare.isEnabled = true
                btnMemo.isEnabled = true
                btnRemove.isEnabled = true
                btnShare.alpha = 1
                btnMemo.alpha = 1
                btnRemove.alpha = 1
            }
            arrSelectedItem.append(sectionId)
            cellInGivenId.btnSelected.layer.borderColor = UIColor.faeAppRedColor().cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor.faeAppRedColor().cgColor
            
        }
        else{
            arrSelectedItem.remove(at: arrSelectedItem.index(of: sectionId)!)
            cellInGivenId.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
            cellInGivenId.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
            
            if(arrSelectedItem.count == 0){
                btnShare.isEnabled = false
                btnMemo.isEnabled = false
                btnRemove.isEnabled = false
                btnShare.alpha = 0.6
                btnMemo.alpha = 0.6
                btnRemove.alpha = 0.6
            }
        }
        
    }
    
    func actionBtnShare(_ sender: UIButton){
        // share
    }
    
    
    func actionBtnMemo(_ sender: UIButton){
        // memo
        
        let memoVC = MemoViewController()
        memoVC.modalPresentationStyle = .overCurrentContext
        memoVC.delegate = self
        self.present(memoVC, animated: false, completion: nil)
        
    }
    // delegate func(transfer the memo data from memoVC to current VC)
    func memoContent(save: Bool, content: String){
        if(save){
            for item in arrSelectedItem{
                
                placeAndLocationDataArr[item]["memo"] = content
                
            }
            TblResult.reloadData()
            arrSelectedItem.removeAll()
            btnShare.isEnabled = false
            btnMemo.isEnabled = false
            btnRemove.isEnabled = false
            btnShare.alpha = 0.6
            btnMemo.alpha = 0.6
            btnRemove.alpha = 0.6
        }
    }
    
    
    func actionBtnRemove(_ sender: UIButton){
        //Remove
        arrSelectedItem.sort {$0 > $1}  //倒序排序，这样保证原数据删除的时候是倒着删 不打乱顺序
        
        for item in arrSelectedItem{
            //            let path : IndexPath = IndexPath(row: 0, section: item)
            //            let  cellInGivenId : PlaceAndLocationTableViewCell = TblResult.cellForRow(at: path) as!   PlaceAndLocationTableViewCell
            //
            //            cellInGivenId.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
            //            cellInGivenId.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
            
            placeAndLocationDataArr.remove(at: item)
            
        }
        TblResult.reloadData()
        arrSelectedItem.removeAll()
        btnShare.isEnabled = false
        btnMemo.isEnabled = false
        btnRemove.isEnabled = false
        btnShare.alpha = 0.6
        btnMemo.alpha = 0.6
        btnRemove.alpha = 0.6
    }
    
    
    
    
    
    
    
    
    
    
    //以下代码是table的构造
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return placeAndLocationDataArr.count
        
    }
    /* To add the space between the cells, we use indexPath.section to get the current cell index. And there is just one row in every section. When we want to get the index of cell, we use indexPath.section rather than indexPath.row */
    
    // Set the spacing between sections
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceAndLocationCell", for: indexPath) as! PlaceAndLocationTableViewCell
        cell.setValueForCell(_: placeAndLocationDataArr[indexPath.section] as [String : AnyObject])
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
            
            //每次刷新都把选中的button清空成灰色
            cell.btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
            cell.btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
            
            
        }
        else
        {
            cell.distance.isHidden = false
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


