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
import Firebase

typealias BackClosure = (Int) -> Void

public var isDraggingRecentTableViewCell = false

// Bryan
// avatarDic was [NSNumber:UIImage] before
public var avatarDic = [Int: UIImage]() // an dictionary to store avatar, this should be moved to else where later
// ENDBryan

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SwipeableCellDelegate {
    
    private let firebase = Database.database().reference().child(fireBaseRef)
    
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
    var backClosure: BackClosure? // used to pass current # of unread messages to main map view
    
    private var arrRecentsRealm: [String: RealmMessage_v2] = [:]
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    private var resultRealmRecents: Results<RealmRecent_v2>!
    private var timerUpdateTimestamp: Timer!
    
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
    }
    deinit {
        notificationToken?.stop()
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
        //loadingRecentTimer.invalidate()
        isDraggingRecentTableViewCell = false
    }

     // MARK: setup UI
    func navigationBarSet() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        //uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-32-[v0(18)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(24)]-12-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-29-[v0(24)]", options: [], views: uiviewNavBar.rightBtn)
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
    }
    
    func loadDeleteConfirm() {
        uiviewBackground = UIView(frame: CGRect(x:0, y:0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        
        uiviewDeleteConfirm = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewDeleteConfirm.center.x = screenWidth / 2
        uiviewDeleteConfirm.backgroundColor = .white
        uiviewDeleteConfirm.layer.cornerRadius = 20
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
        btnDeleteConfirm.layer.cornerRadius = 21 * screenWidthFactor
        uiviewDeleteConfirm.addSubview(btnDeleteConfirm)
        
        btnDismiss = UIButton(frame: CGRect(x: 15, y: 15, w: 17, h: 17))
        btnDismiss.setImage(UIImage.init(named: "btn_close"), for: .normal)
        btnDismiss.addTarget(self, action: #selector(dismissDelete), for: .touchUpInside)
        uiviewDeleteConfirm.addSubview(btnDismiss)
        
        view.addSubview(uiviewBackground)
        uiviewBackground.isHidden = true
    }
    
    private func addGestureRecognizer() {
        tblRecents.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAllCell)))
    }
    
    func navigationLeftItemTapped() {
        //backClosure!(5)
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationRightItemTapped() {
        let vc = NewChatShareController(chatOrShare: "chat")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmDetele() {
        //let indexPath = indexToDelete
        uiviewBackground.isHidden = true
        let cell = tblRecents.cellForRow(at: indexToDelete) as! RecentTableViewCell
        cell.closeCell()
        /*let indexPath = tableView.indexPath(for: cell)!
         let recent = recents![indexPath.row]
         let realmRecent = realmRecents![indexPath.row]
         RealmChat.removeRecentWith(recentItem: realmRecent)
         
         // remove recent form the array
         DeleteRecentItem(recent, completion: { (statusCode, _) -> Void in
         if statusCode / 100 == 2 {
         self.loadRecents(true, removeIndexPaths: [indexPath])
         }
         })
         
         cellsCurrentlyEditing.remove(indexPath)*/
    }
    
    func dismissDelete() {
        uiviewBackground.isHidden = true
        let cell = tblRecents.cellForRow(at: indexToDelete) as! RecentTableViewCell
        cell.closeCell()
    }
    
    // MARK: UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO double click bug
        if self.cellsCurrentlyEditing.count == 0 {
            /*self.loadingRecentTimer.invalidate()
            if let recent = recents?[indexPath.row] {
                if recent["with_user_id"].number != nil {
                    let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor._225225225()
                    gotoChatFromRecent(selectedRowAt: indexPath)
                }
            }*/
            let cell = tableView.cellForRow(at: indexPath) as! RecentTableViewCell
            cell.uiviewMain.backgroundColor = UIColor._225225225()
            gotoChatFromRecent_v2(selectedRowAt: indexPath)
        } else {
            for indexP in self.cellsCurrentlyEditing {
                let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
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
        cell.bindData_v2(recentRealm.latest_message!)
        
        if cellsCurrentlyEditing.contains(indexPath) {
            cell.openCell()
        }
        return cell
    }
    
    // MARK: helpers
    func gotoChatFromRecent_v2(selectedRowAt indexPath: IndexPath) {
        let vcChat = ChatViewController()
        let latestMessage = resultRealmRecents[indexPath.row].latest_message!
        for user in latestMessage.members {
            vcChat.arrRealmUsers.append(user)
        }
        vcChat.strChatId = latestMessage.chat_id
        navigationController?.pushViewController(vcChat, animated: true)
    }
    
    func gotoChatFromRecent(selectedRowAt indexPath: IndexPath) {
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
        
    }
    
    @objc private func startCheckingRecent() {
        loadRecents(false, removeIndexPaths: nil)
    }
    
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
        notificationToken = resultRealmRecents.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                print("initial")
                tableview.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("update")
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
    private func loadRecents(_ animated: Bool, removeIndexPaths indexPathSet: [IndexPath]?) {
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
    }
    
    // MARK: handle tap gesture
    func closeAllCell(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: tblRecents)
        if let indexPath = tblRecents.indexPathForRow(at: point) {
            tableView(tblRecents, didSelectRowAt: indexPath)
        } else {
            for indexP in cellsCurrentlyEditing {
                let cell = tblRecents.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    // MARK: SwipeableCellDelegate
    func cellwillOpen(_ cell: UITableViewCell) {
        closeAllCell(UITapGestureRecognizer())
    }
    
    func cellDidOpen(_ cell: UITableViewCell) {
        let currentEditingIndexPath = tblRecents.indexPath(for: cell)
        if currentEditingIndexPath != nil {
            cellsCurrentlyEditing.add(currentEditingIndexPath!)
        }
    }
    
    func cellDidClose(_ cell: UITableViewCell) {
        if tblRecents.indexPath(for: cell) != nil {
            cellsCurrentlyEditing.remove(tblRecents.indexPath(for: cell)!)
        }
    }
    
    func deleteButtonTapped(_ cell: UITableViewCell) {
        uiviewBackground.isHidden = false
        indexToDelete = tblRecents.indexPath(for: cell)!
    }
    
}
