//
//  RecentViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

typealias BackClosure = (Int) -> Void

public var isDraggingRecentTableViewCell = false

// Bryan
// avatarDic was [NSNumber:UIImage] before
public var avatarDic = [Int: UIImage]() // an dictionary to store avatar, this should be moved to else where later
// ENDBryan

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SwipeableCellDelegate {
    
    // MARK: - properties
    var uiviewNavBar: FaeNavBar!
    var tblRecents: UITableView!
    var uiviewBackground: UIView!
    var uiviewDeleteConfirm: UIView!
    var btnDeleteConfirm: UIButton!
    var lblConfirmLine1: UILabel!
    var lblConfirmLine2: UILabel!
    var btnDismiss: UIButton!
    
    private var recents: JSON? // an array of dic to store recent chatting informations
    private var realmRecents: Results<RealmRecent>?
    private var cellsCurrentlyEditing: NSMutableSet! = NSMutableSet() // a set storing all the cell that the delete button is displaying
    private var loadingRecentTimer: Timer!
    private var indexToDelete = IndexPath() // index of cell whose delete button is tapped
    private var indexShowDelete = -1
    private var indexSelected = -1
    var backClosure: BackClosure? // used to pass current # of unread messages to main map view
    
    private var arrRecentsRealm: [String: RealmMessage_v2] = [:]
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    private var resultRealmRecents: Results<RealmRecent_v2>!
    private var timerUpdateTimestamp: Timer!
    
    var boolFingerMoved: Bool = false
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentsFromRealm()
        
        navigationBarSet()
        loadRecentTable()
        loadDeleteConfirm()
        addGestureRecognizer()        
        downloadCurrentUserAvatar()
        //firebase.keepSynced(true)
        observeOnMessageChange()
        
        // TODO
        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(Key.shared.user_id)", String(Key.shared.user_id), String(Key.shared.user_id), Key.shared.username , Key.shared.nickname ?? "", true, "", Key.shared.gender])
        try! realm.write {
            realm.add(realmUser, update: true)
        }
    }
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //startCheckingRecent()
        //loadingRecentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startCheckingRecent), userInfo: nil, repeats: true)
        //let realm = try! Realm()
        //realmRecents = realm.objects(RealmRecent.self).sorted(byKeyPath: "date", ascending: false)
        //tblRecents.reloadData()
        loadingRecentTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimestamp), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingRecentTimer.invalidate()
        isDraggingRecentTableViewCell = false
        /*for indexP in self.cellsCurrentlyEditing {
            let cell = tblRecents.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
            cell.closeCell()
        }*/
        //closeCurrentOpenCell()
        indexSelected = -1
        indexShowDelete = -1
    }

     // MARK: setup UI
    func navigationBarSet() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        //uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-17-[v0(48)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-17-[v0(48)]", options: [], views: uiviewNavBar.rightBtn)
        //uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "locationPin"), for: .normal)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(navigationRightItemTapped), for: .touchUpInside)
        uiviewNavBar.lblTitle.text = "Chats"
    }
    
    func loadRecentTable() {
        automaticallyAdjustsScrollViewInsets = false
        tblRecents = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tblRecents.dataSource = self
        tblRecents.delegate = self
        tblRecents.register(RecentTableViewCell.self, forCellReuseIdentifier: "Cell")
        tblRecents.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tblRecents.separatorColor = UIColor._200199204()
        tblRecents.separatorInset = UIEdgeInsetsMake(0, 89, 0, 0)
        tblRecents.tableFooterView = UIView()
        tblRecents.backgroundColor = UIColor.white
        view.addSubview(tblRecents)
        tblRecents.delaysContentTouches = false
        
        // Joshua: Add this two lines to enable the edge-gesture on the left side of screen
        //         whole table view and cell will automatically disable this
        let uiview = UIView(frame: CGRect(x: 0, y: 65, width: 15, height: screenHeight - 65))
        view.addSubview(uiview)
    }
    
    func loadDeleteConfirm() {
        uiviewBackground = UIView(frame: CGRect(x:0, y:0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        
        uiviewDeleteConfirm = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewDeleteConfirm.center.x = screenWidth / 2
        uiviewDeleteConfirm.backgroundColor = .white
        uiviewDeleteConfirm.layer.cornerRadius = 21 * screenWidthFactor
        uiviewBackground.addSubview(uiviewDeleteConfirm)
        
        lblConfirmLine1 = UILabel(frame: CGRect(x: 0, y: 30, w: 185, h: 50))
        lblConfirmLine1.center.x = uiviewDeleteConfirm.frame.width / 2
        lblConfirmLine1.textAlignment = .center
        lblConfirmLine1.lineBreakMode = .byWordWrapping
        lblConfirmLine1.numberOfLines = 2
        lblConfirmLine1.text = "Are you sure you want to delete this Chat?"
        lblConfirmLine1.textColor = UIColor._898989()
        lblConfirmLine1.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewDeleteConfirm.addSubview(lblConfirmLine1)
        
        lblConfirmLine2 = UILabel(frame: CGRect(x: 0, y: 93, w: 185, h: 36))
        lblConfirmLine2.center.x = uiviewDeleteConfirm.frame.width / 2
        lblConfirmLine2.textAlignment = .center
        lblConfirmLine2.lineBreakMode = .byWordWrapping
        lblConfirmLine2.numberOfLines = 2
        lblConfirmLine2.text = "All chat history and contents of this chat will also be Cleared."
        lblConfirmLine2.textColor = UIColor._138138138()
        lblConfirmLine2.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        uiviewDeleteConfirm.addSubview(lblConfirmLine2)
        
        btnDeleteConfirm = UIButton(frame: CGRect(x: 0, y: 149, w: 208, h: 39))
        btnDeleteConfirm.center.x = uiviewDeleteConfirm.frame.width / 2
        btnDeleteConfirm.setTitle("Yes", for: .normal)
        btnDeleteConfirm.setTitleColor(UIColor.white, for: .normal)
        btnDeleteConfirm.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnDeleteConfirm.backgroundColor = UIColor._2499090()
        btnDeleteConfirm.addTarget(self, action: #selector(confirmDetele), for: .touchUpInside)
        btnDeleteConfirm.layer.borderWidth = 2
        btnDeleteConfirm.layer.borderColor = UIColor._2499090().cgColor
        btnDeleteConfirm.layer.cornerRadius = 19 * screenWidthFactor
        uiviewDeleteConfirm.addSubview(btnDeleteConfirm)
        
        btnDismiss = UIButton(frame: CGRect(x: 15, y: 15, w: 17, h: 17))
        btnDismiss.setImage(UIImage.init(named: "btn_close"), for: .normal)
        btnDismiss.addTarget(self, action: #selector(dismissDelete), for: .touchUpInside)
        uiviewDeleteConfirm.addSubview(btnDismiss)
        
        view.addSubview(uiviewBackground)
        uiviewBackground.isHidden = true
    }
    
    private func addGestureRecognizer() {
        let tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(closeAllCell))
        tapGestureRecognize.delaysTouchesBegan = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delaysTouchesBegan = false
        longPressGesture.cancelsTouchesInView = true
        //tapGestureRecognize.cancelsTouchesInView = false
        tblRecents.addGestureRecognizer(tapGestureRecognize)
        tblRecents.addGestureRecognizer(longPressGesture)
        //tblRecents.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAllCell)))
    }
    
    @objc func navigationLeftItemTapped() {
        //backClosure!(5)
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navigationRightItemTapped() {
        let vc = NewChatShareController(friendListMode: .chat)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func confirmDetele() {
        let indexPath = indexToDelete
        let recentToDeleted = resultRealmRecents[indexPath.row]
        let chat_id = recentToDeleted.chat_id
        let allMessages = realm.filterAllMessages("\(Key.shared.user_id)", 0, chat_id)
        try! realm.write {
            realm.delete(recentToDeleted)
            realm.delete(allMessages)
        }
        uiviewBackground.isHidden = true
        cellsCurrentlyEditing.remove(indexPath)
        getFromURL("chats_v2/users/\(Key.shared.user_id)/\(chat_id)", parameter: nil, authentication: headerAuthentication()) {statusCode, result in
            if statusCode / 100 == 2 {
                if let response = result as? NSDictionary {
                    let id = response["chat_id"] as! Int
                    deleteFromURL("chats_v2/\(id)", parameter: [:], authentication: headerAuthentication(), completion: { (statusCode, result) in
                        if statusCode / 100 == 2 {
                            print("delete \(chat_id) successfully")
                        }
                    })
                }
            }
        }        
    }
    
    @objc func dismissDelete() {
        uiviewBackground.isHidden = true
        let cell = tblRecents.cellForRow(at: indexToDelete) as! RecentTableViewCell
        cell.closeCell()
    }
    
    // MARK: UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexShowDelete >= 0 {
            if indexShowDelete != indexPath.row {
                indexSelected = indexPath.row
            }
            closeCurrentOpenCell()
        } else {
            gotoChatFromRecent_v2(selectedRowAt: indexPath)
        }
        // TODO double click bug
        //let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
        //cell.uiviewMain.backgroundColor = UIColor._225225225()
        //if self.cellsCurrentlyEditing.count == 0 {
            /*self.loadingRecentTimer.invalidate()
            if let recent = recents?[indexPath.row] {
                if recent["with_user_id"].number != nil {
                    let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor._225225225()
                    gotoChatFromRecent(selectedRowAt: indexPath)
                }
            }*/
            //let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
            //cell.uiviewMain.backgroundColor = UIColor._225225225()
            //gotoChatFromRecent_v2(selectedRowAt: indexPath)
        //} else {
           // for indexP in self.cellsCurrentlyEditing {
               // let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
               // cell.closeCell()
            //}
        //}
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        /*if indexShowDelete < 0 || indexShowDelete != indexPath.row {
            let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
            cell.btnDelete.isHidden = true
            cell.uiviewMain.backgroundColor = UIColor._225225225()
        }*/
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        /*if indexShowDelete == indexPath.row {
            let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
            cell.btnDelete.isHidden = false
            cell.uiviewMain.backgroundColor = UIColor.white
        }*/
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    // MARK: UItableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultRealmRecents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        cell.delegate = self
        cell.uiviewMain.backgroundColor = .white
        
        //let realmRecent = realmRecents![indexPath.row]
        //cell.bindData(realmRecent)
        //let recentRealm = arrRecentsRealm[indexPath.row]
        //cell.bindData_v2(recentRealm)
        let recentRealm = resultRealmRecents[indexPath.row]
        cell.bindData_v2(recentRealm)
        
        //if cellsCurrentlyEditing.contains(indexPath) {
            //cell.openCell()
        //}
        return cell
    }
    
    // MARK: helpers
    func gotoChatFromRecent_v2(selectedRowAt indexPath: IndexPath) {
        let vcChat = ChatViewController()
        let latestMessage = resultRealmRecents[indexPath.row].latest_message!
        for user in latestMessage.members {
            vcChat.arrUserIDs.append(user.id)
        }
        vcChat.strChatId = latestMessage.chat_id
        navigationController?.pushViewController(vcChat, animated: true)
        try! realm.write {
            resultRealmRecents[indexPath.row].unread_count = 0
        }
    }
    
    /*func gotoChatFromRecent(selectedRowAt indexPath: IndexPath) {
        let vcChat = ChatViewController()
        vcChat.hidesBottomBarWhenPushed = true
        let recent = recents![indexPath.row]
        vcChat.strChatRoomId = Key.shared.user_id < recent["with_user_id"].intValue ? "\(Key.shared.user_id)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(Key.shared.user_id)"
        vcChat.strChatId = recent["chat_id"].number?.stringValue
        let withUserUserId = recent["with_user_id"].number?.stringValue
        let withUserName = recent["with_user_name"].string
        let withUserNickName = recent["with_nick_name"].string
        vcChat.realmWithUser = RealmUser()
        vcChat.realmWithUser!.user_name = withUserName!
        vcChat.realmWithUser!.display_name = withUserNickName!
        vcChat.realmWithUser!.id = withUserUserId!
        //vcChat.withUserId = withUserUserId!
        
        //firebase.child(vcChat.chatRoomId).keepSynced(true)
        //firebase.child(vcChat.chatRoomId).queryLimited(toLast: UInt(1)).queryOrdered(byChild: "index").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
        //}
        firebase.child(vcChat.strChatRoomId).queryLimited(toLast: UInt(15)).queryOrdered(byChild: "index").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            //let message = (snapshot.value as? NSDictionary)!
            //vcChat.dictArrInitMessages.append(message)
            let items: NSEnumerator = snapshot.children
            while let item = items.nextObject() as? DataSnapshot {
                let message = (item.value as? NSMutableDictionary)!
                vcChat.dictArrInitMessages.append(message)
            }
            self.navigationController?.pushViewController(vcChat, animated: true)
        })
        
    }*/
    
    /*@objc private func startCheckingRecent() {
        loadRecents(false, removeIndexPaths: nil)
    }*/
    
    // download current user's avatar from server
    private func downloadCurrentUserAvatar() {
        General.shared.avatar(userid: Key.shared.user_id) { (avatarImage) in
            avatarDic[Key.shared.user_id] = avatarImage
        }
    }
    
    @objc private func updateTimestamp() {
        for index in 0..<resultRealmRecents.count {
            let cell = tblRecents.cellForRow(at: IndexPath(row: index, section: 0)) as! RecentTableViewCell
            if cell.lblDate.text == "Just Now" || cell.lblDate.text == "Yesterday" {
                UIView.setAnimationsEnabled(false)
                tblRecents.beginUpdates()
                tblRecents.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                tblRecents.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    // MARK: load recent messages from the server
    private func loadRecentsFromRealm() {
        resultRealmRecents = realm.objects(RealmRecent_v2.self).filter("login_user_id == %@", String(Key.shared.user_id)).sorted(byKeyPath: "created_at", ascending: false)
        /*let allChatID = Set(realm.objects(RealmMessage_v2.self).filter("login_user_id == %@", String(Key.shared.user_id)).value(forKey: "chat_id") as! [String])
        for chatID in allChatID {
            let lastMessage = realm.objects(RealmMessage_v2.self).filter("login_user_id == %@ AND chat_id == %@", String(Key.shared.user_id), chatID).sorted(byKeyPath: "index").last
            arrRecentsRealm.append(lastMessage!)
        }
        arrRecentsRealm.sort { $0.created_at > $1.created_at }*/
    }
    
    private func observeOnMessageChange() {
        guard let tableview = self.tblRecents else { return }
        notificationToken = resultRealmRecents.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("initial")
                tableview.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                felixprint("recent update")
                UIView.setAnimationsEnabled(false)
                tableview.beginUpdates()
                tableview.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.endUpdates()
                UIView.setAnimationsEnabled(true)
            case .error:
                print("error")
            }
        }
    }
    
    /// load recent list from server, also used to reload the recent list after deletion
    /// - Parameters:
    ///   - animated: update the table with/without animation
    ///   - indexPathSet: the specific indexpath set needed to update, set nil if you want to update the whole recent list
    /*private func loadRecents(_ animated: Bool, removeIndexPaths indexPathSet: [IndexPath]?) {
        getFromURL("chats", parameter: nil, authentication: headerAuthentication()) { _, result in
            if let cacheRecent = result as? NSArray {
                let json = JSON(result!)
                self.recents = json
                //RealmChat.updateRecent(recents: cacheRecent)
                for item in cacheRecent {
                    let recent: NSDictionary = item as! NSDictionary
                    let chatRoomId = Key.shared.user_id < recent["with_user_id"] as! Int ? "\(Key.shared.user_id)-\(recent["with_user_id"] ?? "")" : "\(recent["with_user_id"] ?? "")-\(Key.shared.user_id)"
                    self.firebase.child(chatRoomId).keepSynced(true)
                }
                if animated && indexPathSet != nil {
                    self.tblRecents.deleteRows(at: indexPathSet!, with: .left)
                } else {
                    if !isDraggingRecentTableViewCell {
                        self.tblRecents.reloadData()
                    }
                }
            } else {
                self.recents = JSON([])
            }
        }
    }*/
    
    // MARK: handle tap gesture
    @objc func closeAllCell(_ recognizer: UITapGestureRecognizer) {
        //print(recognizer.state)
        if recognizer.state == .ended {
            let point = recognizer.location(in: tblRecents)
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row == indexShowDelete {
                    closeCurrentOpenCell()
                } else {
                    let cell = tblRecents.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor._225225225()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tableView(self.tblRecents, didSelectRowAt: indexPath)
                    }
                }
            } else {
                closeCurrentOpenCell()
            }
        }
    }
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tblRecents)
        switch recognizer.state {
        case .began:
            print("long press begin")
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row == indexShowDelete {
                    closeCurrentOpenCell()
                } else {
                    if indexShowDelete >= 0 {
                        closeCurrentOpenCell()
                    }
                    let cell = tblRecents.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor._225225225()
                }
            } else {
                closeCurrentOpenCell()
            }
            break
        case .changed:
            print("long press changed")
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row != indexShowDelete {
                    let cell = tblRecents.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor.white
                }
            }
            boolFingerMoved = true
            break
        case .ended:
            print("long press ended")
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row == indexShowDelete {
                    indexShowDelete = -1
                } else if !boolFingerMoved {
                    //tableView(tblRecents, didSelectRowAt: indexPath)
                    gotoChatFromRecent_v2(selectedRowAt: indexPath)
                }
            } else {
                indexShowDelete = -1
            }
            boolFingerMoved = false
            break
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func closeCurrentOpenCell() {
        if indexShowDelete >= 0 {
            let cell = tblRecents.cellForRow(at: IndexPath(row: indexShowDelete, section: 0)) as! RecentTableViewCell
            cell.closeCell()
            cell.uiviewMain.backgroundColor = .white
            indexShowDelete = -1
        }
    }
    
    // MARK: SwipeableCellDelegate
    func cellwillOpen(_ cell: UITableViewCell) {
        let current = cell as! RecentTableViewCell
        current.btnDelete.isHidden = false
        //closeAllCell(UITapGestureRecognizer())
        closeCurrentOpenCell()
    }
    
    func cellDidOpen(_ cell: UITableViewCell) {
        //let currentEditingIndexPath = tblRecents.indexPath(for: cell)
        if let currentEditingIndexPath = tblRecents.indexPath(for: cell) {
            //cellsCurrentlyEditing.add(currentEditingIndexPath!)
            indexShowDelete = currentEditingIndexPath.row
        }
    }
    
    func cellDidClose(_ cell: UITableViewCell) {
        if indexSelected >= 0 {
            let cell = tblRecents.cellForRow(at: IndexPath(row: indexSelected, section: 0)) as! RecentTableViewCell
            cell.btnDelete.isHidden = true
            gotoChatFromRecent_v2(selectedRowAt: IndexPath(row: indexSelected, section: 0))
            //indexSelected = -1
        } else {
            indexSelected = -1
        }
        if tblRecents.indexPath(for: cell) != nil {
            //cellsCurrentlyEditing.remove(tblRecents.indexPath(for: cell)!)
            //indexShowDelete = -1
        }
    }
    
    func deleteButtonTapped(_ cell: UITableViewCell) {
        uiviewBackground.isHidden = false
        indexToDelete = tblRecents.indexPath(for: cell)!
    }
    
}
