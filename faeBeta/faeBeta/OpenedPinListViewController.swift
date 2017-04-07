//
//  OpenedPinListViewController.swift
//  faeBeta
//
//  Created by Yue on 11/1/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol OpenedPinListViewControllerDelegate {
    // Directly back to main map
    func directlyReturnToMap()
    // Pass location to fae map view via CommentPinDetailViewController
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, pinID: String)
}

class OpenedPinListViewController: UIViewController {
    
    var delegate: OpenedPinListViewControllerDelegate?

    var buttonBackToMap: UIButton!
    var buttonSubviewBackToMap: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var commentListExpand = false
    var commentListShowed = false
    var labelCommentPinListTitle: UILabel!
    var openedPinListArray = [String]()
    var subviewTable: UIView!
    var subviewWhite: UIView!
    var tableOpenedPin: UITableView!
    var uiviewCommentPinListUnderLine01: UIView!
    var uiviewCommentPinListUnderLine02: UIView!
    var draggingButtonSubview: UIView!
    // For Dragging
    var commentPinSizeFrom: CGFloat = 0
    var commentPinSizeTo: CGFloat = 0
    
    // Control the back to comment pin detail button, prevent the more than once action
    var backJustOnce = true
    
    // Local Storage for storing opened pin id, for opened pin list use
    let storageForOpenedPinList = UserDefaults.standard //??
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let listArray = readByKey("openedPinList") {
            self.openedPinListArray = listArray as! [String]
        }
        buttonSubviewBackToMap = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(buttonSubviewBackToMap)
        self.view.sendSubview(toBack: buttonSubviewBackToMap)
        buttonSubviewBackToMap.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), for: UIControlEvents.touchUpInside)
        loadPinList()
        backJustOnce = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // To get opened pin list, but it is a general func
    func readByKey(_ key: String) -> AnyObject? {
        if let obj = self.storageForOpenedPinList.object(forKey: key) {
            return obj as AnyObject?
        }
        return nil
    }
    
    // Load comment pin list
    func loadPinList() {
        var tableHeight = CGFloat(openedPinListArray.count * 76)
        let subviewTableHeight = CGFloat(255)
        if openedPinListArray.count > 3 {
            tableHeight = CGFloat(228)
        }
        subviewWhite = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewWhite.backgroundColor = UIColor.white
        self.view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 2
        
        subviewTable = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: subviewTableHeight))
        subviewTable.backgroundColor = UIColor.white
        self.view.addSubview(subviewTable)
        subviewTable.layer.zPosition = 1
        
        tableOpenedPin = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableHeight))
        tableOpenedPin.register(OPLTableViewCell.self, forCellReuseIdentifier: "openedPinCell")
        tableOpenedPin.delegate = self
        tableOpenedPin.dataSource = self
        tableOpenedPin.tableFooterView = UIView.init(frame: CGRect.zero)
        subviewTable.addSubview(tableOpenedPin)
        if self.openedPinListArray.count > 3 {
            self.tableOpenedPin.isScrollEnabled = true
        }
        else {
            self.tableOpenedPin.isScrollEnabled = false
        }
        
        // Line at y = 64
        uiviewCommentPinListUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        subviewWhite.addSubview(uiviewCommentPinListUnderLine01)
        
        // Button: Back to Comment Detail
        buttonBackToMap = UIButton()
        buttonBackToMap.setImage(#imageLiteral(resourceName: "openedPinBackToMap"), for: UIControlState())
        buttonBackToMap.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
        subviewWhite.addSubview(buttonBackToMap)
        subviewWhite.addConstraintsWithFormat("H:|-(-21)-[v0(101)]", options: [], views: buttonBackToMap)
        subviewWhite.addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: buttonBackToMap)
        
        // Button: Clear Comment Pin List
        buttonCommentPinListClear = UIButton()
        buttonCommentPinListClear.setImage(#imageLiteral(resourceName: "openedPinClear"), for: UIControlState())
        buttonCommentPinListClear.addTarget(self, action: #selector(OpenedPinListViewController.actionClearCommentPinList(_:)), for: .touchUpInside)
        subviewWhite.addSubview(buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("H:[v0(42)]-15-|", options: [], views: buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: buttonCommentPinListClear)
        
        draggingButtonSubview = UIView(frame: CGRect(x: 0, y: subviewTableHeight - 28, width: screenWidth, height: 27))
        draggingButtonSubview.backgroundColor = UIColor.white
        self.subviewTable.addSubview(draggingButtonSubview)
        
        // Line at y = 228
        uiviewCommentPinListUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        draggingButtonSubview.addSubview(uiviewCommentPinListUnderLine02)
        
        // Button: Drag to larger
        buttonCommentPinListDragToLargeSize = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        buttonCommentPinListDragToLargeSize.setImage(#imageLiteral(resourceName: "pinDetailDraggingButton"), for: UIControlState())
        buttonCommentPinListDragToLargeSize.addTarget(self, action: #selector(OpenedPinListViewController.actionDraggingThisList(_:)), for: .touchUpInside)
        draggingButtonSubview.addSubview(buttonCommentPinListDragToLargeSize)
//        buttonCommentPinListDragToLargeSize.layer.borderColor = UIColor.black.cgColor
//        buttonCommentPinListDragToLargeSize.layer.borderWidth = 1
//        let panCommentPinListDrag = UIPanGestureRecognizer(target: self, action: #selector(OpenedPinListViewController.panActionCommentPinListDrag(_:)))
//        buttonCommentPinListDragToLargeSize.addGestureRecognizer(panCommentPinListDrag)
        
        // Label of Title
        labelCommentPinListTitle = UILabel()
        labelCommentPinListTitle.text = "Opened Pins"
        labelCommentPinListTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinListTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinListTitle.textAlignment = .center
        subviewWhite.addSubview(labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .centerX, relatedBy: .equal, toItem: self.subviewWhite, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
}
