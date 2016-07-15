//
//  PhoneConnectViewController.swift
//  faeBeta
//
//  Created by User on 6/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PhoneConnectViewController: UIViewController, UITextFieldDelegate, SetCountryCodeDelegate, SetupPhoneNumberDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    
    var phoneString = ""
    
    var defaultCode = "1"
    var defaultCountry = "United States"
    
    var linkTextLabel : UILabel!
    var imageDownArrow : UIImageView!
    var labelCountryCode : UILabel!
    var buttonCountrySet : UIButton!
    var labelConnectedPhone : UILabel!
    
    var textPhoneNumber : UITextField!
    var textViewHint : UILabel!
    
    var buttonLink : UIButton!
    
    var faeGray = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    let colorDisableButton = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    
    var tap : UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(PhoneConnectViewController.closeKeyBoard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationBarSetting()
        clearSubview()
        if checkIfHavePhoneConnected() {
            createItemWhenPhoneNotConnect()
            loadItemWhenPhoneNotConnected()
        } else {
            createItemWhenPhoneConnect()
            loadItemWhenPhoneConnected()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationBarSetting() {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "Phone"
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray]
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func loadTextField() {
        textPhoneNumber = UITextField(frame: CGRect(x: 0 + 20, y: 250, width: screenWidth - 40, height: 34))
        textPhoneNumber.textAlignment = .Center
        textPhoneNumber.font = UIFont(name: "Avenir Next", size: 25)
        textPhoneNumber.textColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        textPhoneNumber.placeholder = "Phone Number"
        textPhoneNumber.becomeFirstResponder()
        textPhoneNumber.keyboardType = .NumberPad
        textPhoneNumber.tintColor = colorFae
        textPhoneNumber.addTarget(self, action: #selector(PhoneConnectViewController.checkValidation), forControlEvents: .EditingChanged)
        self.view.addSubview(textPhoneNumber)
    }
    
    func disableButton(button : UIButton) {
        button.backgroundColor = colorDisableButton
        button.enabled = false
    }
    
    func enableButton(button : UIButton) {
        button.backgroundColor = colorFae
        button.enabled = true
    }
    
    func checkValidation() {
        if textPhoneNumber.text?.characters.count != 0 && phoneNumebrValidation() {
            enableButton(buttonLink)
        } else {
            disableButton(buttonLink)
        }
    }
    
    func closeKeyBoard() {
        view.endEditing(true)
    }
    
    func phoneNumebrValidation() -> Bool {
        return true
    }
    
    func buttonCountrySetDidClick() {
        print("clicked button for country set")
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("CountryCodePickerViewController")as! CountryCodePickerViewController
        vc.countryCodeDelegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func buttonLinkDidClick() {
        print("clicked Button for link")
        let user = FaeUser()
        user.whereKey("phone", value: textPhoneNumber.text!)
        user.updatePhoneNumber { (status, message) in
            if status / 100 == 2 {
                print("sent code")
            }
        }
        jumpToVerification()
    }
    
    func jumpToVerification(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("VerificationPhoneViewController")as! VerificationPhoneViewController
        vc.countryCode = defaultCode
        vc.phoneNumber = textPhoneNumber.text!
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkIfHavePhoneConnected() -> Bool {
        return phoneString.characters.count == 0
    }
    
    func buttonChangeDidClick() {
        clearSubview()
        createItemWhenPhoneNotConnect()
        loadItemWhenPhoneNotConnected()
    }
    
    func createItemWhenPhoneNotConnect() {
        loadTextField()
        linkTextLabel = UILabel(frame: CGRect(x: 105, y: 103, width: 204, height: 25))
        linkTextLabel.font = UIFont(name: "Avenir Next", size: 18)
        linkTextLabel.textColor = faeGray
        linkTextLabel.text = "Link your phone number"
        
        textViewHint = UILabel(frame: CGRect(x: 88, y: 343, width: 239, height: 54))
        textViewHint.textAlignment = .Center
        textViewHint.font = UIFont(name: "Avenir Next", size: 13)
        textViewHint.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        textViewHint.text = "Get convenient access to your Contacts,\nfind & invite your Friends, and add\nan extra wall of security to your account. "
        textViewHint.numberOfLines = 0
        
        labelCountryCode = UILabel(frame: CGRect(x: 20, y: 170, width: screenWidth - 40, height: 30))
        loadCountryAndCode()
        labelCountryCode.textColor = faeGray
        labelCountryCode.font = UIFont(name: "Avenir Next", size: 22)
        labelCountryCode.textAlignment = .Center
        
        
        
        buttonLink = UIButton(frame: CGRect(x: 127, y: 437, width: 160, height: 39))
        buttonLink.layer.cornerRadius = 7
        buttonLink.tintColor = UIColor.whiteColor()
        buttonLink.setTitle("Link", forState: .Normal)
        buttonLink.addTarget(self, action: #selector(PhoneConnectViewController.buttonLinkDidClick), forControlEvents: .TouchUpInside)
        disableButton(buttonLink)
        
        buttonCountrySet = UIButton(frame: CGRect(x: 40, y: 175, width: screenWidth - 80, height: 45))
        buttonCountrySet.setTitle("", forState: .Normal)
        buttonCountrySet.tintColor = UIColor.clearColor()
        buttonCountrySet.addTarget(self, action: #selector(PhoneConnectViewController.buttonCountrySetDidClick), forControlEvents: .TouchUpInside)
    }
    
    func createItemWhenPhoneConnect() {
        
        linkTextLabel = UILabel(frame: CGRect(x: 96, y: 103, width: 223, height: 25))
        linkTextLabel.font = UIFont(name: "Avenir Next", size: 18)
        linkTextLabel.textColor = faeGray
        let attributedString = NSMutableAttributedString(string: "Your Linked Phone Number")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.2), range: NSRange(location: 0, length: attributedString.length))
        
        linkTextLabel.attributedText = attributedString
        
        textViewHint = UILabel(frame: CGRect(x: 88, y: 343, width: 239, height: 54))
        textViewHint.textAlignment = .Center
        textViewHint.font = UIFont(name: "Avenir Next", size: 13)
        textViewHint.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        textViewHint.text = "Get convenient access to your Contacts,\nfind & invite your Friends, and add\nan extra wall of security to your account. "
        textViewHint.numberOfLines = 0
        
        labelCountryCode = UILabel(frame: CGRect(x: 20, y: 170, width: screenWidth - 40, height: 30))
        labelCountryCode.text = "\(defaultCountry) +\(defaultCode)"
        labelCountryCode.textColor = faeGray
        labelCountryCode.font = UIFont(name: "Avenir Next", size: 22)
        labelCountryCode.textAlignment = .Center
        
        buttonLink = UIButton(frame: CGRect(x: 127, y: 437, width: 160, height: 39))
        buttonLink.layer.cornerRadius = 7
        buttonLink.tintColor = UIColor.whiteColor()
        buttonLink.setTitle("change", forState: .Normal)
        buttonLink.addTarget(self, action: #selector(PhoneConnectViewController.buttonChangeDidClick), forControlEvents: .TouchUpInside)
        enableButton(buttonLink)
        
        labelConnectedPhone = UILabel(frame: CGRect(x: 20, y: 250, width: screenWidth - 40, height: 34))
        labelConnectedPhone.text = phoneString
        labelConnectedPhone.font = UIFont(name: "Avenir New", size: 25)
        labelConnectedPhone.textAlignment = .Center
        labelConnectedPhone.textColor = faeGray
    }
    
    func loadItemWhenPhoneNotConnected() {
        self.view.addSubview(linkTextLabel)
        self.view.addSubview(textViewHint)
        self.view.addSubview(buttonLink)
        self.view.addSubview(labelCountryCode)
        self.view.addSubview(buttonCountrySet)
    }
    
    func loadItemWhenPhoneConnected() {
        self.view.addSubview(linkTextLabel)
        self.view.addSubview(textViewHint)
        self.view.addSubview(buttonLink)
        self.view.addSubview(labelCountryCode)
        self.view.addSubview(labelConnectedPhone)
    }
    
    func clearSubview() {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    func setCountryCode(code: CountryCode) {
        defaultCode = code.cd
        defaultCountry = code.ct
        loadCountryAndCode()
    }
    
    func setupPhoneNumber(phone : String) {
        phoneString = phone
    }
    
    func loadCountryAndCode() {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "downArrow")
        let attachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        let countryAndCode = " \(defaultCountry) +\(defaultCode)"
        let countryString = NSMutableAttributedString(string: countryAndCode)
        attachmentString.appendAttributedString(countryString)
        labelCountryCode.attributedText = attachmentString
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

