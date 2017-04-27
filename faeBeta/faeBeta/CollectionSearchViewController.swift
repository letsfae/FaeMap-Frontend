//
//  CollectionSearchViewController
//  faeBeta
//
//  Created by Shiqi Wei on 02/12/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectionSearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, FaeSearchControllerDelegate, UITableViewDelegate {
    
    var willAppearFirstLoad = false
    
    var buttonClearSearchBar: UIButton!
    
    var blurViewMainScreenSearch: UIView!
    
    // MARK: -- Search Bar

    var tblSearchResults = UITableView()
    var dataArray = [[String: AnyObject]]()
    var filteredArray = [[String: AnyObject]]()
    var tableTypeName: String = ""
    var searchController: UISearchController!
    var faeSearchController: FaeSearchController!
    var searchBarSubview: UIView!
    var keyboardHeight: CGFloat = 0
    var resultTableWidth: CGFloat {
        if UIScreen.main.bounds.width == 414 { // 5.5
            return 398
        }
        else if UIScreen.main.bounds.width == 320 { // 4.0
            return 308
        }
        else if UIScreen.main.bounds.width == 375 { // 4.7
            return 360.5
        }
        return 308
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlurView()
        loadFunctionButtons()
        loadTableView()
        loadFaeSearchController()
        loadNavBarUnderLine()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: ({
            self.searchBarSubview.center.y = self.searchBarSubview.frame.size.height/2
        }), completion: { (done: Bool) in
            if done {
                self.faeSearchController.faeSearchBar.becomeFirstResponder()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadNavBarUnderLine() {
        let uiviewUnderLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewUnderLine.layer.borderWidth = screenWidth
        uiviewUnderLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewUnderLine.layer.zPosition = 5
        self.searchBarSubview.addSubview(uiviewUnderLine)
    }
    
    func loadBlurView() {
        blurViewMainScreenSearch = UIView()
        blurViewMainScreenSearch.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(blurViewMainScreenSearch)
    }

    func loadFunctionButtons() {
        searchBarSubview = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        searchBarSubview.layer.zPosition = 1
        blurViewMainScreenSearch.addSubview(searchBarSubview)
        self.searchBarSubview.center.y = -self.searchBarSubview.frame.size.height/2
        let backSubviewButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.searchBarSubview.addSubview(backSubviewButton)
        backSubviewButton.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
        backSubviewButton.layer.zPosition = 0
        
        let viewToHideLeftSideSearchBar = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
        viewToHideLeftSideSearchBar.backgroundColor = UIColor.white
        self.searchBarSubview.addSubview(viewToHideLeftSideSearchBar)
        viewToHideLeftSideSearchBar.layer.zPosition = 2
        
        let viewToHideRightSideSearchBar = UIView()
        viewToHideRightSideSearchBar.backgroundColor = UIColor.white
        self.searchBarSubview.addSubview(viewToHideRightSideSearchBar)
        viewToHideRightSideSearchBar.layer.zPosition = 2
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: viewToHideRightSideSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-0-[v0(64)]", options: [], views: viewToHideRightSideSearchBar)
    }
    
    func loadFaeSearchController() {
        faeSearchController = FaeSearchController(searchResultsController: self,
                                                  searchBarFrame: CGRect(x: 18, y: 24, width: resultTableWidth, height: 36),
                                                  searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!,
                                                  searchBarTextColor: UIColor.faeAppInputTextGrayColor(),
                                                  searchBarTintColor: UIColor.white)
        faeSearchController.faeSearchBar.placeholder = "Search Keywords                                       "//blanks for keeping the placeholder not jump during the animation
        faeSearchController.faeDelegate = self
        faeSearchController.faeSearchBar.layer.borderWidth = 2.0
        faeSearchController.faeSearchBar.layer.borderColor = UIColor.white.cgColor
        faeSearchController.faeSearchBar.tintColor = UIColor.faeAppRedColor()
        
        searchBarSubview.addSubview(faeSearchController.faeSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        
        let buttonBackToFaeMap = UIButton(frame: CGRect(x: 15, y: 32, width: 10.5, height: 18))
        buttonBackToFaeMap.setImage(UIImage(named: "mainScreenSearchToFaeMap"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonBackToFaeMap)
        buttonBackToFaeMap.addTarget(self, action: #selector(self.actionDimissSearchBar(_:)), for: .touchUpInside)
        buttonBackToFaeMap.layer.zPosition = 3
        
        buttonClearSearchBar = UIButton()
        buttonClearSearchBar.setImage(UIImage(named: "mainScreenSearchClearSearchBar"), for: UIControlState())
        self.searchBarSubview.addSubview(buttonClearSearchBar)
        buttonClearSearchBar.addTarget(self,
                                       action: #selector(self.actionClearSearchBar(_:)),
                                       for: .touchUpInside)
        buttonClearSearchBar.layer.zPosition = 3
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(17)]-15-|", options: [], views: buttonClearSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-33-[v0(17)]", options: [], views: buttonClearSearchBar)
        buttonClearSearchBar.isHidden = true
        
        let uiviewCommentPinUnderLine = UIView(frame: CGRect(x: 0, y: 63, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine.layer.borderWidth = 1
        uiviewCommentPinUnderLine.layer.borderColor = UIColor(red: 196/255, green: 195/255, blue: 200/255, alpha: 1.0).cgColor
        uiviewCommentPinUnderLine.layer.zPosition = 4
        self.searchBarSubview.addSubview(uiviewCommentPinUnderLine)
    }
    
    func actionDimissSearchBar(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionClearSearchBar(_ sender: UIButton) {
        faeSearchController.faeSearchBar.text = ""
        filteredArray = []
        buttonClearSearchBar.isHidden = true
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()
        
    }
    
    
//    func actionResignResponserofSearchbar(_ sender: UIButton){
//        faeSearchController.faeSearchBar.resignFirstResponder()
//        
//    }
    
    
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: FaeSearchControllerDelegate functions
    func didStartSearching() {
        tblSearchResults.reloadData()
        faeSearchController.faeSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
        //        if !shouldShowSearchResults {
        //            shouldShowSearchResults = true
        //            tblSearchResults.reloadData()
        //        }
    }
    
    //resize the height of the view when the keyboard will show
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            tblSearchResults.frame = CGRect(x: 0, y: 66, width: screenWidth, height: screenHeight-keyboardHeight-66)
        }
        
    }
    //resize the height of the view when the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tblSearchResults.frame = CGRect(x: 0, y: 66, width: screenWidth, height: screenHeight-66)
        }
    }
    
    
    
    
    func didTapOnCancelButton() {
        filteredArray.removeAll()
        buttonClearSearchBar.isHidden = true
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()
    }
    
    
    func didChangeSearchText(_ searchText: String) {
        if searchText != "" {
            buttonClearSearchBar.isHidden = false
            filteredArray = dataArray.filter { (pinArr:[String: AnyObject]) -> Bool in
                if pinArr["type"]?.description == "media" {
                    return (pinArr["description"]?.lowercased.contains(searchText.lowercased()))!
                }
                else if pinArr["type"]?.description == "comment" {
                    return (pinArr["content"]?.lowercased.contains(searchText.lowercased()))!
                }
                else{
                    return (pinArr["address"]?.lowercased.contains(searchText.lowercased()))!
                    
                }
            }
            if filteredArray.count > 0{
                searchBarTableShowAnimation()
            }
            tblSearchResults.reloadData()
            
        }
        else {
            filteredArray.removeAll()
            buttonClearSearchBar.isHidden = true
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 66, width: screenWidth, height: 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 66, width: screenWidth, height:screenHeight-66-self.keyboardHeight)
            
        }), completion: nil)
    }
    
    
    // MARK: TableView Initialize
    
    func loadTableView() {

        tblSearchResults = UITableView(frame: CGRect(x: 0,y: 66,width: screenWidth,height: screenHeight-66))
        tblSearchResults.backgroundColor = .clear
        tblSearchResults.showsVerticalScrollIndicator = false
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: 10))
        headerView.backgroundColor = UIColor.clear
        tblSearchResults.tableHeaderView = headerView
        blurViewMainScreenSearch.addSubview(tblSearchResults)
        
        //for auto layout
        tblSearchResults.rowHeight = UITableViewAutomaticDimension
        tblSearchResults.estimatedRowHeight = 340
        
        // Clear out the empty cells
        tblSearchResults.tableFooterView = UIView()
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
}
