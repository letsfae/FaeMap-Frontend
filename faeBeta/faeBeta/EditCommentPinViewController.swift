
//  EditCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/30/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol EditCommentPinViewControllerDelegate: class {
    func reloadCommentContent()
}

class EditCommentPinViewController: UIViewController {
    
    weak var delegate: EditCommentPinViewControllerDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    //Base View
    var buttonCancel: UIButton!
    var buttonSave: UIButton!
    var labelTitle: UILabel!
    var uiviewLine: UIView!
    var textViewUpdateComment: UITextView!
    var labelTextViewPlaceholder: UILabel!
    var imageViewForChat: UIImageView!
    var collectionViewMedia: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    
    //Parameter passed by parent view
    var pinID = ""
    var previousCommentContent = ""
    var pinGeoLocation: CLLocationCoordinate2D!
    var pinType = ""
    var imageForChat: UIImage!
    var pinMediaImageArray: [UIImageView] = []
    var editPinMode: PinDetailViewController.PinType = .media
    var mediaIdArray: [Int] = []
    
    //input toolbar
    var inputToolbar: CreatePinInputToolbar!
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    var labelCountChars: UILabel!
    var lineOnToolbar: UIView!
    
    //Emoji View
    var emojiView: StickerPickView!
    var isShowingEmoji: Bool = false
    
    
    //New Added ID array
    var newAddedImageArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        loadEditCommentPinItems()
        addObservers()
        loadKeyboardToolBar()
        loadEmojiView()
        textViewDidChange(textViewUpdateComment)
        initPinBasicInfo()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textViewUpdateComment.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        print("[viewDidLayoutSubviews]")
        super.viewDidLayoutSubviews()
        if collectionViewMedia != nil {
            var insets = self.collectionViewMedia.contentInset
            insets.left = 15
            insets.right = 15
            self.collectionViewMedia.contentInset = insets
            self.collectionViewMedia.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    func initPinBasicInfo() {
        switch editPinMode {
        case .comment:
            self.labelTitle.text = "Edit Comment"
            break
        case .media:
            self.labelTitle.text = "Edit Story"
            break
        case .chat_room:
            self.labelTitle.text = "Edit Chat"
            break
        case .place:
            break
        }
    }
        
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification)
    {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.inputToolbar.frame.origin.y = self.screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if(!isShowingEmoji){
            UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
                Void in
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func showEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 271 - 100
                self.emojiView.frame.origin.y = self.screenHeight - 271
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
            self.emojiView.frame.origin.y = screenHeight - 271
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
        }
    }
    
    func hideEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = self.screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 100
            self.inputToolbar.alpha = 0
            self.emojiView.frame.origin.y = screenHeight
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        }
        self.textViewUpdateComment.becomeFirstResponder()
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewUpdateComment.endEditing(true)
    }
    
    func pickMedia() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            self.actionTakeMedia()
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            imagePicker.sourceType = .camera
            menu.removeFromParentViewController()
            self.present(imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu,animated:true,completion: nil)
    }
    
    func actionTakeMedia() {
        let numMediaLeft = 6 - pinMediaImageArray.count
        if numMediaLeft == 0 {
            self.showAlert(title: "Up to 6 pictures can be uploaded at the same time", message: "please try again")
            return
        }
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self
        imagePicker.isCSP = true
        imagePicker._maximumSelectedPhotoNum = numMediaLeft
        self.present(nav, animated: true, completion: {
            UIApplication.shared.statusBarStyle = .default
        })
    }
    
    func deleteMedia(cell: EditPinCollectionViewCell){
        if let indexPath = collectionViewMedia.indexPath(for: cell) {
            print("before mediaIDarray: \(mediaIdArray)")
            pinMediaImageArray.remove(at: indexPath.row-1)
            collectionViewMedia.deleteItems(at: [indexPath])
            mediaIdArray.remove(at: indexPath.row-1)
            checkButtonState()
            print("After mediaIDarray: \(mediaIdArray)")
        }
    }
    
    func loadIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        self.textViewUpdateComment.resignFirstResponder()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func uploadFile(image: UIImage, count: Int, total: Int) {
        let mediaImage = FaeImage()
        mediaImage.type = "image"
        mediaImage.image = image
        mediaImage.faeUploadFile { (status: Int, message: Any?) in
            if status / 100 == 2 {
                print("[uploadFile] Successfully upload Image File")
                let fileIDJSON = JSON(message!)
                if let file_id = fileIDJSON["file_id"].int {
                    print("newID is: \(file_id)")
                    self.mediaIdArray.append(file_id)
                }
                else {
                    print("[uploadFile] Fail to process file_id")
                }
                if count + 1 >= total {
                    self.collectionViewMedia.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.textViewUpdateComment.becomeFirstResponder()
                    return
                }
                self.uploadFile(image: self.newAddedImageArray[count+1],
                                   count: count+1,
                                   total: total)
            } else {
                print("[uploadFile] Fail to upload Image File")
            }
        }
    }
    
    func checkButtonState() {
        let main_string = "Save"
        let string_to_color = "Save"
        let range = (main_string as NSString).range(of: string_to_color)
        if pinType == "media" && pinMediaImageArray.count < 1 || textViewUpdateComment.text.characters.count < 1{
            self.buttonSave.isEnabled = false
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttributes([NSForegroundColorAttributeName: UIColor.faeAppDisabledRedColor(), NSKernAttributeName: CGFloat(-0.46)], range: range)
            self.buttonSave.setAttributedTitle(attribute, for: .normal)
        }else {
            self.buttonSave.isEnabled = true
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttributes([NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSKernAttributeName: CGFloat(-0.46)], range: range)
            self.buttonSave.setAttributedTitle(attribute, for: .normal)
        }
        
    }
}
