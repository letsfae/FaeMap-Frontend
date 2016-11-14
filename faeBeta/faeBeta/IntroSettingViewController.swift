//
//  IntroSettingViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class IntroSettingViewController: UIViewController , UITextViewDelegate{

    let screenWidth = UIScreen.main.bounds.width
    let screenHeigh = UIScreen.main.bounds.height
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
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
    }
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func loadTitle() {
        labelTitle = UILabel(frame: CGRect(x: (screenWidth - 140) / 2, y: 99 - 64, width: 140, height: 27))
        labelTitle.text = "Short Intro"
        labelTitle.font = UIFont(name:"AvenirNext-Medium", size: 20)
        labelTitle.textAlignment = .center
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        self.view.addSubview(labelTitle)

        textInput = UITextView(frame: CGRect(x: (screenWidth - 244) / 2, y: 174 - 64, width: 244, height: 102))
        //textInput.textAlignment = .Center
        //textInput.text = "Write a Short Intro"
        textInput.font = UIFont(name: "AvenirNext-Regular", size: 25)
        textInput.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        textInput.tintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        textInput.delegate = self
        self.view.addSubview(textInput)
        labelPlaceholder = UILabel(frame: CGRect(x: -5, y: 10, width: 244, height: 34))
        labelPlaceholder.textAlignment = .center
        labelPlaceholder.text = "Write a Short Intro"
        labelPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 25)
        labelPlaceholder.textColor = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        self.textInput.addSubview(labelPlaceholder)

        buttonSave = UIButton(frame: CGRect(x: 0, y: screenHeight - 64 - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        buttonSave.center.x = screenWidth / 2
        buttonSave.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSave.setTitle("Save", for: UIControlState())
        buttonSave.layer.cornerRadius = 25
        buttonSave.titleLabel?.textColor = UIColor.white
        buttonSave.addTarget(self, action: #selector(NameSettingViewController.actionSave), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonSave)
        labelDesc = UILabel(frame: CGRect(x: 0, y: self.buttonSave.frame.origin.y - 16 - 18 , width: 242, height: 36))
        labelDesc.center.x = screenWidth / 2
        labelDesc.text = "30 Characters"
        labelDesc.textColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        labelDesc.textAlignment = .center
//        labelDesc.numberOfLines = 0
        self.view.addSubview(labelDesc)
    }
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        //textInput.addTarget(self, action: #selector(self.textfieldDidChange(_:)), forControlEvents:.EditingChanged )

    }
    func keyboardWillShow(_ notification:Notification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.buttonSave.frame.origin.y += (screenHeight - keyboardFrame.height) - self.buttonSave.frame.origin.y - 50 * screenHeightFactor - 14 - 64
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 16 - 18
            //self.supportButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.supportButton.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19

            //self.loginResultLabel.alpha = 0
        })
    }

    func keyboardWillHide(_ notification:Notification){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.buttonSave.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor - 64
            self.labelDesc.frame.origin.y = self.buttonSave.frame.origin.y - 16 - 18
            //self.supportButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            //self.loginResultLabel.alpha = 1
        })
    }
    func handleTap(){
        self.view.endEditing(true)
        if textInput.text.characters.count == 0 {
            labelPlaceholder.isHidden = false
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        let num : Int = 30 - count
        labelDesc.text =  String(num) + " Characters"
        if num > 0 {
            labelPlaceholder.isHidden = true
        }
    }
    func actionSave() {
        let user = FaeUser()
        if let str = textInput.text {
            user.whereKey("short_intro", value: str)
            user.updateNameCard { (status:Int, objects: Any?) in
                print (status)
                if status / 100 == 2 {
                    _ = self.navigationController?.popViewController(animated: true)
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
