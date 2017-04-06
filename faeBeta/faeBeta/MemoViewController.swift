//
//  MemoViewController.swift
//  PinsColSearch
//
//  Created by Shiqi Wei on 3/30/17.
//  Copyright © 2017 Shiqi Wei. All rights reserved.
//

import UIKit

protocol MemoDelegate: class {
    func memoContent(save: Bool, content: String)
}


class MemoViewController: UIViewController, UITextViewDelegate {

    weak var delegate: MemoDelegate?
    var blurViewMemo : UIView!
    var memoView : UIView!
    var memoText: UITextView!
    var placeholderLabel : UILabel!
    var keyboardHeight : CGFloat = 0
    var wordsCount: UILabel!
    var btnSave : UIButton!
    var btnCancel : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        loadBlurView()
        loadMemo()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.memoText.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: ({
            self.blurViewMemo.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 0.3)

        }))
    }

    
    
    func loadBlurView() {
        blurViewMemo = UIView()
        blurViewMemo.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        blurViewMemo.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 0)
        self.view.addSubview(blurViewMemo)

        
    }
    // override textViewDidChange function to limit the length of chars
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let leftcharscount = 50 - textView.text.characters.count
        if(leftcharscount<0){
            wordsCount.textColor = UIColor.faeAppRedColor()
            btnSave.isEnabled = false
            btnSave.alpha = 0.6
        }else{
            wordsCount.textColor = UIColor.faeAppInputPlaceholderGrayColor()
            btnSave.isEnabled = true
            btnSave.alpha = 1
        }
        
        wordsCount.text = String(leftcharscount)
    }
    
    func loadMemo(){
        memoView = UIView(frame: CGRect(x: 0, y: screenHeight-keyboardHeight-180, width: screenWidth, height: 180))
        memoView.backgroundColor = .white
        self.view.addSubview(memoView)
        
        
        memoText = UITextView(frame: CGRect(x: 20, y: 50, width: screenWidth-40, height: screenHeight/2-keyboardHeight-50))
        memoText.delegate = self
        memoText.isEditable = true
        memoText.tintColor = UIColor.faeAppRedColor()
        memoText.font = UIFont(name: "AvenirNext-Regular",size: 18)
        memoText.textColor = UIColor.faeAppInputTextGrayColor()
//placeholder
        placeholderLabel = UILabel()
        placeholderLabel.text = "Type a short memo..."
        placeholderLabel.font = memoText.font
        placeholderLabel.sizeToFit()
        memoText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (memoText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !memoText.text.isEmpty
        
        memoView.addSubview(memoText)
        
        btnCancel = UIButton(frame:CGRect(x: 15, y: 15, width: 51, height: 22))
        btnSave = UIButton(frame:CGRect(x: screenWidth-51, y: 15, width: 36, height: 22))

        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium",size: 16)
        btnCancel.setTitleColor(UIColor.faeAppDarkblueColor(), for: .normal)
        btnCancel.backgroundColor = .clear
        btnCancel.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        
        btnSave.setTitle("Save", for: .normal)
        btnSave.titleLabel?.font = UIFont(name: "AvenirNext-Medium",size: 16)
        btnSave.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnSave.backgroundColor = .clear
        btnSave.addTarget(self, action: #selector(self.actionSaveBtn(_:)), for: .touchUpInside)
        
        memoView.addSubview(btnCancel)
        memoView.addSubview(btnSave)
        
        wordsCount = UILabel(frame: CGRect(x: screenWidth-54, y: self.memoView.frame.height-30, width: 40, height: 22))
        
        wordsCount.font = UIFont(name: "AvenirNext-Medium",size: 16)
        wordsCount.textAlignment = NSTextAlignment.right
        wordsCount.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        wordsCount.text = "50"
        
        memoView.addSubview(wordsCount)
        
    }
    
    //dismiss current view
    func actionDismissCurrentView(_ sender: UIButton) {
        self.delegate?.memoContent(save: false, content: "")
        self.memoText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    // save button action
    func actionSaveBtn(_ sender: UIButton){
    
        self.delegate?.memoContent(save: true, content: memoText.text)
        self.memoText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //resize the height of the view when the keyboard will show
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            self.memoView.frame = CGRect(x: 0, y: screenHeight-keyboardHeight-180, width: screenWidth, height: 180)
            self.memoText.frame = CGRect(x: 20, y: 50, width: screenWidth-40, height: self.memoView.frame.height-50)
            self.wordsCount.frame = CGRect(x: screenWidth-54, y: self.memoView.frame.height-30, width: 40, height: 22)
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
