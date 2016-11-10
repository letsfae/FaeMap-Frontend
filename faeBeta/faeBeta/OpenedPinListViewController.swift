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
    // Cancel marker's shadow when back to Fae Map
    func backFromOpenedPinList(back: Bool)
    // Pass location to fae map view via CommentPinDetailViewController
    func animateToCameraFromOpenedPinListView(coordinate: CLLocationCoordinate2D, commentID: Int)
}

class OpenedPinListViewController: UIViewController {
    
    var delegate: OpenedPinListViewControllerDelegate?

    var buttonBackToCommentPinDetail: UIButton!
    var buttonSubviewBackToMap: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var commentListExpand = false
    var commentListShowed = false
    var labelCommentPinListTitle: UILabel!
    var openedPinListArray = [Int]()
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
    let storageForOpenedPinList = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let listArray = readByKey("openedPinList") {
            self.openedPinListArray = listArray as! [Int]
        }
        buttonSubviewBackToMap = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        self.view.addSubview(buttonSubviewBackToMap)
        self.view.sendSubviewToBack(buttonSubviewBackToMap)
        buttonSubviewBackToMap.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        loadCommentPinList()
        backJustOnce = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // To get opened pin list, but it is a general func
    func readByKey(key: String) -> AnyObject? {
        if let obj = self.storageForOpenedPinList.objectForKey(key) {
            return obj
        }
        return nil
    }
    
    // Load comment pin list
    func loadCommentPinList() {
        var tableHeight: CGFloat = CGFloat(openedPinListArray.count * 76)
        var subviewTableHeight = tableHeight + 28
        if openedPinListArray.count <= 3 {
            subviewTableHeight = CGFloat(256)
        }
        else {
            tableHeight = CGFloat(228)
        }
        subviewTableHeight = CGFloat(256)
        
        subviewWhite = UIView(frame: CGRectMake(0, 0, screenWidth, 65))
        subviewWhite.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 2
        
        subviewTable = UIView(frame: CGRectMake(0, 65, screenWidth, subviewTableHeight))
        subviewTable.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(subviewTable)
        subviewTable.layer.zPosition = 1
        subviewTable.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        subviewTable.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        subviewTable.layer.shadowOpacity = 0.3
        subviewTable.layer.shadowRadius = 10.0
        
        tableOpenedPin = UITableView(frame: CGRectMake(0, 0, screenWidth, tableHeight))
        tableOpenedPin.registerClass(OpenedPinTableViewCell.self, forCellReuseIdentifier: "openedPinCell")
        tableOpenedPin.delegate = self
        tableOpenedPin.dataSource = self
        subviewTable.addSubview(tableOpenedPin)
        tableOpenedPin.scrollEnabled = false
        
        print("DEBUG: opened pin list height")
        print(tableHeight)
        print(subviewTableHeight)
        
        if tableHeight >= subviewTableHeight {
            
        }
        
        // Line at y = 64
        uiviewCommentPinListUnderLine01 = UIView(frame: CGRectMake(0, 64, screenWidth, 1))
        uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        subviewWhite.addSubview(uiviewCommentPinListUnderLine01)
        
        // Button: Back to Comment Detail
        buttonBackToCommentPinDetail = UIButton()
        buttonBackToCommentPinDetail.setImage(UIImage(named: "commentPinBackToCommentDetail"), forState: .Normal)
        buttonBackToCommentPinDetail.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), forControlEvents: .TouchUpInside)
        subviewWhite.addSubview(buttonBackToCommentPinDetail)
        subviewWhite.addConstraintsWithFormat("H:|-(-21)-[v0(101)]", options: [], views: buttonBackToCommentPinDetail)
        subviewWhite.addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: buttonBackToCommentPinDetail)
        
        // Button: Clear Comment Pin List
        buttonCommentPinListClear = UIButton()
        buttonCommentPinListClear.setImage(UIImage(named: "commentPinListClear"), forState: .Normal)
        buttonCommentPinListClear.addTarget(self, action: #selector(OpenedPinListViewController.actionClearCommentPinList(_:)), forControlEvents: .TouchUpInside)
        subviewWhite.addSubview(buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("H:[v0(42)]-15-|", options: [], views: buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: buttonCommentPinListClear)
        
        draggingButtonSubview = UIView(frame: CGRectMake(0, 228, screenWidth, 28))
        draggingButtonSubview.backgroundColor = UIColor.whiteColor()
        self.subviewTable.addSubview(draggingButtonSubview)
        draggingButtonSubview.layer.zPosition = 109
        
        // Line at y = 227
        uiviewCommentPinListUnderLine02 = UIView(frame: CGRectMake(0, 0, screenWidth, 1))
        uiviewCommentPinListUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        draggingButtonSubview.addSubview(uiviewCommentPinListUnderLine02)
        
        // Button: Drag to larger
        buttonCommentPinListDragToLargeSize = UIButton(frame: CGRectMake(0, 1, screenWidth, 27))
        buttonCommentPinListDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        buttonCommentPinListDragToLargeSize.addTarget(self, action: #selector(OpenedPinListViewController.actionDraggingThisList(_:)), forControlEvents: .TouchUpInside)
        draggingButtonSubview.addSubview(buttonCommentPinListDragToLargeSize)
//        let panCommentPinListDrag = UIPanGestureRecognizer(target: self, action: #selector(OpenedPinListViewController.panActionCommentPinListDrag(_:)))
//        buttonCommentPinListDragToLargeSize.addGestureRecognizer(panCommentPinListDrag)
        
        // Label of Title
        labelCommentPinListTitle = UILabel()
        labelCommentPinListTitle.text = "Opened Pins"
        labelCommentPinListTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinListTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinListTitle.textAlignment = .Center
        subviewWhite.addSubview(labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.subviewWhite, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
    }
}
