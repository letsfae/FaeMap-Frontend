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

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SwipeableCellDelegate {
    
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private var tblRecents: UITableView!
    private var uiviewBackground: UIView!
    private var uiviewDeleteConfirm: UIView!
    private var btnDeleteConfirm: UIButton!
    private var lblConfirmLine1: UILabel!
    private var lblConfirmLine2: UILabel!
    private var btnDismiss: UIButton!
    
    let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var resultRealmRecents: Results<RealmRecentMessage>!
    private var timerUpdateTimestamp: Timer!
    
    private var indexToDelete = IndexPath() // index of cell whose delete button is tapped
    private var indexShowDelete = -1
    private var indexSelected = -1
    private var boolFingerMoved: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentsFromRealm()
        navigationBarSet()
        loadRecentTable()
        loadDeleteConfirm()
        addGestureRecognizer()        
        observeOnMessageChange()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timerUpdateTimestamp = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimestamp), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerUpdateTimestamp.invalidate()
        indexSelected = -1
        indexShowDelete = -1
    }

     // MARK: - Setup UI
    private func navigationBarSet() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(device_offset_top + 17)-[v0(48)]", options: [], views: uiviewNavBar.leftBtn)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(device_offset_top + 17)-[v0(48)]", options: [], views: uiviewNavBar.rightBtn)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_talkPlus"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(navigationRightItemTapped), for: .touchUpInside)
        uiviewNavBar.lblTitle.text = "Chats"
    }
    
    private func loadRecentTable() {
        automaticallyAdjustsScrollViewInsets = false
        tblRecents = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
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
        let uiviewLeftMargin = LeftMarginToEnableNavGestureView()
        view.addSubview(uiviewLeftMargin)
    }
    
    private func loadDeleteConfirm() {
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        
        uiviewDeleteConfirm = UIView(frame: CGRect(x: 0, y: alert_offset_top, w: 290, h: 208))
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
        tblRecents.addGestureRecognizer(tapGestureRecognize)
        tblRecents.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Button & gesture actions
    @objc private func navigationLeftItemTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func navigationRightItemTapped() {
        let vc = NewChatShareController(friendListMode: .chat)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func confirmDetele() {
        let indexPath = indexToDelete
        let recentToDeleted = resultRealmRecents[indexPath.row]
        let chat_id = recentToDeleted.chat_id
        let allMessages = realm.filterAllMessages(0, chat_id)
        try! realm.write {
            realm.delete(recentToDeleted)
            realm.delete(allMessages)
        }
        uiviewBackground.isHidden = true
        getFromURL("chats_v2/users/\(Key.shared.user_id)/\(chat_id)", parameter: nil, authentication: Key.shared.headerAuthentication()) {statusCode, result in
            if statusCode / 100 == 2 {
                if let response = result as? NSDictionary {
                    let id = response["chat_id"] as! Int
                    deleteFromURL("chats_v2/\(id)", parameter: [:], completion: { (statusCode, result) in
                        if statusCode / 100 == 2 {
                            print("delete \(chat_id) successfully")
                        }
                    })
                }
            } else if statusCode == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }        
    }
    
    @objc private func dismissDelete() {
        uiviewBackground.isHidden = true
        let cell = tblRecents.cellForRow(at: indexToDelete) as! RecentTableViewCell
        cell.closeCell()
    }
    
    // MARK: Handle tap & long press gesture
    @objc private func closeAllCell(_ recognizer: UITapGestureRecognizer) {
        felixprint("tap gesture")
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
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tblRecents)
        switch recognizer.state {
        case .began:
            felixprint("long press begin")
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
        case .changed:
            felixprint("long press changed")
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row != indexShowDelete {
                    let cell = tblRecents.cellForRow(at: indexPath) as! RecentTableViewCell
                    cell.uiviewMain.backgroundColor = UIColor.white
                }
            }
            boolFingerMoved = true
        case .ended:
            felixprint("long press ended")
            if let indexPath = tblRecents.indexPathForRow(at: point) {
                if indexPath.row == indexShowDelete {
                    indexShowDelete = -1
                } else if !boolFingerMoved {
                    gotoChatFromRecent(selectedRowAt: indexPath)
                }
            } else {
                indexShowDelete = -1
            }
            boolFingerMoved = false
        default: break
        }
    }
    
    private func closeCurrentOpenCell() {
        if indexShowDelete >= 0 {
            let cell = tblRecents.cellForRow(at: IndexPath(row: indexShowDelete, section: 0)) as! RecentTableViewCell
            cell.closeCell()
            cell.uiviewMain.backgroundColor = .white
            indexShowDelete = -1
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexShowDelete >= 0 {
            if indexShowDelete != indexPath.row {
                indexSelected = indexPath.row
            }
            closeCurrentOpenCell()
        } else {
            gotoChatFromRecent(selectedRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
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
    
    // MARK: - UItableViewDataSource
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
        let recentRealm = resultRealmRecents[indexPath.row]
        cell.bindData(recentRealm)
        return cell
    }
    
    // MARK: - Load and observe on recent messages
    private func loadRecentsFromRealm() {
        resultRealmRecents = realm.objects(RealmRecentMessage.self).filter("login_user_id == %@", String(Key.shared.user_id)).sorted(byKeyPath: "created_at", ascending: false)
    }
    
    private func observeOnMessageChange() {
        guard let tableview = self.tblRecents else { return }
        notificationToken = resultRealmRecents.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("initial")
                tableview.reloadData()
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
    
    // MARK: - Helpers
    private func gotoChatFromRecent(selectedRowAt indexPath: IndexPath) {
        let vcChat = ChatViewController()
        let latestMessage = resultRealmRecents[indexPath.row].latest_message!
        for user in latestMessage.members {
            vcChat.arrUserIDs.append(user.id)
        }
        vcChat.strChatId = latestMessage.chat_id
        if let controller = Key.shared.FMVCtrler {
            vcChat.mapDelegate = controller
        }
        navigationController?.pushViewController(vcChat, animated: true)
        try! realm.write {
            resultRealmRecents[indexPath.row].unread_count = 0
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

    // MARK: - SwipeableCellDelegate
    func cellwillOpen(_ cell: UITableViewCell) {
        let current = cell as! RecentTableViewCell
        current.btnDelete.isHidden = false
        closeCurrentOpenCell()
    }
    
    func cellDidOpen(_ cell: UITableViewCell) {
        if let currentEditingIndexPath = tblRecents.indexPath(for: cell) {
            indexShowDelete = currentEditingIndexPath.row
        }
    }
    
    func cellDidClose(_ cell: UITableViewCell) {
        if indexSelected >= 0 {
            let cell = tblRecents.cellForRow(at: IndexPath(row: indexSelected, section: 0)) as! RecentTableViewCell
            cell.btnDelete.isHidden = true
            gotoChatFromRecent(selectedRowAt: IndexPath(row: indexSelected, section: 0))
        } else {
            indexSelected = -1
        }
    }
    
    func deleteButtonTapped(_ cell: UITableViewCell) {
        uiviewBackground.isHidden = false
        indexToDelete = tblRecents.indexPath(for: cell)!
    }
    
}
