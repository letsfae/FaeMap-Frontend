//
//  IntroSettingViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class IntroSettingViewController: UIViewController , UITextViewDelegate{

    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    var labelTitle : UILabel!
    var textInput : UITextView!
    var buttonSave : UIButton!
    var labelDesc : UILabel!
    var labelPlaceholder : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        setupNavigationBar()
        addObservers()
        // Do any additional setup after loading the view.
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
    func loadTitle() {
        labelTitle = UILabel(frame: CGRectMake((screenWidth - 140) / 2, 99 - 64, 140, 27))
        labelTitle.text = "Short Intro"
        labelTitle.font = UIFont(name:"AvenirNext-Medium", size: 20)
        labelTitle.textAlignment = .Center
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.view.addSubview(labelTitle)

        textInput = UITextView(frame: CGRectMake((screenWidth - 244) / 2, 174 - 64, 244, 102))
        //textInput.textAlignment = .Center
        //textInput.text = "Write a Short Intro"
        textInput.font = UIFont(name: "AvenirNext-Regular", size: 25)
        textInput.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        textInput.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        textInput.delegate = self
        self.view.addSubview(textInput)
        labelPlaceholder = UILabel(frame: CGRectMake(-5, 10, 244, 34))
        labelPlaceholder.textAlignment = .Center
        labelPlaceholder.text = "Write a Short Intro"
        labelPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 25)
        labelPlaceholder.textColor = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        self.textInput.addSubview(labelPlaceholder)

        buttonSave = UIButton(frame: CGRectMake(0, screenHeight - 64 - 30 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        buttonSave.center.x = screenWidth / 2
        buttonSave.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSave.setTitle("Save", forState: .Normal)
        buttonSave.layer.cornerRadius = 25
        buttonSave.titleLabel?.textColor = UIColor.whiteColor()
        buttonSave.addTarget(self, action: #selector(NameSettingViewController.actionSave), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonSave)
        labelDesc = UILabel(frame: CGRectMake(0, self.buttonSave.frame.origin.y - 16 - 18 , 242, 36))
        labelDesc.center.x = screenWidth / 2
        labelDesc.text = "30 Characters"
        labelDesc.textColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        labelDesc.textAlignment = .Center
//        labelDesc.numberOfLines = 0
        self.view.addSubview(labelDesc)
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
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 16 - 18
            //self.supportButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.supportButton.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19

            //self.loginResultLabel.alpha = 0
        })
    }

    func keyboardWillHide(notification:NSNotification){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.buttonSave.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor - 64
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 16 - 18
            //self.supportButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            //self.loginResultLabel.alpha = 1
        })
    }
    func handleTap(){
        self.view.endEditing(true)
        if textInput.text.characters.count == 0 {
            labelPlaceholder.hidden = false
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    func textViewDidChange(textView: UITextView) {
        let count = textView.text.characters.count
        let num : Int = 30 - count
        labelDesc.text =  String(num) + " Characters"
        if num > 0 {
            labelPlaceholder.hidden = true
        }
    }
    func actionSave() {
        let user = FaeUser()
        if let str = textInput.text {
            user.whereKey("short_intro", value: str)
            user.updateNameCard { (status:Int, objects:AnyObject?) in
                print (status)
                if status / 100 == 2 {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
