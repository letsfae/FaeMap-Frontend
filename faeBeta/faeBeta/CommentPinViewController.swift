//
//  CommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CommentPinViewControllerDelegate {
    // Cancel marker's shadow when back to Fae Map
    func dismissMarkerShadow(dismiss: Bool)
}

class CommentPinViewController: UIViewController, EditCommentPinViewControllerDelegate {
    
    // Delegate of this class
    var delegate: CommentPinViewControllerDelegate?
    
    // Comment ID To Use In This Controller
    var commentIdSentBySegue: Int = -999
    
    // MARK: -- Common Used Vars and Constants
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    // Comment Pin List
    var commentPinAvoidDic = [Int: Int]()
    var commentPinCellNumCount = 0
    
    var buttonShareOnCommentDetail: UIButton!
    var buttonEditOnCommentDetail: UIButton!
    var buttonSaveOnCommentDetail: UIButton!
    var buttonDeleteOnCommentDetail: UIButton!
    var buttonReportOnCommentDetail: UIButton!
    
    // New Comment Pin Popup Window
    var numberOfCommentTableCells: Int = 0
    var dictCommentsOnCommentDetail = [[String: AnyObject]]()
    var animatingHeart: UIImageView!
    var boolCommentPinLiked = false
    var buttonBackToCommentPinDetail: UIButton!
    var buttonBackToCommentPinLists: UIButton!
    var buttonCommentDetailViewActive: UIButton!
    var buttonCommentDetailViewComments: UIButton!
    var buttonCommentDetailViewPeople: UIButton!
    var buttonCommentPinAddComment: UIButton!
    var buttonCommentPinBackToMap: UIButton!
    var buttonCommentPinDetailDragToLargeSize: UIButton!
    var buttonCommentPinDownVote: UIButton!
    var buttonCommentPinLike: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var buttonCommentPinUpVote: UIButton!
    var buttonMoreOnCommentCellExpanded = false
    var buttonOptionOfCommentPin: UIButton!
    var commentDetailFullBoardScrollView: UIScrollView!
    var commentIDCommentPinDetailView: String = "-999"
    var commentListExpand = false
    var commentListScrollView: UIScrollView!
    var commentListShowed = false
    var commentPinCellArray = [CommentPinListCell]()
    var commentPinDetailLiked = false
    var commentPinDetailShowed = false
    var imageCommentPinUserAvatar: UIImageView!
    var imageViewSaved: UIImageView!
    var labelCommentPinCommentsCount: UILabel!
    var labelCommentPinLikeCount: UILabel!
    var labelCommentPinListTitle: UILabel!
    var labelCommentPinTimestamp: UILabel!
    var labelCommentPinTitle: UILabel!
    var labelCommentPinUserName: UILabel!
    var labelCommentPinVoteCount: UILabel!
    var moreButtonDetailSubview: UIImageView!
    var tableCommentsForComment: UITableView!
    var textviewCommentPinDetail: UITextView!
    var uiviewCommentDetailThreeButtons: UIView!
    var uiviewCommentPinDetail: UIView!
    var uiviewCommentPinDetailGrayBlock: UIView!
    var uiviewCommentPinDetailMainButtons: UIView!
    var uiviewCommentPinListBlank: UIView!
    var uiviewCommentPinListUnderLine01: UIView!
    var uiviewCommentPinListUnderLine02: UIView!
    var uiviewCommentPinUnderLine01: UIView!
    var uiviewCommentPinUnderLine02: UIView!
    var uiviewGrayBaseLine: UIView!
    var uiviewRedSlidingLine: UIView!
    
    // For Dragging
    var buttonCenter = CGPointZero
    var commentPinSizeFrom: CGFloat = 0
    var commentPinSizeTo: CGFloat = 0
    
    // Like Function
    var commentPinLikeCount: Int = 0
    var isUpVoting = false
    var isDownVoting = false

    // Fake Transparent View For Closing
    var buttonFakeTransparentClosingView: UIButton!
    
    // Check if this comment belongs to current user
    var thisIsMyPin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.modalPresentationStyle = .OverCurrentContext
        loadCommentPinDetailWindow()
        commentIDCommentPinDetailView = "\(commentIdSentBySegue)"
        getPinAttributeNum("comment", pinID: commentIDCommentPinDetailView)
        getCommentInfo()
        getPinComments("comment", pinID: commentIDCommentPinDetailView)
        let subviewBackToMap = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        self.view.addSubview(subviewBackToMap)
        self.view.sendSubviewToBack(subviewBackToMap)
        subviewBackToMap.addTarget(self, action: #selector(CommentPinViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "idFirstSegueUnwind" {
            
        }
    }
    
    // Animation of the red sliding line
    func animationRedSlidingLine(sender: UIButton) {
        let tag = CGFloat(sender.tag)
        let centerAtOneThird = screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneThird)
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Pan gesture for dragging comment pin list dragging button
    func panActionCommentPinListDrag(pan: UIPanGestureRecognizer) {
        if pan.state == .Began {
            if uiviewCommentPinListBlank.frame.size.height == 320 {
                commentPinSizeFrom = 320
                commentPinSizeTo = screenHeight
            }
            else {
                commentPinSizeFrom = screenHeight
                commentPinSizeTo = 320
            }
        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
            let location = pan.locationInView(view)
            if abs(location.y - commentPinSizeFrom) >= 60 {
                UIView.animateWithDuration(0.2, animations: {
                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeTo - 13.5
                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeTo
                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeTo - 27.5
                    self.commentListScrollView.frame.size.height = self.commentPinSizeTo - 92
                })
            }
            else {
                UIView.animateWithDuration(0.1, animations: {
                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeFrom - 13.5
                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeFrom
                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeFrom - 27.5
                    self.commentListScrollView.frame.size.height = self.commentPinSizeFrom - 92
                })
            }
        } else {
            let location = pan.locationInView(view)
            if location.y >= 306.5 {
                buttonCommentPinListDragToLargeSize.center.y = location.y
                uiviewCommentPinListBlank.frame.size.height = location.y + 13.5
                commentListScrollView.frame.size.height = location.y - 78.5
            }
        }
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(sender: UIButton) {
        for cell in commentPinCellArray {
            cell.removeFromSuperview()
        }
        commentPinCellArray.removeAll()
        commentPinAvoidDic.removeAll()
        commentPinCellNumCount = 0
        disableTheButton(buttonBackToCommentPinDetail)
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    // Back to comment pin list window when in detail window
    func actionBackToList(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewCommentPinListBlank.center.x += self.screenWidth
            self.uiviewCommentPinDetail.center.x += self.screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.commentListShowed = true
                self.commentPinDetailShowed = false
            }
        })
    }
    
    // Back to comment pin detail window when in pin list window
    func actionBackToCommentDetail(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewCommentPinListBlank.center.x -= self.screenWidth
            self.uiviewCommentPinDetail.center.x -= self.screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.commentListShowed = false
                self.commentPinDetailShowed = true
            }
        })
    }
    
    // Show more options button in comment pin detail window
    func showCommentPinMoreButtonDetails(sender: UIButton!) {
        if buttonMoreOnCommentCellExpanded == false {
            buttonFakeTransparentClosingView = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 101
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self,
                                                       action: #selector(CommentPinViewController.actionToCloseOtherViews(_:)),
                                                       forControlEvents: .TouchUpInside)
            let subviewXBefore: CGFloat = 400 / 414 * screenWidth
            let subviewYBefore: CGFloat = 57 / 414 * screenWidth
            var subviewXAfter: CGFloat = 171 / 414 * screenWidth
            let subviewYAfter: CGFloat = 57 / 414 * screenWidth
            var subviewWidthAfter: CGFloat = 229 / 414 * screenWidth
            let subviewHeightAfter: CGFloat = 110 / 414 * screenWidth
            let firstButtonX: CGFloat = 192 / 414 * screenWidth
            let secondButtonX: CGFloat = 262 / 414 * screenWidth
            let thirdButtonX: CGFloat = 332 / 414 * screenWidth
            let buttonY: CGFloat = 97 / 414 * screenWidth
            let buttonWidth: CGFloat = 44 / 414 * screenWidth
            let buttonHeight: CGFloat = 51 / 414 * screenWidth
            
            var moreOptionBackgroundImage = "moreButtonDetailSubview"
            
            if thisIsMyPin == false {
                subviewXAfter = 308 / 414 * screenWidth
                subviewWidthAfter = 92 / 414 * screenWidth
                moreOptionBackgroundImage = "moreButtonDetailSubviewNotMyPin"
            }
            
            moreButtonDetailSubview = UIImageView(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            moreButtonDetailSubview.image = UIImage(named: moreOptionBackgroundImage)
            moreButtonDetailSubview.layer.zPosition = 102
            self.view.addSubview(moreButtonDetailSubview)
            
            // --> Not for 11.01 Dev
//            buttonShareOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
//            buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
//            buttonShareOnCommentDetail.layer.zPosition = 103
//            self.view.addSubview(buttonShareOnCommentDetail)
//            buttonShareOnCommentDetail.clipsToBounds = true
//            buttonShareOnCommentDetail.alpha = 0.0
//            buttonShareOnCommentDetail.addTarget(self,
//                                                 action: #selector(CommentPinViewController.actionShareComment(_:)),
//                                                 forControlEvents: .TouchUpInside)
            
            buttonEditOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonEditOnCommentDetail.setImage(UIImage(named: "buttonEditOnCommentDetail"), forState: .Normal)
            buttonEditOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonEditOnCommentDetail)
            buttonEditOnCommentDetail.clipsToBounds = true
            buttonEditOnCommentDetail.alpha = 0.0
            buttonEditOnCommentDetail.addTarget(self,
                                                 action: #selector(CommentPinViewController.actionEditComment(_:)),
                                                 forControlEvents: .TouchUpInside)
            
            // --> Not for 11.01 Dev
//            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
//            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
//            buttonSaveOnCommentDetail.layer.zPosition = 103
//            self.view.addSubview(buttonSaveOnCommentDetail)
//            buttonSaveOnCommentDetail.clipsToBounds = true
//            buttonSaveOnCommentDetail.alpha = 0.0
//            buttonSaveOnCommentDetail.addTarget(self,
//                                                action: #selector(CommentPinViewController.actionSavedThisPin(_:)),
//                                                forControlEvents: .TouchUpInside)
            
            buttonDeleteOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonDeleteOnCommentDetail.setImage(UIImage(named: "buttonDeleteOnCommentDetail"), forState: .Normal)
            buttonDeleteOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonDeleteOnCommentDetail)
            buttonDeleteOnCommentDetail.clipsToBounds = true
            buttonDeleteOnCommentDetail.alpha = 0.0
            buttonDeleteOnCommentDetail.addTarget(self,
                                                action: #selector(CommentPinViewController.actionDeleteThisPin(_:)),
                                                forControlEvents: .TouchUpInside)
            
            buttonReportOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            buttonReportOnCommentDetail.addTarget(self,
                                                  action: #selector(CommentPinViewController.actionReportThisPin(_:)),
                                                  forControlEvents: .TouchUpInside)
            
            
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(subviewXAfter,
                                                                subviewYAfter,
                                                                subviewWidthAfter,
                                                                subviewHeightAfter)
//                self.buttonShareOnCommentDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonEditOnCommentDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
//                self.buttonSaveOnCommentDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonDeleteOnCommentDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonReportOnCommentDetail.frame = CGRectMake(thirdButtonX, buttonY, buttonWidth, buttonHeight)
//                self.buttonShareOnCommentDetail.alpha = 1.0
//                self.buttonSaveOnCommentDetail.alpha = 1.0
                if self.thisIsMyPin == true {
                    self.buttonEditOnCommentDetail.alpha = 1.0
                    self.buttonDeleteOnCommentDetail.alpha = 1.0
                }
                self.buttonReportOnCommentDetail.alpha = 1.0
            }))
            buttonMoreOnCommentCellExpanded = true
        }
        else {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(sender: UIButton!) {
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        print("Share Clicks!")
    }
    
    func actionEditComment(sender: UIButton!) {
        if commentIdSentBySegue == -999 {
            return
        }
        let editCommentPinVC = EditCommentPinViewController()
        editCommentPinVC.delegate = self
        editCommentPinVC.previousCommentContent = textviewCommentPinDetail.text
        editCommentPinVC.commentID = "\(commentIdSentBySegue)"
        self.presentViewController(editCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionReportThisPin(sender: UIButton!) {
        let reportCommentPinVC = ReportCommentPinViewController()
        self.presentViewController(reportCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionDeleteThisPin(sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaeMap()
            deleteCommentPin.deleteCommentById(self.commentIDCommentPinDetailView) {(status: Int, message: AnyObject?) in
                if status / 100 == 2 {
                    print("Successfully delete comment")
                    UIView.animateWithDuration(0.583, animations: ({
                        self.uiviewCommentPinDetail.center.y -= self.screenHeight
                    }), completion: { (done: Bool) in
                        if done {
                            self.delegate?.dismissMarkerShadow(false)
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }
                    })
                }
                else {
                    print("Fail to delete comment")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            print("Cancel Deleting")
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func reloadCommentContent() {
        getCommentInfo()
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSavedThisPin(sender: UIButton) {
        if commentIDCommentPinDetailView != "-999" {
            saveThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        UIView.animateWithDuration(0.5, animations: ({
            self.imageViewSaved.alpha = 1.0
        }), completion: { (done: Bool) in
            if done {
                UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {
                    self.imageViewSaved.alpha = 0.0
                    }, completion: { (done: Bool) in
                        if done {
                            
                        }
                })
            }
        })
    }
    
    // Expand or shrink comment pin list
    func actionListExpandShrink(sender: UIButton!) {
        if commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            commentListExpand = true
        }
        else {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            commentListExpand = false
        }
    }
    
    // Shrink comment pin list
    func shrinkCommentList() {
        if commentListExpand {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            commentListExpand = false
        }
    }
    
    // Expand comment pin list
    func expandCommentList() {
        if commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            commentListExpand = true
        }
    }
    
    // When clicking a cell in comment pin list, it jumps to its detail window
    func actionJumpToDetail(sender: UIButton!) {
        actionBackToCommentDetail(buttonBackToCommentPinDetail)
        let row = sender.tag
        labelCommentPinUserName.text = commentPinCellArray[row].userID
        labelCommentPinTimestamp.text = commentPinCellArray[row].time.text
        textviewCommentPinDetail.text = commentPinCellArray[row].content.text
    }
    
    // Hide comment pin more options' button
    func hideCommentPinMoreButtonDetails() {
        buttonMoreOnCommentCellExpanded = false
        let subviewXBefore: CGFloat = 400 / 414 * screenWidth
        let subviewYBefore: CGFloat = 57 / 414 * screenWidth
        UIView.animateWithDuration(0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
//            self.buttonShareOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
//            self.buttonSaveOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            self.buttonEditOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            self.buttonDeleteOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            self.buttonReportOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
//            self.buttonShareOnCommentDetail.alpha = 0.0
//            self.buttonSaveOnCommentDetail.alpha = 0.0
            self.buttonEditOnCommentDetail.alpha = 0.0
            self.buttonDeleteOnCommentDetail.alpha = 0.0
            self.buttonReportOnCommentDetail.alpha = 0.0
        }))
        buttonFakeTransparentClosingView.removeFromSuperview()
    }
    
    // Add line number to comment pin list cell, make it trackable when deleting a cell
    func addTagCommentPinCell(cell: CommentPinListCell, commentID: Int) {
        cell.jumpToDetail.tag = commentPinCellNumCount
        cell.deleteButton.tag = commentPinCellNumCount
        cell.commentID = commentID
        commentPinAvoidDic[commentID] = commentPinCellNumCount
    }
    
    // Disable a button, make it unclickable
    func disableTheButton(button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        button.tintColor = UIColor.lightGrayColor()
        button.userInteractionEnabled = false
    }
    
    // Delete comment pin list cell, ### still has bug ###
    func deleteCommentPinCell(sender: UIButton!) {
        let commentID = commentPinCellArray[sender.tag].commentID
        let rowToDelete = sender.tag
        
        if commentPinCellNumCount == 1 {
            commentPinCellNumCount = 0
            disableTheButton(buttonBackToCommentPinDetail)
            commentListScrollView.contentSize.height -= 76
            commentPinCellArray.first!.removeFromSuperview()
            commentPinCellArray.removeAll()
        }
            
        else if commentPinCellNumCount >= 2 {
            commentPinCellNumCount -= 1
            commentPinCellArray[rowToDelete].removeFromSuperview()
            commentPinCellArray.removeAtIndex(rowToDelete)
            commentListScrollView.contentSize.height -= 76
            for (index, cell) in commentPinCellArray.enumerate() {
                if index >= rowToDelete {
                    cell.jumpToDetail.tag -= 1
                    cell.deleteButton.tag -= 1
                    cell.center.y -= 76
                }
            }
        }
        
        if let aDictionaryIndex = commentPinAvoidDic.indexForKey(commentID) {
            // This will remove the key/value pair from the dictionary and return it as a tuple pair.
            let (_, _) = commentPinAvoidDic.removeAtIndex(aDictionaryIndex)
        }
    }
    
    // Show comment pin detail window
    func showCommentPinDetail() {
        if uiviewCommentPinDetail != nil {
            uiviewCommentPinDetail.frame = CGRectMake(0, -320, screenWidth, 320)
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinDetail.center.y += self.uiviewCommentPinDetail.frame.size.height
            }), completion: { (done: Bool) in
                if done {
                    self.commentPinDetailShowed = true
                    self.commentListShowed = false
                }
            })
        }
    }
    
    // Hide comment pin detail window
    func hideCommentPinDetail() {
        if uiviewCommentPinDetail != nil {
            if commentPinDetailShowed {
                actionBackToMap(self.buttonCommentPinBackToMap)
                UIView.animateWithDuration(0.583, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                    }
                })
            }
            if commentListShowed {
                UIView.animateWithDuration(0.583, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveLinear, animations: {
                    self.uiviewCommentPinListBlank.center.y -= self.uiviewCommentPinListBlank.frame.size.height
                }) { (Finished) -> Void in
                    self.commentPinDetailShowed = false
                    self.commentListShowed = false
                    self.uiviewCommentPinListBlank.frame = CGRectMake(-self.screenWidth, 0, self.screenWidth, 320)
                    self.uiviewCommentPinDetail.frame = CGRectMake(0, -320, self.screenWidth, 320)
                }
            }
        }
    }
    
    // When clicking reply button in comment pin detail window
    func actionReplyToThisComment(sender: UIButton) {
        if commentIDCommentPinDetailView != "-999" {
            getPinAttributeCommentsNum("comment", pinID: commentIDCommentPinDetailView)
        }
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        self.numberOfCommentTableCells = self.dictCommentsOnCommentDetail.count
        let newHeight = CGFloat(140 * self.numberOfCommentTableCells)
        
        textviewCommentPinDetail.scrollEnabled = false
        commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.25, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.uiviewCommentPinDetail.frame.size.height = self.screenHeight + 26
            self.uiviewCommentPinUnderLine02.frame.origin.y = self.screenHeight
            self.commentDetailFullBoardScrollView.frame.size.height = self.screenHeight - 155
            self.tableCommentsForComment.frame = CGRectMake(0, 281, self.screenWidth, newHeight)
            if numLines > 4 {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281 + diffHeight
                self.tableCommentsForComment.center.y += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewCommentDetailThreeButtons.center.y += diffHeight
                self.uiviewCommentPinDetailGrayBlock.center.y += diffHeight
                self.uiviewCommentPinDetailMainButtons.center.y += diffHeight
            }
            else {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281
            }
        }), completion: { (done: Bool) in
            if done {
                self.tableCommentsForComment.reloadData()
            }
        })
    }
    
    func actionBackToMap(sender: UIButton) {
            UIView.animateWithDuration(0.583, animations: ({
                self.uiviewCommentPinDetail.center.y -= self.screenHeight
            }), completion: { (done: Bool) in
                if done {
                    self.delegate?.dismissMarkerShadow(true)
                    self.dismissViewControllerAnimated(false, completion: nil)
                }
            })
    }
    
    func animateHeart() {
        animatingHeart = UIImageView(frame: CGRectMake(0, 0, 26, 22))
        animatingHeart.image = UIImage(named: "commentPinLikeFull")
        uiviewCommentPinDetailMainButtons.addSubview(animatingHeart)
        
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        var transform: CGAffineTransform = CGAffineTransformMakeTranslation(buttonCommentPinLike.center.x, buttonCommentPinLike.center.y)
        let path =  CGPathCreateMutable()
        CGPathMoveToPoint(path, &transform, 0, 0)
        CGPathAddLineToPoint(path, &transform, randomX-75, -randomY)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(CATransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(CATransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        animatingHeart.layer.addAnimation(orbit, forKey:"Move")
        animatingHeart.layer.addAnimation(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.addAnimation(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPointMake(buttonCommentPinLike.center.x, buttonCommentPinLike.center.y)
    }
}
