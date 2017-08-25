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
    var lastTextField: String = ""
    var readyToChat: Bool = false
    var readyToDel: Bool = false
    var toDelete: Bool = false
    var lastToDelPos: Int = 0
    var searchWord: String = ""
    let AT_SELECTED_AREA: Int = 0
    let AT_BORDER_POSITION: Int = 1
    let AT_UNSELECTED_AREA: Int = 2
    
    let apiCalls = FaeContact()
    
    var placeDetail: PlacePin?
    
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
    }
    
    func loadFriends() {
        apiCalls.getFriends() {(status: Int, message: Any?) in
            let json = JSON(message!)
            if json.count == 0 {
                self.loadNoFriends()
            }
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
        uiviewNavBar.rightBtn.isEnabled = false
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
        navigationController?.popViewController(animated: true)
    }
    
    func navigationRightItemTapped() {
        //if chatOrShare == "chat" {
            chatWithUser(id: Int(arrFriends[arrSelected[0]].userID)!)
        //}
        //else if chatOrShare == "share" {
            
        //}
        
    }
    
    func chatWithUser(id: Int) {
        // First get chatroom id
        getFromURL("chats/users/\(Key.shared.user_id)/\(id)", parameter: nil, authentication: headerAuthentication()) { status, result in
            var resultJson1 = JSON([])
            if status / 100 == 2 {
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(id)/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
                guard status / 100 == 2 else { return }
                let resultJson2 = JSON(result!)
                var chat_id: String?
                if let id = resultJson1["chat_id"].number {
                    chat_id = id.stringValue
                }
                if let nickName = resultJson2["nick_name"].string {
                    self.startChat(chat_id, userId: id, nickName: nickName)
                } else {
                    self.startChat(chat_id, userId: id, nickName: nil)
                }
            }
        }
    }
    
    func startChat(_ chat_id: String?, userId: Int, nickName: String?) {
        let chatVC = ChatViewController()
        chatVC.chatRoomId = Key.shared.user_id < userId ? "\(Key.shared.user_id)-\(userId)" : "\(userId)-\(Key.shared.user_id)"
        chatVC.chat_id = chat_id
        
        // Bryan
        let nickName = nickName ?? "Chat"
        // ENDBryan
        // chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        // TODO: Tell nickname and username apart
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userNickName = nickName
        chatVC.realmWithUser!.userID = "\(userId)"
        // chatVC.realmWithUser?.userAvatar =
        
        // RealmChat.addWithUser(withUser: chatVC.realmWithUser!)
        
        // EndBryan
        //self.present(chatVC, animated: true, completion: nil)
        if chatOrShare == "share" {
            let snap = UIImagePNGRepresentation(UIImage(named:"locationExtendViewHolder")!) as Data!
            chatVC.sendMessage(text: "", place: placeDetail, snapImage: snap,  date: Date())
            navigationController?.popViewController(animated: true)
        }
        else if chatOrShare == "chat" {
            var arrViewControllers = navigationController?.viewControllers
            arrViewControllers!.removeLast()
            arrViewControllers!.append(chatVC)
            navigationController?.setViewControllers(arrViewControllers!, animated: true)
        }
    }

    
    func loadSearchBar() {
        uiviewSchabr = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 50))
        
        searchField = UITextField(frame: CGRect(x: 49, y: 2, width: screenWidth - 55, height: 50))
        searchField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        searchField.textColor = UIColor._898989()
        searchField.tintColor = UIColor._2499090()
        uiviewSchabr.addSubview(searchField)
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let lblChatTo = UILabel()
        lblChatTo.text = "To:"
        lblChatTo.textAlignment = .left
        lblChatTo.textColor = UIColor._182182182()
        lblChatTo.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        uiviewSchabr.addSubview(lblChatTo)
        //uiviewSchabr.addConstraintsToView(child: lblChatTo, left: true, gapH: 15, width: 29, top: true, gapV: 13, height: 25)
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
        lblHeader.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
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
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath as IndexPath) as! NewChatTableViewCell
        cell.lblNickName.text = arrFiltered[indexPath.row].nickName
        cell.lblUserName.text = arrFiltered[indexPath.row].userName
        General.shared.avatar(userid: Int(arrFiltered[indexPath.row].userID)!, completion: { (avatarImage) in
            cell.imgAvatar.image = avatarImage
        })
        if arrSelected.contains(arrFiltered[indexPath.row].index) {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_selected")
        }
        else {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! NewChatTableViewCell
        var currentIndex: Int = 0
        for friend in arrFriends {
            if friend.nickName == currentCell.lblNickName.text {
                currentIndex = friend.index
            }
        }
        if (arrSelected.contains(currentIndex)) {
            searchWord = findCurrentSearchWord(searchField.text!)
            if let i = arrSelected.index(of: currentIndex) {
                arrSelected.remove(at: i)
            }
            loadTextInSearchBar(moreWord: searchWord)
        }
        else {
            uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "canSendMessage"), for: .normal)
            uiviewNavBar.rightBtn.isEnabled = true
            arrSelected.append(currentIndex)
            loadTextInSearchBar(moreWord: "")
            filter("")
        }
        loadStatus()
        searchField.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    // end of UITableViewDelegate
    
    // deal with searching
    func filter(_ searchText: String) {
        //print("filter: \(searchText)")
        if searchText == "" {
            arrFiltered = arrFriends;
        }
        else {
            arrFiltered = arrFriends.filter({(($0.nickName).lowercased()).range(of: searchText.lowercased()) != nil})
        }
        tblFriends.reloadData()
    }
    
    // callback when text field changes
    func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            filter("")
            return
        }
        
        isDeleting = detectDeleting(textField.text!)
        let curCursorPos = detectCursorPosition(textField: textField)
        //print("current section: \(curCursorPos)")
        let textArray = (textField.text!.trimmingCharacters(in: .whitespaces)).components(separatedBy: ", ")
        
        if !isDeleting {
            if [AT_BORDER_POSITION, AT_UNSELECTED_AREA].contains(curCursorPos) {
                if toDelete {
                    toDelete = false
                    loadTextInSearchBar(moreWord: searchWord.trimmingCharacters(in: .whitespaces))
                }
                else {
                    searchWord = findCurrentSearchWord(textField.text!)
                    filter(searchWord.trimmingCharacters(in: .whitespaces))
                    lastTextField = searchField.text!
                }
            }
            else {
                if toDelete {
                    toDelete = false
                }
                if textArray.count == arrSelected.count {
                    loadTextInSearchBar(moreWord: "")
                }
                else {
                    searchWord = findCurrentSearchWord(textField.text!)
                    filter(searchWord.trimmingCharacters(in: .whitespaces))
                    loadTextInSearchBar(moreWord: searchWord.trimmingCharacters(in: .whitespaces))
                }
            }
        }
        else {
            if curCursorPos == AT_UNSELECTED_AREA {
                searchWord = findCurrentSearchWord(textField.text!)
                filter(searchWord.trimmingCharacters(in: .whitespaces))
                lastTextField = searchField.text!
            }
            else {
                let curToDelPos = detectToDelIndex(textField: textField)
                if toDelete && (curToDelPos == lastToDelPos) {
                    filter(searchWord.trimmingCharacters(in: .whitespaces))
                    arrSelected.remove(at: curToDelPos)
                    loadTextInSearchBar(moreWord: searchWord.trimmingCharacters(in: .whitespaces))
                    toDelete = false
                    readyToDel = false
                }
                else {
                    lastToDelPos = curToDelPos
                    loadTextInSearchBarWithDeleting(textField: textField, toDelIndex: lastToDelPos, moreWord: searchWord.trimmingCharacters(in: .whitespaces))
                    loadStatus()
                    return
                }
            }
        }
        loadStatus()
        
    }
    
    // deal with the cells on current screen
    func loadStatus() {
        if arrSelected.count == 0 {
            uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "cannotSendMessage"), for: .normal)
            uiviewNavBar.rightBtn.isEnabled = false
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
    
    // helper functions for editing the list of selected friends
    func detectDeleting(_ searchText: String) -> Bool {
        if searchText.characters.count > lastTextField.characters.count {
            return false
        }
        else {
            return true
        }
    }
    
    func detectCursorPosition(textField: UITextField) -> Int {
        var selectedLength: Int = 0
        for index in arrSelected {
            let currentLength = arrFriends[index].nickName.characters.count + 2
            selectedLength = selectedLength + currentLength
        }
        
        if let selectedRange = textField.selectedTextRange {
            var cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            if isDeleting {
                cursorPosition = cursorPosition + 1
            }
            else if cursorPosition == selectedLength {
                return AT_SELECTED_AREA
            }
            
            if cursorPosition > selectedLength {
                return AT_UNSELECTED_AREA
            }
            else if cursorPosition == selectedLength {
                return AT_BORDER_POSITION
            }
        }
        
        return AT_SELECTED_AREA
    }
    
    func findCurrentSearchWord(_ searchText: String) -> String {
        var selectedLength: Int = 0
        for index in arrSelected {
            let currentLength = arrFriends[index].nickName.characters.count + 2
            selectedLength = selectedLength + currentLength
        }
        return searchText.substring(from: searchText.index(searchText.startIndex, offsetBy: selectedLength))
    }
    
    func loadTextInSearchBar(moreWord: String) {
        if arrSelected.count == 0 && searchWord == "" {
            searchField.text = ""
            searchField.textColor = UIColor._898989()
            return
        }
        else if arrSelected.count == 0 {
            searchField.text = searchWord.trimmingCharacters(in: .whitespaces)
            searchField.textColor = UIColor._898989()
            return
        }
        
        lastTextField = ""
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        for index in 0 ..< arrSelected.count - 1 {
            let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].nickName + ", ", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
            attributedStrM.append(textNS)
            lastTextField = lastTextField + arrFriends[arrSelected[index]].nickName + ", "
            //print(index)
        }
        
        let lastNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[arrSelected.count - 1]].nickName + ",", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
        attributedStrM.append(lastNS)
        lastTextField = lastTextField + arrFriends[arrSelected[arrSelected.count - 1]].nickName + ","
        
        let changeColor : NSAttributedString = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        attributedStrM.append(changeColor)
        
        let newSearchWord : NSAttributedString = NSAttributedString(string: moreWord, attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        attributedStrM.append(newSearchWord)
        lastTextField = lastTextField + moreWord
        
        searchField.attributedText = attributedStrM
    }
    
    func loadTextInSearchBarWithDeleting(textField: UITextField, toDelIndex: Int, moreWord: String) {
        toDelete = true
        
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        for index in 0 ..< arrSelected.count {
            if index == toDelIndex {
                let delNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].nickName + ", ", attributes: [NSForegroundColorAttributeName : UIColor.blue])
                attributedStrM.append(delNS)
            }
            else {
                let textNS : NSAttributedString = NSAttributedString(string: arrFriends[arrSelected[index]].nickName + ", ", attributes: [NSForegroundColorAttributeName : UIColor._2499090()])
                attributedStrM.append(textNS)
            }
            //print(index)
        }
        
        let lastNS : NSAttributedString = NSAttributedString(string: moreWord, attributes: [NSForegroundColorAttributeName : UIColor._898989()])
        attributedStrM.append(lastNS)
        searchField.attributedText = attributedStrM
        
        // move the cursor to the end of word to be deleted
        var targetPosition: Int = 0
        for index in 0 ..< toDelIndex {
            targetPosition = targetPosition + arrFriends[arrSelected[index]].nickName.characters.count + 2
        }
        targetPosition = targetPosition + arrFriends[arrSelected[toDelIndex]].nickName.characters.count + 2
        //print(targetPosition)
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: targetPosition) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func detectToDelIndex(textField: UITextField) -> Int {
        var cursorPosition: Int = 0
        if let selectedRange = textField.selectedTextRange {
            cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        }
        cursorPosition = cursorPosition + 1
        var currentWordEndPosition: Int = 0
        var lastWordEndPosition: Int = 0
        for index in 0 ..< arrSelected.count {
            if index != 0 {
                lastWordEndPosition = currentWordEndPosition
            }
            currentWordEndPosition = currentWordEndPosition + arrFriends[arrSelected[index]].nickName.characters.count + 2
            if cursorPosition > lastWordEndPosition && cursorPosition <= currentWordEndPosition {
                return index
            }
        }
        return arrSelected.count - 1
    }
    
}
