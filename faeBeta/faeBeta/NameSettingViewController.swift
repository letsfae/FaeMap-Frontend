//
//  NameSettingViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameSettingViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    var labelTitle : UILabel!
    var textInput : UITextField!
    var buttonSave : UIButton!
    var labelDesc : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        setupNavigationBar()
        addObservers()
        // Do any additional setup after loading the view.
    }
    func loadTitle() {
        labelTitle = UILabel(frame: CGRectMake(0, 35, screenWidth, 27))
        labelTitle.center.x = screenWidth/2
        labelTitle.text = "Your Display Name"
        labelTitle.textAlignment = .Center
        labelTitle.font = UIFont(name:"AvenirNext-Medium", size: 25)
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.view.addSubview(labelTitle)

        textInput = UITextField(frame: CGRectMake((screenWidth - 270) / 2, 110, 270, 102))
        textInput.textAlignment = .Center
        textInput.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        textInput.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        textInput.font = UIFont(name: "AvenirNext-Regular", size: 25)
        textInput.placeholder = "Write a Display Name"
        self.view.addSubview(textInput)

        //buttonSave = UIButton(frame: CGRectMake((screenWidth - 300) / 2,screenHeigh - 336, 300, 50))
        buttonSave = UIButton(frame: CGRectMake(0, screenHeight - 64 - 30 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        buttonSave.center.x = screenWidth / 2
        buttonSave.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSave.setTitle("Save", forState: .Normal)
        buttonSave.layer.cornerRadius = 25
        buttonSave.titleLabel?.textColor = UIColor.whiteColor()
        buttonSave.titleLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 20)
        buttonSave.addTarget(self, action: #selector(NameSettingViewController.actionSave), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonSave)
        labelDesc = UILabel(frame: CGRectMake(0, buttonSave.frame.minY - 19 - 36, 242, 36))
        labelDesc.center.x = screenWidth / 2
        labelDesc.text = "Unlike your Username, a Nickname is just for show. You can change it anytime!"
        labelDesc.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDesc.textAlignment = .Center
        labelDesc.numberOfLines = 0
        labelDesc.textColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        self.view.addSubview(labelDesc)
    }
    func actionSave() {
        let user = FaeUser()
        if let str = textInput.text {
        user.whereKey("nick_name", value: str)
        user.updateNameCard { (status:Int, objects:AnyObject?) in
            print (status)
            print (objects)
            if status / 100 == 2 {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {// if it contain not letter or number, it will have error.

            }
        }
        }
        //navi back
//        self.navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.navigationBarHidden = false
    }
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        //textInput.addTarget(self, action: #selector(self.textfieldDidChange(_:)), forControlEvents:.EditingChanged )

    }
    func keyboardWillShow(notification:NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonSave.frame.origin.y += (screenHeight - keyboardFrame.height) - self.buttonSave.frame.origin.y - 50 * screenHeightFactor - 14 - 64
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 19 - 36
            //self.supportButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.supportButton.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19

            //self.loginResultLabel.alpha = 0
        })
    }

    func keyboardWillHide(notification:NSNotification){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonSave.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor - 64
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 19 - 36
            //self.supportButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            //self.loginResultLabel.alpha = 1
        })
    }
    func handleTap(){
        self.view.endEditing(true)
    }
    /*func textfieldDidChange(textfield: UITextField){
        if(usernameTextField.text!.characters.count > 0 && passwordTextField.text?.characters.count >= 8){
            loginButton.backgroundColor = UIColor.faeAppRedColor()
            loginButton.enabled = true
        }else{
            loginButton.backgroundColor = UIColor.faeAppDisabledRedColor()
            loginButton.enabled = false
        }
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
