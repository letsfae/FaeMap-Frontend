//
//  PinColViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 1/31/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
//import SDWebImage
//import RealmSwift


class PinColViewController: UIViewController, UISearchBarDelegate {
    
    
    // Table bar
    var viewTable: UIView!
    var TblResult: UITableView!
    var viewSearchBarCover: UIView! //Transparent view to cover the searchbar for detect the click event
    var SearchBar: UISearchBar!
    var emptyTblImgView: UIImageView!
    var emptySavedTblImgView: UIImageView!
    var arrSelectedItem = [Int]() // Store the id of selected cell when the table is editing
    
    // Edit bar, show when the table is editable
    var viewEditbar:UIView!
    var btnShare: UIButton!
    var btnRemove: UIButton!
    
    
    //Nagivation Bar Init******
    var uiviewNavBar: UIView!
    var btnNavBar: UIButton!
    
    var btnTop: UIButton!
    var btnMiddle: UIButton!
    var btnBottom: UIButton!

    
    var btnBack: UIButton!
    var btnEdit: UIButton!
//    var isbtnEdittaped: Bool!
    
    var NavBarLineTop: UIView!
    var NavBarLineBottom: UIView!
    
    var uiviewNavBarMenu: UIView!
    var navbarclicked = true;

    
    var navbar: UITextView!
    var NameArray:[String] = ["Saved Pins", "Saved Places", "Saved Locations"]
    var currentTitle : String  = "My Pins"
 
    
    
    //The set of searched results
    var filteredArr = [[String: AnyObject]]()
    
    
    var myPinDataArr = [[String: AnyObject]]()
    

    
    // Navigation bar Init******

    
    var savedPinDataArr = [[String: AnyObject]]()
    //[["September 23, 2016","3 hours left on Map","There’s a party going on later near the USC campus, anyone wanna go with me? Looking for aroup GROUPA.","999M","997M","1","0"],["September 23, 2015","3 hours left on Map","saved place test test test","999M","999M","0","1"]]
    
    
    var locationDataArr = [[String: AnyObject]]()
        
        
        
//        [["325 W ADAMS BLVD","LOS ANGELES, CA 90007 UNITED STATES","< 0.1 km"],["3335 S Figueroa St","LOS ANGELES, CA 90006 UNITED STATES","1.6 km"],["925 W 34th St","LOS ANGELES, CA 90089 UNITED STATES","2.2 km"],["307 E Jefferson Blvd","LOS ANGELES, CA 90011 UNITED STATES","2.3 km"],["900 Exposition Blvd21123213213213213123213","LOS ANGELES, CA 90007 UNITED STATES","> 999 km"]]
    
    var placeDataArr = [[String: AnyObject]]()
    //[["325 W ADAMS BLVD","LOS ANGELES, CA 90007 UNITED STATES","< 0.1 km"],["3335 S Figueroa St","LOS ANGELES, CA 90006 UNITED STATES","1.6 km"],["925 W 34th St","LOS ANGELES, CA 90089 UNITED STATES","2.2 km"],["saved place test","LOS ANGELES, CA 90007 UNITED STATES","> 999 km"],["325 W ADAMS BLVD","LOS ANGELES, CA 90007 UNITED STATES","< 0.1 km"]]

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        getMyPins()
        loadTblResult()
        loadNavBar()
        loadEditBar()
    }
    
    
    func getMyPins() {
        let getMyPinsData = FaeMap()
        getMyPinsData.getMyPins() {(status: Int, message: Any?) in
                if status == 200 {
                    print("Successfully get my pins!")
                    self.myPinDataArr.removeAll()
                    let PinsOfMyPinsJSON = JSON(message!)

                    if PinsOfMyPinsJSON.count > 0 {
                        for i in 0...(PinsOfMyPinsJSON.count-1) {
                            var dicCell = [String: AnyObject]()
                            
                            if let time = PinsOfMyPinsJSON[i]["created_at"].string {
                                dicCell["created_at"] = time as AnyObject?
                            }
                            let pin_id = PinsOfMyPinsJSON[i]["pin_id"].int
                            let type = PinsOfMyPinsJSON[i]["type"].string

                            if pin_id != nil && type != nil{
                                dicCell["type"] = type as AnyObject?
                                dicCell["pin_id"] = pin_id as AnyObject?
                                getMyPinsData.getPin(type: "\(type!)", pinId: String(describing: pin_id!)) {(status: Int, message: Any?) in
                                
                                    if status == 200 {
                                        let getPinByIdJSON = JSON(message!)

                                        if let content = getPinByIdJSON["content"].string {
                                            self.myPinDataArr[i]["content"] = content as AnyObject?
                                        }
                                        //因为media tab里面存的不叫content 叫description
                                        if let description = getPinByIdJSON["description"].string {
                                            self.myPinDataArr[i]["description"] = description as AnyObject?
                                        }

                                        if let liked_count = getPinByIdJSON["liked_count"].int {
                                            self.myPinDataArr[i]["liked_count"] = liked_count as AnyObject?
                                        }

                                        if let comment_count = getPinByIdJSON["comment_count"].int {
                                            self.myPinDataArr[i]["comment_count"] = comment_count as AnyObject?
                                        }
                                        
                                        if let mediaImgArr = getPinByIdJSON["file_ids"].array {
                                            self.myPinDataArr[i]["file_ids"] = mediaImgArr as AnyObject?
                                        }
                                        

                                        // reload the table when get the cell data
                                        self.TblResult.reloadData()
//                                        let indexpath = IndexPath(row: 0, section: i)
//                                        self.TblResult.reloadRows(at: [indexpath], with: .fade)
                                        
                                        
                                    }
                                    else{
                                        print("fail to get the Pin by given id")
                                    }
                                }
                            }
                            self.myPinDataArr.append(dicCell)
                           
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
                }
                else {
                    print("Fail to get my pins!")
                }
            }
    }
    
    
    func getSavedPins() {
        let getSavedPinsData = FaeMap()
        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
            if status == 200 {
                print("Successfully get saved pins!")
                self.savedPinDataArr.removeAll()
                let PinsOfSavedPinsJSON = JSON(message!)

                
                if PinsOfSavedPinsJSON.count > 0 {
                    for i in 0...(PinsOfSavedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        
                        if let time = PinsOfSavedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject?
                        }
                        let pin_id = PinsOfSavedPinsJSON[i]["pin_id"].int
                        let type = PinsOfSavedPinsJSON[i]["type"].string

                        if pin_id != nil && type != nil{
                            dicCell["type"] = type as AnyObject?
                            dicCell["pin_id"] = pin_id as AnyObject?
                            getSavedPinsData.getPin(type: "\(type!)", pinId: String(describing: pin_id!)) {(status: Int, message: Any?) in
                                
                                if status == 200 {
                                    let getPinByIdJSON = JSON(message!)

                                    if let content = getPinByIdJSON["content"].string {
                                        self.savedPinDataArr[i]["content"] = content as AnyObject?
                                    }
                                    //因为media tab里面存的不叫content 叫description
                                    if let description = getPinByIdJSON["description"].string {
                                        self.savedPinDataArr[i]["description"] = description as AnyObject?
                                    }
                                    
                                    if let liked_count = getPinByIdJSON["liked_count"].int {
                                        self.savedPinDataArr[i]["liked_count"] = liked_count as AnyObject?
                                    }
                                    
                                    if let comment_count = getPinByIdJSON["comment_count"].int {
                                        self.savedPinDataArr[i]["comment_count"] = comment_count as AnyObject?
                                    }
                                    
                                    if let mediaImgArr = getPinByIdJSON["file_ids"].array {
                                        self.savedPinDataArr[i]["file_ids"] = mediaImgArr as AnyObject?
                                    }
                                    // reload the table when get the cell data

                                    self.TblResult.reloadData()
                                    
                                }
                                else{
                                    print("fail to get the Pin by given id")
                                }
                            }
                        }
                        self.savedPinDataArr.append(dicCell)
                        
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
            }
            else {
                print("Fail to get saved pins!")
            }
        }
    }
    
    
    
    
    
    func loadEditBar(){
        viewEditbar = UIView(frame: CGRect(x: 0, y: screenHeight-56, width: screenWidth, height: 56))
        viewEditbar.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        self.view.addSubview(viewEditbar)
        
        btnShare = UIButton(frame: CGRect(x: 4, y: 9, width: 201, height: 38))
        btnShare.setTitle("Share", for: .normal)
        btnShare.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 18)
        btnShare.setTitleColor(UIColor.white, for: .normal)
        btnShare.backgroundColor = UIColor(red:174/255, green:226/255, blue:118/255,alpha:1)
        btnShare.layer.cornerRadius = 8
        
        btnRemove = UIButton(frame: CGRect(x: screenWidth-4-201, y: 9, width: 201, height: 38))
        btnRemove.setTitle("Remove", for: .normal)
        btnRemove.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 18)
        btnRemove.setTitleColor(UIColor.white, for: .normal)
        btnRemove.backgroundColor = UIColor.faeAppRedColor()
        btnRemove.layer.cornerRadius = 8
        
        btnShare.addTarget(self, action: #selector(self.actionBtnShare(_:)), for: .touchUpInside)
        btnRemove.addTarget(self, action: #selector(self.actionBtnRemove(_:)), for: .touchUpInside)
        
        viewEditbar.addSubview(btnShare)
        viewEditbar.addSubview(btnRemove)
        viewEditbar.isHidden = true
    
    }
    
    
    
    func loadNavBar() {
        
        loadNavBarMenu()
        
        uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        
        
        let MyPinsAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor() ]
        let MyPinsString = NSMutableAttributedString(string: currentTitle + " ", attributes: MyPinsAttribute )
        
        
        let DownAttachment = InlineTextAttachment()
        DownAttachment.fontDescender = 1
        DownAttachment.image =  #imageLiteral(resourceName: "menu_down")
        let DownString = NSAttributedString(attachment: DownAttachment)
        
        let MyPinsDownString = MyPinsString;
        MyPinsDownString.append(DownString)   //append image and text "My Pins"
        
        
        //        self.view.addSubview(backgroundpicView)
        self.view.addSubview(uiviewNavBar)
        
        btnNavBar = UIButton(frame: CGRect(x: 0, y: 29, width: 200, height: 27))
        btnNavBar.center.x = screenWidth / 2
        btnNavBar.setAttributedTitle(MyPinsString, for: UIControlState.normal)
        
        btnBack = UIButton(frame: CGRect(x: 16, y: 33, width: 10.5, height: 18))
        
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        
        btnBack.addTarget(self, action: #selector(PinColViewController.actionDimissCurrentView(_:)), for: .touchUpInside)
        
        btnNavBar.addTarget(self, action: #selector(self.actionNavMenu(_:)), for: .touchUpInside)
        btnBack.addTarget(self, action: #selector(self.closeit(_:)), for: .touchUpInside)
        
        
        uiviewNavBar.addSubview(btnBack)
        uiviewNavBar.addSubview(btnNavBar)
        
        // button for edit, show only for saved locations and places page
        btnEdit = UIButton(type: .custom)
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.titleLabel?.font = UIFont(name: "AvenirNext-Medium",size: 18)
        btnEdit.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnEdit.backgroundColor = .clear
        btnEdit.addTarget(self, action: #selector(PinColViewController.actionEditCurrentTable(_:)), for: .touchUpInside)
        btnEdit.isHidden = true
        uiviewNavBar.addSubview(btnEdit)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(46)]-15-|", options: [], views: btnEdit)
        uiviewNavBar.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: btnEdit)
//        isbtnEdittaped = false
        
        

    }
    
    func actionDimissCurrentView(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func closeit(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    private func loadNavBarMenu() {
        uiviewNavBarMenu = UIView(frame: CGRect(x: -1, y: 64, width: screenWidth+2, height: 158))
        uiviewNavBarMenu.center.y -= 158
        uiviewNavBarMenu.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewNavBarMenu.layer.borderWidth = 1
        uiviewNavBarMenu.backgroundColor = UIColor.white
        
        
        btnTop = UIButton(frame: CGRect(x: 10, y: 15, width: screenWidth - 20, height: 25))
        btnTop.center.x = screenWidth / 2
        btnTop.setTitle(NameArray[0], for: .normal)
        btnTop.setTitleColor(UIColor.gray, for: .normal)
        btnTop.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnTop.titleLabel?.textAlignment = .center
        
        btnTop.addTarget(self, action: #selector(self.topBtnAct(_:)), for: .touchUpInside)
        uiviewNavBarMenu.addSubview(btnTop)
        
        btnMiddle = UIButton(frame: CGRect(x: 10, y: 65, width: screenWidth - 20, height: 25))
        btnMiddle.center.x = screenWidth / 2
        btnMiddle.setTitle(NameArray[1], for: .normal)
        btnMiddle.setTitleColor(UIColor.gray, for: .normal)
        btnMiddle.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnMiddle.titleLabel?.textAlignment = .center
        
        btnMiddle.addTarget(self, action: #selector(self.middleBtnAct(_:)), for: .touchUpInside)
        uiviewNavBarMenu.addSubview(btnMiddle)
        
        btnBottom = UIButton(frame: CGRect(x: 10, y: 115, width: screenWidth - 20, height: 25))
        btnBottom.center.x = screenWidth / 2
        btnBottom.setTitle(NameArray[2], for: .normal)
        btnBottom.setTitleColor(UIColor.gray, for: .normal)
        btnBottom.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnBottom.titleLabel?.textAlignment = .center
        
        btnBottom.addTarget(self, action: #selector(self.bottomBtnAct(_:)), for: .touchUpInside)
        uiviewNavBarMenu.addSubview(btnBottom)
        
        NavBarLineTop = UIView(frame: CGRect(x: 205, y: 55, width: 282.36, height: 1))
        NavBarLineTop.center.x = screenWidth / 2
        NavBarLineTop.backgroundColor = UIColor.faeAppShadowGrayColor()
        
        
        uiviewNavBarMenu.addSubview(NavBarLineTop)
        
        NavBarLineBottom = UIView(frame: CGRect(x: 205, y: 105, width: 282.36, height: 1))
        NavBarLineBottom.center.x = screenWidth / 2
        NavBarLineBottom.backgroundColor = UIColor.faeAppShadowGrayColor()
        
        uiviewNavBarMenu.addSubview(NavBarLineBottom)
        
        self.view.addSubview(uiviewNavBarMenu)
    }
    
    // Action fuction when the edit button is tapped
    func actionEditCurrentTable(_ sender: UIButton){
        if !TblResult.isEditing {
            btnEdit.setTitle("Done", for: .normal)
//            isbtnEdittaped = true
            TblResult.isEditing = true
            TblResult.reloadData()
            viewEditbar.isHidden = false
            TblResult.frame = CGRect(x: 0,y: 44,width: screenWidth,height: screenHeight-106-56)
            arrSelectedItem.removeAll()
            
 
            
        }else{
            btnEdit.setTitle("Edit", for: .normal)
//            isbtnEdittaped = false
            TblResult.isEditing = false
            TblResult.reloadData()
            viewEditbar.isHidden = true
            TblResult.frame = CGRect(x: 0,y: 44,width: screenWidth,height: screenHeight-106)
            arrSelectedItem.removeAll()
            
        }
    
    }
    
    
    
    func actionNavMenu(_ sender: UIButton) {
        
        if(navbarclicked)
        {
            UIView.animate(withDuration: 0.2,animations: {
                self.uiviewNavBarMenu.center.y += 158
            })
            
            let TitleAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.gray ]
            let TitleString = NSMutableAttributedString(string: currentTitle + " ", attributes: TitleAttribute )
            let ImageAttachment = NSTextAttachment()
            ImageAttachment.image = #imageLiteral(resourceName: "menu_up")
            let ImageString = NSAttributedString(attachment: ImageAttachment)
            TitleString.append(ImageString)   //append image and text "My Pins"
            btnNavBar.setAttributedTitle(TitleString, for: UIControlState.normal)
            
            
            navbarclicked = false;
        }
        else
        {
            UIView.animate(withDuration: 0.2,animations: {
                self.uiviewNavBarMenu.center.y -= 158
            })
            let TitleAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.gray ]
            let TitleString = NSMutableAttributedString(string: currentTitle + " ", attributes: TitleAttribute )
            let ImageAttachment = NSTextAttachment()
            ImageAttachment.image =  #imageLiteral(resourceName: "menu_down")
            let ImageString = NSAttributedString(attachment: ImageAttachment)
            TitleString.append(ImageString)
            btnNavBar.setAttributedTitle(TitleString, for: UIControlState.normal)
            
            navbarclicked = true;
        }
        
    }
    
    
   // The action function for the three button in the nagivation bar list
    
    func topBtnAct(_ sender: UIButton) {
        
        let temp = NameArray[0]
        NameArray[0] = currentTitle
        currentTitle = temp
        
        NameArray.sort{$0.characters.count < $1.characters.count}
        
        btnTop.setTitle(NameArray[0], for: UIControlState.normal)
        btnMiddle.setTitle(NameArray[1], for: UIControlState.normal)
        btnBottom.setTitle(NameArray[2], for: UIControlState.normal)
        let TitleAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.gray ]
        let TitleString = NSMutableAttributedString(string: currentTitle+" ", attributes: TitleAttribute )
        let ImageAttachment = NSTextAttachment()
        ImageAttachment.image = #imageLiteral(resourceName: "menu_down")
        let ImageString = NSAttributedString(attachment: ImageAttachment)
        TitleString.append(ImageString)
        btnNavBar.setAttributedTitle(TitleString, for: UIControlState.normal)
        
        UIView.animate(withDuration: 0.2,animations: {
            self.uiviewNavBarMenu.center.y -= 158
        })
        navbarclicked = true;
        
        
        
        //Reget the data from the server && show or hide the Edit button
        switch currentTitle {
            
        case "My Pins":
            btnEdit.isHidden = true
            getMyPins()
            
        case "Saved Pins":
            btnEdit.isHidden = true
            getSavedPins()
        
        default:
            TblResult.reloadData()

            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
            if(filteredArr.count != 0){
                btnEdit.isHidden = false
            }
            
            
            if(self.filteredArr.count == 0){
                self.emptySavedTblImgView.isHidden = false
                self.SearchBar.isHidden = true
                self.TblResult.isHidden = true
            }
            else{
                self.emptySavedTblImgView.isHidden = true
                self.SearchBar.isHidden = false
                self.TblResult.isHidden = false
            }
            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
        }
        
    }
    
    func middleBtnAct(_ sender: UIButton) {
        
        let temp = NameArray[1]
        NameArray[1] = currentTitle
        currentTitle = temp
        
        NameArray.sort{$0.characters.count < $1.characters.count}
        
        btnTop.setTitle(NameArray[0], for: UIControlState.normal)
        btnMiddle.setTitle(NameArray[1], for: UIControlState.normal)
        btnBottom.setTitle(NameArray[2], for: UIControlState.normal)
        
        let TitleAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.gray ]
        let TitleString = NSMutableAttributedString(string: currentTitle+" " ,attributes: TitleAttribute )
        let ImageAttachment = NSTextAttachment()
        ImageAttachment.image = #imageLiteral(resourceName: "menu_down")
        let ImageString = NSAttributedString(attachment: ImageAttachment)
        TitleString.append(ImageString)
        btnNavBar.setAttributedTitle(TitleString, for: UIControlState.normal)
        
        UIView.animate(withDuration: 0.2,animations: {
            self.uiviewNavBarMenu.center.y -= 158
        })
        navbarclicked = true;
        
        
        //Reget the data from the server && show or hide the Edit button
        switch currentTitle {
            
        case "My Pins":
            btnEdit.isHidden = true
            getMyPins()
            
        case "Saved Pins":
            btnEdit.isHidden = true
            getSavedPins()
            
        default:
            TblResult.reloadData()
            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
            if(filteredArr.count != 0){
                btnEdit.isHidden = false
            }
            
            
            if(self.filteredArr.count == 0){
                self.emptySavedTblImgView.isHidden = false
                self.SearchBar.isHidden = true
                self.TblResult.isHidden = true
            }
            else{
                self.emptySavedTblImgView.isHidden = true
                self.SearchBar.isHidden = false
                self.TblResult.isHidden = false
            }
            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
            

        }
        
    }
    
    func bottomBtnAct(_ sender: UIButton) {
        
        let temp = NameArray[2]
        NameArray[2] = currentTitle
        currentTitle = temp
        
        NameArray.sort{$0.characters.count < $1.characters.count}
        
        btnTop.setTitle(NameArray[0], for: UIControlState.normal)
        btnMiddle.setTitle(NameArray[1], for: UIControlState.normal)
        btnBottom.setTitle(NameArray[2], for: UIControlState.normal)
        
        let TitleAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.gray ]
        let TitleString = NSMutableAttributedString(string: currentTitle + " ", attributes: TitleAttribute )
        let ImageAttachment = NSTextAttachment()
        ImageAttachment.image = #imageLiteral(resourceName: "menu_down")
        let ImageString = NSAttributedString(attachment: ImageAttachment)
        TitleString.append(ImageString)
        btnNavBar.setAttributedTitle(TitleString, for: UIControlState.normal)
        UIView.animate(withDuration: 0.2,animations: {
            self.uiviewNavBarMenu.center.y -= 158
        })
        navbarclicked = true;
        
        
        //Reget the data from the server && show or hide the Edit button
        switch currentTitle {
            
        case "My Pins":
            btnEdit.isHidden = true
            getMyPins()
            
        case "Saved Pins":
            btnEdit.isHidden = true
            getSavedPins()
            
        default:
            TblResult.reloadData()
            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
            if(filteredArr.count != 0){
                btnEdit.isHidden = false
            }
            
            
            if(self.filteredArr.count == 0){
                self.emptySavedTblImgView.isHidden = false
                self.SearchBar.isHidden = true
                self.TblResult.isHidden = true
            }
            else{
                self.emptySavedTblImgView.isHidden = true
                self.SearchBar.isHidden = false
                self.TblResult.isHidden = false
            }
            /*Is the table empty 此处在这里判断是因为location 跟place还没有api,写好后要挪到get api数据那里进行判断，不让get api代码还没执行完成返回结果到filteredarr，filteredarr很可能还是空的， 外部判断就会以为是空表*/
            
        }
    }
    
    
    private func loadSearchBar(){
        
        SearchBar = UISearchBar()
        SearchBar.frame = CGRect(x: 0,y: 64,width: screenWidth,height: 50)
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
        
        self.view.addSubview(SearchBar)
        SearchBar.addSubview(viewSearchBarCover)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDown(_:)))
        
        viewSearchBarCover.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
    }
    
    
    private func loadTblResult(){
        
        viewTable = UIView(frame: CGRect(x: 0,y: 62,width: screenWidth,height: screenHeight-62))
        viewTable.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        TblResult = UITableView(frame: CGRect(x: 0,y: 44,width: screenWidth,height: screenHeight-106), style: UITableViewStyle.plain)
        TblResult.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
//        TblResult.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        TblResult.register(PinTableViewCell.self, forCellReuseIdentifier: "PinCell")
        TblResult.register(PlaceAndLocationTableViewCell.self, forCellReuseIdentifier: "PlaceAndLocationCell")
        TblResult.delegate = self
        TblResult.dataSource = self
        TblResult.showsVerticalScrollIndicator = false
        
        //for auto layout
        TblResult.rowHeight = UITableViewAutomaticDimension
        TblResult.estimatedRowHeight = 340
        
        self.view.addSubview(viewTable)
        
        emptyTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptyTblImgView.image = #imageLiteral(resourceName: "empty_table_bg")
        emptyTblImgView.isHidden = true
        
        emptySavedTblImgView = UIImageView(frame: CGRect(x: (screenWidth - 252)/2, y: (screenHeight - 209)/2-106, width: 252, height: 209))
        emptySavedTblImgView.image = #imageLiteral(resourceName: "empty_savedtable_bg")
        emptySavedTblImgView.isHidden = true

        
        
        
        viewTable.addSubview(emptyTblImgView)
        viewTable.addSubview(emptySavedTblImgView)
        viewTable.addSubview(TblResult)
        loadSearchBar()
        
        // Clear out the empty cells
        TblResult.tableFooterView = UIView()
    }
    
    // Creat the search view when tap the fake searchbar
    func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let pinsearchVC = PinsearchViewController()
        pinsearchVC.modalPresentationStyle = .overCurrentContext
        self.present(pinsearchVC, animated: false, completion: nil)
        pinsearchVC.tableTypeName = currentTitle
        
        switch currentTitle {
            
        case "My Pins":
            pinsearchVC.dataArray = myPinDataArr
            
        case "Saved Pins":
            pinsearchVC.dataArray = savedPinDataArr
            
        case "Saved Places":
            pinsearchVC.dataArray = placeDataArr
            
        case "Saved Locations":
            pinsearchVC.dataArray = locationDataArr
            
        // default is required, but never to be called here
        default:
            pinsearchVC.dataArray = myPinDataArr
        }
        
    }
    

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//class InlineTextAttachment: NSTextAttachment {
//    var fontDescender: CGFloat = 0
//    
//    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
//        var superRect = super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
//        
//        superRect.origin.y = fontDescender
//        
//        return superRect
//    }
//}



