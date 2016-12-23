//
//  VerificationPhoneViewController.swift
//  faeBeta
//
//  Created by User on 6/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol SetupPhoneNumberDelegate {
    
    func setupPhoneNumber(_ phone : String)
    
}

class VerificationPhoneViewController: UIViewController {
    
    var countryCode = ""
    var phoneNumber = ""
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeigh = UIScreen.main.bounds.height
    
    var labelVerificationTitle : UILabel!
    var labelVerificationHint : UILabel!
    var labelPhoneNumber : UILabel!
    
    var buttonProceed : UIButton!
    var buttonResend : UIButton!
    
    var TextFieldDummy = UITextField(frame: CGRect.zero)
    
    var faeGray = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
    
    let colorDisableButton = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    
    let warmGray = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
    
    var imageCodeDotArray = [UIImageView!]()
    
    var textVerificationCode = [UILabel!]()
    
    var index : Int = 0
    
    let isIPhone5 = UIScreen.main.bounds.size.height == 568
    
    var delegate : SetupPhoneNumberDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTextLabel()
        loadDot()
        loadVerificaitonCode()
        loadTextField()
        loadButton()
        navigationBarSetting()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    func navigationBarSetting() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "Phone"
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray] as [String : Any]
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func loadTextLabel() {
        labelPhoneNumber = UILabel(frame: CGRect(x: 20, y: 376, width: screenWidth - 40, height: 27))
        labelPhoneNumber.textColor = warmGray
        labelPhoneNumber.textAlignment = .center
        labelPhoneNumber.font = UIFont(name: "Avenir Next", size: 20)
        labelPhoneNumber.text = "+\(countryCode) \(phoneNumber)"
        self.view.addSubview(labelPhoneNumber)
        
        labelVerificationHint = UILabel(frame: CGRect(x: 91.5, y: 352, width: 231, height: 18))
        labelVerificationHint.textAlignment = .center
        labelVerificationHint.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        labelVerificationHint.font = UIFont(name: "Avenir Next", size: 13)
        labelVerificationHint.text = "Didn’t get a code? Tap here to Resend."
        self.view.addSubview(labelVerificationHint)
        
        labelVerificationTitle = UILabel(frame: CGRect(x: 91, y: 103, width: 233, height: 50))
        labelVerificationTitle.font = UIFont(name: "Avenir Next", size: 18)
        labelVerificationTitle.numberOfLines = 0
        labelVerificationTitle.textAlignment = .center
        labelVerificationTitle.textColor = faeGray
        labelVerificationTitle.text = "Verify your Number with the\nCode we texted you."
        self.view.addSubview(labelVerificationTitle)
    }
    
    func loadTextField() {
        self.view.addSubview(TextFieldDummy)
        TextFieldDummy.keyboardType = UIKeyboardType.numberPad
        TextFieldDummy.addTarget(self, action: #selector(VerificationPhoneViewController.textFieldValueDidChanged(_:)), for: UIControlEvents.editingChanged)
        TextFieldDummy.becomeFirstResponder()
    }
    
    func loadDot() {
        var xDistance = 0.23 * screenWidth
        let paddingTop = 0.325 * screenHeigh
        let length = 0.03*screenWidth
        let height = 0.017*screenHeigh
        let interval = 0.1014 * screenWidth
        for i in 0  ..< 6 {
            imageCodeDotArray.append(UIImageView(frame : CGRect(x: xDistance, y: paddingTop, width: length, height: height)))
            xDistance += interval
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            self.view.addSubview(imageCodeDotArray[i]);
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func textFieldValueDidChanged(_ textField: UITextField) {
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index -= 1;
            imageCodeDotArray[index].isHidden = false
            textVerificationCode[index].isHidden = true
            disableButton(buttonProceed)
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count >= 6) {
                enableButton(buttonProceed)
            }
            if(buffer.characters.count > 6) {
                let endIndex = buffer.characters.index(buffer.startIndex, offsetBy: 6)
                textField.text = buffer.substring(to: endIndex)
            } else {
                textVerificationCode[index].text = (String)(buffer[buffer.characters.index(before: buffer.endIndex)])
                imageCodeDotArray[index].isHidden = true
                textVerificationCode[index].isHidden = false;
                index += 1
            }
        }
        print(index)
    }
    
    func loadVerificaitonCode() {
        var xDistance = 0.201 * screenWidth
        let length = 0.085 * screenWidth
        let height = 0.1114 * screenHeigh
        let paddingTop = 0.28*screenHeigh
        let interval = 0.102*screenWidth
        for i in 0  ..< 6 {
            textVerificationCode.append(UILabel(frame: CGRect(x: xDistance, y: paddingTop, width: length, height: height)))
            if(isIPhone5) {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 50)
            } else {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 60)
            }
            textVerificationCode[i].textColor = UIColor.faeAppRedColor()
            textVerificationCode[i].textAlignment = .center
            let attributedString = NSMutableAttributedString(string: "\(i)")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.6), range: NSRange(location: 0, length: attributedString.length))
            
            textVerificationCode[i].attributedText = attributedString
            textVerificationCode[i].isHidden = true
            xDistance += interval
            self.view.addSubview(textVerificationCode[i])
        }
    }
    
    func disableButton(_ button : UIButton) {
        button.backgroundColor = colorDisableButton
        button.isEnabled = false
    }
    
    func enableButton(_ button : UIButton) {
        button.backgroundColor = UIColor.faeAppRedColor()
        button.isEnabled = true
    }
    
    func loadButton() {
        buttonProceed = UIButton(frame: CGRect(x: 0, y: 456, width: screenWidth, height: 56))
        buttonProceed.setTitle("Proceed", for: UIControlState())
        buttonProceed.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        disableButton(buttonProceed)
        buttonProceed.addTarget(self, action: #selector(VerificationPhoneViewController.verfication), for: .touchUpInside)
        self.view.addSubview(buttonProceed)
        
        buttonResend = UIButton(frame: CGRect(x: 85, y: 345, width: 245, height: 65))
        buttonResend.setTitle("", for: UIControlState())
        buttonResend.backgroundColor = UIColor.clear
        buttonResend.addTarget(self, action: #selector(VerificationPhoneViewController.resendCode), for: .touchUpInside)
        self.view.addSubview(buttonResend)
    }
    
    func resendCode() {
        
        let user = FaeUser()
        user.whereKey("phone", value: phoneNumber)
        user.verifyPhoneNumber { (status, message) in
            if status / 100 != 2 {
                print("sent code successfully")
            }
        }
        
    }
    
    func verfication() {
        
        var checkFromBackEnd = true
        
        let user = FaeUser()
        user.whereKey("phone", value: phoneNumber)
        user.whereKey("code", value: TextFieldDummy.text!)
        user.verifyPhoneNumber { (status, message) in
            if status / 100 != 2 {
                checkFromBackEnd = false
            }
        }
        
        if(!checkFromBackEnd) {
            labelVerificationTitle.text = "Oops...That's not right/ncode. Please try again!"
            TextFieldDummy.text = ""
        } else {
            if let navController = self.navigationController {
                self.delegate.setupPhoneNumber(phoneNumber)
                navController.popViewController(animated: true)
            }
        }
    }
}
