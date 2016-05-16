//
//  RegisterProfileViewController.swift
//  faeBeta
//  Written by Yue Shen
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    //6 plus 414 736
    //6      375 667
    //5      320 568
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    let colorUnactive = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
    
    var uiviewDatePicker: UIView!
    
    var buttonProfileIcon: UIButton!
    var imageFirstName: UIImageView!
    var imageLastName: UIImageView!
    var imageBirthday: UIImageView!
    var imageFirstLine: UIImageView!
    
    var textFieldFirstName: UITextField!
    var textFieldLastName: UITextField!
    var textFieldBirthday: UITextField!
    
    var buttonCamera: UIButton!
    var buttonFemaleIcon: UIButton!
    var buttonMaleIcon: UIButton!
    var buttonFinish: UIButton!
    var buttonDatePickerDone: UIButton!
    var buttonBirthdayMask: UIButton!
    var maleSelected = false
    var femaleSelected = false
    
    var lineFirstName: UIView!
    var lineLastName: UIView!
    var lineBirthday: UIView!
    
    var labelTitle: UILabel!
    var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadTextFiledView()
        loadButton()
        loadLine()
        loadLabel()
        loadDatePicker()
        uiviewDatePicker.hidden = true
        textFieldBirthday.text = ""
        //        self.view.backgroundColor = UIColor.redColor()
    }
    
    func loadImageView() {
        
        let firstNameWidth = screenHeight*0.029
        let firstNameHeight = screenHeight*0.037
        imageFirstName = UIImageView(frame: CGRectMake(screenHeight*0.065, screenHeight*0.418, firstNameWidth, firstNameHeight))
        imageFirstName.image = UIImage(named: "name_unactive")
        self.view.addSubview(imageFirstName)
        
        let lastNameWidth = screenHeight*0.029
        let lastNameHeight = screenHeight*0.0367
        imageLastName = UIImageView(frame: CGRectMake(screenHeight*0.065, screenHeight*0.505, lastNameWidth, lastNameHeight))
        imageLastName.image = UIImage(named: "name_unactive")
        self.view.addSubview(imageLastName)
        
        let birthWidth = screenHeight*0.031
        let birthHeight = screenHeight*0.031
        imageBirthday = UIImageView(frame: CGRectMake(screenHeight*0.064, screenHeight*0.595, birthWidth, birthHeight))
        imageBirthday.image = UIImage(named: "cake_unactive")
        self.view.addSubview(imageBirthday)
        
    }
    
    func loadTextFiledView() {
        textFieldFirstName = UITextField(frame: CGRectMake(screenHeight*0.120, screenHeight*0.425, screenHeight*0.318, screenHeight*0.034))
        let placeholderFirstName = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldFirstName.delegate = self
        textFieldFirstName.attributedPlaceholder = placeholderFirstName
        textFieldFirstName.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textFieldFirstName)
        textFieldFirstName.autocorrectionType = UITextAutocorrectionType.No
        
        textFieldLastName = UITextField(frame: CGRectMake(screenHeight*0.120, screenHeight*0.512, screenHeight*0.318, screenHeight*0.034))
        let placeholderLastName = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldLastName.delegate = self
        textFieldLastName.attributedPlaceholder = placeholderLastName
        textFieldLastName.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textFieldLastName)
        textFieldLastName.autocorrectionType = UITextAutocorrectionType.No
        
        textFieldBirthday = UITextField(frame: CGRectMake(screenHeight*0.120, screenHeight*0.600, screenHeight*0.318, screenHeight*0.034))
        let placeholderBirthday = NSAttributedString(string: "Birthday", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldBirthday.delegate = self
        textFieldBirthday.attributedPlaceholder = placeholderBirthday
        textFieldBirthday.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textFieldBirthday)
        textFieldBirthday.autocorrectionType = UITextAutocorrectionType.No
    }
    
    func loadButton(){
        let profileIcon = screenHeight * 0.189
        buttonProfileIcon = UIButton(frame: CGRectMake(screenWidth/2-profileIcon/2, screenHeight*0.145, profileIcon, profileIcon))
        buttonProfileIcon.setImage(UIImage(named: "fae_profile"), forState: .Normal)
        self.view.addSubview(buttonProfileIcon)
        buttonProfileIcon.addTarget(self, action: #selector(RegisterProfileViewController.actionProfileIcon(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonProfileIcon.layer.cornerRadius = buttonProfileIcon.frame.width/2-3
        buttonProfileIcon.clipsToBounds = true
        buttonProfileIcon.layer.borderWidth = 6
        buttonProfileIcon.layer.borderColor = colorFae.CGColor
        
        let cameraWidth = screenHeight*0.043
        let cameraHeight = screenHeight*0.035
        buttonCamera = UIButton(frame: CGRectMake(screenWidth/2-cameraWidth/2, screenHeight*0.359, cameraWidth, cameraHeight))
        buttonCamera.setImage(UIImage(named: "camera_profile"), forState: .Normal)
        self.view.addSubview(buttonCamera)
        buttonCamera.addTarget(self, action: #selector(RegisterProfileViewController.actionCamera(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let maleIconWidth = screenHeight*0.086
        let maleIconHeight = screenHeight*0.080
        buttonMaleIcon = UIButton(frame: CGRectMake(screenHeight*0.133, screenHeight*0.711, maleIconWidth, maleIconHeight))
        buttonMaleIcon.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        self.view.addSubview(buttonMaleIcon)
        buttonMaleIcon.addTarget(self, action: #selector(RegisterProfileViewController.actionMale(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let femaleIconWidth = screenHeight*0.072
        let femaleIconHeight = screenHeight*0.080
        buttonFemaleIcon = UIButton(frame: CGRectMake(screenHeight*0.359, screenHeight*0.711, femaleIconWidth, femaleIconHeight))
        buttonFemaleIcon.setImage(UIImage(named: "female_unselected"), forState: .Normal)
        self.view.addSubview(buttonFemaleIcon)
        buttonFemaleIcon.addTarget(self, action: #selector(RegisterProfileViewController.actionFemale(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonFinishWidth = screenHeight*0.448
        let buttonFinishHeight = screenHeight*0.068
        buttonFinish = UIButton(frame:CGRectMake(screenWidth/2-buttonFinishWidth/2, screenHeight*0.851, buttonFinishWidth, buttonFinishHeight))
        buttonFinish.layer.cornerRadius = 7
        buttonFinish.setTitle("Finish!", forState: .Normal)
        buttonFinish.setTitle("Finish!", forState: .Highlighted)
        buttonFinish.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonFinish.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonFinish.backgroundColor = colorFae
        buttonFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        self.view.addSubview(buttonFinish)
        
        let buttonBirthdayMaskBounds = textFieldBirthday.frame
        buttonBirthdayMask = UIButton(frame: buttonBirthdayMaskBounds)
        self.view.addSubview(buttonBirthdayMask)
        buttonBirthdayMask.addTarget(self, action: #selector(RegisterProfileViewController.actionBirthdayMask(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func actionCamera(sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func actionProfileIcon(sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        buttonProfileIcon.setImage(image, forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionBirthdayMask(sender: UIButton!) {
        imageBirthday.image = UIImage(named: "cake_active")
        lineBirthday.layer.borderColor = colorFae.CGColor
        if (textFieldFirstName.text == "") {
            imageFirstName.image = UIImage(named: "name_unactive")
            lineFirstName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageFirstName.image = UIImage(named: "name_active")
            lineFirstName.layer.borderColor = colorFae.CGColor
        }
        if (textFieldLastName.text == "") {
            imageLastName.image = UIImage(named: "name_unactive")
            lineLastName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageLastName.image = UIImage(named: "name_active")
            lineLastName.layer.borderColor = colorFae.CGColor
        }
        uiviewDatePicker.center.y = screenHeight+screenHeight*0.326/2
        uiviewDatePicker.hidden = false
        view.endEditing(true)
        datePickerAnimation()
    }
    
    func actionMale(sender: UIButton!) {
        if maleSelected {
            buttonMaleIcon.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        }
        else {
            buttonMaleIcon.setImage(UIImage(named: "male_selected"), forState: .Normal)
        }
        buttonFemaleIcon.setImage(UIImage(named: "female_unselected"), forState: .Normal)
        maleSelected = !maleSelected
        femaleSelected = false
    }
    
    func actionFemale(sender: UIButton!) {
        if femaleSelected {
            buttonFemaleIcon.setImage(UIImage(named: "female_unselected"), forState: .Normal)
        }
        else {
            buttonFemaleIcon.setImage(UIImage(named: "female_selected"), forState: .Normal)
        }
        buttonMaleIcon.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        femaleSelected = !femaleSelected
        maleSelected = false
    }
    
    func loadLine() {
        lineFirstName = UIView(frame: CGRectMake(screenHeight*0.057, screenHeight*0.465, screenHeight*0.448, 2))
        lineFirstName.layer.borderWidth = 1.0
        lineFirstName.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineFirstName)
        
        lineLastName = UIView(frame: CGRectMake(screenHeight*0.057, screenHeight*0.552, screenHeight*0.448, 2))
        lineLastName.layer.borderWidth = 1.0
        lineLastName.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineLastName)
        
        lineBirthday = UIView(frame: CGRectMake(screenHeight*0.057, screenHeight*0.639, screenHeight*0.448, 2))
        lineBirthday.layer.borderWidth = 1.0
        lineBirthday.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineBirthday)
    }
    
    func loadLabel() {
        let titleWidth = screenHeight*0.38
        let titleHeight = screenHeight*0.046
        labelTitle = UILabel(frame: CGRectMake(screenWidth/2-titleWidth/2, screenHeight*0.069, titleWidth, titleHeight))
        labelTitle.text = "A little bit about you..."
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 25)
        labelTitle.textColor = colorFae
        labelTitle.textAlignment = .Center
        self.view.addSubview(labelTitle)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == textFieldFirstName {
            imageFirstName.image = UIImage(named: "name_active")
            lineFirstName.layer.borderColor = colorFae.CGColor
            if (textFieldLastName.text == "") {
                imageLastName.image = UIImage(named: "name_unactive")
                lineLastName.layer.borderColor = colorUnactive.CGColor
            }
            else {
                imageLastName.image = UIImage(named: "name_active")
                lineLastName.layer.borderColor = colorFae.CGColor
            }
            if (textFieldBirthday.text == "") {
                imageBirthday.image = UIImage(named: "cake_unactive")
                lineBirthday.layer.borderColor = colorUnactive.CGColor
            }
            else {
                imageBirthday.image = UIImage(named: "cake_active")
                lineBirthday.layer.borderColor = colorFae.CGColor
            }
            uiviewDatePicker.hidden = true
        }
        if textField == textFieldLastName {
            imageLastName.image = UIImage(named: "name_active")
            lineLastName.layer.borderColor = colorFae.CGColor
            if (textFieldFirstName.text == "") {
                imageFirstName.image = UIImage(named: "name_unactive")
                lineFirstName.layer.borderColor = colorUnactive.CGColor
            }
            else {
                imageFirstName.image = UIImage(named: "name_active")
                lineFirstName.layer.borderColor = colorFae.CGColor
            }
            if (textFieldBirthday.text == "") {
                imageBirthday.image = UIImage(named: "cake_unactive")
                lineBirthday.layer.borderColor = colorUnactive.CGColor
            }
            else {
                imageBirthday.image = UIImage(named: "cake_active")
                lineBirthday.layer.borderColor = colorFae.CGColor
            }
            uiviewDatePicker.hidden = true
        }
    }
    
    func loadDatePicker() {
        uiviewDatePicker = UIView(frame: CGRectMake(0, screenHeight*0.674, screenWidth, screenHeight*0.326))
        self.view.addSubview(uiviewDatePicker)
        
        datePicker = UIDatePicker(frame: CGRectMake(0, screenHeight*0.034, screenWidth, screenHeight*0.293))
        datePicker.timeZone = NSTimeZone.localTimeZone()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.backgroundColor = UIColor.whiteColor()
        self.uiviewDatePicker.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(RegisterProfileViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        handleDatePicker(datePicker)
        
        buttonDatePickerDone = UIButton(frame:CGRectMake(screenWidth*0.85, screenHeight*0.011, screenHeight*0.07, screenHeight*0.034))
        buttonDatePickerDone.setTitle("Done", forState: .Normal)
        buttonDatePickerDone.setTitle("Done", forState: .Highlighted)
        buttonDatePickerDone.setTitleColor(colorFae, forState: .Normal)
        buttonDatePickerDone.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonDatePickerDone.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18.0)
        self.uiviewDatePicker.addSubview(buttonDatePickerDone)
        buttonDatePickerDone.addTarget(self, action: #selector(RegisterProfileViewController.actionDone(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        textFieldBirthday.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func actionDone(sender: UIButton!) {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.uiviewDatePicker.center.y = self.screenHeight+self.screenHeight*0.326/2
        }), completion: nil)
    }
    
    func datePickerAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.uiviewDatePicker.center.y = self.screenHeight-self.screenHeight*0.326/2
        }), completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        uiviewDatePicker.hidden = true
        view.endEditing(true)
        if (textFieldFirstName.text == "") {
            imageFirstName.image = UIImage(named: "name_unactive")
            lineFirstName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageFirstName.image = UIImage(named: "name_active")
            lineFirstName.layer.borderColor = colorFae.CGColor
        }
        if (textFieldLastName.text == "") {
            imageLastName.image = UIImage(named: "name_unactive")
            lineLastName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageLastName.image = UIImage(named: "name_active")
            lineLastName.layer.borderColor = colorFae.CGColor
        }
        if (textFieldBirthday.text == "") {
            imageBirthday.image = UIImage(named: "cake_unactive")
            lineBirthday.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageBirthday.image = UIImage(named: "name_active")
            lineBirthday.layer.borderColor = colorFae.CGColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
