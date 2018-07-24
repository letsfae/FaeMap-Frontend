//
//  AddNearbyViewController.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/27.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AddNearbyController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeAddUsernameDelegate, FriendOperationFromContactsDelegate, NameCardDelegate, AddFriendFromNameCardDelegate {
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private var lblScanTitle: UILabel!
    private var lblScanSubtitle: UILabel!
    private var imgAvatar: FaeAvatarView!
    private var tblUsernames: UITableView!
    private var uiviewAvatarWaveSub: UIView!
    private var arrNearby = [UserNameCard]()
    private var uiviewNameCard = FMNameCardView()
    private var hasUser = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        loadNavBar()
        loadTextView()
        loadTable()
        loadAvatarWave()
        
        loadNameCard()
        updateTable()
    }
    
    func loadNameCard() {
        view.addSubview(uiviewNameCard)
        uiviewNameCard.delegate = self
    }
    
    // MARK: - Load tableView data source & Update table data
    private func updateTable() {
        loadNearbyPeople {(count: Int) in
            UIView.animate(withDuration: 0, delay: 5, options: .curveEaseOut, animations: {
                self.hasUser = count != 0
                self.tblUsernames.reloadData()
                self.showTable()
            }, completion: nil)
        }
    }
    
    private func hideTable() {
        uiviewAvatarWaveSub.alpha = 1
        loadWaves()
        lblScanTitle.alpha = 1
        lblScanSubtitle.alpha = 1
        uiviewNavBar.rightBtn.alpha = 0
        tblUsernames.alpha = 0
    }
    
    private func showTable() {
        uiviewAvatarWaveSub.alpha = 0
        lblScanTitle.alpha = 0
        lblScanSubtitle.alpha = 0
        uiviewNavBar.rightBtn.alpha = 1
        tblUsernames.alpha = 1
    }
    
    // TODO: Vicky - 换scan nearby API
    private func loadNearbyPeople(_ completion: ((Int) -> ())?) {
        let faeMap = FaeMap()
        faeMap.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
        faeMap.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
        faeMap.whereKey("radius", value: "99999999")
        faeMap.whereKey("type", value: "user")
        faeMap.getMapPins { [weak self] (status: Int, message: Any?) in
            guard let `self` = self else { return }
            if status / 100 != 2 || message == nil {
                print("[loadNearbyPeople] status/100 != 2")
                return
            }
            let json = JSON(message!)
            if json.count <= 0 {
                print("[loadNearbyPeople] array is nil")
                return
            }
            vickyprint(json)
            
            for i in 0..<json.count {
                if json[i]["user_id"].intValue == Key.shared.user_id {
                    continue
                }
                let nearby = UserNameCard(user_id: json[i]["user_id"].intValue, nick_name: json[i]["user_nick_name"].stringValue, user_name: json[i]["user_name"].stringValue, short_intro: json[i]["short_intro"].stringValue)
                self.arrNearby.append(nearby)
                let realm = try! Realm()
                var relation = NO_RELATION
                if let userExist = realm.filterUser(id: "\(json[i]["user_id"].intValue)") {
                    relation = userExist.relation
                }
                let user = RealmUser(value: ["\(Key.shared.user_id)_\(json[i]["user_id"].intValue)", "\(Key.shared.user_id)", "\(json[i]["user_id"].intValue)", json[i]["user_name"].stringValue, json[i]["nick_name"].stringValue, relation, json[i]["age"].stringValue, json[i]["show_age"].boolValue, json[i]["gender"].stringValue, json[i]["show_gender"].boolValue, json[i]["short_intro"].stringValue])
                try! realm.write {
                    realm.add(user, update: true)
                }
            }
            
//            self.mbPeople.sort{ $0.dis < $1.dis }
            completion?(self.arrNearby.count)
        }
    }
    
    // MARK: - Set up UI
    private func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add Nearby"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)

        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        uiviewNavBar.rightBtn.setTitle("Refresh", for: .normal)
        uiviewNavBar.rightBtn.setTitleColor(UIColor._2499090(), for: .normal)
        uiviewNavBar.rightBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewNavBar.rightBtn.addConstraintsWithFormat("H:|-0-[v0(64)]", options: [], views: uiviewNavBar.rightBtn.titleLabel!)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(actionRefresh(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.alpha = 0
    }
    
    private func loadTextView() {
        lblScanTitle = UILabel()
        lblScanTitle.text = "Scanning for people nearby!"
        lblScanTitle.textAlignment = .center
        lblScanTitle.textColor = UIColor._898989()
        lblScanTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        
        lblScanSubtitle = UILabel()
        lblScanSubtitle.text = "make sure others are also scanning..."
        lblScanSubtitle.textAlignment = .center
        lblScanSubtitle.textColor = UIColor._138138138()
        lblScanSubtitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        view.addSubview(lblScanTitle)
        view.addSubview(lblScanSubtitle)
        
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblScanTitle)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblScanSubtitle)
        view.addConstraintsWithFormat("V:|-\(110+device_offset_top)-[v0]", options: [], views: lblScanTitle)
        view.addConstraintsWithFormat("V:|-\(140+device_offset_top)-[v0]", options: [], views: lblScanSubtitle)
    }
    
    private func loadAvatarWave() {
        let xAxis: CGFloat = screenWidth / 2
        let yAxis: CGFloat = 368 * screenHeightFactor + device_offset_top + device_offset_top
        
        uiviewAvatarWaveSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        uiviewAvatarWaveSub.center = CGPoint(x: xAxis, y: yAxis)
        view.addSubview(uiviewAvatarWaveSub)
        
        let imgAvatarSub = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imgAvatarSub.contentMode = .scaleAspectFill
        imgAvatarSub.image = #imageLiteral(resourceName: "exp_avatar_border")
        imgAvatarSub.center = CGPoint(x: xAxis, y: xAxis)
        uiviewAvatarWaveSub.addSubview(imgAvatarSub)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        imgAvatar.layer.cornerRadius = 35
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.center = CGPoint(x: xAxis, y: xAxis)
        imgAvatar.isUserInteractionEnabled = false
        imgAvatar.clipsToBounds = true
        uiviewAvatarWaveSub.addSubview(imgAvatar)
        imgAvatar.userID = Key.shared.user_id
        imgAvatar.loadAvatar(id: Key.shared.user_id)
        
        loadWaves()
    }
    
    private func loadWaves() {
        var filterCircle_1: UIImageView!
        var filterCircle_2: UIImageView!
        var filterCircle_3: UIImageView!
        var filterCircle_4: UIImageView!
        
        func createFilterCircle() -> UIImageView {
            let xAxis: CGFloat = screenWidth / 2
            let imgView = UIImageView(frame: CGRect.zero)
            imgView.frame.size = CGSize(width: 80, height: 80)
            imgView.center = CGPoint(x: xAxis, y: xAxis)
            imgView.image = #imageLiteral(resourceName: "exp_wave")
            imgView.tag = 0
            return imgView
        }
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
            filterCircle_2.removeFromSuperview()
            filterCircle_3.removeFromSuperview()
            filterCircle_4.removeFromSuperview()
        }
        filterCircle_1 = createFilterCircle()
        filterCircle_2 = createFilterCircle()
        filterCircle_3 = createFilterCircle()
        filterCircle_4 = createFilterCircle()
        uiviewAvatarWaveSub.addSubview(filterCircle_1)
        uiviewAvatarWaveSub.addSubview(filterCircle_2)
        uiviewAvatarWaveSub.addSubview(filterCircle_3)
        uiviewAvatarWaveSub.addSubview(filterCircle_4)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_1)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_2)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_3)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_4)

        animation(circle: filterCircle_1, delay: 0)
        animation(circle: filterCircle_2, delay: 0.5)
        animation(circle: filterCircle_3, delay: 2)
        animation(circle: filterCircle_4, delay: 2.5)
    }
    
    private func animation(circle: UIImageView, delay: Double) {
        let animateTime: Double = 3
        let radius: CGFloat = screenWidth
        let newFrame = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        let xAxis: CGFloat = screenWidth / 2
        circle.frame.size = CGSize(width: 80, height: 80)
        circle.center = CGPoint(x: xAxis, y: xAxis)
        circle.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: animateTime, delay: 0, options: [.curveEaseOut], animations: ({
                circle.alpha = 0.0
                circle.frame = newFrame
            }), completion: { _ in
                self.animation(circle: circle, delay: 0.75)
            })
        }
    }
    
    private func loadTable() {
        tblUsernames = UITableView()
        tblUsernames.frame = CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top)
        tblUsernames.dataSource = self
        tblUsernames.delegate = self
        tblUsernames.register(FaeAddUsernameCell.self, forCellReuseIdentifier: "FaeAddUsernameCell")
        tblUsernames.register(BoardNoResultCell.self, forCellReuseIdentifier: "BoardNoResultCell")
        tblUsernames.indicatorStyle = .white
        tblUsernames.separatorStyle = .none
        view.addSubview(tblUsernames)
        tblUsernames.alpha = 0
    }
    
    // MARK: - Button actions
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionRefresh(_ sender: UIButton) {
        hideTable()
        updateTable()
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasUser ? arrNearby.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hasUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BoardNoResultCell", for: indexPath) as! BoardNoResultCell
            let hint = "Sorry, we couldn't find any matches nearby."
            cell.setValueForCell(hint: hint)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddUsernameCell", for: indexPath) as! FaeAddUsernameCell
        let nearby = arrNearby[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setValueForCell(user: nearby)
        cell.userId = nearby.userId
        cell.getFriendStatus(id: cell.userId)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasUser {
            uiviewNameCard.userId = arrNearby[indexPath.row].userId
            uiviewNameCard.show {}
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return hasUser ? 74 : tableView.frame.size.height
    }
    
    // MARK: - FaeAddUsernameDelegate
    func addFriend(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "add"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func resendRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "resend"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func acceptRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "accept"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func ignoreRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "ignore"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func withdrawRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "withdraw"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    // MARK: - FriendOperationFromContactsDelegate
    func passFriendStatusBack(indexPath: IndexPath) {
        tblUsernames.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - NameCardDelegate
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hideSelf()
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        uiviewNameCard.hideSelf()
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(id)")
        vcChat.strChatId = "\(id)"
        navigationController?.pushViewController(vcChat, animated: true)
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.contactsDelegate = self
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    // MARK: - AddFriendFromNameCardDelegate
    func changeContactsTable(action: Int, userId: Int) {
        print("changeContactsTable")
        uiviewNameCard.hide { }
    }
}
