//
//  LeftSlidingMenuViewController.swift
//  faeBeta
//
//  Created by Jacky on 12/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import RealmSwift

protocol LeftSlidingMenuDelegate: class {
    func userInvisible(isOn: Bool)
    func jumpToMoodAvatar()
    func logOutInLeftMenu()
    func jumpToFaeUserMainPage()
}

class LeftSlidingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: LeftSlidingMenuDelegate?
    
    var uiViewLeftWindow: UIView!
    var buttonBackground: UIButton!
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
    
    enum TableSelctions {
        case none
        case mapBoard
        case goInvisible
        case relations
        case moodAvatar
        case pins
        case myActivities
        case logOut
        case myFaeMainPage
    }
    var tableSelections: TableSelctions = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLeftWindow()
        readRealmData()
        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionCommentPinDetailDrag(_:)))
        self.view.addGestureRecognizer(draggingGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonBackground.alpha = 1
            self.tableLeftSlideWindow.center.x += 290
            self.backgroundColorViewTop.center.x += 290
            self.backgroundColorViewDown.center.x += 290
        }, completion: nil)
    }
    
    func loadLeftWindow() {
        buttonBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        buttonBackground.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        buttonBackground.addTarget(self, action: #selector(self.actionCloseMenu(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBackground)
        buttonBackground.alpha = 0
        
        backgroundColorViewTop = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight/2))
        backgroundColorViewTop.backgroundColor = UIColor.faeAppRedColor()
        self.view.addSubview(backgroundColorViewTop)
        self.backgroundColorViewTop.center.x -= 290
        
        backgroundColorViewDown = UIView(frame: CGRect(x: 0, y: screenHeight/2, width: 290, height: screenHeight/2))
        backgroundColorViewDown.backgroundColor = UIColor.white
        self.view.addSubview(backgroundColorViewDown)
        self.backgroundColorViewDown.center.x -= 290
        
        uiViewLeftWindow = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: 241.5))
        uiViewLeftWindow.backgroundColor = UIColor.white
        
        imageLeftSlideWindowUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 238))
        imageLeftSlideWindowUp.image = UIImage(named: "leftWindowbackground")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowUp)
        
        imageAvatar = UIImageView(frame: CGRect(x: 105, y: 49, width: 81, height: 81))
        uiViewLeftWindow.addSubview(imageAvatar)
        imageAvatar.center.x = 145
        imageAvatar.layer.cornerRadius = 40.5*screenWidthFactor
        imageAvatar.layer.borderColor = UIColor.white.cgColor
        imageAvatar.layer.borderWidth = 5
        if let gender = userUserGender {
            if gender == "male" {
                imageAvatar.image = #imageLiteral(resourceName: "defaultMen")
            }
            else {
                imageAvatar.image = #imageLiteral(resourceName: "defaultWomen")
            }
        }
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.layer.masksToBounds = true
        buttonImageOverlay = UIButton(frame: CGRect(x: 100, y: 44, width: 91, height: 91))
        uiViewLeftWindow.addSubview(buttonImageOverlay)
        buttonImageOverlay.center.x = 145
        buttonImageOverlay.layer.cornerRadius = 45.5*screenWidthFactor
        buttonImageOverlay.addTarget(self, action: #selector(self.actionJumpToMainPage(_:)), for: .touchUpInside)
        
        label = UILabel(frame: CGRect(x: 0, y: 142, width: 290, height: 27))
        label.text = displayName
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = UIColor.white
        label.center.x = 145
        label.textAlignment = .center
        uiViewLeftWindow.addSubview(label)
        
        imageLeftSlideWindowMiddle = UIImageView(frame: CGRect(x: 0, y: 138, width: 290, height: 120))
        imageLeftSlideWindowMiddle.image = #imageLiteral(resourceName: "leftWindowCloud")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowMiddle)
        
        tableLeftSlideWindow = UITableView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight))
        tableLeftSlideWindow.delegate = self
        tableLeftSlideWindow.dataSource = self
        tableLeftSlideWindow.register(LeftSlideWindowCell.self, forCellReuseIdentifier: "cellLeftSlideWindow")
        tableLeftSlideWindow.separatorStyle = .none
        tableLeftSlideWindow.tableHeaderView = uiViewLeftWindow
        self.view.addSubview(tableLeftSlideWindow)
        tableLeftSlideWindow.center.x -= 290
        tableLeftSlideWindow.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableLeftSlideWindow.dequeueReusableCell(withIdentifier: "cellLeftSlideWindow", for: indexPath) as! LeftSlideWindowCell
        // "Log Out" will be replaced by "Setting"
        let array = ["Map Boards", "Go Invisible", "Relations", "Mood Avatar", "Pins", "My Activities", "Log Out"]
        cell.imageLeft.image = UIImage(named: "leftSlideWindowImage\(indexPath.row)")
        cell.labelMiddle.text = array[indexPath.row]
        if indexPath.row < 2 {
            cell.switchRight.isHidden = false
            cell.switchRight.tag = indexPath.row
            if indexPath.row == 1 {
                if userStatus == 5 {
                    cell.switchRight.isOn = true
                }
            }
            cell.switchRight.addTarget(self, action: #selector(self.switchToInvisibleOrOnline(_:)), for: .valueChanged)
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableLeftSlideWindow.cellForRow(at: indexPath) as! LeftSlideWindowCell
        // Go Invisible
        if indexPath.row == 1 {
            cell.switchRight.setOn(!cell.switchRight.isOn, animated: true)
            self.switchToInvisibleOrOnline(cell.switchRight)
        }
        // Map Board
        else if indexPath.row == 0 {
            cell.switchRight.setOn(!cell.switchRight.isOn, animated: true)
        }
        // Mood Avatar
        else if indexPath.row == 3 {
            self.tableSelections = .moodAvatar
            self.actionCloseMenu(self.buttonBackground)
        }
        // Setting, currently is logging out
        else if indexPath.row == 6 {
            let logOut = FaeUser()
            logOut.logOut {(status: Int?, message: Any?) in
                if status! / 100 == 2 {
                    print("[LeftMenu-LogOut] Success")
                    self.tableSelections = .logOut
                    self.actionCloseMenu(self.buttonBackground)
                }
                else{
                    print("[LeftMenu-LogOut] Failure")
                    self.tableSelections = .logOut
                    self.actionCloseMenu(self.buttonBackground)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
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
                    self.buttonBackground.alpha = 0
                }, completion: {(done: Bool) in
                    self.dismiss(animated: false, completion: nil)
                })
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tableLeftSlideWindow.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewTop.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewDown.frame.origin.x = self.sizeFrom
                    self.buttonBackground.alpha = 1
                })
            }
        } else {
            let location = pan.location(in: view)
            if location.x <= end {
                self.tableLeftSlideWindow.frame.origin.x = location.x - (290 + space)
                self.backgroundColorViewTop.frame.origin.x = location.x - (290 + space)
                self.backgroundColorViewDown.frame.origin.x = location.x - (290 + space)
                self.buttonBackground.alpha = (location.x - space) / 290
                percent = Double((end - location.x) / 290)
            }
            
        }
    }
    
    func readRealmData() {
        let realm = try! Realm()
        let selfInfoRealm = realm.objects(SelfInformation.self).filter("currentUserID == \(user_id.stringValue) AND avatar != nil")
        if selfInfoRealm.count >= 1 {
            if let selfAvatar = selfInfoRealm.first {
                let picture = UIImage.sd_image(with: selfAvatar.avatar as Data!)
                imageAvatar.image = picture
            }
        }
        else {
            if user_id != nil {
                let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
                imageAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let selfInfoRealm = SelfInformation()
                        selfInfoRealm.currentUserID = Int(user_id)
                        selfInfoRealm.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(selfInfoRealm)
                        }
                    }
                })
            }
        }
    }
    
    func switchToInvisibleOrOnline(_ sender: UISwitch) {
        let switchToInvisible = FaeUser()
        if (sender.isOn == true){
            print("sender.on")
            switchToInvisible.whereKey("status", value: "5")
            switchToInvisible.setSelfStatus({ (status, message) in
                if status / 100 == 2 {
                    userStatus = 5
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
                    print("Successfully switch to invisible")
                    self.tableSelections = .goInvisible
                    self.actionCloseMenu(self.buttonBackground)
                }
                else {
                    print("Fail to switch to invisible")
                }
            })
        }
        else{
            print("sender.off")
            switchToInvisible.whereKey("status", value: "1")
            switchToInvisible.setSelfStatus({ (status, message) in
                if status / 100 == 2 {
                    userStatus = 1
                    self.delegate?.userInvisible(isOn: false)
                    let storageForUserStatus = UserDefaults.standard
                    storageForUserStatus.set(userStatus, forKey: "userStatus")
                    print("Successfully switch to online")
                }
                else {
                    print("Fail to switch to online")
                }
            })
        }
    }
    
    func actionCloseMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonBackground.alpha = 0
            self.tableLeftSlideWindow.center.x -= 290
            self.backgroundColorViewTop.center.x -= 290
            self.backgroundColorViewDown.center.x -= 290
        }) { (done: Bool) in
            self.dismiss(animated: false, completion: {
                switch self.tableSelections {
                case .mapBoard:
                    self.tableSelections = .none
                    break
                case .goInvisible:
                    if userStatus == 5 {
                        self.tableSelections = .none
                        self.delegate?.userInvisible(isOn: true)
                    }
                    break
                case .relations:
                    self.tableSelections = .none
                    break
                case .moodAvatar:
                    self.tableSelections = .none
                    self.delegate?.jumpToMoodAvatar()
                    break
                case .pins:
                    self.tableSelections = .none
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
        self.tableSelections = .myFaeMainPage
        self.actionCloseMenu(self.buttonBackground)
    }
}
