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
    func logOutInLeftMenu()
    func jumpToFaeUserMainPage()
    func jumpToCollections()
    func jumpToContacts()
    func reloadSelfPosition()
    func switchMapMode()
}

class LeftSlidingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: LeftSlidingMenuDelegate?
    
    var uiViewLeftWindow: UIView!
    var btnBackground: UIButton!
    var imageLeftSlideWindowUp: UIImageView!
    var imageLeftSlideWindowMiddle: UIImageView!
    var imageAvatar: UIImageView!
    var buttonImageOverlay: UIButton!
    var label: UILabel!
    var tableLeftSlideWindow: UITableView!
    var backgroundColorViewTop: UIView!
    var backgroundColorViewDown: UIView!
    
    // For pan gesture var
    var sizeFrom: CGFloat = 0
    var sizeTo: CGFloat = 0
    var space: CGFloat = 0
    var end: CGFloat = 0
    var percent: Double = 0
    var displayName = ""
    // End of pan gesture var
    
    static var boolMapBoardIsOn = false
    
    enum TableSelctions {
        case none
        case mapBoard
        case goInvisible
        case contacts
        case moodAvatar
        case collections
        case myActivities
        case logOut
        case myFaeMainPage
    }
    var tableSelections: TableSelctions = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLeftWindow()
        loadUserInfo()
        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionCommentPinDetailDrag(_:)))
        view.addGestureRecognizer(draggingGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.btnBackground.alpha = 0.7
            self.tableLeftSlideWindow.frame.origin.x = 0
            self.backgroundColorViewTop.frame.origin.x = 0
            self.backgroundColorViewDown.frame.origin.x = 0
        }, completion: nil)
    }
    
    func loadLeftWindow() {
        btnBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        btnBackground.backgroundColor = UIColor._107105105()
        btnBackground.addTarget(self, action: #selector(actionCloseMenu(_:)), for: .touchUpInside)
        view.addSubview(btnBackground)
        btnBackground.alpha = 0
        
        backgroundColorViewTop = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight / 2))
        backgroundColorViewTop.backgroundColor = UIColor._2499090()
        view.addSubview(backgroundColorViewTop)
        backgroundColorViewTop.center.x -= 290
        
        backgroundColorViewDown = UIView(frame: CGRect(x: 0, y: screenHeight / 2, width: 290, height: screenHeight / 2))
        backgroundColorViewDown.backgroundColor = UIColor.white
        view.addSubview(backgroundColorViewDown)
        backgroundColorViewDown.center.x -= 290
        
        uiViewLeftWindow = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: 241.5))
        uiViewLeftWindow.backgroundColor = UIColor.white
        
        imageLeftSlideWindowUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 238))
        imageLeftSlideWindowUp.image = UIImage(named: "leftWindowbackground")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowUp)
        
        imageAvatar = UIImageView(frame: CGRect(x: 105, y: 40, width: 91, height: 91))
        uiViewLeftWindow.addSubview(imageAvatar)
        imageAvatar.center.x = 145
        imageAvatar.layer.cornerRadius = 45.5 * screenWidthFactor
        imageAvatar.layer.borderColor = UIColor.white.cgColor
        imageAvatar.layer.borderWidth = 5
        if let gender = userUserGender {
            if gender == "male" {
                imageAvatar.image = #imageLiteral(resourceName: "defaultMen")
            } else {
                imageAvatar.image = #imageLiteral(resourceName: "defaultWomen")
            }
        }
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.layer.masksToBounds = true
        buttonImageOverlay = UIButton(frame: CGRect(x: 100, y: 40, width: 91, height: 91))
        uiViewLeftWindow.addSubview(buttonImageOverlay)
        buttonImageOverlay.center.x = 145
        buttonImageOverlay.layer.cornerRadius = 45.5 * screenWidthFactor
        buttonImageOverlay.addTarget(self, action: #selector(actionJumpToMainPage(_:)), for: .touchUpInside)
        
        label = UILabel(frame: CGRect(x: 0, y: 139, width: 184, height: 27))
        label.text = displayName
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = UIColor.white
        label.center.x = 145
        label.textAlignment = .center
        uiViewLeftWindow.addSubview(label)
        
        imageLeftSlideWindowMiddle = UIImageView(frame: CGRect(x: 0, y: 152, width: 290, height: 108))
        imageLeftSlideWindowMiddle.image = #imageLiteral(resourceName: "leftMenuCloud")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowMiddle)
        
        tableLeftSlideWindow = UITableView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight))
        tableLeftSlideWindow.delegate = self
        tableLeftSlideWindow.dataSource = self
        tableLeftSlideWindow.register(LeftSlideWindowCell.self, forCellReuseIdentifier: "cellLeftSlideWindow")
        tableLeftSlideWindow.separatorStyle = .none
        tableLeftSlideWindow.tableHeaderView = uiViewLeftWindow
        view.addSubview(tableLeftSlideWindow)
        tableLeftSlideWindow.center.x -= 290
        tableLeftSlideWindow.backgroundColor = UIColor.clear
        tableLeftSlideWindow.delaysContentTouches = false
        tableLeftSlideWindow.showsVerticalScrollIndicator = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableLeftSlideWindow.dequeueReusableCell(withIdentifier: "cellLeftSlideWindow", for: indexPath) as! LeftSlideWindowCell
        // "Log Out" will be replaced by "Setting"
        let array = ["Board Mode", "Go Invisible", "Contacts", "Collections", "Mood Avatar", "Log Out"]
        let idx = indexPath.row
        cell.imgLeft.image = UIImage(named: "leftSlideMenuImage\(idx)")
        cell.lblMiddle.text = array[idx]
        cell.switchRight.tag = idx
        if idx == 0 || idx == 2 || idx == 5 {
            cell.uiviewRedDot.isHidden = false
        }
        if idx < 2 {
            cell.switchRight.isHidden = false
        } else {
            cell.switchRight.isHidden = true
        }
        if idx == 0 {
            cell.switchRight.addTarget(self, action: #selector(self.mapBoardSwitch(_:)), for: .valueChanged)
            cell.switchRight.setOn(LeftSlidingMenuViewController.boolMapBoardIsOn, animated: false)
        } else if idx == 1 {
            cell.switchRight.setOn(userStatus == 5, animated: false)
            cell.switchRight.addTarget(self, action: #selector(self.invisibleSwitch(_:)), for: .valueChanged)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableLeftSlideWindow.cellForRow(at: indexPath) as! LeftSlideWindowCell
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
            let logOut = FaeUser()
            logOut.logOut { (status: Int?, _: Any?) in
                if status! / 100 == 2 {
                    print("[LeftMenu-LogOut] Success")
                    self.tableSelections = .logOut
                    self.actionCloseMenu(self.btnBackground)
                } else {
                    print("[LeftMenu-LogOut] Failure")
                    self.tableSelections = .logOut
                    self.actionCloseMenu(self.btnBackground)
                }
            }
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
            if tableLeftSlideWindow.frame.origin.x == 0 {
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
                    self.tableLeftSlideWindow.frame.origin.x = self.sizeTo
                    self.backgroundColorViewTop.frame.origin.x = self.sizeTo
                    self.backgroundColorViewDown.frame.origin.x = self.sizeTo
                    self.btnBackground.alpha = 0
                }, completion: { (_: Bool) in
                    self.dismiss(animated: false, completion: {
                        self.delegate?.reloadSelfPosition()
                    })
                })
            } else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tableLeftSlideWindow.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewTop.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewDown.frame.origin.x = self.sizeFrom
                    self.btnBackground.alpha = 1
                })
            }
        } else {
            let location = pan.location(in: view)
            if location.x <= end {
                tableLeftSlideWindow.frame.origin.x = location.x - (290 + space)
                backgroundColorViewTop.frame.origin.x = location.x - (290 + space)
                backgroundColorViewDown.frame.origin.x = location.x - (290 + space)
                btnBackground.alpha = (location.x - space) / 290
                percent = Double((end - location.x) / 290)
            }
            
        }
    }
    
    func loadUserInfo() {
        General.shared.avatar(userid: Key.shared.user_id, completion: { (avatarImage) in
            self.imageAvatar.image = avatarImage
        })
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard { (status: Int, message: Any?) in
                guard status / 100 == 2 else { return }
                let nickNameInfo = JSON(message!)
                DispatchQueue.main.async {
                    self.label.text = nickNameInfo["nick_name"].stringValue
                }
            }
        }
    }
    
    func actionCloseMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.btnBackground.alpha = 0
            self.tableLeftSlideWindow.center.x -= 290
            self.backgroundColorViewTop.center.x -= 290
            self.backgroundColorViewDown.center.x -= 290
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
                case .logOut:
                    self.tableSelections = .none
                    self.delegate?.logOutInLeftMenu()
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
    
    func actionJumpToMainPage(_ sender: UIButton) {
        tableSelections = .myFaeMainPage
        actionCloseMenu(btnBackground)
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "invisibleMode"), object: nil)
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
                } else {
                    print("Fail to switch to online")
                }
            })
        }
    }
}
