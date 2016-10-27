//
//  CommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FAEChatToolBarContentViewDelegate, UITextViewDelegate {
    
    // Comment ID To Use In This Controller
    var commentIdSentBySegue: Int = -999
    
    // MARK: -- Common Used Vars and Constants
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    // Comment Pin List
    var commentPinAvoidDic = [Int: Int]()
    var commentPinCellNumCount = 0
    
    var buttonShareOnCommentDetail: UIButton!
    var buttonSaveOnCommentDetail: UIButton!
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
    
    // Toolbar
    var inputToolbar: JSQMessagesInputToolbarCustom!
    
    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    
    var toolbarContentView: FAEChatToolBarContentView!
    
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
        addObservers()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        setupInputToolbar()
        setupToolbarContentView()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        closeToolbarContentView()
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
    
    private func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidHide), name:UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterForeground), name:"appWillEnterForeground", object: nil)
    }
    
    private func setupInputToolbar()
    {
        func loadInputBarComponent() {
            
            //        let camera = Camera(delegate_: self)
            let contentView = self.inputToolbar.contentView
            let contentOffset = (screenWidth - 42 - 29 * 5) / 4 + 29
            buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Highlighted)
            buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), forControlEvents: .TouchUpInside)
            contentView.addSubview(buttonKeyBoard)
            
            buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
            buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
            buttonSticker.addTarget(self, action: #selector(ChatViewController.showStikcer), forControlEvents: .TouchUpInside)
            contentView.addSubview(buttonSticker)
            
            buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
            contentView.addSubview(buttonImagePicker)
            
            buttonImagePicker.addTarget(self, action: #selector(ChatViewController.showLibrary), forControlEvents: .TouchUpInside)
            
            let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
            buttonCamera.setImage(UIImage(named: "camera"), forState: .Highlighted)
            contentView.addSubview(buttonCamera)
            
            buttonCamera.addTarget(self, action: #selector(ChatViewController.showCamera), forControlEvents: .TouchUpInside)
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Highlighted)
            contentView.addSubview(buttonSend)
            buttonSend.enabled = false
            buttonSend.addTarget(self, action: #selector(ChatViewController.sendMessageButtonTapped), forControlEvents: .TouchUpInside)
            
            buttonSet.append(buttonKeyBoard)
            buttonSet.append(buttonSticker)
            buttonSet.append(buttonImagePicker)
            buttonSet.append(buttonCamera)
            buttonSet.append(buttonSend)
            
            for button in buttonSet{
                button.autoresizingMask = [.FlexibleTopMargin]
            }
        }

        inputToolbar = JSQMessagesInputToolbarCustom(frame: CGRect(x: 0, y: screenHeight - 90, width: screenWidth, height: 90))
        inputToolbar.contentView.textView.delegate = self
        loadInputBarComponent()
        self.view.addSubview(inputToolbar)
    }
    
    private func setupToolbarContentView()
    {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        UIApplication.sharedApplication().keyWindow?.addSubview(toolbarContentView)
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
                                                       forControlEvents: UIControlEvents.TouchUpInside)
            
            moreButtonDetailSubview = UIImageView(frame: CGRectMake(400, 57, 0, 0))
            moreButtonDetailSubview.image = UIImage(named: "moreButtonDetailSubview")
            moreButtonDetailSubview.layer.zPosition = 102
            self.view.addSubview(moreButtonDetailSubview)
            
            buttonShareOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
            buttonShareOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonShareOnCommentDetail)
            buttonShareOnCommentDetail.clipsToBounds = true
            buttonShareOnCommentDetail.alpha = 0.0
            buttonShareOnCommentDetail.addTarget(self,
                                                 action: #selector(CommentPinViewController.actionShareComment(_:)),
                                                 forControlEvents: UIControlEvents.TouchUpInside)
            
            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            buttonSaveOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonSaveOnCommentDetail)
            buttonSaveOnCommentDetail.clipsToBounds = true
            buttonSaveOnCommentDetail.alpha = 0.0
            buttonSaveOnCommentDetail.addTarget(self,
                                                action: #selector(CommentPinViewController.actionSavedThisPin(_:)),
                                                forControlEvents: UIControlEvents.TouchUpInside)
            
            buttonReportOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            
            
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(171, 57, 229, 110)
                self.buttonShareOnCommentDetail.frame = CGRectMake(192, 97, 44, 51)
                self.buttonSaveOnCommentDetail.frame = CGRectMake(262, 97, 44, 51)
                self.buttonReportOnCommentDetail.frame = CGRectMake(332, 97, 44, 51)
                self.buttonShareOnCommentDetail.alpha = 1.0
                self.buttonSaveOnCommentDetail.alpha = 1.0
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
        print("Share Clicks!")
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
        UIView.animateWithDuration(0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRectMake(400, 57, 0, 0)
            self.buttonShareOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonSaveOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonReportOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonShareOnCommentDetail.alpha = 0.0
            self.buttonSaveOnCommentDetail.alpha = 0.0
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
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinDetail.center.y -= self.screenHeight
            }), completion: { (done: Bool) in
                if done {
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
    
    func appWillEnterForeground(){
    }
    
    func keyboardDidShow(notification: NSNotification){
        toolbarContentView.keyboardShow = true
    }
    
    func keyboardDidHide(notification: NSNotification){
        toolbarContentView.keyboardShow = false
    }
    
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.toolbarContentView.showKeyboard()
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        UIView.animateWithDuration(0.3, animations: {
            self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), forState: .Normal)
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
    }
    
    func showLibrary() {
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), forState: .Normal)
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
    }
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: NSDate(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.enabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
    }
    
    private func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Highlighted)
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
    }
    
    private func closeToolbarContentView()
    {
        resetToolbarButtonIcon()
        moveDownInputBar()
        toolbarContentView.closeAll()
        toolbarContentView.frame.origin.y = screenHeight
    }
    
    func moveUpInputBar() {
        //when keybord, stick, photoes preview show, move tool bar up
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = self.screenHeight - 271 - 90
//        UIView.setAnimationsEnabled(false)
//        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 271 + 90, right: 0.0)
//        UIView.setAnimationsEnabled(true)
        //        self.inputToolbar.frame.origin.y = yPosition
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func moveDownInputBar() {
        //
        let height = self.inputToolbar.frame.height
        let width = self.inputToolbar.frame.width
        let xPosition = self.inputToolbar.frame.origin.x
        let yPosition = screenHeight - 153
//        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 90, right: 0.0)
        self.inputToolbar.frame = CGRectMake(xPosition, yPosition, width, height)
    }
    
    func moveUpInputBarContentView(animated: Bool)
    {
        if(animated){
            self.toolbarContentView.frame.origin.y = self.screenHeight
            UIView.animateWithDuration(0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = self.screenHeight - 271
                }, completion:{ (Bool) -> Void in
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = self.screenHeight - 271
        }
    }
    
    // MARK: - send messages
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : NSData?, audio : NSData?) {
    
    }
    
    //MARK: -  UIImagePickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
//        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func image(image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?)
    {
        self.appWillEnterForeground()
    }
    
    //MARK: - toolbar Content view delegate
    
    func showAlertView()
    {
        
    }
    func sendStickerWithImageName(name : String)
    {
        
    }
    func sendImages(images:[UIImage])
    {
        
    }
    func getMoreImage()
    {
        
    }
    
    func endEdit()
    {
        self.view.endEditing(true)
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    //MARK: - TEXTVIEW delegate
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count == 0 {
            // when text has no char, cannot send message
            buttonSend.enabled = false
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
        } else {
            buttonSend.enabled = true
            buttonSend.setImage(UIImage(named: "canSendMessage"), forState: .Normal)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.showKeyboard()
    }
}
