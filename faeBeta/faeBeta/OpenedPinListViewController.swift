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
import GoogleMaps

protocol OpenedPinListViewControllerDelegate: class {
    // Directly back to main map
    func directlyReturnToMap()
    // Pass location to fae map view via CommentPinDetailViewController
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, index: Int)
}

class OpenedPinListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OpenedPinTableCellDelegate {
    
    weak var delegate: OpenedPinListViewControllerDelegate?
    
    var buttonBackToMap: UIButton!
    var buttonSubviewBackToMap: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var commentListExpand = false
    var commentListShowed = false
    var labelCommentPinListTitle: UILabel!
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
    let storageForOpenedPinList = UserDefaults.standard // ??
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSubviewBackToMap = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(buttonSubviewBackToMap)
        view.sendSubview(toBack: buttonSubviewBackToMap)
        buttonSubviewBackToMap.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), for: UIControlEvents.touchUpInside)
        loadPinList()
        backJustOnce = true
        UIApplication.shared.statusBarStyle = .default
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
        var tableHeight = CGFloat(OpenedPlaces.openedPlaces.count * 76)
        let subviewTableHeight = CGFloat(255)
        if OpenedPlaces.openedPlaces.count > 3 {
            tableHeight = CGFloat(228)
        }
        subviewWhite = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewWhite.backgroundColor = UIColor.white
        view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 2
        
        subviewTable = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: subviewTableHeight))
        subviewTable.backgroundColor = UIColor.white
        view.addSubview(subviewTable)
        subviewTable.layer.zPosition = 1
        subviewTable.layer.shadowColor = UIColor.gray.cgColor
        subviewTable.layer.shadowOffset = CGSize.zero
        subviewTable.layer.shadowOpacity = 1
        subviewTable.layer.shadowRadius = 25
        
        tableOpenedPin = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableHeight))
        tableOpenedPin.register(OPLTableViewCell.self, forCellReuseIdentifier: "openedPinCell")
        tableOpenedPin.delegate = self
        tableOpenedPin.dataSource = self
        tableOpenedPin.tableFooterView = UIView.init(frame: CGRect.zero)
        subviewTable.addSubview(tableOpenedPin)
        if OpenedPlaces.openedPlaces.count > 3 {
            tableOpenedPin.isScrollEnabled = true
        } else {
            tableOpenedPin.isScrollEnabled = false
        }
        
        // Line at y = 64
        uiviewCommentPinListUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        subviewWhite.addSubview(uiviewCommentPinListUnderLine01)
        
        // Button: Back to Comment Detail
        buttonBackToMap = UIButton()
        buttonBackToMap.setImage(#imageLiteral(resourceName: "pinDetailHalfPinBack"), for: .normal)
        buttonBackToMap.addTarget(self, action: #selector(actionBackToMap(_:)), for: .touchUpInside)
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
        subviewTable.addSubview(draggingButtonSubview)
        
        // Line at y = 228
        uiviewCommentPinListUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine02.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
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
        labelCommentPinListTitle.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        labelCommentPinListTitle.textAlignment = .center
        subviewWhite.addSubview(labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .centerX, relatedBy: .equal, toItem: subviewWhite, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableOpenedPin {
            return OpenedPlaces.openedPlaces.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableOpenedPin {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openedPinCell", for: indexPath) as! OPLTableViewCell
            
            cell.delegate = self
            cell.pinID = OpenedPlaces.openedPlaces[indexPath.row].pinId
            cell.indexPathInCell = indexPath
            cell.content.text = OpenedPlaces.openedPlaces[indexPath.row].title
            cell.time.text = OpenedPlaces.openedPlaces[indexPath.row].pinTime
            cell.location = OpenedPlaces.openedPlaces[indexPath.row].position
            cell.deleteButton.isEnabled = true
            cell.jumpToDetail.isEnabled = true
            cell.imageViewAvatar.image = placeCategory(placeType: OpenedPlaces.openedPlaces[indexPath.row].category)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    fileprivate func placeCategory(placeType: String) -> UIImage? {
        switch placeType {
        case "burgers":
            return #imageLiteral(resourceName: "openedPinBurger")
        case "pizza":
            return #imageLiteral(resourceName: "openedPinPizza")
        case "foodtrucks":
            return #imageLiteral(resourceName: "openedPinFoodtruck")
        case "coffee":
            return #imageLiteral(resourceName: "openedPinCoffee")
        case "desserts":
            return #imageLiteral(resourceName: "openedPinDessert")
        case "movietheaters":
            return #imageLiteral(resourceName: "openedPinCinema")
        case "beautysvc":
            return #imageLiteral(resourceName: "openedPinBeauty")
        case "playgrounds":
            return #imageLiteral(resourceName: "openedPinSport")
        case "museums":
            return #imageLiteral(resourceName: "openedPinArt")
        case "juicebars":
            return #imageLiteral(resourceName: "openedPinBoba")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableOpenedPin {
            return 76
        } else {
            return 0
        }
    }
    
    // When clicking dragging button in opened pin list window
    func actionDraggingThisList(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            
            UIView.animate(withDuration: 0.5, animations: ({
                self.draggingButtonSubview.frame.origin.y = 227
                self.subviewTable.frame.size.height = 256
                if OpenedPlaces.openedPlaces.count <= 3 {
                    self.tableOpenedPin.frame.size.height = CGFloat(OpenedPlaces.openedPlaces.count * 76)
                } else {
                    self.tableOpenedPin.frame.size.height = CGFloat(227)
                }
            }), completion: { (done: Bool) in
                if done {
                }
            })
            return
        }
        sender.tag = 1
        UIView.animate(withDuration: 0.5, animations: ({
            self.draggingButtonSubview.frame.origin.y = screenHeight - 93
            self.tableOpenedPin.frame.size.height = screenHeight - 92
            self.subviewTable.frame.size.height = screenHeight - 65
        }), completion: { (done: Bool) in
            if done {
            }
        })
    }
    
    // Back to main map from opened pin list
    func actionBackToMap(_ sender: UIButton) {
        delegate?.directlyReturnToMap()
        UIView.animate(withDuration: 0.4, animations: ({
            self.subviewWhite.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: {
                    
                })
            }
        })
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(_ sender: UIButton) {
        OpenedPlaces.openedPlaces.removeAll()
        tableOpenedPin.frame.size.height = 0
        tableOpenedPin.reloadData()
        actionBackToMap(buttonSubviewBackToMap)
    }
    
    func passCL2DLocationToOpenedPinList(_ coordinate: CLLocationCoordinate2D, index: Int) {
        dismiss(animated: false, completion: {
            self.delegate?.animateToCameraFromOpenedPinListView(coordinate, index: index)
        })
    }
    
    func deleteThisCellCalledFromDelegate(_ indexPath: IndexPath) {
        
        OpenedPlaces.openedPlaces.remove(at: indexPath.row)
        
        if buttonCommentPinListDragToLargeSize.tag == 1 {
            tableOpenedPin.frame.size.height = screenHeight - 92
        } else if OpenedPlaces.openedPlaces.count <= 3 {
            tableOpenedPin.frame.size.height = CGFloat(OpenedPlaces.openedPlaces.count * 76)
        } else {
            tableOpenedPin.frame.size.height = CGFloat(228)
        }
        
        // Scroll enabled or not
        if OpenedPlaces.openedPlaces.count > 3 {
            tableOpenedPin.isScrollEnabled = true
        } else {
            tableOpenedPin.isScrollEnabled = false
        }
        
        tableOpenedPin.reloadData()
        if OpenedPlaces.openedPlaces.count == 0 {
            delegate?.directlyReturnToMap()
            UIView.animate(withDuration: 0.4, animations: ({
                self.subviewWhite.center.y -= screenHeight
                self.subviewTable.center.y -= screenHeight
            }), completion: nil)
        }
        
    }
}
