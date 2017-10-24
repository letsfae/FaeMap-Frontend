//
//  CollectionsViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-24.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

enum CollectionTableMode: String {
    case place
    case location
}

class CollectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CollectionsListDetailDelegate, CreateColListDelegate {
    var btnNavBarMenu: UIButton!
    var imgTick: UIImageView!
    var uiviewDropDownMenu: UIView!
    var tblCollections: UITableView!
    var btnPlaces: UIButton!
    var btnLocations: UIButton!
    var lblPlaces: UILabel!
    var lblLocations: UILabel!
    var countPlaces: Int = 0
    var countLocations: Int = 0
    var tableMode: CollectionTableMode = .place
    var curtTitle: String = "Choose a Collection..."
    var navBarMenuBtnClicked: Bool = false
    var arrPlaces = [PinCollection]()
    var arrLocations = [PinCollection]()
    let faeCollection = FaeCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        laodMyListView()
        loadTable()
        loadDropDownMenu()
        loadNavBar()
        loadCollectionData()
    }
    
    fileprivate func loadCollectionData() {
        faeCollection.getCollections {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let collections = JSON(message!)
                
                guard let colArray = collections.array else {
                    print("[loadCollectionData] fail to parse collections info")
                    return
                }
                
                for col in colArray {
                    let data = PinCollection(json: col)
                    if data.colType == "place" {
                        self.arrPlaces.append(data)
                    }
                    if data.colType == "location" {
                        self.arrLocations.append(data)
                    }
                }
                
                self.countPlaces = self.arrPlaces.count
                self.countLocations = self.arrLocations.count
                self.tblCollections.reloadData()
            } else {
                print("[Get Collections] Fail to Get \(status) \(message!)")
            }
        }
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth - 260) / 2, y: 23, width: 260, height: 37))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarMenu.setTitle(curtTitle, for: .normal)
        btnNavBarMenu.setTitleColor(UIColor._898989(), for: .normal)
        btnNavBarMenu.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
    }
    
    fileprivate func btnNavBarSetTitle() {
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    fileprivate func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 103))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -36 // 65 - 201
        uiviewDropDownMenu.isHidden = true
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor._200199204()
        
        btnPlaces = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnPlaces)
        btnPlaces.tag = 0
        btnPlaces.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnLocations = UIButton(frame: CGRect(x: 0, y: 52, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnLocations)
        btnLocations.tag = 1
        btnLocations.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        lblPlaces = FaeLabel(CGRect(x: 104, y: 16, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnPlaces.addSubview(lblPlaces)
        
        lblLocations = FaeLabel(CGRect(x: 104, y: 16, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnLocations.addSubview(lblLocations)
        
        let imgPlaces = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgPlaces.image = #imageLiteral(resourceName: "collection_places")
        imgPlaces.contentMode = .center
        btnPlaces.addSubview(imgPlaces)
        
        let imgLocations = UIImageView(frame: CGRect(x: 56, y: 14, width: 28, height: 28))
        imgLocations.image = #imageLiteral(resourceName: "collection_locations")
        imgLocations.contentMode = .center
        btnLocations.addSubview(imgLocations)
        
        // imgTick.frame.origin.y = 20, 70, 120, 168
        imgTick = UIImageView(frame: CGRect(x: screenWidth - 70, y: 20, width: 16, height: 16))
        imgTick.image = #imageLiteral(resourceName: "mb_tick")
        uiviewDropDownMenu.addSubview(imgTick)
        
        let uiviewDropMenuFirstLine = UIView(frame: CGRect(x: 41, y: 50, width: screenWidth - 82, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuFirstLine)
        uiviewDropMenuFirstLine.backgroundColor = UIColor._206203203()
        
        updateCount()
    }
    
    fileprivate func updateCount() {
        countPlaces = arrPlaces.count
        let attributedStr1 = NSMutableAttributedString()
        let strPlaces = NSAttributedString(string: "Places ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        let countP = NSAttributedString(string: "(\(countPlaces))", attributes: [NSForegroundColorAttributeName : UIColor._155155155()])
        attributedStr1.append(strPlaces)
        attributedStr1.append(countP)
        lblPlaces.attributedText = attributedStr1
        
        countLocations = arrLocations.count
        let attributedStr2 = NSMutableAttributedString()
        let strLocations = NSAttributedString(string: "Locations ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        let countL = NSAttributedString(string: "(\(countLocations))", attributes: [NSForegroundColorAttributeName : UIColor._155155155()])
        attributedStr2.append(strLocations)
        attributedStr2.append(countL)
        lblLocations.attributedText = attributedStr2
    }
    
    fileprivate func laodMyListView() {
        let uiviewMyList = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 25))
        uiviewMyList.backgroundColor = UIColor._248248248()
        view.addSubview(uiviewMyList)
        
        let lblMyList = UILabel(frame: CGRect(x: 15, y: 3, width: 60, height: 20))
        lblMyList.text = "My Lists"
        lblMyList.textColor = UIColor._155155155()
        lblMyList.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        uiviewMyList.addSubview(lblMyList)
        
        let line = UIView()
        line.backgroundColor = UIColor._200199204()
        uiviewMyList.addSubview(line)
        uiviewMyList.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: line)
        uiviewMyList.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: line)
    }
    
    fileprivate func loadTable() {
        tblCollections = UITableView(frame: CGRect(x: 0, y: 90, width: screenWidth, height: screenHeight - 90), style: UITableViewStyle.plain)
        view.addSubview(tblCollections)
        tblCollections.backgroundColor = .white
        tblCollections.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        tblCollections.register(CollectionsEmptyListCell.self, forCellReuseIdentifier: "CollectionsEmptyListCell")
        tblCollections.delegate = self
        tblCollections.dataSource = self
        tblCollections.separatorStyle = .none
        tblCollections.showsVerticalScrollIndicator = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rollUpDropDownMenu(_:)))
        tblCollections.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    fileprivate func hideDropDownMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36
        }, completion: { _ in
            self.uiviewDropDownMenu.isHidden = true
        })
        
        navBarMenuBtnClicked = false
    }
    
    func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            uiviewDropDownMenu.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65
            })
            navBarMenuBtnClicked = true
        } else {
            hideDropDownMenu()
        }
        updateCount()
    }
    
    // function for hide the drop down menu when tap on table
    func rollUpDropDownMenu(_ tap: UITapGestureRecognizer) {
        hideDropDownMenu()
    }
    
    // function for buttons in drop down menu
    func dropDownMenuAct(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            curtTitle = "Places"
            tableMode = .place
            imgTick.frame.origin.y = 20
            break
        case 1:
            curtTitle = "Locations"
            tableMode = .location
            imgTick.frame.origin.y = 70
            break
        default:
            return
        }
        btnNavBarSetTitle()
        hideDropDownMenu()
        tblCollections.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        } else {
            return tableMode == .place ? arrPlaces.count : arrLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsEmptyListCell", for: indexPath) as! CollectionsEmptyListCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
            let collection = tableMode == .place ? arrPlaces[indexPath.row] : arrLocations[indexPath.row]
            cell.setValueForCell(cols: collection)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = CreateColListViewController()
            vc.delegate = self
            vc.enterMode = tableMode
            present(vc, animated: true)
        } else {
            let vc = CollectionsListDetailViewController()
            vc.delegate = self
            vc.indexPath = indexPath
            vc.enterMode = tableMode
            vc.arrColDetails = tableMode == .place ? arrPlaces[indexPath.row] : arrLocations[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
    
    // CollectionsListDetailDelegate
    func deleteColList(enterMode: CollectionTableMode, indexPath: IndexPath) {
        if enterMode == .place {
            arrPlaces.remove(at: indexPath.row)
        } else {
            arrLocations.remove(at: indexPath.row)
        }
        reloadAfterDelete(indexPath: indexPath)
    }
    
    func updateColName(enterMode: CollectionTableMode, indexPath: IndexPath, name: String, numItems: Int) {
        if enterMode == .place {
            arrPlaces[indexPath.row].colName = name
            arrPlaces[indexPath.row].itemsCount = numItems
        } else {
            arrLocations[indexPath.row].colName = name
            arrLocations[indexPath.row].itemsCount = numItems
        }
        tblCollections.reloadRows(at: [indexPath], with: .none)
    }
    
    func reloadAfterDelete(indexPath: IndexPath) {
        tblCollections.performUpdate({
            self.tblCollections.deleteRows(at: [indexPath], with: .right)
        }) {
            self.tblCollections.reloadData()
        }
    }
    
    // CreateColListDelegate
    func updateCols(col: PinCollection) {
        if col.colType == "place" {
            arrPlaces.append(col)
        } else {
            arrLocations.append(col)
        }
        tblCollections.reloadData()
        print(col)
    }
    
    func saveSettings(name: String, desp: String) {}
}
