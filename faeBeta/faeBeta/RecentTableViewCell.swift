//
//  RecentTableViewCell.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SwipeableCellDelegate {
    func cellwillOpen(cell:UITableViewCell)
    func cellDidOpen(cell:UITableViewCell)
    func cellDidClose(cell:UITableViewCell)
    func deleteButtonTapped(cell:UITableViewCell)
}

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var countLabelLength: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var distanceToRight: NSLayoutConstraint!
    @IBOutlet weak var distanceToLeft: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    var panRecognizer:UIPanGestureRecognizer!
    var panStartPoint:CGPoint!
    var startingRightLayoutConstraintConstant: CGFloat = 0
    var buttonTotalWidth: CGFloat = 69
    
    let kBounceValue:CGFloat = 20.0
    
    var delegate: SwipeableCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(RecentTableViewCell.panThisCell))
        self.panRecognizer.delegate = self;
        self.mainView.addGestureRecognizer(self.panRecognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // MARK: populate cell 
    func bindData(recent : JSON) {
        self.layoutIfNeeded()
        self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.bounds) / 2 // half the cell's height
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.contentMode = .ScaleAspectFill
        self.avatarImageView.image = avatarDic[recent["with_user_id"].number!] == nil ? UIImage(named: "avatarPlaceholder") : avatarDic[recent["with_user_id"].number!]

        if let name = recent["with_user_name"].string{
            nameLabel.text = name
        }
        lastMessageLabel.text = recent["last_message"].string
        counterLabel.text = ""
        counterLabel.layer.cornerRadius = 11
        counterLabel.layer.masksToBounds = true
        counterLabel.backgroundColor = UIColor.faeAppRedColor()
        if (recent["unread_count"].number)!.intValue != 0 {
            counterLabel.hidden = false
            counterLabel.text = "\(recent["unread_count"].number!.intValue)"
            if(counterLabel.text?.characters.count == 2){
                countLabelLength.constant = 25
            }else{
                countLabelLength.constant = 22
            }
        }else{
            counterLabel.hidden = true
        }
        var timeString = recent["last_message_timestamp"].string
        var index = 0
        for c in (timeString?.characters)!{
            if c < "0" || c > "9" {
                timeString?.removeAtIndex((timeString?.characters.startIndex.advancedBy(index))!)
            }else{
                index += 1
            }
        }
        
        let date = dateFormatter().dateFromString(timeString!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLabel.text = TimeElipsed(seconds,lastMessageTime:date!)
        dateLabel.textColor = counterLabel.hidden ? UIColor.faeAppDescriptionTextGrayColor() : UIColor.faeAppRedColor()
        
        if(avatarDic[recent["with_user_id"].number!] == nil){
            getImageFromURL(("files/users/" + recent["with_user_id"].number!.stringValue + "/avatar/"), authentication: headerAuthentication(), completion: {(status:Int, image:AnyObject?) in
                if status / 100 == 2 {
                    avatarDic[recent["with_user_id"].number!] = image as? UIImage
                }
            })
        }
        
    }
    // MARK: helper
    func TimeElipsed(seconds : NSTimeInterval, lastMessageTime:NSDate) -> String {
        let dayFormatter = dateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        let minFormatter = dateFormatter()
        minFormatter.timeStyle = .ShortStyle
        let weekdayFormatter = dateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let realDateFormatter = dateFormatter()
        realDateFormatter.dateFormat = "MM/dd/yy"
        
        let elipsed : String?
        if seconds < 60 {
            elipsed = "Just Now"
        }else if (dayFormatter.stringFromDate(lastMessageTime) == dayFormatter.stringFromDate(NSDate())) {
            elipsed = minFormatter.stringFromDate(lastMessageTime)
        }else if (Int(dayFormatter.stringFromDate(NSDate()))! - Int(dayFormatter.stringFromDate(lastMessageTime))! == 1 ){
            elipsed = "Yesterday"
        }else if (Int(dayFormatter.stringFromDate(NSDate()))! - Int(dayFormatter.stringFromDate(lastMessageTime))! < 7 ){
            elipsed = weekdayFormatter.stringFromDate(lastMessageTime)
        }else{
            elipsed = realDateFormatter.stringFromDate(lastMessageTime)
        }

        return elipsed!
    }

    
    //MARK: - delete button related
    @IBAction func deleteButtonTapped(sender: UIButton) {
        self.delegate.deleteButtonTapped(self)
    }
    
    func panThisCell(recognizer:UIPanGestureRecognizer){
        switch (recognizer.state) {
        case .Began:
            isDraggingRecentTableViewCell = true
            self.panStartPoint = recognizer.translationInView(self.mainView)
            self.startingRightLayoutConstraintConstant = self.distanceToRight.constant;
            break;
        case .Changed:
            let currentPoint = recognizer.translationInView(self.mainView)
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
        case .Ended:
            
//            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                let halfOfButtonOne = CGRectGetWidth(self.deleteButton.frame) / 2; //2
                if (self.distanceToRight.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen:true)
                } else {
                    //Re-close
                    self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
                }
            break;
        case .Cancelled:
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
    
    func resetConstraintContstantsToZero(animated: Bool, notifyDelegateDidClose notifyDelegate:Bool)
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
    
    func setConstraintsToShowAllButtons(animated: Bool, notifyDelegateDidOpen notifyDelegate:Bool)
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
    
    func updateConstraintsIfNeeded(animated:Bool, completion: ( (finised:Bool) -> Void))
    {
        var duration:Double = 0;
        if (animated) {
            duration = 0.1
        }
        UIView.animateWithDuration(duration, delay: 0, options:.CurveEaseOut , animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.resetConstraintContstantsToZero(false, notifyDelegateDidClose: false)
    }
    
    func openCell()
    {
        self.setConstraintsToShowAllButtons(false, notifyDelegateDidOpen:false)
    }
    func closeCell()
    {
        self.resetConstraintContstantsToZero(true, notifyDelegateDidClose: true)
    }
    
//    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
}
