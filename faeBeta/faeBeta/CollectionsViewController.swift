//
//  CollectionsViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-24.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

enum CollectionTableMode: String {
    case place
    case location
}

class CollectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    private var btnNavBarMenu: UIButton!
    private var imgTick: UIImageView!
    private var uiviewDropDownMenu: UIView!
    private var tblCollections: UITableView!
    private var btnPlaces: UIButton!
    private var btnLocations: UIButton!
    private var lblPlaces: UILabel!
    private var lblLocations: UILabel!
    private var countPlaces: Int = 0
    private var countLocations: Int = 0
    private var tableMode: CollectionTableMode = .place
    private var curtTitle: String = "Places"
    private var navBarMenuBtnClicked: Bool = false
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var realmColPlaces: Results<RealmCollection>!
    private var realmColLocations: Results<RealmCollection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadCollectionData()
        loadMyListView()
        loadTable()
        loadDropDownMenu()
        loadNavBar()
        observeOnCollectionChange()
    }
    deinit {
        notificationToken?.invalidate()
    }
    
    private func loadCollectionData() {
        /*if realm.objects(RealmCollection.self).count != 0 {
            realmColPlaces = RealmCollection.filterCollectedTypes(type: "place")
            realmColLocations = RealmCollection.filterCollectedTypes(type: "location")
        }*/
        realmColPlaces = realm.filterCollectedTypes(type: "place")
        realmColLocations = realm.filterCollectedTypes(type: "location")
    }
    
    private func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        //uiviewNavBar.addConstraintsWithFormat("H:[v0(92)]-(-22)-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(createNewList), for: .touchUpInside)
        
        btnNavBarMenu = UIButton(frame: CGRect(x: (screenWidth - 260) / 2, y: 23 + device_offset_top, width: 260, height: 37))
        uiviewNavBar.addSubview(btnNavBarMenu)
        btnNavBarMenu.setTitleColor(UIColor._898989(), for: .normal)
        btnNavBarMenu.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btnNavBarMenu.addTarget(self, action: #selector(navBarMenuAct(_:)), for: .touchUpInside)
        btnNavBarSetTitle()
    }
    
    private func btnNavBarSetTitle() {
        let curtTitleAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: curtTitle + " ", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "mb_btnDropDown")
        
        let curtTitlePlusImg = curtTitleStr
        curtTitlePlusImg.append(NSAttributedString(attachment: downAttachment))
        btnNavBarMenu.setAttributedTitle(curtTitlePlusImg, for: .normal)
    }
    
    private func loadDropDownMenu() {
        uiviewDropDownMenu = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 101))
        uiviewDropDownMenu.backgroundColor = .white
        view.addSubview(uiviewDropDownMenu)
        uiviewDropDownMenu.frame.origin.y = -36 // 65 - 101
        uiviewDropDownMenu.isHidden = true
        
        let uiviewDropMenuBottomLine = UIView(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 1))
        uiviewDropDownMenu.addSubview(uiviewDropMenuBottomLine)
        uiviewDropMenuBottomLine.backgroundColor = UIColor._200199204()
        
        btnPlaces = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnPlaces)
        btnPlaces.tag = 0
        btnPlaces.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        btnLocations = UIButton(frame: CGRect(x: 0, y: 51, width: screenWidth, height: 50))
        uiviewDropDownMenu.addSubview(btnLocations)
        btnLocations.tag = 1
        btnLocations.addTarget(self, action: #selector(self.dropDownMenuAct(_:)), for: .touchUpInside)
        
        lblPlaces = FaeLabel(CGRect(x: 104, y: 14, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
        btnPlaces.addSubview(lblPlaces)
        
        lblLocations = FaeLabel(CGRect(x: 104, y: 14, width: 180 , height: 25), .left, .medium, 18, UIColor._898989())
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
    
    private func updateCount() {
        countPlaces = realmColPlaces != nil ? realmColPlaces.count : 0
        let attributedStr1 = NSMutableAttributedString()
        let strPlaces = NSAttributedString(string: "Places ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let countP = NSAttributedString(string: "(\(countPlaces))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr1.append(strPlaces)
        attributedStr1.append(countP)
        lblPlaces.attributedText = attributedStr1
        
        countLocations = realmColLocations != nil ? realmColLocations.count : 0
        let attributedStr2 = NSMutableAttributedString()
        let strLocations = NSAttributedString(string: "Locations ", attributes: [NSAttributedStringKey.foregroundColor : UIColor._898989()])
        let countL = NSAttributedString(string: "(\(countLocations))", attributes: [NSAttributedStringKey.foregroundColor : UIColor._155155155()])
        attributedStr2.append(strLocations)
        attributedStr2.append(countL)
        lblLocations.attributedText = attributedStr2
    }
    
    private func loadMyListView() {
        let uiviewMyList = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 25))
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
    
    private func loadTable() {
        tblCollections = UITableView(frame: CGRect(x: 0, y: 90 + device_offset_top, width: screenWidth, height: screenHeight - 90 - device_offset_top), style: UITableViewStyle.plain)
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
    
    private func hideDropDownMenu() {
        btnNavBarSetTitle()
        UIView.animate(withDuration: 0.2, animations: {
            self.uiviewDropDownMenu.frame.origin.y = -36 + device_offset_top
        }, completion: { _ in
            self.uiviewDropDownMenu.isHidden = true
        })
        
        navBarMenuBtnClicked = false
    }
    
    @objc private func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func navBarMenuAct(_ sender: UIButton) {
        if !navBarMenuBtnClicked {
            btnNavBarMenu.setAttributedTitle(nil, for: .normal)
            btnNavBarMenu.setTitle("Choose a Collection...", for: .normal)
            uiviewDropDownMenu.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewDropDownMenu.frame.origin.y = 65 + device_offset_top
            })
            navBarMenuBtnClicked = true
        } else {
            hideDropDownMenu()
        }
        updateCount()
    }
    
    // function for hide the drop down menu when tap on table
    @objc private func rollUpDropDownMenu(_ tap: UITapGestureRecognizer) {
        hideDropDownMenu()
    }
    
    // function for buttons in drop down menu
    @objc private func dropDownMenuAct(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            curtTitle = "Places"
            tableMode = .place
            imgTick.frame.origin.y = 20
        case 1:
            curtTitle = "Locations"
            tableMode = .location
            imgTick.frame.origin.y = 70
        default: return
        }
        btnNavBarSetTitle()
        hideDropDownMenu()
//        tblCollections.reloadData()
        observeOnCollectionChange()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableMode {
        case .place:
            return realmColPlaces.count == 0 ? 1 : realmColPlaces.count
        case .location:
            return realmColLocations.count == 0 ? 1 : realmColLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableMode {
        case .place:
            if realmColPlaces.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsEmptyListCell", for: indexPath) as! CollectionsEmptyListCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
                let collection = realmColPlaces[indexPath.row]
                cell.setValueForCell(cols: collection)
                return cell
            }
        case .location:
            if realmColLocations.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsEmptyListCell", for: indexPath) as! CollectionsEmptyListCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
                let collection = realmColLocations[indexPath.row]
                cell.setValueForCell(cols: collection)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        func gotoListDetail() {
            let vc = CollectionsListDetailViewController()
            vc.enterMode = tableMode
            vc.colId = tableMode == .place ? realmColPlaces[indexPath.row].collection_id : realmColLocations[indexPath.row].collection_id
            if let ctrler = Key.shared.FMVCtrler {
                vc.featureDelegate = ctrler
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
        switch tableMode {
        case .place:
            if realmColPlaces.count == 0 {
                createNewList()
            } else {
                gotoListDetail()
            }
        case .location:
            if realmColLocations.count == 0 {
                createNewList()
            } else {
                gotoListDetail()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func createNewList() {
        let vc = CreateColListViewController()
        vc.enterMode = tableMode
        present(vc, animated: true)
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDropDownMenu()
    }
    
    private func observeOnCollectionChange() {
        let datasource = tableMode == .place ? realmColPlaces : realmColLocations
        notificationToken?.invalidate()
        notificationToken = datasource?.observe { (changes: RealmCollectionChange) in
            guard let tableview = self.tblCollections else { return }
            switch changes {
            case .initial:
                tableview.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableview.beginUpdates()
                tableview.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .right)
                tableview.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.endUpdates()
            case .error:
                print("error")
            }
        }
    }
}

