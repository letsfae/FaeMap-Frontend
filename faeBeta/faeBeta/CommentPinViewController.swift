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

protocol CommentPinDetailDelegate: class {
    // Cancel marker's shadow when back to Fae Map
    func dismissMarkerShadow(_ dismiss: Bool)
    // Pass location data to fae map view
    func animateToCameraFromCommentPinDetailView(_ coordinate: CLLocationCoordinate2D, commentID: Int)
}

class CommentPinDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FAEChatToolBarContentViewDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    // Delegate of this class
    weak var delegate: CommentPinDetailDelegate?
    
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
    
    // People table
    var tableViewPeople: UITableView!
    var dictPeopleOfCommentDetail = [Int: String]()
    
    // Toolbar
    var inputToolbar: JSQMessagesInputToolbarCustom!
    fileprivate var isObservingInputTextView = false
    fileprivate var inputTextViewContext = 0
    var inputTextViewMaximumHeight:CGFloat = 250 * screenHeightFactor * screenHeightFactor// the distance from the top of toolbar to top of screen
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
    
    // Another dragging button for UI effect
    var draggingButtonSubview: UIView!
    
    // Timer for animating heart
    var animatingHeartTimer: Timer!
    
    // Timer for touching pin comment cell
    var touchToReplyTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = .overCurrentContext
        loadCommentPinDetailWindow()
        loadTransparentButtonBackToMap()
        commentIDCommentPinDetailView = "\(commentIdSentBySegue)"
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
        setupInputToolbar()
        setupToolbarContentView()
        addObservers()
        for constraint in self.inputToolbar.constraints{
            if constraint.constant == 90 {
                toolbarHeightConstraint = constraint
            }
        }
        if toolbarHeightConstraint == nil{
            toolbarHeightConstraint = NSLayoutConstraint(item:inputToolbar, attribute:.height,relatedBy:.equal,toItem:nil,attribute:.notAnAttribute ,multiplier:1,constant:90)
            self.inputToolbar.addConstraint(toolbarHeightConstraint)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.width,relatedBy:.equal,toItem:self.view,attribute:.width ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.bottom,relatedBy:.equal,toItem:self.view,attribute:.bottom ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    override func viewDidAppear(_ animated:Bool) {
        adjustInputToolbarHeightConstraint(byDelta: -90)// A tricky way to set the toolbarHeight to default
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        let subviewBackToMap = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(subviewBackToMap)
        self.view.sendSubview(toBack: subviewBackToMap)
        subviewBackToMap.addTarget(self, action: #selector(CommentPinDetailViewController.actionBackToMap(_:)), for: .touchUpInside)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        
        if (self.isObservingInputTextView) {
            return;
        }
        let scrollView = self.inputToolbar.contentView.textView as UIScrollView
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        
        self.isObservingInputTextView = true
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        if (!self.isObservingInputTextView) {
            return;
        }
        
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        self.isObservingInputTextView = false
    }
    
    fileprivate func setupInputToolbar()
    {
        func loadInputBarComponent() {
            
            //        let camera = Camera(delegate_: self)
            let contentView = self.inputToolbar.contentView
            let contentOffset = (screenWidth - 42 - 29 * 5) / 4 + 29
            buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
            buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
            contentView?.addSubview(buttonKeyBoard)
            
            /*
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
            */
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
            contentView?.addSubview(buttonSend)
            buttonSend.isEnabled = false
            buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
            
            buttonSet.append(buttonKeyBoard)
//            buttonSet.append(buttonSticker)
//            buttonSet.append(buttonImagePicker)
//            buttonSet.append(buttonCamera)
            buttonSet.append(buttonSend)
            
            for button in buttonSet{
                button.autoresizingMask = [.flexibleTopMargin]
            }
        }
        inputToolbar = JSQMessagesInputToolbarCustom(frame: CGRect(x: 0, y: screenHeight - 90, width: screenWidth, height: 90))
        inputToolbar.contentView.textView.delegate = self
        inputToolbar.contentView.textView.tintColor = colorFae
        inputToolbar.contentView.textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        inputToolbar.contentView.textView.delaysContentTouches = false
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 7, y: 3, width: 200, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        lableTextViewPlaceholder.text = "Write a Comment..."
        inputToolbar.contentView.textView.addSubview(lableTextViewPlaceholder)
        
        inputToolbar.maximumHeight = 128
        self.uiviewCommentPinDetail.addSubview(inputToolbar)
        loadInputBarComponent()
        inputToolbar.isHidden = true
    }
    
    fileprivate func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
    }
    
    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        endEdit()
        if sender.tag == 1 {
            tableViewPeople.isHidden = true
            tableCommentsForComment.isHidden = false
            commentDetailFullBoardScrollView.contentSize.height = tableCommentsForComment.frame.size.height + 281
        }
        else if sender.tag == 3 {
            tableViewPeople.isHidden = false
            tableCommentsForComment.isHidden = true
            commentDetailFullBoardScrollView.contentSize.height = tableViewPeople.frame.size.height + 281
        }
        let tag = CGFloat(sender.tag)
        let centerAtOneThird = screenWidth / 4
        let targetCenter = CGFloat(tag * centerAtOneThird)
        UIView.animate(withDuration: 0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Hide comment pin more options' button
    func hideCommentPinMoreButtonDetails() {
        buttonMoreOnCommentCellExpanded = false
        let subviewXBefore: CGFloat = 400 / 414 * screenWidth
        let subviewYBefore: CGFloat = 57 / 414 * screenWidth
        UIView.animate(withDuration: 0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
//            self.buttonShareOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
//            self.buttonSaveOnCommentDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            self.buttonEditOnCommentDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonDeleteOnCommentDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonReportOnCommentDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
//            self.buttonShareOnCommentDetail.alpha = 0.0
//            self.buttonSaveOnCommentDetail.alpha = 0.0
            self.buttonEditOnCommentDetail.alpha = 0.0
            self.buttonDeleteOnCommentDetail.alpha = 0.0
            self.buttonReportOnCommentDetail.alpha = 0.0
        }))
        buttonFakeTransparentClosingView.removeFromSuperview()
    }
    
    // Disable a button, make it unclickable
    func disableTheButton(_ button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: UIControlState())
        button.tintColor = UIColor.lightGray
        button.isUserInteractionEnabled = false
    }
    
    // Hide comment pin detail window
    func hideCommentPinDetail() {
        if uiviewCommentPinDetail != nil {
            if commentPinDetailShowed {
                actionBackToMap(self.buttonCommentPinBackToMap)
                UIView.animate(withDuration: 0.583, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        
                    }
                })
            }
        }
    }
    
    func animateHeart() {
        buttonCommentPinLike.tag = 0
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = UIImage(named: "commentPinLikeFull")
        animatingHeart.layer.zPosition = 108
        uiviewCommentPinDetailMainButtons.addSubview(animatingHeart)
        
        //
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: buttonCommentPinLike.center.x, y: buttonCommentPinLike.center.y)
        let path =  CGMutablePath()
        path.move(to: CGPoint(x:0,y:0), transform: transform )
        path.addLine(to: CGPoint(x:randomX-75, y:-randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
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
        animatingHeart.layer.add(orbit, forKey:"Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: buttonCommentPinLike.center.x, y: buttonCommentPinLike.center.y)
    }
    
    func appWillEnterForeground(){
        
    }
    
    func keyboardWillShow(_ notification: Notification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = -keyboardHeight
            self.view.setNeedsUpdateConstraints()
        }, completion: nil)
    }
    
    func keyboardDidShow(_ notification: Notification){
        toolbarContentView.keyboardShow = true
    }
    
    func keyboardWillHide(_ notification: Notification){
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = 0
            self.view.setNeedsUpdateConstraints()
        }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        toolbarContentView.keyboardShow = false
    }
    
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.toolbarContentView.showKeyboard()
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
    }
    
    func showLibrary() {
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
    }
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    fileprivate func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
//        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
//        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
//        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
//        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    fileprivate func closeToolbarContentView() {
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
    
    func moveUpInputBarContentView(_ animated: Bool)
    {
        if(animated){
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
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
    func sendMessage(_ text : String?, date: Date, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : Data?, audio : Data?) {
        if let realText = text {
            commentThisPin("comment", pinID: commentIDCommentPinDetailView, text: realText)
        }
        self.inputToolbar.contentView.textView.text = ""
        self.lableTextViewPlaceholder.isHidden = false
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    //MARK: -  UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: Date(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
//        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func image(_ image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?) {
        self.appWillEnterForeground()
    }
    
    //MARK: - toolbar Content view delegate
    func showAlertView(withWarning text:String) {
        
    }
    
    func sendStickerWithImageName(_ name : String) {
        
    }
    func sendImages(_ images:[UIImage]) {
        
    }
    
    func showFullAlbum() {
        
    }
    
    func endEdit() {
        self.view.endEditing(true)
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    //MARK: - TEXTVIEW delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.inputToolbar.contentView.textView {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if self.inputToolbar.contentView.textView.text.trimmingCharacters(in: spacing).isEmpty == false {
                self.lableTextViewPlaceholder.isHidden = true
            }
            else {
                self.lableTextViewPlaceholder.isHidden = false
            }
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                buttonSend.isEnabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            } else {
                buttonSend.isEnabled = true
                buttonSend.setImage(UIImage(named: "canSendMessage"), for: UIControlState())
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.showKeyboard()
    }
    
    
    
    //MARK: - observe key path
    override func observeValue(forKeyPath keyPath: String?,
                                         of object: Any?,
                                                  change: [NSKeyValueChangeKey : Any]?,
                                                  context: UnsafeMutableRawPointer?)
    {
        let textView = object as! UITextView
        if (textView == self.inputToolbar.contentView.textView && keyPath! == "contentSize") {
            
            let oldContentSize = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgSizeValue
                
            let newContentSize = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgSizeValue
            
            let dy = (newContentSize?.height)! - (oldContentSize?.height)!;
            
            if toolbarHeightConstraint != nil {
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.inputToolbar.contentView.textView.resignFirstResponder()
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
        if commentDetailFullBoardScrollView.contentOffset.y >= 226 {
            if self.controlBoard != nil {
                self.controlBoard.isHidden = false
            }
        }
        if commentDetailFullBoardScrollView.contentOffset.y < 226 {
            if self.controlBoard != nil {
                self.controlBoard.isHidden = true
            }
        }
    }
    
}
