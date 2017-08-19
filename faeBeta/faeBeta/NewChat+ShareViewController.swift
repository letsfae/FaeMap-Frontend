//
//  NewChat+ShareViewController.swift
//  faeBeta
//
//  Created by Jichao Zhong on 8/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

struct cellFriendData {
    var Image = UIImage()
    var nickName: String
    var userName: String
    var userID: String
    var index: Int
    
    init(userName: String, nickName: String, userID: String, index: Int) {
        self.nickName = nickName
        self.userName = userName
        self.userID = userID
        self.index = index
    }
}

class NewChatShareController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    var chatOrShare: String!
    
    //var arrFriends: [cellFriendData] = [cellFriendData(name: "friendsOne", index: 0), cellFriendData(name: "friendsTwo", index: 1), cellFriendData(name: "friendsThree", index: 2), cellFriendData(name: "friendsFour", index: 3)]
    var arrFriends: [cellFriendData] = []
    var arrFiltered: [cellFriendData] = []
    var arrSelected: [Int] = []
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSchabr: UIView!
    var schbarChatTo: FaeSearchBar!
    var searchField: UITextField!
    let uitxDummy: UITextField = UITextField()
    
    var tblFriends: UITableView!
    var imgGhost: UIImageView!
    
    var isDeleting: Bool = false
    var lastLength: Int = 0
    var readyToChat: Bool = false
    var readyToDel: Bool = false
    var toDelete: Bool = false
    
    let apiCalls = FaeContact()
    
    //    convenience init() {
    //        self.init()
    //    }
    
    init(chatOrShare: String) {
        self.chatOrShare = chatOrShare
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriends()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        loadNavBar()
        loadSearchBar()
        loadChatsList()
        if chatOrShare == "share" && arrFriends.count == 0 {
            loadNoFriends()
        }
    }
    
    func loadFriends() {
        apiCalls.getFriends() {(status: Int, message: Any?) in
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.arrFriends.append(cellFriendData(userName: json[i-1]["friend_user_name"].stringValue, nickName: json[i-1]["friend_user_nick_name"].stringValue,  userID: json[i-1]["friend_id"].stringValue, index: i - 1))
                }
            }
            self.arrFiltered = self.arrFriends
            self.arrFriends.sort{ $0.nickName < $1.nickName }
            self.tblFriends.reloadData()
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar()
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "cannotSendMessage"), for: .normal)
        uiviewNavBar.loadBtnConstraints()
        if chatOrShare == "chat" {
            uiviewNavBar.lblTitle.text = "Start New Chat"
        }
        else if chatOrShare == "share" {
            uiviewNavBar.lblTitle.text = "Share"
        }
        
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(navigationRightItemTapped), for: .touchUpInside)
    }
    
    func navigationLeftItemTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationRightItemTapped() {
        //self.navigationController?.popViewController(animated: true)
    }
    
    func loadSearchBar() {
        uiviewSchabr = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 50))
        
        schbarChatTo = FaeSearchBar(frame: CGRect(x: 8, y: 2, width: screenWidth  + 25, height: 50), font: UIFont(name: "AvenirNext-Medium", size: 18)!, textColor: UIColor._182182182())
        schbarChatTo.backgroundImage = UIImage()
        schbarChatTo.barTintColor = .white
        //schbarChatTo.tintColor = UIColor.faeAppInputTextGrayColor()
        schbarChatTo.tintColor = UIColor._2499090()
        //schbarChatTo.placeholder = "Chat to"
        //let imgBarIcon = UIImageView(frame: CGRect(x: 13, y: 17, width: 15, height: 15))
        //imgBarIcon.backgroundColor = .white
        //schbarChatTo.addSubview(imgBarIcon)
        schbarChatTo.delegate = self
        searchField = schbarChatTo.subviews[0].subviews[schbarChatTo.indexOfSearchFieldInSubviews()] as! UITextField
        
        /*        let topView: UIView = schbarChatTo.subviews[0] as UIView
         
         for subView in topView.subviews {
         if subView is UITextField {
         searchField = subView as! UITextField
         break
         }
         }*/
        //if ((searchField) != nil) {
        //searchField.text = "testtest"
        //let leftview = searchField.leftView as! UIImageView
        let imageView  = UIImageView(frame: CGRect(x: schbarChatTo.frame.origin.x  , y:  10, width: 20, height: 20 ) )
        searchField.leftView = UIView(frame: CGRect(x: 0 , y: 0, width: 20, height: 20) )
        searchField.leftViewMode = .always
        searchField.superview?.addSubview(imageView)
        //}
        
        uiviewSchabr.addSubview(schbarChatTo)
        
        
        let lblChatTo = UILabel()
        //lblChatTo.backgroundColor = .green
        lblChatTo.text = "To:"
        lblChatTo.textAlignment = .left
        lblChatTo.textColor = UIColor._182182182()
        lblChatTo.font = UIFont(name: "AvenireNext-Bold", size: 18)
        lblChatTo.font = UIFont.boldSystemFont(ofSize: 18)
        uiviewSchabr.addSubview(lblChatTo)
        uiviewSchabr.addConstraintsWithFormat("H:|-15-[v0(29)]", options: [], views: lblChatTo)
        uiviewSchabr.addConstraintsWithFormat("V:|-13-[v0(25)]", options: [], views: lblChatTo)
        
        view.addSubview(uiviewSchabr)
    }
    
    func loadChatsList() {
        let uiviewHeader:UIView = UIView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 27))
        
        let separateLine1 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        separateLine1.layer.borderWidth = screenWidth
        separateLine1.layer.borderColor = UIColor._200199204cg()
        uiviewHeader.addSubview(separateLine1)
        
        let separateLine2 = UIView(frame: CGRect(x: 0, y: 26, width: screenWidth, height: 1))
        separateLine2.layer.borderWidth = screenWidth
        separateLine2.layer.borderColor = UIColor._200199204cg()
        uiviewHeader.addSubview(separateLine2)
        
        let lblHeader:UILabel = UILabel(frame: uiviewHeader.bounds)
        lblHeader.textColor = UIColor._155155155()
        lblHeader.backgroundColor = UIColor.clear
        lblHeader.font = UIFont(name: "AvenireNext-Bold", size: 15)
        lblHeader.font = UIFont.boldSystemFont(ofSize: 15)
        lblHeader.text = "Friends"
        uiviewHeader.addSubview(lblHeader)
        uiviewHeader.addConstraintsWithFormat("H:|-15-[v0(100)]", options: [], views: lblHeader)
        uiviewHeader.addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblHeader)
        uiviewHeader.backgroundColor = UIColor._248248248()
        
        tblFriends = UITableView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: screenHeight - 114))
        tblFriends.dataSource = self
        tblFriends.delegate = self
        tblFriends.tableHeaderView = uiviewHeader
        tblFriends.register(NewChatTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tblFriends.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tblFriends.separatorColor = UIColor._200199204()
        tblFriends.separatorInset = UIEdgeInsetsMake(0, 74, 0, 0)
        tblFriends.tableFooterView = UIView()
        view.addSubview(tblFriends)
    }
    
    func loadNoFriends() {
        imgGhost = UIImageView()
        imgGhost.frame = CGRect(x: screenWidth/5, y: 256 * screenHeightFactor, width: 252, height: 209)
        imgGhost.contentMode = .scaleAspectFit
        imgGhost.image = #imageLiteral(resourceName: "no_friend_ghost")
        view.addSubview(imgGhost)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath as IndexPath) as! NewChatTableViewCell
        cell.lblNickName.text = arrFiltered[indexPath.row].nickName
        cell.lblUserName.text = arrFiltered[indexPath.row].userName
        if arrSelected.contains(arrFiltered[indexPath.row].index) {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_selected")
        }
        else {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("select \(indexPath)")
        let currentCell = tableView.cellForRow(at: indexPath) as! NewChatTableViewCell
        if (currentCell.statusSelected) {
            //currentCell.statusSelected = false
            //currentCell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        }
        else {
            currentCell.statusSelected = true
            currentCell.imgStatus.image = #imageLiteral(resourceName: "status_selected")
            uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "canSendMessage"), for: .normal)
            let currentFriend: cellFriendData = arrFiltered[indexPath.row]
            arrSelected.append(currentFriend.index)
            
            //let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
            /*let currentContent : NSAttributedString = searchField.attributedText!
             let currentSelected : NSAttributedString = NSAttributedString(string: currentCell.lblUserName.text! + ",", attributes: [NSForegroundColorAttributeName : UIColor.faeAppRedColor()])
             let changeColor : NSAttributedString = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName : UIColor.faeAppInputTextGrayColor()])
             attributedStrM.append(currentContent)
             attributedStrM.append(currentSelected)
             attributedStrM.append(changeColor)
             searchField.attributedText = attributedStrM*/
            
            /*for index in 0 ..< arrSelected.count {
             let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].name + ", ", attributes: [NSForegroundColorAttributeName : UIColor.faeAppRedColor()])
             attributedStrM.append(textNS)
             //print(index)
             }
             searchField.attributedText = attributedStrM*/
            loadTextInSearchBar()
            loadStatus()
            lastLength = searchField.text!.characters.count
            filter("")
            //print(searchField.attributedText!.index(ofAccessibilityElement: 1))
            //print(searchField.attributedText)
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        detectDeleting(searchText)
        if searchText == "" {
            filter("")
            return
        }
        print("isDeleting:\(isDeleting)")
        print("readyToDel:\(readyToDel)")
        print("toDelete:\(toDelete)")
        let textArray = searchText.components(separatedBy: ", ")
        //let lastWord = textArray[textArray.count - 1]
        //let searchWord = findCurrentSearchWord(searchText)
        //print(searchWord)
        let lastChar = searchText.substring(from: searchText.index(searchText.endIndex, offsetBy: -1))
        print(lastChar)
        if textArray.count == arrSelected.count {
            filter("")
        }
        else {
            filter(findCurrentSearchWord(searchText))
        }
        if isDeleting {
            let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
            //print(readyToDel)
            if toDelete {
                filter("")
                /*                for index in 0 ..< arrSelected.count - 1 {
                 let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].name + ", ", attributes: [NSForegroundColorAttributeName : UIColor.faeAppRedColor()])
                 attributedStrM.append(textNS)
                 //print(index)
                 }
                 searchField.attributedText = attributedStrM*/
                toDelete = false
                readyToDel = false
                arrSelected.remove(at: arrSelected.count - 1)
                loadTextInSearchBar()
                
            }
            if readyToDel {
                filter("")
                for index in 0 ..< arrSelected.count - 1 {
                    let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].nickName + ", ", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
                    attributedStrM.append(textNS)
                    //print(index)
                }
                let lastNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[arrSelected.count - 1]].nickName + ",", attributes: [NSForegroundColorAttributeName : UIColor.blue])
                attributedStrM.append(lastNS)
                searchField.attributedText = attributedStrM
                toDelete = true
                
            }
            if lastChar == "," && textArray.count == arrSelected.count {
                readyToDel = true
            }
            else {
                readyToDel = false
            }
            
            
        }
        else {
            if toDelete {
                toDelete = false
                loadTextInSearchBar()
            }
        }
        /*        else {
         if textArray.count == arrSelected.count {
         filter("")
         }
         else {
         filter(lastWord)
         }
         
         }*/
        lastLength = searchField.text!.characters.count
        loadStatus()
        print("isDeleting:\(isDeleting)")
        print("readyToDel:\(readyToDel)")
        print("toDelete:\(toDelete)")
        //print("editing")
        //filter(searchText: searchText)
        //print("search bar \(searchText)")
        /*        if searchText.characters.count > 0 {
         //print(searchText.index(after: searchText.characters.count - 1))
         print(searchText.substring(from: searchText.index(searchText.endIndex, offsetBy: -1)))
         }*/
        /*let lastChar = searchText.substring(from: searchText.index(searchText.endIndex, offsetBy: -1))
         print(lastChar)
         
         let textArray = searchText.components(separatedBy: " ")
         let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
         
         if readyToDel {
         for index in 0 ..< textArray.count - 1 {
         let textNS : NSAttributedString = NSAttributedString(string: textArray[index] + " ", attributes: [NSForegroundColorAttributeName : UIColor.faeAppRedColor()])
         attributedStrM.append(textNS)
         //print(index)
         }
         let lastNS : NSAttributedString = NSAttributedString(string: textArray[textArray.count - 1] + ",", attributes: [NSForegroundColorAttributeName : UIColor.blue])
         attributedStrM.append(lastNS)
         searchField.attributedText = attributedStrM
         }
         else {
         
         }
         
         if lastChar == "," {
         readyToDel = true
         }
         else {
         readyToDel = false
         }*/
        
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        print("search bar should change")
        return true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        schbarChatTo.becomeFirstResponder()
        //uitxDummy.becomeFirstResponder()
        print("search bar 2")
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        schbarChatTo.resignFirstResponder()
        print("search bar 3")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //schbarContacts.resignFirstResponder()
        print("search bar 4")
    }
    // End of UISearchBarDelegate
    
    func detectDeleting(_ searchText: String) {
        if searchText.characters.count > lastLength {
            isDeleting = false
        }
        else {
            isDeleting = true
        }
    }
    
    func filter(_ searchText: String) {
        print("filter: \(searchText)")
        if searchText == "" {
            arrFiltered = arrFriends;
        }
        else {
            arrFiltered = arrFriends.filter({(($0.nickName).lowercased()).range(of: searchText.lowercased()) != nil})
        }
        tblFriends.reloadData()
    }
    
    /*    func deleteSelected(_ searchText: String) {
     let lastChar = searchText.substring(from: searchText.index(searchText.endIndex, offsetBy: -1))
     
     }*/
    
    func loadTextInSearchBar() {
        if arrSelected.count == 0 {
            searchField.text = ""
            searchField.textColor = UIColor._898989()
            return
        }
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        for index in 0 ..< arrSelected.count - 1 {
            let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].nickName + ", ", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
            attributedStrM.append(textNS)
            //print(index)
        }
        let lastNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[arrSelected.count - 1]].nickName + ",", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
        attributedStrM.append(lastNS)
        let changeColor : NSAttributedString = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        attributedStrM.append(changeColor)
        searchField.attributedText = attributedStrM
    }
    
    // deal with the cells on current screen
    func loadStatus() {
        if arrSelected.count == 0 {
            uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "cannotSendMessage"), for: .normal)
            //return
        }
        for index in 0 ..< arrFiltered.count {
            if tblFriends.cellForRow(at: IndexPath(row: index, section: 0)) == nil {
                break
            }
            let currentCell = tblFriends.cellForRow(at: IndexPath(row: index, section: 0)) as! NewChatTableViewCell
            let currentFriend: cellFriendData = arrFiltered[index]
            if arrSelected.contains(currentFriend.index) {
                currentCell.imgStatus.image = #imageLiteral(resourceName: "status_selected")
                currentCell.statusSelected = true
            }
            else {
                currentCell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
                currentCell.statusSelected = false
            }
        }
        
    }
    
    func findCurrentSearchWord(_ searchText: String) -> String {
        var selectedLength: Int = 0
        for index in arrSelected {
            let currentLength = arrFriends[index].nickName.characters.count + 2
            selectedLength = selectedLength + currentLength
        }
        return searchText.substring(from: searchText.index(searchText.startIndex, offsetBy: selectedLength))
    }
}

