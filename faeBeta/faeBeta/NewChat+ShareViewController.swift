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
    }
    
    mutating func setIndex(at index: Int) {
        self.index = index
    }
}

class NewChatShareController: UIViewController  {
    
    // MARK: - Properties
    private var arrFriends: [cellFriendData] = []
    private var arrFiltered: [cellFriendData] = []
    private var arrIntSelected: [Int] = []
    
    private var uiviewNavBar: FaeNavBar!
    private var lblTo: UILabel!
    private var cllcSelected: UICollectionView!
    private var uiviewSchabr: UIView!
    private var uiviewBottomLine: UIView!
    private var schbarChatTo: FaeSearchBar!
    private var searchField: UITextField!
    
    private var tblFriends: UITableView!
    private var imgGhost: UIImageView!
    
    private var intSelectedIndex: Int = -1
    private var boolIsFirst: Bool = true
    private var boolIsClick: Bool = false
    private var floatScrollViewOriginOffset: CGFloat = 0
    
    var boolShared: Bool = false
    
    enum FriendListMode {
        case chat
        case location
        case collection
        case place
    }
    var friendListMode: FriendListMode = .chat
    var locationDetail: String = ""
    var locationSnapImage: UIImage?
    var collectionDetail: RealmCollection?
    var placeDetail: PlacePin?
    
    var boolFromLocDetail: Bool = false
    var boolFromPlaceDetail: Bool = false
    
    private let apiCalls = FaeContact()
    
    //var placeDetail: PlacePin?
    
    // MARK: - init
    init(friendListMode: FriendListMode) {
        self.friendListMode = friendListMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadSearchBar()
        loadFriends()
        
        // Joshua: Add this two lines to enable the edge-gesture on the left side of screen
        //         whole table view and cell will automatically disable this
        let uiviewLeftMargin = LeftMarginToEnableNavGestureView()
        view.addSubview(uiviewLeftMargin)
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
    
    func loadSearchBar() {
        lblTo = UILabel(frame: CGRect(x: 15, y: 78 + device_offset_top, width: 29, height: 25))
        lblTo.text = "To:"
        lblTo.textAlignment = .left
        lblTo.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTo.textColor = UIColor._182182182()
        view.addSubview(lblTo)
        
        let layout = CPCollectionViewLayout()
        layout.minimumLineSpacing = 0
        
        cllcSelected = UICollectionView(frame: CGRect(x: 47, y: 65 + device_offset_top, width: screenWidth - 47, height: 50), collectionViewLayout: layout)
        cllcSelected.backgroundColor = .white
        cllcSelected.delegate = self
        cllcSelected.dataSource = self
        cllcSelected.register(SelectedFriendCollectionViewCell.self, forCellWithReuseIdentifier: "select")
        cllcSelected.register(TextFieldCollectionViewCell.self, forCellWithReuseIdentifier: "input")
        view.addSubview(cllcSelected)
        
        uiviewBottomLine = UIView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: 1))
        uiviewBottomLine.layer.borderWidth = screenWidth
        uiviewBottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewBottomLine.layer.zPosition = 1
        view.addSubview(uiviewBottomLine)
    }
    
    func loadFriends() {
        let realm = try! Realm()
        let friends = realm.filterFriends()
        for (index, friend) in friends.enumerated() {
            arrFriends.append(cellFriendData(userName: friend.user_name, nickName: friend.display_name, userID: friend.id))
            arrFriends[index].setIndex(at: index)
        }
        arrFiltered = arrFriends
        if arrFriends.count == 0 {
            loadNoFriends()
        } else {
            loadFriendList()
        }
    }
    
    func loadFriendList() {
        tblFriends = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top), style: .plain)
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
    
    // MARK: - Button actions
    @objc func navigationLeftItemTapped() {
        if let arrVCs = navigationController?.viewControllers {
            if boolFromPlaceDetail {
                let vcPlaceDetail = arrVCs[arrVCs.count - 2] as! PlaceDetailViewController
                vcPlaceDetail.boolShared = boolShared
            }
            if boolFromLocDetail {
                let vcLocDetail = arrVCs[arrVCs.count - 2] as! LocDetailViewController
                vcLocDetail.boolShared = boolShared
            }
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func navigationRightItemTapped() {
        if friendListMode == .chat {
            chatWithUsers(IDs: [arrFriends[arrIntSelected[0]].userID])
        } else {
            shareWithUsers()
        }
    }
    
    // MARK: - Helper methods for button actions
    func chatWithUsers(IDs: [String]) {
        let vcChat = ChatViewController()
        if IDs.count == 1 {
            vcChat.arrUserIDs.append("\(Key.shared.user_id)")
            vcChat.arrUserIDs.append("\(IDs[0])")
            vcChat.strChatId = "\(IDs[0])"
            startChat(vcChat)
        }
    }
    
    func startChat(_ vc: UIViewController) {
        var arrViewControllers = navigationController?.viewControllers
        arrViewControllers!.removeLast()
        arrViewControllers!.append(vc)
        navigationController?.setViewControllers(arrViewControllers!, animated: true)
    }
    
    func shareWithUsers() {
        boolShared = true
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
                vcChat.storeChatMessageToRealm(type: type, text: text, media: media)
            case .collection:
                type = "[Collection]"
                text = "{\"id\":\"\(collectionDetail!.collection_id)\", \"name\":\"\(collectionDetail!.name)\", \"count\":\"\(collectionDetail!.count)\", \"creator\":\"\(collectionDetail!.user_id)\"}"
                vcChat.storeChatMessageToRealm(type: type, text: text)
            case .place:
                type = "[Place]"
                text = "{\"id\":\"\(placeDetail!.id)\", \"name\":\"\(placeDetail!.name)\", \"address\":\"\(placeDetail!.address1),\(placeDetail!.address2)\", \"imageURL\":\"\(placeDetail!.imageURL)\"}"
                downloadImage(URL: placeDetail!.imageURL) { (rawData) in
                    guard let data = rawData else { return }
                    media = data
                    vcChat.storeChatMessageToRealm(type: type, text: text, media: media)
                }
            default: break
            }
        }
    }
    
    func sendMessage(to shareToUser: RealmUser, chat_id: String, newIndex: Int) {
        let login_user_id = String(Key.shared.user_id)
        let realm = try! Realm()
        let newMessage = RealmMessage()
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
        case .collection:
            newMessage.type = "[Collection]"
            newMessage.text = "{\"id\":\"\(collectionDetail!.collection_id)\", \"name\":\"\(collectionDetail!.name)\", \"count\":\"\(collectionDetail!.pins.count)\", \"creator\":\"\"}"
        case .place:
            newMessage.type = "[Place]"
            newMessage.text = "{\"id\":\"\(placeDetail!.id)\", \"name\":\"\(placeDetail!.name)\", \"address\":\"\(placeDetail!.address1),\(placeDetail!.address2)\"}"
        default: break
        }
        let recentRealm = RealmRecentMessage()
        recentRealm.created_at = newMessage.created_at
        recentRealm.unread_count = 0
        recentRealm.setPrimaryKeyInfo(login_user_id, 0, chat_id)
        try! realm.write {
            realm.add(newMessage)
            realm.add(recentRealm, update: true)
        }
    }
}

// MARK: - UICollectionView
extension NewChatShareController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            inputCell.tfInput.searchBarDelegate = self
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
    
}

// MARK: - UITableView
extension NewChatShareController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
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
    
    // MARK: UITableViewDelegate
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndex = arrFiltered[indexPath.row].index
        if arrIntSelected.contains(currentIndex) {
            let indexInCollection = arrIntSelected.index(of: currentIndex)!
            arrIntSelected.remove(at: indexInCollection)
            UIView.setAnimationsEnabled(false)
            cllcSelected.deleteItems(at: [IndexPath(row: indexInCollection, section: 0)])
            UIView.setAnimationsEnabled(true)
        } else {
            arrIntSelected.append(currentIndex)
            UIView.setAnimationsEnabled(false)
            cllcSelected.insertItems(at: [IndexPath(row: arrIntSelected.count - 1, section: 0)])
            UIView.setAnimationsEnabled(true)
            deselectCell()
        }
        setSelectedBoxHeight()
        loadSelectionStatus()
        cleanTextField()
        filter("")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

// MARK: - UIScrollViewDelegate
extension NewChatShareController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tblFriends {
            view.endEditing(true)
            boolIsClick = false
        }
    }
}

// MARK: - SearchBarTextFieldDelegate
extension NewChatShareController: SearchBarTextFieldDelegate {
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
            loadSelectionStatus()
            intSelectedIndex = -1
        } else {
            lastSelected.setCellSelected(true)
            intSelectedIndex = arrIntSelected.count - 1
        }
    }
}

// MARK: - KeyboardDeleteTappedDelegate
extension NewChatShareController: KeyboardDeleteTappedDelegate {
    func deleteIsTapped() {
        // print("delete in vc")
        if intSelectedIndex < 0 { return }
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
        loadSelectionStatus()
    }
}

// MARK: - Helper methods
extension NewChatShareController {
    func filter(_ searchText: String) {
        //print("filter: \(searchText)")
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            arrFiltered = arrFriends;
        } else {
            arrFiltered = arrFriends.filter({(($0.nickName).lowercased()).range(of: searchText.lowercased()) != nil})
        }
        tblFriends.reloadData()
    }
    
    func loadSelectionStatus() {
        if arrIntSelected.count == 0 {
            uiviewNavBar.rightBtn.isSelected = false
            uiviewNavBar.rightBtn.isEnabled = false
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
            } else {
                currentCell.imgStatus.image = #imageLiteral(resourceName: "status_unselected")
                currentCell.statusSelected = false
            }
        }
    }
    
    func setTextFieldFirstResponder() {
        if boolIsClick {
            let inputCell = cllcSelected.cellForItem(at: IndexPath(row: arrIntSelected.count, section: 0)) as! TextFieldCollectionViewCell
            inputCell.tfInput.becomeFirstResponder()
        }
    }
    
    func cleanTextField() {
        let inputCell = cllcSelected.cellForItem(at: IndexPath(row: arrIntSelected.count, section: 0)) as! TextFieldCollectionViewCell
        inputCell.tfInput.text = ""
    }
    
    func deselectCell() {
        if intSelectedIndex >= 0 {
            let prevSelected = cllcSelected.cellForItem(at: IndexPath(row: intSelectedIndex, section: 0)) as! SelectedFriendCollectionViewCell
            prevSelected.setCellSelected(false)
            intSelectedIndex = -1
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
        cllcSelected.frame = CGRect(x: 47, y: 65 + device_offset_top, width: screenWidth - 47, height: currentHeight)
        uiviewBottomLine.frame.origin.y = 65 + currentHeight + device_offset_top
        tblFriends.frame = CGRect(x: 0, y: 65 + currentHeight + device_offset_top, width: screenWidth, height: screenHeight - 65 - currentHeight)
    }
    
    func getLabelWidth(text: String) -> CGFloat {
        let size = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [], attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!], context: nil).size
        return size.width
    }
}
