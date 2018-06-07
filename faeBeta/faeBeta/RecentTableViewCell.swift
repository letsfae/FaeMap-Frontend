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
    
    // MARK: - Properties
    private var imgAvatar: UIImageView!
    private var lblCounter: UILabel!
    private var lblName: UILabel!
    private var lblLastMessage: UILabel!
    var lblDate: UILabel!
    var uiviewMain: UIView!
    var btnDelete: UIButton!
    private var distanceToRight: NSLayoutConstraint!
    private var distanceToLeft: NSLayoutConstraint!
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var pointPanStart: CGPoint!
    private var floatStartingRightLayoutConstraintConstant: CGFloat = 0.0
    private var floatButtonTotalWidth: CGFloat = 69.0
    private let floatKBounceValue: CGFloat = 20.0
    
    weak var delegate: SwipeableCellDelegate!
    
    // MARK: - init
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
        lblLastMessage.numberOfLines = 0
        
        lblLastMessage.font = UIFont(name: "AvenirNext-Medium", size: 15)
        uiviewMain.addSubview(lblLastMessage)
        
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
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraintContstantsToZero(false, notifyDelegateDidClose: false)
        lblLastMessage.removeConstraints(lblLastMessage.constraints)
    }
    
    // MARK: - Button & pan gesture actions
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        self.delegate.deleteButtonTapped(self)
    }
    
    @objc private func panThisCell(_ recognizer:UIPanGestureRecognizer){
        switch (recognizer.state) {
        case .began:
            pointPanStart = recognizer.translation(in: uiviewMain)
            floatStartingRightLayoutConstraintConstant = distanceToRight.constant
            uiviewMain.backgroundColor = .white
            btnDelete.isHidden = false
        case .changed:
            let currentPoint = recognizer.translation(in: uiviewMain)
            let deltaX = currentPoint.x - pointPanStart.x
            var panningLeft = false
            if currentPoint.x < pointPanStart.x {  //1
                panningLeft = true
            }
            
            if floatStartingRightLayoutConstraintConstant == 0 { //2
                //The cell was closed and is now opening
                if !panningLeft {
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
        case .cancelled:
            if floatStartingRightLayoutConstraintConstant == 0 {
                //Cell was closed - reset everything to 0
                resetConstraintContstantsToZero(true, notifyDelegateDidClose:true)
            } else {
                //Cell was open - reset to the open state
                setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
            }
        default: break
        }
    }
    
    // MARK: Helper methods for pan gesture
    private func resetConstraintContstantsToZero(_ animated: Bool, notifyDelegateDidClose notifyDelegate:Bool) {
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
    
    // MARK: - Bind data to the cell
    func bindData(_ recent: RealmRecentMessage) {
        guard let latest = recent.latest_message else { return }
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
        guard let sender = latest.sender else { return }
        var latestContent = sender.id == "\(Key.shared.user_id)" ? "You" : sender.display_name
        latestContent += " shared a "
        switch latest.type {
        case "text":
            latestContent = latest.text
        case "[Location]":
            latestContent += "Location."
        case "[Place]":
            latestContent += "Place."
        case "[Collection]":
            latestContent += "Collection."
        default:
            latestContent = latest.type
        }
        lblLastMessage.text = latestContent
        let height = latestContent.boundingRect(with: CGSize(width: screenWidth - 89 - 56, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!], context: nil).size.height
        let onelineHeight = "oneLine".boundingRect(with: CGSize(width: screenWidth - 89 - 56, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!], context: nil).size.height
        if height > onelineHeight {
            uiviewMain.addConstraintsWithFormat("H:|-89-[v0]-56-|", options: [], views: lblLastMessage)
            uiviewMain.addConstraintsWithFormat("V:|-29-[v0(41)]", options: [], views: lblLastMessage)
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
        
        let date = RealmChat.dateConverter(str: latest.created_at)
        let seconds = Date().timeIntervalSince(date)
        lblDate.text = TimeElipsed(seconds, lastMessageTime: date)
        lblDate.textColor = lblCounter.isHidden ? UIColor._138138138() : UIColor._2499090()
        lblDate.font = lblCounter.isHidden ? UIFont(name: "AvenirNext-Regular", size: 13) : UIFont(name: "AvenirNext-DemiBold", size: 13)
    }

    // Helper
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
    
    // MARK: - Close the cell
    func closeCell() {
        resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
    }
 
}
