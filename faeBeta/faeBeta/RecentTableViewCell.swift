//
//  RecentTableViewCell.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

protocol SwipeableCellDelegate: class {
    func cellwillOpen(_ cell:UITableViewCell)
    func cellDidOpen(_ cell:UITableViewCell)
    func cellDidClose(_ cell:UITableViewCell)
    func deleteButtonTapped(_ cell:UITableViewCell)
}

class RecentTableViewCell: UITableViewCell {
    
    // MARK: - properties
    var imgAvatar: UIImageView!
    var lblCounter: UILabel!
    var lblName: UILabel!
    var lblLastMessage: UILabel!
    var lblDate: UILabel!
    var uiviewMain: UIView!
    var btnDelete: UIButton!
    var distanceToRight: NSLayoutConstraint!
    var distanceToLeft: NSLayoutConstraint!
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var pointPanStart: CGPoint!
    private var floatStartingRightLayoutConstraintConstant: CGFloat = 0.0
    private var floatButtonTotalWidth: CGFloat = 69.0
    private let floatKBounceValue: CGFloat = 20.0
    
    weak var delegate: SwipeableCellDelegate!
    
    // MARK: init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        btnDelete = UIButton(frame: CGRect(x: screenWidth - 69, y: 0, width: 69, height: 74))
        btnDelete.setImage(UIImage(named: "deleteButton.png"), for: .normal)
        addSubview(btnDelete)
        btnDelete.isHidden = true
        btnDelete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        uiviewMain = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 74.5))
        uiviewMain.backgroundColor = .white
        uiviewMain.translatesAutoresizingMaskIntoConstraints = false
        
        imgAvatar = UIImageView()
        imgAvatar.layer.cornerRadius = 30
        imgAvatar.layer.masksToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        uiviewMain.addSubview(imgAvatar)
        uiviewMain.addConstraintsWithFormat("H:|-15-[v0(60)]", options: [], views: imgAvatar)
        uiviewMain.addConstraintsWithFormat("V:|-7.5-[v0(60)]", options: [], views: imgAvatar)
        
        lblCounter = UILabel()
        lblCounter.text = ""
        lblCounter.textColor = .white
        lblCounter.textAlignment = .center
        lblCounter.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        lblCounter.layer.cornerRadius = 11
        lblCounter.layer.masksToBounds = true
        lblCounter.backgroundColor = UIColor._2499090()
        lblCounter.isHidden = true
        uiviewMain.addSubview(lblCounter)
        
        lblName = UILabel()
        lblName.text = ""
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewMain.addSubview(lblName)
        uiviewMain.addConstraintsWithFormat("H:|-89-[v0]-120-|", options: [], views: lblName)
        uiviewMain.addConstraintsWithFormat("V:|-7-[v0(22)]", options: [], views: lblName)
        
        lblLastMessage = UILabel()
        lblLastMessage.text = ""
        lblLastMessage.textAlignment = .left
        lblLastMessage.textColor = UIColor._146146146()
        //lblLastMessage.lineBreakMode = .byWordWrapping
        lblLastMessage.numberOfLines = 0
        
        lblLastMessage.font = UIFont(name: "AvenirNext-Medium", size: 15)
        uiviewMain.addSubview(lblLastMessage)
        //uiviewMain.addConstraintsWithFormat("H:|-89-[v0]-56-|", options: [], views: lblLastMessage)
        //uiviewMain.addConstraintsWithFormat("V:|-29-[v0(22)]", options: [], views: lblLastMessage)
        
        lblDate = UILabel()
        lblDate.text = ""
        lblDate.textAlignment = .right
        uiviewMain.addSubview(lblDate)
        uiviewMain.addConstraintsWithFormat("H:[v0(106)]-14-|", options: [], views: lblDate)
        uiviewMain.addConstraintsWithFormat("V:|-4-[v0(18.5)]", options: [], views: lblDate)
        
        addSubview(uiviewMain)
        
        distanceToLeft = NSLayoutConstraint(item: uiviewMain, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        addConstraint(distanceToLeft)
        
        let bottomMargin = NSLayoutConstraint(item: uiviewMain, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        addConstraint(bottomMargin)
        
        distanceToRight = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: uiviewMain, attribute: .trailing, multiplier: 1.0, constant: 0)
        addConstraint(distanceToRight)
        
        let mainviewTop = NSLayoutConstraint(item: uiviewMain, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        addConstraint(mainviewTop)
        
        selectionStyle = .none
        
        panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(RecentTableViewCell.panThisCell))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetConstraintContstantsToZero(false, notifyDelegateDidClose: false)
        lblLastMessage.removeConstraints(lblLastMessage.constraints)
    }
    
    // MARK: bind data to the cell
    func bindData_v2(_ recent: RealmRecent_v2) {
        /*if let myInteger = Int(latest.withUserID) {
            imgAvatar.image = avatarDic[myInteger] == nil ? UIImage(named: "avatarPlaceholder") : avatarDic[myInteger]
        }*/
        let latest = recent.latest_message!
        for user in latest.members {
            if user.id != user.login_user_id || latest.chat_id == user.login_user_id {
                lblName.text = user.display_name
                if let avatarData = user.avatar?.userSmallAvatar {
                    imgAvatar.image = UIImage(data: avatarData as Data)
                } else {
                    imgAvatar.image = UIImage(named: "avatarPlaceholder")
                }
            }
        }
        var latestContent: String = ""
        if latest.sender?.id == "\(Key.shared.user_id)" {
            latestContent = "You"
        } else {
            latestContent = (latest.sender?.display_name)!
        }
        latestContent += " shared a "
        switch latest.type {
        case "text":
            latestContent = latest.text
            break
        case "[Location]":
            latestContent += "Location."
            break
        case "[Place]":
            latestContent += "Place."
            break
        case "[Collection]":
            latestContent += "Collection."
            break
        default:
            latestContent = latest.type
            break
        }
        lblLastMessage.text = latestContent
        let height = latestContent.boundingRect(with: CGSize(width: screenWidth - 89 - 56, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!], context: nil).size.height
        let onelineHeight = "oneLine".boundingRect(with: CGSize(width: screenWidth - 89 - 56, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!], context: nil).size.height
        if height > onelineHeight {
            uiviewMain.addConstraintsWithFormat("H:|-89-[v0]-56-|", options: [], views: lblLastMessage)
            uiviewMain.addConstraintsWithFormat("V:|-29-[v0(41)]", options: [], views: lblLastMessage)
            //lblLastMessage.numberOfLines = 2
        } else {
            uiviewMain.addConstraintsWithFormat("H:|-89-[v0]-56-|", options: [], views: lblLastMessage)
            uiviewMain.addConstraintsWithFormat("V:|-29-[v0(22)]", options: [], views: lblLastMessage)
        }
        
        if recent.unread_count > 0 {
            lblCounter.isHidden = false
            lblCounter.text = latest.unread_count > 99 ? "•••" : "\(recent.unread_count)"
            if lblCounter.text?.count >= 2 {
                uiviewMain.addConstraintsWithFormat("H:|-56-[v0(28)]", options: [], views: lblCounter)
                uiviewMain.addConstraintsWithFormat("V:|-7-[v0(22)]", options: [], views: lblCounter)
            } else {
                uiviewMain.addConstraintsWithFormat("H:|-56-[v0(22)]", options: [], views: lblCounter)
                uiviewMain.addConstraintsWithFormat("V:|-7-[v0(22)]", options: [], views: lblCounter)
            }
        } else {
            lblCounter.isHidden = true
        }
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.calendar = Calendar(identifier: .gregorian)
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        //let date = dateFormatter.date(from: latest.created_at)
        let date = dateFormatter().date(from: latest.created_at)
        let seconds = Date().timeIntervalSince(date!)
        lblDate.text = TimeElipsed(seconds, lastMessageTime: date!)
        lblDate.textColor = lblCounter.isHidden ? UIColor._138138138() : UIColor._2499090()
        lblDate.font = lblCounter.isHidden ? UIFont(name: "AvenirNext-Regular", size: 13) : UIFont(name: "AvenirNext-DemiBold", size: 13)
        
        //        guard let userid = Int(recent.withUserID) else { return }
        //        guard avatarDic[userid] == nil else { return }
        //        General.shared.avatar(userid: userid) { (avatarImage) in
        //            avatarDic[userid] = avatarImage
        //        }
    }

    func bindData(_ recent : RealmRecent) {
        if let myInteger = Int(recent.withUserID) {
            imgAvatar.image = avatarDic[myInteger] == nil ? UIImage(named: "avatarPlaceholder") : avatarDic[myInteger]
        }
        
        lblName.text = recent.withUserNickName
        lblLastMessage.text = recent.message
        
        if recent.unread > 0 {
            lblCounter.isHidden = false
            lblCounter.text = recent.unread > 99 ? "•••" : "\(recent.unread)"
            if lblCounter.text?.count >= 2 {
                uiviewMain.addConstraintsWithFormat("H:|-56-[v0(28)]", options: [], views: lblCounter)
                uiviewMain.addConstraintsWithFormat("V:|-7-[v0(22)]", options: [], views: lblCounter)
            } else {
                uiviewMain.addConstraintsWithFormat("H:|-56-[v0(22)]", options: [], views: lblCounter)
                uiviewMain.addConstraintsWithFormat("V:|-7-[v0(22)]", options: [], views: lblCounter)
            }
        } else {
            lblCounter.isHidden = true
        }
        
        let date = recent.date
        let seconds = Date().timeIntervalSince(date as Date)
        lblDate.text = TimeElipsed(seconds,lastMessageTime:date as Date)
        lblDate.textColor = lblCounter.isHidden ? UIColor._138138138() : UIColor._2499090()
        lblDate.font = lblCounter.isHidden ? UIFont(name: "AvenirNext-Regular", size: 13) : UIFont(name: "AvenirNext-DemiBold", size: 13)
        
//        guard let userid = Int(recent.withUserID) else { return }
//        guard avatarDic[userid] == nil else { return }
//        General.shared.avatar(userid: userid) { (avatarImage) in
//            avatarDic[userid] = avatarImage
//        }
    }

    
    // MARK: helper
    private func TimeElipsed(_ seconds: TimeInterval, lastMessageTime: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        let minFormatter = DateFormatter()
        minFormatter.timeStyle = .short
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let realDateFormatter = DateFormatter()
        realDateFormatter.dateFormat = "MM/dd/yy"
        
        let elipsed : String?
        if seconds < 60 {
            elipsed = "Just Now"
        } else if dayFormatter.string(from: lastMessageTime) == dayFormatter.string(from: Date()) {
            elipsed = minFormatter.string(from: lastMessageTime)
        } else if Int(dayFormatter.string(from: Date()))! - Int(dayFormatter.string(from: lastMessageTime))! == 1 {
            elipsed = "Yesterday"
        } else if Int(dayFormatter.string(from: Date()))! - Int(dayFormatter.string(from: lastMessageTime))! < 7 {
            elipsed = weekdayFormatter.string(from: lastMessageTime)
        } else {
            elipsed = realDateFormatter.string(from: lastMessageTime)
        }
        return elipsed!
    }
    
    //MARK: handle delete button tapped
    @objc func deleteButtonTapped(_ sender: UIButton) {
        self.delegate.deleteButtonTapped(self)
    }
    
    //MARK: handle cell pan
    @objc private func panThisCell(_ recognizer:UIPanGestureRecognizer){
        switch (recognizer.state) {
        case .began:
            isDraggingRecentTableViewCell = true
            pointPanStart = recognizer.translation(in: uiviewMain)
            floatStartingRightLayoutConstraintConstant = distanceToRight.constant
            self.uiviewMain.backgroundColor = .white
            self.btnDelete.isHidden = false
            break
        case .changed:
            let currentPoint = recognizer.translation(in: uiviewMain)
            let deltaX = currentPoint.x - pointPanStart.x
            var panningLeft = false
            if currentPoint.x < pointPanStart.x {  //1
                panningLeft = true
            }
            
            if floatStartingRightLayoutConstraintConstant == 0 { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    let constant = max(-deltaX, 0) //3
                    if constant == 0 { //4
                        resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                    } else { //5
                        distanceToRight.constant = constant
                    }
                } else {
                    delegate.cellwillOpen(self)
                    let constant = min(-deltaX, floatButtonTotalWidth) //6
                    if constant == floatButtonTotalWidth { //7
                        setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:false)
                    } else { //8
                        distanceToRight.constant = constant
                    }
                }
            
            } else {
                let adjustment = floatStartingRightLayoutConstraintConstant - deltaX //1
                if !panningLeft {
                    let constant = max(adjustment, 0) //2
                    if constant == 0 { //3
                        resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                    } else { //4
                        distanceToRight.constant = constant
                    }
                } else {
                    let constant = min(adjustment, self.floatButtonTotalWidth) //5
                    if constant == self.floatButtonTotalWidth { //6
                        setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:false)
                    } else { //7
                        distanceToRight.constant = constant
                    }
                }
            }
            distanceToLeft.constant = -distanceToRight.constant //8
            break
        case .ended:
                // if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                let halfOfButtonOne = btnDelete.frame.width / 2 //2
                if self.distanceToRight.constant >= halfOfButtonOne { //3
                    //Open all the way
                    setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
                } else {
                    //Re-close
                    resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                }
            break
        case .cancelled:
            if floatStartingRightLayoutConstraintConstant == 0 {
                //Cell was closed - reset everything to 0
                resetConstraintContstantsToZero(true, notifyDelegateDidClose:true)
            } else {
                //Cell was open - reset to the open state
                setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
            }
            break
        default:
            break
        }
    }
    
    private func resetConstraintContstantsToZero(_ animated: Bool, notifyDelegateDidClose notifyDelegate:Bool) {
        /*if (notifyDelegate) {
            delegate.cellDidClose(self)
        }*/
        
        if floatStartingRightLayoutConstraintConstant == 0 && distanceToRight.constant == 0 {
            //Already all the way closed, no bounce necessary
            return
        }
        
        distanceToRight.constant = -floatKBounceValue;
        distanceToLeft.constant = floatKBounceValue;
        
        //UIView.animate(withDuration: 0.3, animations: {
            self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                self.distanceToRight.constant = 0
                self.distanceToLeft.constant = 0
                self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                    self.floatStartingRightLayoutConstraintConstant = self.distanceToRight.constant
                    isDraggingRecentTableViewCell = false
                    if notifyDelegate {
                        self.delegate.cellDidClose(self)
                    }
                })
            })
        //})
    }
    
    private func setConstraintsToShowAllButtons(_ animated: Bool, notifyDelegateDidOpen notifyDelegate:Bool) {
        if (notifyDelegate) {
            delegate.cellDidOpen(self)
        }
        
        if floatStartingRightLayoutConstraintConstant == floatButtonTotalWidth &&
            distanceToRight.constant == floatButtonTotalWidth {
            return
        }
        //2
        distanceToLeft.constant = -floatButtonTotalWidth - floatKBounceValue
        distanceToRight.constant = floatButtonTotalWidth + floatKBounceValue
        
        //UIView.animate(withDuration: 0.3, animations: {
            self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                //3
                self.distanceToLeft.constant = -self.floatButtonTotalWidth
                self.distanceToRight.constant = self.floatButtonTotalWidth
                self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                    //4
                    self.floatStartingRightLayoutConstraintConstant = self.distanceToRight.constant
                })
            })
        //})
    }
    
    private func updateConstraintsIfNeeded(_ animated:Bool, completion: @escaping ( (_ finised:Bool) -> Void)) {
        var duration:Double = 0
        if animated {
            duration = 0.1
        }
        UIView.animate(withDuration: duration, delay: 0, options:.curveEaseOut , animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    func openCell() {
        setConstraintsToShowAllButtons(false, notifyDelegateDidOpen: false)
    }
    
    func closeCell() {
        resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
    }
 
}
