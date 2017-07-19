//
//  CreatePinBaseViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CreatePinDelegate: class {
    func sendGeoInfo(pinID: String, type: String)
    func backFromPinCreating(back: Bool)
    func closePinMenu(close: Bool)
}

/// This class this the BASE of the create pin views, which include the title image, title, left arrow & cross button, bottom submit button, anonymous button.
/// A subclass of this class will automatically have all the elements above.
/// This class also contains the logic for the input Toolbar, including it's position, and timing to show.

class CreatePinBaseViewController: UIViewController, UITextFieldDelegate, CreatePinInputToolbarDelegate, CreatePinTextViewDelegate, SendStickerDelegate, UIGestureRecognizerDelegate, SelectLocationViewControllerDelegate {
    
    // MARK: - properties
    weak var delegate: CreatePinDelegate?
    var btnSubmit: UIButton!
    var imgTitle: UIImageView!
    var lblTitle: UILabel!
    var tblPinOptions: CreatePinOptionsTableView!
    var tblMoreOptions: CreatePinOptionsTableView!
    var uiviewMain: UIView!
    
    var strSelectedLocation: String!
    var boolBtnSubmitEnabled: Bool = false
    var strTags: String!
    
    var textviewDescrip: CreatePinTextView!
    
    var btnDoAnony: UIButton!
    var switchAnony: UISwitch!
    
    // input toolbar
    var inputToolbar: CreatePinInputToolbar!
    
    // pin location
    var selectedLatitude: CLLocationDegrees = 0
    var selectedLongitude: CLLocationDegrees = 0
    
    // emoji
    var isShowingEmoji: Bool = false // whether the emoji picker view is shown
    var emojiView: StickerPickView!
    
    var prevFirstResponder: AnyObject? // this is a variable used to track the previous first responder, it can be either a textView or a textField. After hiding the emoji picker view, we need to make the previous first responder active again
    
    enum PinType: String {
        case comment = "comment"
        case story = "moment"
        case chat = "chat"
    }
    var pinType: PinType!
    
    enum OptionViewMode{
        case pin
        case bubble
        case more
    }
    var optionViewMode: OptionViewMode = .pin
    
    // specific View
    enum CreatePinSpecificViewOptions {
        case description
        case moreOptionsTable
    }
    
    // What specific content the user is current looking at. Such as the description textView or the more options table
    var currentViewingContent: CreatePinSpecificViewOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTable()
        setupBaseUI()
        addObservers()
        self.view.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadKeyboardToolBar()
        loadEmojiView()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }
    
    // MARK: - setup
    func setupBaseUI() {
        // back button
        let btnBackToPinSelection = UIButton()
        btnBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: UIControlState())
        view.addSubview(btnBackToPinSelection)
        view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: btnBackToPinSelection)
        view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: btnBackToPinSelection)
        btnBackToPinSelection.addTarget(self, action: #selector(self.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
        
        // close button
        let btnCloseCreateComment = UIButton()
        btnCloseCreateComment.setImage(UIImage(named: "closePinCreation"), for: UIControlState())
        view.addSubview(btnCloseCreateComment)
        view.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: btnCloseCreateComment)
        view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: btnCloseCreateComment)
        btnCloseCreateComment.addTarget(self, action: #selector(self.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
        // bottom button - submit / back
        btnSubmit = UIButton()
        btnSubmit.setTitle("Submit!", for: UIControlState())
        btnSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
        btnSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
        btnSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        view.addSubview(btnSubmit)
        btnSubmit.addTarget(self, action: #selector(self.actionSubmitOrBack(_:)), for: .touchUpInside)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: btnSubmit)
        view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: btnSubmit)
        
        //title image
        imgTitle = UIImageView(frame: CGRect(x: (screenWidth - 84) / 2, y: 36, width: 84, height: 91))
        view.addSubview(imgTitle)
        
        lblTitle = UILabel(frame: CGRect(x: (screenWidth - 200) / 2, y: 146, width: 200, height: 27))
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.textColor = .white
        view.addSubview(lblTitle)
        
        // text view of Add Description / Comment
        textviewDescrip = CreatePinTextView(frame: CGRect(x: (screenWidth - 294) / 2, y: 195, width: 294, height: 47))
        textviewDescrip.observerDelegate = self
        textviewDescrip.alpha = 0
        self.view.addSubview(textviewDescrip)
        
        loadAnonymous()
    }
    
    func loadAnonymous() {
        switchAnony = UISwitch()
        switchAnony.transform = CGAffineTransform(scaleX: 35 / 51, y: 21 / 31)
        view.addSubview(switchAnony)
        view.addConstraintsWithFormat("H:[v0(35)]-130-|", options: [], views: switchAnony)
        view.addConstraintsWithFormat("V:[v0(21)]-79-|", options: [], views: switchAnony)
        
        btnDoAnony = UIButton()
        btnDoAnony.setTitle("Anonymous", for: .normal)
        btnDoAnony.setTitleColor(UIColor.white, for: .normal)
        btnDoAnony.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        view.addSubview(btnDoAnony)
        view.addConstraintsWithFormat("H:[v0(100)]-14-|", options: [], views: btnDoAnony)
        view.addConstraintsWithFormat("V:[v0(41)]-66-|", options: [], views: btnDoAnony)
        btnDoAnony.addTarget(self, action: #selector(actionDoAnony), for: .touchUpInside)
    }
    
    func actionDoAnony() {
        switchAnony.setOn(!switchAnony.isOn, animated: true)
    }
    
    func loadTable() {
        tblPinOptions = CreatePinOptionsTableView(frame: CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3))
        self.view.addSubview(tblPinOptions)
        tblPinOptions.delegate = self
        tblPinOptions.dataSource = self
    }
    
    /// This is the method to update the bottom button
    ///
    /// - Parameters:
    ///   - title: the title text for the button
    ///   - enabled: whether this button is enabled or not. If not, the background color will have an alpha 0.65
    func setSubmitButton(withTitle title: String, isEnabled enabled: Bool) {
        // backgroundColor color: UIColor, 
        
        if btnSubmit.currentTitle != title {
            btnSubmit.setTitle(title, for: .normal)
        }
        btnSubmit.backgroundColor = btnSubmit.backgroundColor?.withAlphaComponent(enabled ? 1 : 0.65)
        btnSubmit.setTitleColor(enabled ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: .normal)
        btnSubmit.isEnabled = enabled
    }
    
    /// This is the method to setup the input Toolbar
    private func loadKeyboardToolBar() {
        inputToolbar = CreatePinInputToolbar()
        inputToolbar.delegate = self
        view.addSubview(inputToolbar)
        inputToolbar.alpha = 0
        view.layoutIfNeeded()
    }
    
    func loadEmojiView() {
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        view.addSubview(emojiView)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tapToDismissKeyboard.delegate = self
        //        tapToDismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToDismissKeyboard)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.superview is UITableViewCell {
            return false
        }
        if touch.view is UITableViewCell {
            return false
        }
        return true
    }
    
    // MARK: - button actions
    func actionBackToPinSelections(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.view.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromPinCreating(back: true)
            }
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton) {
        dismiss(animated: false, completion: {
            self.delegate?.closePinMenu(close: true)
        })
    }

    func actionSubmitOrBack(_ sender: UIButton) {
        if optionViewMode == .more {
            switch currentViewingContent! {
            case .description:
                leaveDescription()
                break
            case .moreOptionsTable:
                leaveMoreOptions()
                break
            }
        }
            // create a pin
        else if optionViewMode == .pin {
            self.actionSubmit()
        }
    }
    
    /// This method is empty because this should be override in its subclass
    func actionSubmit() {
    }
    
    func switchToDescription() {
        self.optionViewMode = .more
        self.currentViewingContent = .description
    }
    
    func leaveDescription() {
        self.optionViewMode = .pin
    }
    
    func switchToMoreOptions() {
        self.optionViewMode = .more
        self.currentViewingContent = .moreOptionsTable
        
        if tblMoreOptions == nil {
            tblMoreOptions = CreatePinOptionsTableView(frame: CGRect(x: 0, y: 195, width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 5))
            
            tblMoreOptions.delegate = self
            tblMoreOptions.dataSource = self
            self.view.addSubview(tblMoreOptions)
            tblMoreOptions.alpha = 0
        }
 
        if pinType == .chat {
            tblMoreOptions.frame = CGRect(x: 0, y: 195, width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 5)
        } else {
            tblMoreOptions.frame = CGRect(x: 0, y: 195, width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3)
        }
    }
    
    func leaveMoreOptions() {
        self.optionViewMode = .pin
    }
    
    // MARK: - CreatePinInputToolbarDelegate
    
    /// handle the event when right(finish) button of the keyboard tool bar is touched
    ///
    /// - Parameter inputToolbar: the toolbar that contains the finish button
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar) {
        view.endEditing(true)

        if isShowingEmoji {
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
        
        updateSubmitButton()
    }
    
    // MARK: - CreatePinInputToolbarDelegate
    
    /// handle the event when the left(emoji/keyboard) button on the keyboard toolbar is touched
    ///
    /// - Parameter inputToolbar: the toolbar that contains the left button
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        // if the keyboard is shown, show emoji picker view instead
        if !isShowingEmoji {
            isShowingEmoji = true
            view.endEditing(true)
            showEmojiViewAnimated(animated: true)
        } else {
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: false)
            _ = prevFirstResponder?.becomeFirstResponder()
        }
    }
    
    // MARK: - CreatePinTextViewDelegate
    func textView(_ textView: CreatePinTextView, numberOfCharactersEntered num: Int) {
        if inputToolbar != nil {
            inputToolbar.numberOfCharactersEntered = max(0, num)
        }
        prevFirstResponder = textView
    }
    
    // MARK: - keyboard show/hide
    
    func keyboardWillShow(_ notification: Notification) {
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            _ in
            self.inputToolbar.frame.origin.y = screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if !isShowingEmoji {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                _ in
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        if isShowingEmoji {
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
        
        updateSubmitButton()
    }
    
    fileprivate func updateSubmitButton() {
        if pinType == .comment {
            boolBtnSubmitEnabled = (textviewDescrip.text?.characters.count)! > 0
            setSubmitButton(withTitle: btnSubmit.currentTitle!, isEnabled: boolBtnSubmitEnabled)
        }
    }
    
    // MARK: - textfield delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        prevFirstResponder = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // MARK: - sendSticker Delegate
    
    func sendStickerWithImageName(_ name: String) {
        // do nothing here, won't send sticker
    }
    
    // MARK: - append / delete emoji
    func appendEmojiWithImageName(_ name: String) {
        print("emojiName \(name)")
        print("responder \(String(describing: prevFirstResponder))")
        if let prevFirstResponder = prevFirstResponder {
            //the input view can either be a textfield or a textView, so we need to check it first
            if prevFirstResponder is CreatePinTextView {
                let textView = prevFirstResponder as! CreatePinTextView
                textView.insertText("[\(name)]")
                textView.textViewDidChange(textView)
            } else if prevFirstResponder is UITextField {
                // MARK - 待解决 Vicky06/30/17
                print("textField")
                let textField = prevFirstResponder as! UITextField
                textField.insertText("heresaaa")
                textField.insertText("[\(name)]")
            }
        }
    }
    
    func deleteEmoji() {
        if let prevFirstResponder = prevFirstResponder {
            var previous = ""
            if prevFirstResponder is UITextView {
                let textView = prevFirstResponder as! UITextView
                previous = textView.text
            } else if prevFirstResponder is UITextField {
                let textField = prevFirstResponder as! UITextField
                previous = textField.text!
            }
            
            let finalString = previous.stringByDeletingLastEmoji()
            if prevFirstResponder is CreatePinTextView {
                let textView = prevFirstResponder as! CreatePinTextView
                textView.text = finalString
                textView.textViewDidChange(textView)
            } else if prevFirstResponder is UITextField {
                let textField = prevFirstResponder as! UITextField
                textField.text = finalString
            }
        }
    }
    
    // MARK: - show / hide emoji view
    func showEmojiViewAnimated(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
                self.emojiView.frame.origin.y = screenHeight - 271
            }, completion: { _ in
                self.inputToolbar.switchToEmojiMode()
            })
        } else {
            inputToolbar.frame.origin.y = screenHeight - 271 - 100
            emojiView.frame.origin.y = screenHeight - 271
            inputToolbar.switchToEmojiMode()
        }
    }
    
    func hideEmojiViewAnimated(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = screenHeight
            }, completion: { _ in
                self.inputToolbar.switchToKeyboardMode()
            })
        } else {
            inputToolbar.frame.origin.y = screenHeight - 100
            inputToolbar.alpha = 0
            emojiView.frame.origin.y = screenHeight
            inputToolbar.switchToKeyboardMode()
        }
    }
    
    func randomLocation() -> CLLocationCoordinate2D {
        let lat = LocManage.shared.curtLat
        let lon = LocManage.shared.curtLong
        let random_lat = Double.random(min: -0.01, max: 0.01)
        let random_lon = Double.random(min: -0.01, max: 0.01)
        return CLLocationCoordinate2DMake(lat+random_lat, lon+random_lon)
    }
    
    func actionSelectLocation() {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
        selectLocationVC.pinType = pinType.rawValue
        self.present(selectLocationVC, animated: false, completion: nil)
    }
    
    // SelectLocationViewControllerDelegate
    func sendAddress(_ value: String) {
        strSelectedLocation = value
        self.tblPinOptions.reloadData()
    }
    // SelectLocationViewControllerDelegate End
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
