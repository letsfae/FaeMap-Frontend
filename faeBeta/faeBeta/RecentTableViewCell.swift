//
//  RecentTableViewCell.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SwiftyJSON
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
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var lastMessageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var countLabelLength: NSLayoutConstraint!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var distanceToRight: NSLayoutConstraint!
    @IBOutlet private weak var distanceToLeft: NSLayoutConstraint!
    @IBOutlet private weak var mainView: UIView!
    
    private var panRecognizer:UIPanGestureRecognizer!
    private var panStartPoint:CGPoint!
    private var startingRightLayoutConstraintConstant: CGFloat = 0
    private var buttonTotalWidth: CGFloat = 69
    
    private let kBounceValue:CGFloat = 20.0
    
    weak var delegate: SwipeableCellDelegate!
    
    //MARK : - life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(RecentTableViewCell.panThisCell))
        self.panRecognizer.delegate = self;
        self.mainView.addGestureRecognizer(self.panRecognizer)
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.resetConstraintContstantsToZero(false, notifyDelegateDidClose: false)
    }
    
    // MARK: - populate cell
    // set up the cell with a JSON data
    func bindData(_ recent : JSON) {
        self.layoutIfNeeded()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width / 2 // half the cell's height
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.image = avatarDic[recent["with_user_id"].number!] == nil ? UIImage(named: "avatarPlaceholder") : avatarDic[recent["with_user_id"].number!]

        if let name = recent["with_user_name"].string{
            nameLabel.text = name
        }
        if let lastMessage = recent["last_message"].string{
            lastMessageLabel.text = lastMessage
        }
        counterLabel.text = ""
        counterLabel.layer.cornerRadius = 11
        counterLabel.layer.masksToBounds = true
        counterLabel.backgroundColor = UIColor.faeAppRedColor()
        if recent["unread_count"].number != nil && (recent["unread_count"].number)!.int32Value != 0 {
            counterLabel.isHidden = false
            counterLabel.text = recent["unread_count"].number!.int32Value > 99 ? "•••" : "\(recent["unread_count"].number!.int32Value)"
            if(counterLabel.text?.characters.count >= 2){
                countLabelLength.constant = 28
            }else{
                countLabelLength.constant = 22
            }
        }else{
            counterLabel.isHidden = true
        }
        
        if var timeString = recent["last_message_timestamp"].string{
            var index = 0
            for c in timeString.characters{
                if c < "0" || c > "9" {
                    timeString.remove(at: timeString.characters.index(timeString.characters.startIndex, offsetBy: index))
                }else{
                    index += 1
                }
            }
            
            let date = dateFormatter().date(from: timeString)
            let seconds = Date().timeIntervalSince(date!)
            dateLabel.text = TimeElipsed(seconds,lastMessageTime:date!)
            dateLabel.textColor = counterLabel.isHidden ? UIColor.faeAppDescriptionTextGrayColor() : UIColor.faeAppRedColor()
            dateLabel.font = counterLabel.isHidden ? UIFont(name: "AvenirNext-Regular", size: 13) : UIFont(name: "AvenirNext-DemiBold", size: 13)
        }
        
        if recent["with_user_id"].number != nil && (avatarDic[recent["with_user_id"].number!] == nil){
            getImageFromURL(("files/users/" + recent["with_user_id"].number!.stringValue + "/avatar/"), authentication: headerAuthentication(), completion: {(status:Int, image:Any?) in
                if status / 100 == 2 {
                    avatarDic[recent["with_user_id"].number!] = image as? UIImage
                }
            })
        }
    }
    // MARK: - helper
    private func TimeElipsed(_ seconds : TimeInterval, lastMessageTime:Date) -> String {
        let dayFormatter = dateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        let minFormatter = dateFormatter()
        minFormatter.timeStyle = .short
        let weekdayFormatter = dateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let realDateFormatter = dateFormatter()
        realDateFormatter.dateFormat = "MM/dd/yy"
        
        let elipsed : String?
        if seconds < 60 {
            elipsed = "Just Now"
        }else if (dayFormatter.string(from: lastMessageTime) == dayFormatter.string(from: Date())) {
            elipsed = minFormatter.string(from: lastMessageTime)
        }else if (Int(dayFormatter.string(from: Date()))! - Int(dayFormatter.string(from: lastMessageTime))! == 1 ){
            elipsed = "Yesterday"
        }else if (Int(dayFormatter.string(from: Date()))! - Int(dayFormatter.string(from: lastMessageTime))! < 7 ){
            elipsed = weekdayFormatter.string(from: lastMessageTime)
        }else{
            elipsed = realDateFormatter.string(from: lastMessageTime)
        }

        return elipsed!
    }

    
    //MARK: - Delete button related
    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        self.delegate.deleteButtonTapped(self)
    }
    
    //MARK: - Cell control
    @objc private func panThisCell(_ recognizer:UIPanGestureRecognizer){
        switch (recognizer.state) {
        case .began:
            isDraggingRecentTableViewCell = true
            self.panStartPoint = recognizer.translation(in: self.mainView)
            self.startingRightLayoutConstraintConstant = self.distanceToRight.constant;
            break;
        case .changed:
            let currentPoint = recognizer.translation(in: self.mainView)
            let deltaX = currentPoint.x - self.panStartPoint.x;
            var panningLeft = false
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = true;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    let constant = max(-deltaX, 0); //3
                    if (constant == 0) { //4
                        self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                    } else { //5
                        self.distanceToRight.constant = constant;
                    }
                } else {
                    self.delegate.cellwillOpen(self)
                    let constant = min(-deltaX, self.buttonTotalWidth) //6
                    if (constant == self.buttonTotalWidth) { //7
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:false)
                    } else { //8
                        self.distanceToRight.constant = constant;
                    }
                }
            
            }else{
                let adjustment = self.startingRightLayoutConstraintConstant - deltaX; //1
                if (!panningLeft) {
                    let constant = max(adjustment, 0); //2
                    if (constant == 0) { //3
                        self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: false)
                    } else { //4
                        self.distanceToRight.constant = constant;
                    }
                } else {
                    let constant = min(adjustment, self.buttonTotalWidth); //5
                    if (constant == self.buttonTotalWidth) { //6
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:false)
                    } else { //7
                        self.distanceToRight.constant = constant;
                    }
                }
            }
            self.distanceToLeft.constant = -self.distanceToRight.constant; //8
            
            break;
        case .ended:
            
//            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                let halfOfButtonOne = self.deleteButton.frame.width / 2; //2
                if (self.distanceToRight.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
                } else {
                    //Re-close
                    self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                }
            break;
        case .cancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                self.resetConstraintContstantsToZero(true, notifyDelegateDidClose:true)
            } else {
                //Cell was open - reset to the open state
                self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
            }
            break;
        default:
            break;
        }
    }
    
    private func resetConstraintContstantsToZero(_ animated: Bool, notifyDelegateDidClose notifyDelegate:Bool)
    {
        if (notifyDelegate) {
            self.delegate.cellDidClose(self)
        }
        
        if (self.startingRightLayoutConstraintConstant == 0 &&
            self.distanceToRight.constant == 0) {
            //Already all the way closed, no bounce necessary
            return;
        }
        
        self.distanceToRight.constant = -kBounceValue;
        self.distanceToLeft.constant = kBounceValue;
        
        self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
            self.distanceToRight.constant = 0;
            self.distanceToLeft.constant = 0;
            
            self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                self.startingRightLayoutConstraintConstant = self.distanceToRight.constant;
                isDraggingRecentTableViewCell = false

            });
        });
    }
    
    private func setConstraintsToShowAllButtons(_ animated: Bool, notifyDelegateDidOpen notifyDelegate:Bool)
    {
        if (notifyDelegate) {
            self.delegate.cellDidOpen(self)
        }
        
        if (self.startingRightLayoutConstraintConstant == self.buttonTotalWidth &&
            self.distanceToRight.constant == self.buttonTotalWidth) {
            return;
        }
        //2
        self.distanceToLeft.constant = -self.buttonTotalWidth - kBounceValue;
        self.distanceToRight.constant = self.buttonTotalWidth + kBounceValue;
        
        self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
            //3
            self.distanceToLeft.constant = -self.buttonTotalWidth;
            self.distanceToRight.constant = self.buttonTotalWidth;
            
            self.updateConstraintsIfNeeded(animated, completion:{ (finished: Bool) in
                //4
                self.startingRightLayoutConstraintConstant = self.distanceToRight.constant;
            })
        })
    }
    
    private func updateConstraintsIfNeeded(_ animated:Bool, completion: @escaping ( (_ finised:Bool) -> Void))
    {
        var duration:Double = 0;
        if (animated) {
            duration = 0.1
        }
        UIView.animate(withDuration: duration, delay: 0, options:.curveEaseOut , animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    func openCell()
    {
        self.setConstraintsToShowAllButtons(false, notifyDelegateDidOpen:false)
    }
    func closeCell()
    {
        self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
    }
    
}
