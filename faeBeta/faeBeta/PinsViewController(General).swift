//
//  PinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/20/17.
//  Edited by Sophie Wang
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIKit.UIGestureRecognizerSubclass

class TouchGestureRecognizer: UIGestureRecognizer {
    // initialize the cellInGivenId
    var cellInGivenId = PinsTableViewCell()
    var isCellSwiped = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        // This assignment is very importment for custom gesture
        state = UIGestureRecognizerState.began
        let frame = cellInGivenId.uiviewCellView.frame
        let frameOriginal = CGRect(x: -screenWidth, y: frame.origin.y, width: frame.width, height: frame.height)
        UIView.animate(withDuration: 0.3, animations: {
            self.cellInGivenId.uiviewCellView.frame = frameOriginal
        }, completion: { _ in
            self.isCellSwiped = false
        })
    }
}

protocol CollectionsBoardDelegate: class {
    // Go back to collections
    func backToBoard(count: Int)
}

class PinsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, PinTableViewCellDelegate, UIGestureRecognizerDelegate {
    
    weak var delegateBackBoard: CollectionsBoardDelegate? // For collectionBoard
    
    // initialize the cellInGivenId
    var cellCurrSwiped = PinsTableViewCell()
    var gesturerecognizerTouch: TouchGestureRecognizer!
    // background view
    var uiviewBackground: UIView!
    var tblPinsData: UITableView!
    // Transparent view to cover the searchbar for detect the click event
    var uiviewSearchBarCover: UIView!
    var schbarPin: UISearchBar!
    var imgEmptyTbl: UIImageView!
    var lblEmptyTbl: UILabel!
    // Nagivation Bar Init
    var uiviewNavBar: UIView!
    // Title for current table
    var strTableTitle: String!
    // The set of pin data
    var arrPinData = [[String: AnyObject]]()
    var arrMapPin = [MapPinCollections]()
    // Current select row
    var indexCurrSelectRowAt: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The background of this controller, all subviews are added to this view
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(uiviewBackground)
        loadTblPinsData()
        loadNavBar()
    }
    
    func handleAfterTouch(recognizer: TouchGestureRecognizer) {
        // remove the gesture after cell backs, or the gesture will always collect touches in the table
        tblPinsData.removeGestureRecognizer(gesturerecognizerTouch)
    }
    
    // only the buttons in the siwped cell don't respond to the gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: cellCurrSwiped.uiviewSwipedBtnsView))! {
            return false
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        delegateBackBoard?.backToBoard(count: arrPinData.count)
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth + 2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
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
        lblNavBarTitle.textColor = UIColor.faeAppTimeTextBlackColor()
        lblNavBarTitle.text = strTableTitle
        uiviewNavBar.addSubview(lblNavBarTitle)
    }
    
    fileprivate func loadSearchBar() {
        schbarPin = UISearchBar()
        schbarPin.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 50)
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
        uiviewSearchBarCover = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        uiviewSearchBarCover.backgroundColor = .clear
        schbarPin.addSubview(uiviewSearchBarCover)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.searchBarTapDown(_:)))
        uiviewSearchBarCover.addGestureRecognizer(tapRecognizer)
        uiviewSearchBarCover.isUserInteractionEnabled = true
    }
    
    // Creat the search view when tap the fake searchbar
    func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let vcSearch = PinSearchViewController()
        vcSearch.modalPresentationStyle = .overCurrentContext
        present(vcSearch, animated: false, completion: nil)
        vcSearch.strTableTypeName = strTableTitle
        vcSearch.arrData = arrPinData
        vcSearch.arrMapPin = arrMapPin
    }
    
    func loadTblPinsData() {
        uiviewBackground.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        tblPinsData = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65), style: UITableViewStyle.plain)
        tblPinsData.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        tblPinsData.isHidden = true
        tblPinsData.showsVerticalScrollIndicator = false
        
        // for auto layout
        tblPinsData.rowHeight = UITableViewAutomaticDimension
        tblPinsData.estimatedRowHeight = 340
        
        imgEmptyTbl = UIImageView(frame: CGRect(x: (screenWidth - 252) / 2, y: (screenHeight - 209) / 2 - 106, width: 252, height: 209))
        imgEmptyTbl.image = #imageLiteral(resourceName: "empty_bg")
        lblEmptyTbl = UILabel(frame: CGRect(x: 24, y: 7, width: 206, height: 75))
        lblEmptyTbl.lineBreakMode = NSLineBreakMode.byTruncatingTail
        lblEmptyTbl.numberOfLines = 3
        lblEmptyTbl.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblEmptyTbl.textAlignment = .left
        lblEmptyTbl.textColor = UIColor.faeAppInputTextGrayColor()
        imgEmptyTbl.addSubview(lblEmptyTbl)
        uiviewBackground.addSubview(imgEmptyTbl)
        uiviewBackground.addSubview(tblPinsData)
        
        // initialize the touch gesture
        gesturerecognizerTouch = TouchGestureRecognizer(target: self, action: #selector(handleAfterTouch))
        gesturerecognizerTouch.delegate = self
        
        loadSearchBar()
        tblPinsData.tableHeaderView = schbarPin
    }
    
    // 以下代码是table的构造
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let uiviewHeaderView = UIView()
        uiviewHeaderView.backgroundColor = UIColor.clear
        return uiviewHeaderView
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
    
    // PinTableViewCellDelegate protocol required function
    func itemSwiped(indexCell: Int) {}
    
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String) {}
    
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String) {}
    
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String) {}
    
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String) {}
    
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String) {}
    
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String) {}
    
}

extension UITableView {
    /// Perform a series of method calls that insert, delete, or select rows and sections of the table view.
    /// This is equivalent to a beginUpdates() / endUpdates() sequence,
    /// with a completion closure when the animation is finished.
    /// Parameter update: the update operation to perform on the tableView.
    /// Parameter completion: the completion closure to be executed when the animation is completed.
    
    func performUpdate(_ update: () -> Void, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        // Table View update on row / section
        beginUpdates()
        update()
        endUpdates()
        CATransaction.commit()
    }
}
