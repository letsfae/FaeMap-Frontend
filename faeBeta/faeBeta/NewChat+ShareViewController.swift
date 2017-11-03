//
//  NewChat+ShareViewController.swift
//  faeBeta
//
//  Created by Jichao Zhong on 8/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

struct cellFriendData {
    var Image = UIImage()
    var nickName: String
    var userName: String
    var userID: String
    var index: Int = -1
    
    init(userName: String, nickName: String, userID: String) {
        self.nickName = nickName
        self.userName = userName
        self.userID = userID
        //self.index = index
    }
    
    mutating func setIndex(at index: Int) {
        self.index = index
    }
}

class NewChatShareController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, CustomTextFieldDelegate, DeleteCellDelegate {
    
    var chatOrShare: String!
    
    //var arrFriends: [cellFriendData] = [cellFriendData(name: "friendsOne", index: 0), cellFriendData(name: "friendsTwo", index: 1), cellFriendData(name: "friendsThree", index: 2), cellFriendData(name: "friendsFour", index: 3)]
    var arrFriends: [cellFriendData] = []
    var arrFiltered: [cellFriendData] = []
    var arrIntSelected: [Int] = []
    
    var uiviewNavBar: FaeNavBar!
    var lblTo: UILabel!
    var cllcSelected: UICollectionView!
    var uiviewSchabr: UIView!
    var uiviewBottomLine: UIView!
    var schbarChatTo: FaeSearchBar!
    var searchField: UITextField!
    let uitxDummy: UITextField = UITextField()
    
    var tblFriends: UITableView!
    var imgGhost: UIImageView!
    
    var intSelectedIndex: Int = -1
    var boolIsFirst: Bool = true
    var boolIsClick: Bool = false
    var floatScrollViewOriginOffset: CGFloat = 0
    
    enum FriendListMode {
        case chat
        case location
        case collection
        case place
    }
    var friendListMode: FriendListMode = .chat
    var locationDetail: String = ""
    var locationSnapImage: UIImage?
    var collectionDetail: PinCollection?
    var placeDetail: PlacePin?
    
    let apiCalls = FaeContact()
    
    //var placeDetail: PlacePin?
    
    init(friendListMode: FriendListMode) {
        self.friendListMode = friendListMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadFriends()
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
                    self.arrFriends.append(cellFriendData(userName: json[i-1]["friend_user_name"].stringValue, nickName: json[i-1]["friend_user_nick_name"].stringValue, userID: json[i-1]["friend_id"].stringValue))
                }
            }
            self.arrFriends.sort{ $0.nickName < $1.nickName }
            for i in 0..<self.arrFriends.count {
                self.arrFriends[i].setIndex(at: i)
            }
            self.arrFiltered = self.arrFriends
            self.tblFriends.reloadData()
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar()
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "cannotSendMessage"), for: .normal)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "canSendMessage"), for: .selected)
        uiviewNavBar.rightBtn.isEnabled = false
        uiviewNavBar.loadBtnConstraints()
        if friendListMode == .chat {
            uiviewNavBar.lblTitle.text = "Start New Chat"
        } else {
            uiviewNavBar.lblTitle.text = "Share"
        }
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(navigationRightItemTapped), for: .touchUpInside)
    }
    
    @objc func navigationLeftItemTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func navigationRightItemTapped() {
        if friendListMode == .chat {
            chatWithUsers(IDs: [arrFriends[arrIntSelected[0]].userID])
        } else {
            shareWithUsers()
        }
        
    }
    
    func chatWithUsers(IDs: [String]) {
        let vcChat = ChatViewController()
        if IDs.count == 1 {
            //let realm = try! Realm()
            vcChat.arrUserIDs.append("\(Key.shared.user_id)")
            vcChat.arrUserIDs.append("\(IDs[0])")
            //let chatSelf = realm.objects(RealmUser.self).filter("loginUserID_id = '\(Key.shared.user_id)_\(Key.shared.user_id)'").first!
            //vcChat.arrRealmUsers.append(chatSelf)
            //let chatWithUser = realm.objects(RealmUser.self).filter("loginUserID_id = '\(Key.shared.user_id)_\(IDs[0])'").first!
            //let chatWithUser = realm.filterUser("\(Key.shared.user_id)", id: "\(IDs[0])")!
            //vcChat.arrRealmUsers.append(chatWithUser)
            //vcChat.realmWithUser = chatWithUser
            //if let message = realm.objects(RealmMessage_v2.self).filter("login_user_id = '\(Key.shared.user_id)' AND \(chatWithUser) in members AND members.count = 2").sorted(byKeyPath: "index").first {
            vcChat.strChatId = "\(IDs[0])"
            startChat_v2(vcChat)
            /*if let message = chatWithUser.message {
                vcChat.strChatId = message.chat_id
                startChat_v2(vcChat)
            } else {
                postToURL("chats_v2", parameter: ["receiver_id": IDs[0] as AnyObject, "message": "[GET_CHAT_ID]", "type": "get_id"], authentication: headerAuthentication(), completion: { (statusCode, result) in
                    if statusCode / 100 == 2 {
                        if let resultDic = result as? NSDictionary {
                            vcChat.strChatId = (resultDic["chat_id"] as! NSNumber).stringValue
                            self.startChat_v2(vcChat)
                        }
                    }
                })
            }*/
            
        }
        // First get chatroom id
        /*getFromURL("chats/users/\(Key.shared.user_id)/\(id)", parameter: nil, authentication: headerAuthentication()) { status, result in
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
        }*/
    }
    
    func startChat_v2(_ vc: UIViewController) {
        var arrViewControllers = navigationController?.viewControllers
        arrViewControllers!.removeLast()
        arrViewControllers!.append(vc)
        navigationController?.setViewControllers(arrViewControllers!, animated: true)
    }
    
    /*func startChat(_ chat_id: String?, userId: Int, nickName: String?) {
        let chatVC = ChatViewController()
        chatVC.strChatRoomId = Key.shared.user_id < userId ? "\(Key.shared.user_id)-\(userId)" : "\(userId)-\(Key.shared.user_id)"
        chatVC.strChatId = chat_id
        
        // Bryan
        let nickName = nickName ?? "Chat"
        // ENDBryan
        // chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        // TODO: Tell nickname and username apart
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.display_name = nickName
        chatVC.realmWithUser!.id = "\(userId)"
        // chatVC.realmWithUser?.userAvatar =
        
        // RealmChat.addWithUser(withUser: chatVC.realmWithUser!)
        
        // EndBryan
        //self.present(chatVC, animated: true, completion: nil)
        if chatOrShare == "share" {
            chatVC.ref.child(chatVC.strChatRoomId).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                if snapshot.exists() {
                    let items = (snapshot.value as? NSDictionary)!
                    for item in items {
                        let message = (item.value as? NSDictionary)!
                        chatVC.arrDictMessages.append(message)
                    }
                }
                let snap = UIImagePNGRepresentation(UIImage(named:"locationExtendViewHolder")!) as Data!
                chatVC.sendMessage(text: "", place: self.placeDetail, snapImage: snap,  date: Date())
            })
            
            navigationController?.popViewController(animated: true)
        }
        else if chatOrShare == "chat" {
            var arrViewControllers = navigationController?.viewControllers
            arrViewControllers!.removeLast()
            arrViewControllers!.append(chatVC)
            navigationController?.setViewControllers(arrViewControllers!, animated: true)
        }
    }
 */
    
    func shareWithUsers() {
        navigationLeftItemTapped()
        for index in arrIntSelected {
            let vcChat = ChatViewController()
            let login_user_id = String(Key.shared.user_id)
            vcChat.arrUserIDs.append(login_user_id)
            vcChat.arrUserIDs.append(arrFriends[index].userID)
            vcChat.strChatId = arrFriends[index].userID
            var type = ""
            var text = ""
            var media: Data?
            switch friendListMode {
            case .location:
                type = "[Location]"
                let arrLocationInfo = locationDetail.split(separator: ",")
                text = "{\"latitude\":\"\(arrLocationInfo[0])\", \"longitude\":\"\(arrLocationInfo[1])\", \"address1\":\"\(arrLocationInfo[2])\", \"address2\":\"\(arrLocationInfo[3]),\(arrLocationInfo[4])\", \"address3\":\"\(arrLocationInfo[5])\", \"comment\":\"\"}"
                media = RealmChat.compressImageToData(locationSnapImage!)
                vcChat.sendMeaages_v2(type: type, text: text, media: media)
                break
            case .collection:
                type = "[Collection]"
                text = "{\"id\":\"\(collectionDetail!.colId)\", \"name\":\"\(collectionDetail!.colName)\", \"count\":\"\(collectionDetail!.pinIds.count)\", \"creator\":\"\"}"
                vcChat.sendMeaages_v2(type: type, text: text)
                break
            case .place:
                type = "[Place]"
                text = "{\"id\":\"\(placeDetail!.id)\", \"name\":\"\(placeDetail!.name)\", \"address\":\"\(placeDetail!.address1),\(placeDetail!.address2)\", \"imageURL\":\"\(placeDetail!.imageURL)\"}"
                downloadImage(URL: placeDetail!.imageURL) { (rawData) in
                    guard let data = rawData else { return }
                    media = data
                    vcChat.sendMeaages_v2(type: type, text: text, media: media)
                }
                break
            default:
                break
            }
            //vcChat.sendMeaages_v2(type: type, text: text, media: media)
            /*let realm = try! Realm()
            let login_user_id = String(Key.shared.user_id)
            let shareToUser = realm.filterUser(login_user_id, id: arrFriends[index].userID)!
            var newIndex = 0
            let chat_id = arrFriends[index].userID
            if let message = shareToUser.message {
                newIndex = message.index + 1
            } /*else {
                postToURL("chats_v2", parameter: ["receiver_id": shareToUser.id as AnyObject, "message": "[GET_CHAT_ID]", "type": "get_id"], authentication: headerAuthentication(), completion: { (statusCode, result) in
                    if statusCode / 100 == 2 {
                        if let resultDic = result as? NSDictionary {
                            chat_id = (resultDic["chat_id"] as! NSNumber).stringValue
                            self.sendMessage(to: shareToUser, chat_id: chat_id, newIndex: newIndex)
                        }
                    }
                })
            }*/
            //sendMessage(to: shareToUser, chat_id: chat_id, newIndex: newIndex)
            let newMessage = RealmMessage_v2()
            newMessage.setPrimaryKeyInfo(login_user_id, 0, chat_id, newIndex)
            let selfUser = realm.filterUser(login_user_id, id: login_user_id)!
            newMessage.sender = selfUser
            newMessage.members.append(selfUser)
            newMessage.members.append(shareToUser)
            newMessage.created_at = RealmChat.dateConverter(date: Date())
            switch friendListMode {
            case .location:
                newMessage.type = "[Location]"
                let arrLocationInfo = locationDetail.split(separator: ",")
                newMessage.text = "{\"latitude\":\"\(arrLocationInfo[0])\", \"longitude\":\"\(arrLocationInfo[1])\", \"address1\":\"\(arrLocationInfo[2])\", \"address2\":\"\(arrLocationInfo[3]),\(arrLocationInfo[4])\", \"address3\":\"\(arrLocationInfo[5])\", \"comment\":\"\"}"
                break
            case .collection:
                newMessage.type = "[Collection]"
                newMessage.text = "{\"id\":\"\(collectionDetail!.colId)\", \"name\":\"\(collectionDetail!.colName)\", \"count\":\"\(collectionDetail!.pinIds.count)\", \"creator\":\"\"}"
                break
            case .place:
                newMessage.type = "[Place]"
                newMessage.text = "{\"id\":\"\(placeDetail!.id)\", \"name\":\"\(placeDetail!.name)\", \"address\":\"\(placeDetail!.address1),\(placeDetail!.address2)\"}"
                break
            default:
                break
            }
            let recentRealm = RealmRecent_v2()
            recentRealm.created_at = newMessage.created_at
            recentRealm.unread_count = 0
            recentRealm.setPrimaryKeyInfo(login_user_id, 0, chat_id)
            try! realm.write {
                realm.add(newMessage)
                realm.add(recentRealm, update: true)
            }*/
        }
    }
    
    func sendMessage(to shareToUser: RealmUser, chat_id: String, newIndex: Int) {
        let login_user_id = String(Key.shared.user_id)
        let realm = try! Realm()
        let newMessage = RealmMessage_v2()
        newMessage.setPrimaryKeyInfo(login_user_id, 0, chat_id, newIndex)
        let selfUser = realm.filterUser(id: login_user_id)!
        newMessage.sender = selfUser
        newMessage.members.append(selfUser)
        newMessage.members.append(shareToUser)
        newMessage.created_at = RealmChat.dateConverter(date: Date())
        switch friendListMode {
        case .location:
            newMessage.type = "[Location]"
            let arrLocationInfo = locationDetail.split(separator: ",")
            newMessage.text = "{\"latitude\":\"\(arrLocationInfo[0])\", \"longitude\":\"\(arrLocationInfo[1])\", \"address1\":\"\(arrLocationInfo[2])\", \"address2\":\"\(arrLocationInfo[3]),\(arrLocationInfo[4])\", \"address3\":\"\(arrLocationInfo[5])\", \"comment\":\"\"}"
            break
        case .collection:
            newMessage.type = "[Collection]"
            newMessage.text = "{\"id\":\"\(collectionDetail!.colId)\", \"name\":\"\(collectionDetail!.colName)\", \"count\":\"\(collectionDetail!.pinIds.count)\", \"creator\":\"\"}"
            break
        case .place:
            newMessage.type = "[Place]"
            newMessage.text = "{\"id\":\"\(placeDetail!.id)\", \"name\":\"\(placeDetail!.name)\", \"address\":\"\(placeDetail!.address1),\(placeDetail!.address2)\"}"
            break
        default:
            break
        }
        let recentRealm = RealmRecent_v2()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, chat_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }
    
    func loadSearchBar() {
        lblTo = UILabel(frame: CGRect(x: 15, y: 78, width: 29, height: 25))
        lblTo.text = "To:"
        lblTo.textAlignment = .left
        lblTo.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTo.textColor = UIColor._182182182()
        view.addSubview(lblTo)
        
        let layout = CPCollectionViewLayout()
        layout.minimumLineSpacing = 0
        
        cllcSelected = UICollectionView(frame: CGRect(x: 47, y: 65, width: screenWidth - 47, height: 50), collectionViewLayout: layout)
        cllcSelected.backgroundColor = .white
        cllcSelected.delegate = self
        cllcSelected.dataSource = self
        cllcSelected.register(SelectedFriendCollectionViewCell.self, forCellWithReuseIdentifier: "select")
        cllcSelected.register(TextFieldCollectionViewCell.self, forCellWithReuseIdentifier: "input")
        view.addSubview(cllcSelected)
        
        uiviewBottomLine = UIView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: 1))
        uiviewBottomLine.layer.borderWidth = screenWidth
        uiviewBottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewBottomLine.layer.zPosition = 1
        view.addSubview(uiviewBottomLine)
    }
    
    func loadChatsList() {
        tblFriends = UITableView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114), style: .plain)
        tblFriends.dataSource = self
        tblFriends.delegate = self
        tblFriends.register(NewChatTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tblFriends.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tblFriends.separatorColor = UIColor._200199204()
        tblFriends.separatorInset = UIEdgeInsetsMake(0, 74, 0, 0)
        //tblFriends.tableHeaderView = uiviewHeader
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
    
    // MARK: CollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrIntSelected.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if indexPath.row == arrIntSelected.count {
            let inputCell = collectionView.dequeueReusableCell(withReuseIdentifier: "input", for: indexPath) as! TextFieldCollectionViewCell
            inputCell.tfInput.customDelegate = self
            cell = inputCell
        } else {
            let selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "select", for: indexPath) as! SelectedFriendCollectionViewCell
            selectedCell.lblSelected.text = arrFriends[arrIntSelected[indexPath.row]].nickName + ","
            selectedCell.setCellSelected(false)
            selectedCell.deleteDelegate = self
            cell = selectedCell
        }
        return cell
    }
    
    // MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SelectedFriendCollectionViewCell
        if selectedCell.boolSelected {
            selectedCell.setCellSelected(false)
            intSelectedIndex = -1
        } else {
            deselectCell()
            selectedCell.setCellSelected(true)
            selectedCell.becomeFirstResponder()
            intSelectedIndex = indexPath.row
        }
        cleanTextField()
        //boolIsClick = true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0
        if indexPath.row < arrIntSelected.count {
            width = getLabelWidth(text: arrFriends[arrIntSelected[indexPath.row]].nickName)
        } else if arrIntSelected.count > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "select", for: IndexPath(row: indexPath.row - 1, section: 0)) as! SelectedFriendCollectionViewCell
            var inputWidth = screenWidth - 47 - cell.frame.width - cell.frame.minX - 10
            if inputWidth <= 50 {
                inputWidth = screenWidth - 47 - 2
            }
            return CGSize(width: inputWidth, height: 25)
        } else {
            return CGSize(width: screenWidth - 47 - 10, height: 25)
        }
        if width >= screenWidth - 40 {
            width = screenWidth - 40
        }
        //print(width)
        return CGSize(width: width + 10, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(13, 1, 11, 1)
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let uiviewHeader:UIView = UIView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 25))
        
        let separateLine1 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        separateLine1.layer.borderWidth = screenWidth
        separateLine1.layer.borderColor = UIColor._200199204cg()
        uiviewHeader.addSubview(separateLine1)
        
        let separateLine2 = UIView(frame: CGRect(x: 0, y: 24, width: screenWidth, height: 1))
        separateLine2.layer.borderWidth = screenWidth
        separateLine2.layer.borderColor = UIColor._200199204cg()
        uiviewHeader.addSubview(separateLine2)
        //view.addSubview(uiviewHeader)
        
        let lblHeader:UILabel = UILabel(frame: uiviewHeader.bounds)
        lblHeader.textColor = UIColor._155155155()
        lblHeader.backgroundColor = UIColor.clear
        lblHeader.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        lblHeader.text = "Friends"
        uiviewHeader.addSubview(lblHeader)
        uiviewHeader.addConstraintsWithFormat("H:|-15-[v0(100)]", options: [], views: lblHeader)
        uiviewHeader.addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblHeader)
        uiviewHeader.backgroundColor = UIColor._248248248()
        
        return uiviewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
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
        if arrIntSelected.contains(arrFiltered[indexPath.row].index) {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_selected")
        } else {
            cell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.cellForRow(at: indexPath) as! NewChatTableViewCell
        let currentIndex = arrFiltered[indexPath.row].index
        if arrIntSelected.contains(currentIndex) {
            let indexInCollection = arrIntSelected.index(of: currentIndex)!
            arrIntSelected.remove(at: indexInCollection)
            UIView.setAnimationsEnabled(false)
            cllcSelected.deleteItems(at: [IndexPath(row: indexInCollection, section: 0)])
            UIView.setAnimationsEnabled(true)
        } else {
            arrIntSelected.append(indexPath.row)
            UIView.setAnimationsEnabled(false)
            cllcSelected.insertItems(at: [IndexPath(row: arrIntSelected.count - 1, section: 0)])
            UIView.setAnimationsEnabled(true)
            deselectCell()
        }
        setSelectedBoxHeight()
        loadStatus()
        cleanTextField()
        filter("")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    // end of UITableViewDelegate
    
    // deal with searching
    func filter(_ searchText: String) {
        //print("filter: \(searchText)")
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            arrFiltered = arrFriends;
        } else {
            arrFiltered = arrFriends.filter({(($0.nickName).lowercased()).range(of: searchText.lowercased()) != nil})
        }
        tblFriends.reloadData()
    }
    
   
    
    // deal with the cells on current screen
    func loadStatus() {
        if arrIntSelected.count == 0 {
            //uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "cannotSendMessage"), for: .normal)
            uiviewNavBar.rightBtn.isSelected = false
            uiviewNavBar.rightBtn.isEnabled = false
            //return
        } else {
            uiviewNavBar.rightBtn.isSelected = true
            uiviewNavBar.rightBtn.isEnabled = true
        }
        for index in 0 ..< arrFiltered.count {
            if tblFriends.cellForRow(at: IndexPath(row: index, section: 0)) == nil {
                break
            }
            let currentCell = tblFriends.cellForRow(at: IndexPath(row: index, section: 0)) as! NewChatTableViewCell
            let currentFriend: cellFriendData = arrFiltered[index]
            if arrIntSelected.contains(currentFriend.index) {
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
    func textFieldDidChange(_ textField: UITextField) {
        //print("[\(textField.text ?? "")]")
        filter(textField.text!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin")
        boolIsClick = true
        deselectCell()
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        if textField.text != "" || arrIntSelected.count == 0 {
            return
        }
        let lastSelected = cllcSelected.cellForItem(at: IndexPath(row: arrIntSelected.count - 1, section: 0)) as! SelectedFriendCollectionViewCell
        if lastSelected.boolSelected {
            arrIntSelected.remove(at: arrIntSelected.count - 1)
            UIView.setAnimationsEnabled(false)
            cllcSelected.deleteItems(at: [IndexPath(row: arrIntSelected.count, section: 0)])
            UIView.setAnimationsEnabled(true)
            //cllcSelected.layoutIfNeeded()
            setSelectedBoxHeight()
            loadStatus()
            intSelectedIndex = -1
        } else {
            lastSelected.setCellSelected(true)
            intSelectedIndex = arrIntSelected.count - 1
        }
    }
    
    /*func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("end editing")
    }*/
    
    // MyCellDelegate
    func deleteIsTapped() {
        print("delete in vc")
        if intSelectedIndex < 0 {
            return
        }
        let selectedCell = cllcSelected.dequeueReusableCell(withReuseIdentifier: "select", for: IndexPath(row: intSelectedIndex, section: 0)) as! SelectedFriendCollectionViewCell
        selectedCell.resignFirstResponder()
        let selectedIndex = arrIntSelected[intSelectedIndex]
        arrIntSelected = arrIntSelected.filter { $0 != selectedIndex }
        UIView.setAnimationsEnabled(false)
        cllcSelected.deleteItems(at: [IndexPath(row: intSelectedIndex, section: 0)])
        UIView.setAnimationsEnabled(true)
        intSelectedIndex = -1
        setSelectedBoxHeight()
        boolIsClick = true
        setTextFieldFirstResponder()
        loadStatus()
    }
    
    // scroll
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tblFriends {
            view.endEditing(true)
            boolIsClick = false
        }
    }
    
    func getLabelWidth(text: String) -> CGFloat {
        let size = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [], attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!], context: nil).size
        return size.width
    }
    
    func setTextFieldFirstResponder() {
        if boolIsClick {
            //cllcSelected.reloadItems(at: [IndexPath(row: arrIntSelected.count, section: 0)])
            //cllcSelected.reloadData()
            let inputCell = cllcSelected.cellForItem(at: IndexPath(row: arrIntSelected.count, section: 0)) as! TextFieldCollectionViewCell
            inputCell.tfInput.becomeFirstResponder()
            let res = inputCell.tfInput.isEditing
            print(res)
        }
    }
    
    func setSelectedBoxHeight() {
        var currentHeight = cllcSelected.collectionViewLayout.collectionViewContentSize.height
        if currentHeight > 99 {
            cllcSelected.setContentOffset(CGPoint(x: 0, y: currentHeight - 99), animated: false)
            currentHeight = 99
        }
        if currentHeight < 49 {
            currentHeight = 49
        }
        cllcSelected.frame = CGRect(x: 47, y: 65, width: screenWidth - 47, height: currentHeight)
        uiviewBottomLine.frame.origin.y = 65 + currentHeight
        tblFriends.frame = CGRect(x: 0, y: 65 + currentHeight, width: screenWidth, height: screenHeight - 65 - currentHeight)
    }
    
    func deselectCell() {
        if intSelectedIndex >= 0 {
            let prevSelected = cllcSelected.cellForItem(at: IndexPath(row: intSelectedIndex, section: 0)) as! SelectedFriendCollectionViewCell
            prevSelected.setCellSelected(false)
            intSelectedIndex = -1
        }
    }
    
    func cleanTextField() {
        let inputCell = cllcSelected.cellForItem(at: IndexPath(row: arrIntSelected.count, section: 0)) as! TextFieldCollectionViewCell
        inputCell.tfInput.text = ""
    }
}
