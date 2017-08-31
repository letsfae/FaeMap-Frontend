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
    
    //@IBOutlet private weak var tableView: UITableView!
    var tableView: UITableView!
    
    private var recents: JSON? // an array of dic to store recent chatting informations
    private var realmRecents: Results<RealmRecent>?
    private var cellsCurrentlyEditing: NSMutableSet! = NSMutableSet() // a set storing all the cell that the delete button is displaying
    private var loadingRecentTimer: Timer!
    
    var backClosure: BackClosure?
    
    // MARK: - View did/will funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.separatorColor = UIColor._200199204()
        tableView.separatorInset = UIEdgeInsetsMake(0, 89, 0, 0)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        //navigationController?.setNavigationBarHidden(false, animated: true)
        //self.tableView.tableFooterView = UIView()
        navigationBarSet()
        addGestureRecognizer()
        // downloadCurrentUserAvatar()
        
        // Bryan
//        let realm = try! Realm()
//        self.realmRecents = realm.objects(RealmRecent.self)
//        self.tableView.reloadData()
        
        // TODO: Delete userDefaults
        //        if let recentData = UserDefaults.standard.array(forKey: user_id.stringValue + "recentData"){
        //            self.recents = JSON(recentData)
        //            print(self.recents!)
        //            self.tableView.reloadData()
        //        }
        // ENDBryan
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.loadingRecentTimer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCheckingRecent()
        let realm = try! Realm()
        self.realmRecents = realm.objects(RealmRecent.self).sorted(byKeyPath: "date", ascending: false)
        self.tableView.reloadData()
        //print("recent will appear")
        //startCheckingRecent()
        //self.tableView.reloadData()
        self.loadingRecentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startCheckingRecent), userInfo: nil, repeats: true)
        self.downloadCurrentUserAvatar()
    }
    
    /*
     // MARK: - setup
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func navigationBarSet() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        //uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.addConstraintsWithFormat("H:|-15-[v0(24)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(24)]-12-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-29-[v0(24)]", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "locationPin"), for: .normal)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(navigationRightItemTapped), for: .touchUpInside)
        
        uiviewNavBar.lblTitle.text = "Chats"
        
        /*self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = nil
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = "Chats"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "locationPin"), style: .plain, target: self, action: #selector(RecentViewController.navigationLeftItemTapped))*/
        
        // ATTENTION: Temporary comment it here because it's not used for now
        //        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(RecentViewController.navigationRightItemTapped)),UIBarButtonItem.init(image: UIImage(named: "cross"), style: .Plain, target: self, action: #selector(RecentViewController.crossTapped))]
        
        //self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 89, bottom: 0, right: 0)
    }
    
    private func addGestureRecognizer() {
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecentViewController.closeAllCell)))
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
    
    // MARK: - tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.cellsCurrentlyEditing.count == 0 {
            //tableView.deselectRow(at: indexPath, animated: true)
            if let recent = recents?[indexPath.row] {
                if recent["with_user_id"].number != nil {
                    //performSegue(withIdentifier: "recentToChatSeg", sender: indexPath)
                    gotoChatFromRecent(selectedRowAt: indexPath)
                }
            }
        } else {
            for indexP in self.cellsCurrentlyEditing {
                let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    // MARK: - UItableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recents == nil ? 0 : self.recents!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        cell.delegate = self
        
        // Bryan
        // let recent = recents![indexPath.row]
        // cell.bindData(recent)
        
        let realmRecent = realmRecents![indexPath.row]
        cell.bindData2(realmRecent)
        // ENDBryan
        
        if self.cellsCurrentlyEditing.contains(indexPath) {
            cell.openCell()
        }
        return cell
    }
    // MARK: - helpers
    
    func gotoChatFromRecent(selectedRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        let recent = recents![indexPath.row]
        //chatVC.chatRoomId = user_id < recent["with_user_id"].intValue ? "\(user_id)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(user_id)"
        chatVC.chatRoomId = Key.shared.user_id < recent["with_user_id"].intValue ? "\(Key.shared.user_id)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(Key.shared.user_id)"
        chatVC.chat_id = recent["chat_id"].number?.stringValue
        let withUserUserId = recent["with_user_id"].number?.stringValue
        let withUserName = recent["with_user_name"].string
        let withUserNickName = recent["with_nick_name"].string
        //loadInitMessages(chatin: chatVC.chatRoomId, chatWith: withUserUserId!)
        
        //chatVC.loadInitMessages()
        //chatVC.loadNewMessages()
        // Bryan
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userName = withUserName!
        chatVC.realmWithUser!.userNickName = withUserNickName!
        chatVC.realmWithUser!.userID = withUserUserId!
        chatVC.withUserId = withUserUserId!
        // EndBryan
        //present(chatVC, animated: true, completion: nil)
        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            //self.navigationController?.pushViewController(chatVC, animated: true)
        //}
        /*firebase.child(chatVC.chatRoomId).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            //this function will run only once
            let items = (snapshot.value as? NSMutableDictionary)!
            print(snapshot.key)
            for item in items {
                RealmChat.receiveMessage(message: item.value as! NSDictionary, withUserID: withUserUserId!)
            }
            self.navigationController?.pushViewController(chatVC, animated: true)
        }*/
        firebase.child(chatVC.chatRoomId).queryLimited(toLast: 15).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let items = (snapshot.value as? NSMutableDictionary)!
            for item in items {
                
            }
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    func loadInitMessages(chatin chatRoomId: String, chatWith user: String) {
        //let roomRef = firebase.child(chatRoomId)
        firebase.child(chatRoomId).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            //this function will run only once
            let items = (snapshot.value as? NSMutableDictionary)!
            print(snapshot.key)
            for item in items {
                RealmChat.receiveMessage(message: item.value as! NSDictionary, withUserID: user)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! IndexPath
            let chatVC = segue.destination as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let recent = recents![indexPath.row]
            chatVC.chatRoomId = Key.shared.user_id < recent["with_user_id"].intValue ? "\(Key.shared.user_id)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(Key.shared.user_id)"
            chatVC.chat_id = recent["chat_id"].number?.stringValue
            let withUserUserId = recent["with_user_id"].number?.stringValue
            let withUserName = recent["with_user_name"].string
            let withUserNickName = recent["with_nick_name"].string
            // Bryan
            chatVC.realmWithUser = RealmUser()
            chatVC.realmWithUser!.userName = withUserName!
            chatVC.realmWithUser!.userNickName = withUserNickName!
            chatVC.realmWithUser!.userID = withUserUserId!
            // EndBryan
        }
    }
    
    @objc private func startCheckingRecent() {
        self.loadRecents(false, removeIndexPaths: nil)
    }
    
    // download current user's avatar from server
    private func downloadCurrentUserAvatar() {
        General.shared.avatar(userid: Key.shared.user_id) { (avatarImage) in
            avatarDic[Key.shared.user_id] = avatarImage
        }
    }
    
    // MARK: load recents form server
    
    /// load recent list from server, also used to reload the recent list after deletion
    ///
    /// - Parameters:
    ///   - animated: update the table with/without animation
    ///   - indexPathSet: the specific indexpath set needed to update, set nil if you want to update the whole recent list
    private func loadRecents(_ animated: Bool, removeIndexPaths indexPathSet: [IndexPath]?) {
        
        //firebase.childbY
        //
        getFromURL("chats", parameter: nil, authentication: headerAuthentication()) { _, result in
            if let cacheRecent = result as? NSArray {
                // Bryan
                //                getFromURL("chat_rooms", parameter: nil, authentication: headerAuthentication()) { (status2, result2) in
                //                    if let cacheRecent2 = result2 as? NSArray {
                //                        cacheRecent.addingObjects(from: cacheRecent2 as! [Any])
                //                    }
                //                }
                // ENDBryan
                let json = JSON(result!)
                //print(json)
                self.recents = json
                // Bryan
                // UserDefaults.standard.set(cacheRecent, forKey: (user_id.stringValue + "recentData"))
                RealmChat.updateRecent(recents: cacheRecent)
                if animated && indexPathSet != nil {
                    self.tableView.deleteRows(at: indexPathSet!, with: .left)
                } else {
                    if !isDraggingRecentTableViewCell {
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.recents = JSON([])
            }
        }
    }
    
    func closeAllCell(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        } else {
            for indexP in self.cellsCurrentlyEditing {
                let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    // MARK: - swipeable cell delegate
    
    func cellwillOpen(_ cell: UITableViewCell) {
        self.closeAllCell(UITapGestureRecognizer())
    }
    
    func cellDidOpen(_ cell: UITableViewCell) {
        let currentEditingIndexPath = self.tableView.indexPath(for: cell)
        if currentEditingIndexPath != nil {
            self.cellsCurrentlyEditing.add(currentEditingIndexPath!)
        }
    }
    
    func cellDidClose(_ cell: UITableViewCell) {
        if self.tableView.indexPath(for: cell) != nil {
            self.cellsCurrentlyEditing.remove(self.tableView.indexPath(for: cell)!)
        }
    }
    
    func deleteButtonTapped(_ cell: UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let recent = recents![indexPath.row]
        let realmRecent = realmRecents![indexPath.row]
        RealmChat.removeRecentWith(recentItem: realmRecent)
        
        // remove recent form the array
        DeleteRecentItem(recent, completion: { (statusCode, _) -> Void in
            if statusCode / 100 == 2 {
                self.loadRecents(true, removeIndexPaths: [indexPath])
            }
        })
        
        cellsCurrentlyEditing.remove(indexPath)
    }
}
