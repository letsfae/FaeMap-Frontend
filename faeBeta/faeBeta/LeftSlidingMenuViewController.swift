//
//  LeftSlidingMenuViewController.swift
//  faeBeta
//
//  Created by Jacky on 12/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

protocol LeftSlidingMenuDelegate: class {
    func userInvisible(isOn: Bool)
    func jumpToMoodAvatar()
    func jumpToSettings()
    func jumpToFaeUserMainPage()
    func jumpToCollections()
    func jumpToContacts()
    func reloadSelfPosition()
    func switchMapMode()
}

class LeftSlidingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: LeftSlidingMenuDelegate?
    
    var uiviewLeftWindow: UIView!
    var btnBackground: UIButton!
    var imgLeftSlideUp: UIImageView!
    var imgLeftSlideMiddle: UIImageView!
    var imgAvatar: UIImageView!
    var lblNickName: UILabel!
    var tblLeftSlide: UITableView!
    var uiviewBackTop: UIView!
    var uiviewBackBottom: UIView!
    
    // For pan gesture var
    var sizeFrom: CGFloat = 0
    var sizeTo: CGFloat = 0
    var space: CGFloat = 0
    var end: CGFloat = 0
    var percent: Double = 0
    var displayName = ""
    // End of pan gesture var
    
    var activityIndicator: UIActivityIndicatorView!
    
    static var boolMapBoardIsOn = false
    
    enum TableSelctions {
        case none
        case mapBoard
        case goInvisible
        case contacts
        case moodAvatar
        case collections
        case myActivities
        case settings
        case myFaeMainPage
    }
    var tableSelections: TableSelctions = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.loadLeftWindow()
            let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionCommentPinDetailDrag(_:)))
            self.view.addGestureRecognizer(draggingGesture)
            self.loadUserInfo()
            self.loadActivityIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.btnBackground.alpha = 0.7
            self.tblLeftSlide.frame.origin.x = 0
            self.uiviewBackTop.frame.origin.x = 0
            self.uiviewBackBottom.frame.origin.x = 0
        }, completion: nil)
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func loadLeftWindow() {
        btnBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        btnBackground.backgroundColor = UIColor._107105105()
        btnBackground.addTarget(self, action: #selector(actionCloseMenu(_:)), for: .touchUpInside)
        view.addSubview(btnBackground)
        btnBackground.alpha = 0
        
        uiviewBackTop = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight / 2))
        uiviewBackTop.backgroundColor = UIColor._2499090()
        view.addSubview(uiviewBackTop)
        uiviewBackTop.center.x -= 290
        
        uiviewBackBottom = UIView(frame: CGRect(x: 0, y: screenHeight / 2, width: 290, height: screenHeight / 2))
        uiviewBackBottom.backgroundColor = UIColor.white
        view.addSubview(uiviewBackBottom)
        uiviewBackBottom.center.x -= 290
        
        uiviewLeftWindow = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: 241.5))
        uiviewLeftWindow.backgroundColor = UIColor.white
        
        imgLeftSlideUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 238))
        imgLeftSlideUp.image = #imageLiteral(resourceName: "leftWindowbackground")
        uiviewLeftWindow.addSubview(imgLeftSlideUp)
        
        imgAvatar = UIImageView(frame: CGRect(x: 105, y: 40, width: 91, height: 91))
        uiviewLeftWindow.addSubview(imgAvatar)
        imgAvatar.center.x = 145
        imgAvatar.layer.cornerRadius = 45.5
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.borderWidth = 5
        imgAvatar.image = Key.shared.gender == "male" ? #imageLiteral(resourceName: "defaultMen") : #imageLiteral(resourceName: "defaultWomen")
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        imgAvatar.isUserInteractionEnabled = true
        let imgTapGes = UITapGestureRecognizer(target: self, action: #selector(actionJumpToMainPage))
        imgAvatar.addGestureRecognizer(imgTapGes)
        
        lblNickName = UILabel(frame: CGRect(x: 0, y: 139, width: 184, height: 27))
        lblNickName.text = displayName
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblNickName.textColor = UIColor.white
        lblNickName.center.x = 145
        lblNickName.textAlignment = .center
        uiviewLeftWindow.addSubview(lblNickName)
        
        imgLeftSlideMiddle = UIImageView(frame: CGRect(x: 0, y: 152, width: 290, height: 108))
        imgLeftSlideMiddle.image = #imageLiteral(resourceName: "leftMenuCloud")
        uiviewLeftWindow.addSubview(imgLeftSlideMiddle)
        
        tblLeftSlide = UITableView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight))
        tblLeftSlide.delegate = self
        tblLeftSlide.dataSource = self
        tblLeftSlide.register(LeftSlideWindowCell.self, forCellReuseIdentifier: "cellLeftSlideWindow")
        tblLeftSlide.separatorStyle = .none
        tblLeftSlide.tableHeaderView = uiviewLeftWindow
        view.addSubview(tblLeftSlide)
        tblLeftSlide.center.x -= 290
        tblLeftSlide.backgroundColor = UIColor.clear
        tblLeftSlide.delaysContentTouches = false
        tblLeftSlide.showsVerticalScrollIndicator = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblLeftSlide.dequeueReusableCell(withIdentifier: "cellLeftSlideWindow", for: indexPath) as! LeftSlideWindowCell
        // "Log Out" will be replaced by "Setting"
        let array = ["Boards", "Go Invisible", "Contacts", "Collections", "Mood Avatars", "Settings"]
        //  "Activities",
        cell.imgLeft.image = UIImage(named: "leftSlideMenuImage\(indexPath.row)")
        cell.lblMiddle.text = array[indexPath.row]
        cell.switchRight.tag = indexPath.row
        if indexPath.row < 2 {
            cell.switchRight.isHidden = false
        } else {
            cell.switchRight.isHidden = true
        }
        if indexPath.row == 0 {
            cell.switchRight.addTarget(self, action: #selector(self.mapBoardSwitch(_:)), for: .valueChanged)
            cell.switchRight.setOn(LeftSlidingMenuViewController.boolMapBoardIsOn, animated: false)
        } else if indexPath.row == 1 {
            cell.switchRight.setOn(userStatus == 5, animated: false)
            cell.switchRight.addTarget(self, action: #selector(self.invisibleSwitch(_:)), for: .valueChanged)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // 7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tblLeftSlide.cellForRow(at: indexPath) as! LeftSlideWindowCell
        // Go Invisible
        if indexPath.row == 0 {
            tableSelections = .mapBoard
            cell.switchRight.setOn(!cell.switchRight.isOn, animated: true)
            actionCloseMenu(btnBackground)
        } else if indexPath.row == 1 {
            tableSelections = .goInvisible
            cell.switchRight.setOn(!cell.switchRight.isOn, animated: true)
            invisibleSwitch(cell.switchRight)
        } else if indexPath.row == 2 {
            tableSelections = .contacts
            actionCloseMenu(btnBackground)
        } else if indexPath.row == 3 {
            tableSelections = .collections
            actionCloseMenu(btnBackground)
        } else if indexPath.row == 4 {
            tableSelections = .moodAvatar
            actionCloseMenu(btnBackground)
        } else if indexPath.row == 5 {
            tableSelections = .settings
            actionCloseMenu(btnBackground)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81 // 67
    }
    
    func panActionCommentPinDetailDrag(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            let location = pan.location(in: view)
            space = location.x - 290
            end = location.x
            if tblLeftSlide.frame.origin.x == 0 {
                sizeFrom = 0
                sizeTo = -290
            }
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: view)
            let location = pan.location(in: view)
            resumeTime = abs(Double(CGFloat(end - location.x) / velocity.x))
            if resumeTime > 0.3 {
                resumeTime = 0.3
            }
            if percent > 0.1 {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tblLeftSlide.frame.origin.x = self.sizeTo
                    self.uiviewBackTop.frame.origin.x = self.sizeTo
                    self.uiviewBackBottom.frame.origin.x = self.sizeTo
                    self.btnBackground.alpha = 0
                }, completion: { (_: Bool) in
                    self.dismiss(animated: false, completion: {
                        self.delegate?.reloadSelfPosition()
                    })
                })
            } else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tblLeftSlide.frame.origin.x = self.sizeFrom
                    self.uiviewBackTop.frame.origin.x = self.sizeFrom
                    self.uiviewBackBottom.frame.origin.x = self.sizeFrom
                    self.btnBackground.alpha = 0.7
                })
            }
        } else {
            let location = pan.location(in: view)
            if location.x <= end {
                tblLeftSlide.frame.origin.x = location.x - (290 + space)
                uiviewBackTop.frame.origin.x = location.x - (290 + space)
                uiviewBackBottom.frame.origin.x = location.x - (290 + space)
                btnBackground.alpha = (location.x - space) / 290 * 0.7
                percent = Double((end - location.x) / 290)
            }
            
        }
    }
    
    func loadUserInfo() {
        General.shared.avatar(userid: Key.shared.user_id, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard { (status: Int, message: Any?) in
                guard status / 100 == 2 else { return }
                let nickNameInfo = JSON(message!)
                DispatchQueue.main.async {
                    self.lblNickName.text = nickNameInfo["nick_name"].stringValue
                }
            }
        }
    }
    
    func actionCloseMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.btnBackground.alpha = 0
            self.tblLeftSlide.center.x -= 290
            self.uiviewBackTop.center.x -= 290
            self.uiviewBackBottom.center.x -= 290
        }) { _ in
            self.dismiss(animated: false, completion: {
                self.delegate?.reloadSelfPosition()
                switch self.tableSelections {
                case .mapBoard:
                    self.tableSelections = .none
                    self.delegate?.switchMapMode()
                    break
                case .goInvisible:
                    if userStatus == 5 {
                        self.tableSelections = .none
                        self.delegate?.userInvisible(isOn: true)
                    }
                    break
                case .contacts:
                    self.tableSelections = .none
                    self.delegate?.jumpToContacts()
                    break
                case .moodAvatar:
                    self.tableSelections = .none
                    self.delegate?.jumpToMoodAvatar()
                    break
                case .collections:
                    self.tableSelections = .none
                    self.delegate?.jumpToCollections()
                    break
                case .myActivities:
                    self.tableSelections = .none
                    break
                case .settings:
                    self.tableSelections = .none
                    self.delegate?.jumpToSettings()
                    break
                case .myFaeMainPage:
                    self.tableSelections = .none
                    self.delegate?.jumpToFaeUserMainPage()
                    break
                default:
                    break
                }
            })
        }
    }
    
    func actionJumpToMainPage() {
//        tableSelections = .myFaeMainPage
//        actionCloseMenu(btnBackground)
        addProfileAvatar()
    }
    
    func mapBoardSwitch(_ sender: UISwitch) {
        tableSelections = .mapBoard
        actionCloseMenu(btnBackground)
    }
    func invisibleSwitch(_ sender: UISwitch) {
        let switchToInvisible = FaeUser()
        if sender.isOn {
            print("sender.on")
            switchToInvisible.whereKey("status", value: "5")
            switchToInvisible.setSelfStatus({ status, _ in
                if status / 100 == 2 {
                    userStatus = 5
                    self.tableSelections = .goInvisible
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
                    print("Successfully switch to invisible")
                    self.actionCloseMenu(self.btnBackground)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
                } else {
                    print("Fail to switch to invisible")
                }
            })
        } else {
            print("sender.off")
            switchToInvisible.whereKey("status", value: "1")
            switchToInvisible.setSelfStatus({ status, _ in
                if status / 100 == 2 {
                    userStatus = 1
                    self.delegate?.userInvisible(isOn: false)
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
                    print("Successfully switch to online")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
                } else {
                    print("Fail to switch to online")
                }
            })
        }
    }
}
