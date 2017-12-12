//
//  SetDisplayName.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
// Vicky 09/17/17 问题1：这个地方的布局。。。没有autolayout？   save button直接取距下面的距离   也就是"V:[v0()]-距屏幕底端的距离-|"  如果你是在iphone7 plus上显示正常   那考虑到小屏幕  就会出现这种问题  看不到save button了。SetShortIntro页面同样问题。  问题2：在页面加一个gesture用来隐藏keyboard（直接textfield.resignFirstResponder()就可以），目的是点击其他空白地方时候将键盘隐藏。详细效果可以参见app的Log In页面。 问题3：Unlike your Username, a Display Name is \njust....这个地方按照老板的sketch文件，在just前面换行，加入换行符\n，在我的屏幕尺寸上，这整个label的字显示不全，原因是你的x起始点是88，宽度是screenWidth - 176,在小屏幕上width是不是会变窄？是不是会导致字显示不全？正确做法是使用老板给定的width,比如248，那x的起始点就是(screenWidth - 248) / 2，这个问题以后画图时都需要非常注意。同样的问题，txtField的宽度，尽量给宽点，之后"Write a Short Intro"也是一样，这地方不是老板给多宽，你就需要给多宽，需要考虑的是用户体验，当用户输入很长的short intro的时候，你希望app怎么去显示？ 最简单的办法：horizontal左右分别给同样的距离，比如30，这样无论屏幕尺寸多大，用户体验都是较好的。在画每个部分都思考一下，究竟是给定用户控件的宽度，还是设置控件距左右的距离，究竟是给定用户距屏幕上方的距离，还是给定距屏幕下方的距离。不同情况不同方法去做。

protocol ViewControllerNameDelegate: class {
    func protSaveName(txtName: String?)
}

class SetDisplayName: UIViewController {
    
    weak var delegate: ViewControllerNameDelegate?
    var btnBack: UIButton!
    var lblTitle: UILabel!
    var textField: FAETextField!
    var lblEditIntro: UILabel!
    var btnSave: UIButton!
    var txtName: String!
    var boolWillDisappear: Bool = false
    var strFieldText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addObersers()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 99 + device_offset_top, width: screenWidth, height: 27))
        view.addSubview(lblTitle)
        lblTitle.text = "Display Name"
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        
        textField = FAETextField(frame: CGRect(x: 0, y: 174 + device_offset_top, width: screenWidth - 70, height: 34))
        textField.center.x = screenWidth / 2
        view.addSubview(textField)
        textField.textAlignment = .center
        textField.placeholder = "Display Name"
        if strFieldText != "" {
            textField.text = strFieldText
        }
        
        lblEditIntro = UILabel(frame: CGRect(x: 0, y: screenHeight - 99 - 36 - device_offset_bot, width: 248, height: 36))
        lblEditIntro.center.x = screenWidth / 2
        view.addSubview(lblEditIntro)
        lblEditIntro.text = "Unlike your Username, a Display Name is\njust for show. You can change it anytime!"
        lblEditIntro.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblEditIntro.textColor = UIColor._138138138()
        lblEditIntro.textAlignment = .center
        lblEditIntro.lineBreakMode = .byWordWrapping
        lblEditIntro.numberOfLines = 0
        
        btnSave = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 - device_offset_bot, width: 300, height: 50))
        btnSave.center.x = screenWidth / 2
        view.addSubview(btnSave)
        btnSave.setImage(#imageLiteral(resourceName: "settings_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSaveName(_ :)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boolWillDisappear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        boolWillDisappear = true
    }
    
    func addObersers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            textField.resignFirstResponder()
        }
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            textField.resignFirstResponder()
            dismiss(animated: true)
        }
    }
    
    @objc func actionSaveName(_ sender: UIButton) {
        delegate?.protSaveName(txtName: textField.text)
        actionGoBack(sender)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.lblEditIntro.frame.origin.y = screenHeight - frameKeyboard.height - 119
            self.btnSave.frame.origin.y = screenHeight - frameKeyboard.height - 64
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if boolWillDisappear {
            return
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.lblEditIntro.frame.origin.y = screenHeight - 99 - 36 - device_offset_bot
            self.btnSave.frame.origin.y = screenHeight - 30 - 50 - device_offset_bot
        })
    }
}
