//
//  CommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol CommentPinViewControllerDelegate {
    // Cancel marker's shadow when back to Fae Map
    func dismissMarkerShadow(dismiss: Bool)
    // Pass location data to fae map view
    func animateToCameraFromCommentPinDetailView(coordinate: CLLocationCoordinate2D, commentID: Int)
}

class CommentPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FAEChatToolBarContentViewDelegate, UITextViewDelegate,EditCommentPinViewControllerDelegate, OpenedPinListViewControllerDelegate, UIScrollViewDelegate {
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    // Delegate of this class
    var delegate: CommentPinViewControllerDelegate?
    
    // Comment ID To Use In This Controller
    var commentIdSentBySegue: Int = -999
    
    // Pin options
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
    var buttonBackToCommentPinLists: UIButton!
    var buttonCommentDetailViewActive: UIButton!
    var buttonCommentDetailViewComments: UIButton!
    var buttonCommentDetailViewPeople: UIButton!
    var buttonCommentPinAddComment: UIButton!
    var buttonCommentPinBackToMap: UIButton!
    var buttonCommentPinDetailDragToLargeSize: UIButton!
    var buttonCommentPinDownVote: UIButton!
    var buttonCommentPinLike: UIButton!
    var buttonCommentPinUpVote: UIButton!
    var buttonMoreOnCommentCellExpanded = false
    var buttonOptionOfCommentPin: UIButton!
    var commentDetailFullBoardScrollView: UIScrollView!
    var commentIDCommentPinDetailView: String = "-999"
    var commentPinDetailLiked = false
    var commentPinDetailShowed = false
    var imageCommentPinUserAvatar: UIImageView!
    var imageViewSaved: UIImageView!
    var labelCommentPinCommentsCount: UILabel!
    var labelCommentPinLikeCount: UILabel!
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
    var uiviewCommentPinUnderLine01: UIView!
    var uiviewCommentPinUnderLine02: UIView!
    var uiviewGrayBaseLine: UIView!
    var uiviewRedSlidingLine: UIView!
    var anotherRedSlidingLine: UIView!
    var subviewWhite: UIView!
    var lableTextViewPlaceholder: UILabel!
    
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
    
    // Control the back to comment pin detail button, prevent the more than once action
    var backJustOnce = true
    
    // A duplicate ControlBoard to hold
    var controlBoard: UIView!
    
    // Toolbar
    var inputToolbar: JSQMessagesInputToolbarCustom!
    private var isObservingInputTextView = false
    private var inputTextViewContext = 0
    var inputTextViewMaximumHeight:CGFloat = 300
    var toolbarDistanceToBottom: NSLayoutConstraint!
    var toolbarHeightConstraint: NSLayoutConstraint!

    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    
    var toolbarContentView: FAEChatToolBarContentView!
    
    // FullboardScrollView and TableViewCommentsOnComments control
    var switchedToFullboard = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.modalPresentationStyle = .OverCurrentContext
        loadCommentPinDetailWindow()
        loadTransparentButtonBackToMap()
        commentIDCommentPinDetailView = "\(commentIdSentBySegue)"
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
        setupInputToolbar()
        setupToolbarContentView()
        addObservers()
    }
    
    override func viewDidAppear(animated:Bool)
    {
        for constraint in self.inputToolbar.constraints{
            if constraint.constant == 90{
                toolbarHeightConstraint = constraint
            }
        }
        if toolbarHeightConstraint == nil{
            toolbarHeightConstraint = NSLayoutConstraint(item:inputToolbar, attribute:.Height,relatedBy:.Equal,toItem:nil,attribute:.NotAnAttribute ,multiplier:1,constant:90)
            self.inputToolbar.addConstraint(toolbarHeightConstraint)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.Width,relatedBy:.Equal,toItem:self.view,attribute:.Width ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.Bottom,relatedBy:.Equal,toItem:self.view,attribute:.Bottom ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        closeToolbarContentView()
        removeObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSeveralInfo() {
        getPinAttributeNum("comment", pinID: commentIDCommentPinDetailView)
        getCommentInfo()
        getPinComments("comment", pinID: commentIDCommentPinDetailView, sendMessageFlag: false)
    }
    
    func loadTransparentButtonBackToMap() {
        let subviewBackToMap = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        self.view.addSubview(subviewBackToMap)
        self.view.sendSubviewToBack(subviewBackToMap)
        subviewBackToMap.addTarget(self, action: #selector(CommentPinViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    private func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name:UIKeyboardDidShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidHide), name:UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterForeground), name:"appWillEnterForeground", object: nil)
        
        if (self.isObservingInputTextView) {
            return;
        }
        let scrollView = self.inputToolbar.contentView.textView as UIScrollView
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.Old, .New], context: nil)
        
        self.isObservingInputTextView = true
    }
    
    private func removeObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if (!self.isObservingInputTextView) {
            return;
        }
        
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        self.isObservingInputTextView = false
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
            buttonSticker.addTarget(self, action: #selector(self.showStikcer), forControlEvents: .TouchUpInside)
            contentView.addSubview(buttonSticker)
            
            buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
            buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
            contentView.addSubview(buttonImagePicker)
            
            buttonImagePicker.addTarget(self, action: #selector(self.showLibrary), forControlEvents: .TouchUpInside)
            
            let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
            buttonCamera.setImage(UIImage(named: "camera"), forState: .Highlighted)
            contentView.addSubview(buttonCamera)
            
            buttonCamera.addTarget(self, action: #selector(self.showCamera), forControlEvents: .TouchUpInside)
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Highlighted)
            contentView.addSubview(buttonSend)
            buttonSend.enabled = false
            buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), forControlEvents: .TouchUpInside)
            
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
        inputToolbar.contentView.textView.tintColor = colorFae
        inputToolbar.contentView.textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder = UILabel(frame: CGRectMake(7, 3, 200, 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        lableTextViewPlaceholder.text = "Write a Comment..."
        inputToolbar.contentView.textView.addSubview(lableTextViewPlaceholder)
        
        inputToolbar.maximumHeight = 128
        self.uiviewCommentPinDetail.addSubview(inputToolbar)
        loadInputBarComponent()
        inputToolbar.hidden = true
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
        let centerAtOneThird = screenWidth / 4
        let targetCenter = CGFloat(tag * centerAtOneThird)
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
//    // Pan gesture for dragging comment pin list dragging button
//    func panActionCommentPinListDrag(pan: UIPanGestureRecognizer) {
//        if pan.state == .Began {
//            if uiviewCommentPinListBlank.frame.size.height == 320 {
//                commentPinSizeFrom = 320
//                commentPinSizeTo = screenHeight
//            }
//            else {
//                commentPinSizeFrom = screenHeight
//                commentPinSizeTo = 320
//            }
//        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
//            let location = pan.locationInView(view)
//            if abs(location.y - commentPinSizeFrom) >= 60 {
//                UIView.animateWithDuration(0.2, animations: {
//                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeTo - 13.5
//                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeTo
//                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeTo - 27.5
//                    self.commentListScrollView.frame.size.height = self.commentPinSizeTo - 92
//                })
//            }
//            else {
//                UIView.animateWithDuration(0.1, animations: {
//                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeFrom - 13.5
//                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeFrom
//                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeFrom - 27.5
//                    self.commentListScrollView.frame.size.height = self.commentPinSizeFrom - 92
//                })
//            }
//        } else {
//            let location = pan.locationInView(view)
//            if location.y >= 306.5 {
//                buttonCommentPinListDragToLargeSize.center.y = location.y
//                uiviewCommentPinListBlank.frame.size.height = location.y + 13.5
//                commentListScrollView.frame.size.height = location.y - 78.5
//            }
//        }
//    }
        
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    // Back to comment pin list window when in detail window
    func actionBackToList(sender: UIButton!) {
        if backJustOnce == true {
            backJustOnce = false
            UIView.animateWithDuration(0.583, animations:({
                self.subviewWhite.center.y -= self.subviewWhite.frame.size.height
                self.uiviewCommentPinDetail.center.y -= screenHeight
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(openedPinListVC, animated: false, completion: nil)
        }
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
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted from both the Map and Mapboards, no one can find it anymore. All the comments and replies will also be removed.", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaeMap()
            deleteCommentPin.deleteCommentById(self.commentIDCommentPinDetailView) {(status: Int, message: AnyObject?) in
                if status / 100 == 2 {
                    print("Successfully delete comment")
                    UIView.animateWithDuration(0.583, animations: ({
                        self.uiviewCommentPinDetail.center.y -= screenHeight
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
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func reloadCommentContent() {
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
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
    
    // Disable a button, make it unclickable
    func disableTheButton(button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        button.tintColor = UIColor.lightGrayColor()
        button.userInteractionEnabled = false
    }
    
    // Hide comment pin detail window
    func hideCommentPinDetail() {
        if uiviewCommentPinDetail != nil {
            if commentPinDetailShowed {
                actionBackToMap(self.buttonCommentPinBackToMap)
                UIView.animateWithDuration(0.583, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        
                    }
                })
            }
        }
    }
    
    // When clicking reply button in comment pin detail window
    func actionReplyToThisComment(sender: UIButton) {
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        self.numberOfCommentTableCells = self.dictCommentsOnCommentDetail.count
        let newHeight = CGFloat(140 * self.numberOfCommentTableCells)
        
        textviewCommentPinDetail.scrollEnabled = false
        commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.uiviewCommentPinDetail.frame.size.height = screenHeight + 26
            self.uiviewCommentPinUnderLine02.frame.origin.y = screenHeight
            self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 155
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
                self.tableCommentsForComment.frame.size.height = newHeight
                self.inputToolbar.hidden = false
            }
        })
    }
    
    func actionBackToMap(sender: UIButton) {
        inputToolbar.hidden = true
        UIView.animateWithDuration(0.583, animations: ({
            self.subviewWhite.center.y -= self.subviewWhite.frame.size.height
            self.uiviewCommentPinDetail.center.y -= screenHeight+150
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
        
        //
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
    
    func backFromOpenedPinList(back: Bool) {
        if back {
            backJustOnce = true
            subviewWhite.frame = CGRectMake(0, 0, screenWidth, 65)
            UIView.animateWithDuration(0.583, animations:({
                self.uiviewCommentPinDetail.center.y += screenHeight
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
        }
        if !back {
            self.delegate?.dismissMarkerShadow(true)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func appWillEnterForeground(){
    }
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        UIView.animateWithDuration(0.3,delay: 0, options: .CurveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = -keyboardHeight
            self.view.setNeedsUpdateConstraints()
        }, completion: nil)
    }
    
    func keyboardDidShow(notification: NSNotification){
        toolbarContentView.keyboardShow = true
    }
    
    func keyboardWillHide(notification: NSNotification){
        UIView.animateWithDuration(0.3,delay: 0, options: .CurveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = 0
            self.view.setNeedsUpdateConstraints()
        }, completion: nil)
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
        toolbarDistanceToBottom.constant = -271
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveDownInputBar() {
        toolbarDistanceToBottom.constant = 0
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveUpInputBarContentView(animated: Bool)
    {
        if(animated){
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animateWithDuration(0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
                }, completion:{ (Bool) -> Void in
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = screenHeight - 271
        }
    }
    
    // MARK: - send messages
    func sendMessage(text : String?, date: NSDate, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : NSData?, audio : NSData?) {
        if let realText = text {
            commentThisPin("comment", pinID: commentIDCommentPinDetailView, text: realText)
        }
        self.inputToolbar.contentView.textView.text = ""
        self.lableTextViewPlaceholder.hidden = false
        self.inputToolbar.contentView.textView.resignFirstResponder()
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
        if textView == self.inputToolbar.contentView.textView {
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if self.inputToolbar.contentView.textView.text.stringByTrimmingCharactersInSet(spacing).isEmpty == false {
                self.lableTextViewPlaceholder.hidden = true
            }
            else {
                self.lableTextViewPlaceholder.hidden = false
            }
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                buttonSend.enabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), forState: .Normal)
            } else {
                buttonSend.enabled = true
                buttonSend.setImage(UIImage(named: "canSendMessage"), forState: .Normal)
            }
        }
    }
    
    func animateToCameraFromOpenedPinListView(coordinate: CLLocationCoordinate2D, commentID: Int) {
        self.delegate?.animateToCameraFromCommentPinDetailView(coordinate, commentID: commentID)
        self.backJustOnce = true
        self.subviewWhite.frame = CGRectMake(0, 0, screenWidth, 65)
        self.uiviewCommentPinDetail.center.y += screenHeight
        self.commentIDCommentPinDetailView = "\(commentID)"
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), forState: .Normal)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), forState: .Normal)
        self.showKeyboard()
    }
    
    //MARK: - observe key path
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?,
                                                  change: [String : AnyObject]?,
                                                  context: UnsafeMutablePointer<Void>)
    {
        let textView = object as! UITextView
        if (textView == self.inputToolbar.contentView.textView && keyPath! == "contentSize") {
            
            let oldContentSize = change![NSKeyValueChangeOldKey]!.CGSizeValue
                
            let newContentSize = change![NSKeyValueChangeNewKey]!.CGSizeValue
            
            let dy = newContentSize().height - oldContentSize().height;
            
            if toolbarHeightConstraint != nil {
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.inputToolbar.contentView.textView.resignFirstResponder()
        if commentDetailFullBoardScrollView.contentOffset.y >= 226 {
            self.controlBoard.hidden = false
        }
        if commentDetailFullBoardScrollView.contentOffset.y < 226 {
            self.controlBoard.hidden = true
        }
    }

}
