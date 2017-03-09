//
//  LogInViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import RealmSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class LogInViewController: UIViewController {
    //MARK: - Interface
    
    fileprivate var iconImageView: UIImageView!
    fileprivate var supportButton: UIButton!
    fileprivate var loginButton: UIButton!
    fileprivate var loginResultLabel: UILabel!
    fileprivate var usernameTextField: FAETextField!
    fileprivate var passwordTextField: FAETextField!
    fileprivate var activityIndicator: UIActivityIndicatorView!

    // Mark: - View did/will ..
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate func setupInterface()
    {
        //icon
        iconImageView = UIImageView(image:UIImage(named: "faeWingIcon"))
        iconImageView.frame = CGRect(x: screenWidth/2-30, y: 70 * screenHeightFactor, width: 60 * screenHeightFactor, height: 60 * screenHeightFactor)
        self.view.addSubview(iconImageView)
        
        
        // username textField
        usernameTextField = FAETextField(frame: CGRect(x: 15, y: 174 * screenHeightFactor, width: screenWidth - 30, height: 34))
        usernameTextField.placeholder = "Username/Email"
        usernameTextField.adjustsFontSizeToFitWidth = true
        usernameTextField.keyboardType = .emailAddress
        self.view.addSubview(usernameTextField)
        
        // result label
        loginResultLabel = UILabel(frame:CGRect(x: 0,y: 0,width: screenWidth,height: 36))
        loginResultLabel.font = UIFont(name: "AvenirNext-Medium", size: 13)
        loginResultLabel.text = "Oops… Can’t find any Accounts\nwith this Username/Email!"
        loginResultLabel.textColor = UIColor.faeAppRedColor()
        loginResultLabel.numberOfLines = 2
        loginResultLabel.center = self.view.center
        loginResultLabel.textAlignment = .center
        loginResultLabel.isHidden = true
        
        self.view.addSubview(loginResultLabel)
        
        // password textField
        passwordTextField = FAETextField(frame: CGRect(x: 15, y: 243 * screenHeightFactor, width: screenWidth - 30, height: 34))
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        self.view.addSubview(passwordTextField)
        
        //support button
        supportButton = UIButton(frame: CGRect(x: (screenWidth - 150)/2, y: screenHeight - 50 * screenHeightFactor - 71 ,width: 150,height: 22))
        supportButton.center.x = screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 13)
        
        supportButton.setAttributedTitle(NSAttributedString(string: "Sign In Support", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), for: UIControlState())
        supportButton.contentHorizontalAlignment = .center
        supportButton.addTarget(self, action: #selector(LogInViewController.supportButtonTapped), for: .touchUpInside)
        self.view.insertSubview(supportButton, at: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        loginButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        loginButton.center.x = screenWidth / 2
        loginButton.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font! ]), for: UIControlState())
        loginButton.layer.cornerRadius = 25*screenHeightFactor
        loginButton.addTarget(self, action: #selector(LogInViewController.loginButtonTapped), for: .touchUpInside)
        loginButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        loginButton.isEnabled = false
        self.view.insertSubview(loginButton, at: 0)
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        usernameTextField.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for:.editingChanged )
        passwordTextField.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for:.editingChanged)

    }
    
    func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.faeAppRedColor()
        
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func loginButtonTapped()
    {
        activityIndicator.startAnimating()
        self.view.endEditing(true)
        self.loginResultLabel.isHidden = true

        let user = FaeUser()
        if usernameTextField.text!.range(of: "@") != nil {
            user.whereKey("email", value: usernameTextField.text!)
        }else{
            user.whereKey("user_name", value: usernameTextField.text!)
        }
        user.whereKey("password", value: passwordTextField.text!)
//        user.whereKey("user_name", value: "heheda")
        // for iphone: device_id is required and is_mobile should set to true
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status: Int?, message: Any?) in
            if status! / 100 == 2 {
                //success
                let realm = try! Realm()
                let userRealm = FaeUserRealm()
                userRealm.userId = Int(user_id)
                var isFirstTimeLogin = false
                let messageJSON = JSON(message!)
                if let _ = messageJSON["last_login_at"].string {
                    userRealm.firstUpdate = true
                } else {
                    userRealm.firstUpdate = false
                    isFirstTimeLogin = true
                    print("[loginUser] is first time login!")
                }
                try! realm.write {
                    realm.add(userRealm, update: true)
                }
                self.dismiss(animated: true, completion: {
                    if isFirstTimeLogin {
                        firebaseWelcome()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isFirstLogin"), object: nil)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "returnFromLoginSignup"), object: nil)
                })
            }
            else{
                let loginJSONInfo = JSON(message!)
                if let info = loginJSONInfo["message"].string {
                    if info.contains("such") || info.contains("non") {
                        self.setLoginResult("Oops… Can’t find any Accounts\nwith this Username/Email!")
                    }
                    else if info.contains("incorrect") {
                        self.setLoginResult("That’s not the Correct Password!\nPlease Check your Password!")
                    }
                    else {
                        self.setLoginResult("Internet Error!")
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }

    func setLoginResult(_ result:String){
        self.loginResultLabel.text = result
        self.loginResultLabel.isHidden = false
    }
    
    func supportButtonTapped()
    {
        let controller = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInSupportViewController") as! SignInSupportViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Navigation
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - keyboard 
    
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(_ notification:Notification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.loginButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.loginButton.frame.origin.y - 50 * screenHeightFactor - 14
            
            self.supportButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.supportButton.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19
            
            self.loginResultLabel.alpha = 0
        })
    }
    
    func keyboardWillHide(_ notification:Notification){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.loginButton.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.supportButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            self.loginResultLabel.alpha = 1
        })
    }
    // MARK: - helper
    func handleTap(){
        self.view.endEditing(true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: - textfield
    func textfieldDidChange(_ textfield: UITextField){
        if(usernameTextField.text!.characters.count > 0 && passwordTextField.text?.characters.count >= 8){
            loginButton.backgroundColor = UIColor.faeAppRedColor()
            loginButton.isEnabled = true
        }else{
            loginButton.backgroundColor = UIColor.faeAppDisabledRedColor()
            loginButton.isEnabled = false
        }
    }

}

extension LogInViewController :UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 16
    }
}
