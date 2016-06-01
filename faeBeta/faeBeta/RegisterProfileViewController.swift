//
//  RegisterProfileViewController.swift
//  faeBeta
//  Written by Yue Shen
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var emailFromPrevious : String!
    var passwordFromPrevious : String!
    
    var fontSize_11: CGFloat!
    var fontSize_18: CGFloat!
    var fontSize_20: CGFloat!
    var fontSize_25: CGFloat!
    
    //6 plus 414 736
    //6      375 667
    //5      320 568
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    let colorUnactive = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
    
    var uiviewDatePicker: UIView!
    var uiviewIneligibleTerms: UIView!
    
    var imageFirstName: UIImageView!
    var imageLastName: UIImageView!
    var imageBirthday: UIImageView!
    var imageFirstLine: UIImageView!
    var imageBirthdayArrow: UIImageView!
    var imageBirthdayOkay: UIImageView!
    var imageBirthdayIneligible: UIImageView!
    
    var textFieldFirstName: UITextField!
    var textFieldLastName: UITextField!
    var textFieldBirthday: UITextField!
    
    var buttonProfileIcon: UIButton!
    var buttonCamera: UIButton!
    var buttonFemaleIcon: UIButton!
    var buttonMaleIcon: UIButton!
    var buttonFinish: UIButton!
    var buttonDatePickerDone: UIButton!
    var buttonBirthdayMask: UIButton!
    var buttonTerms: UIButton!
    
    var lineFirstName: UIView!
    var lineLastName: UIView!
    var lineBirthday: UIView!
    
    var labelTitle: UILabel!
    var datePicker: UIDatePicker!
    
    var tableImagePicker: UITableView!
    
    var labelTerms: UILabel!
    
    var maleSelected = false
    var femaleSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        //        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        self.navigationController?.navigationBar.topItem?.title = ""
//        print(self.emailFromPrevious)
//        print(self.passwordFromPrevious)
        fontSize_11 = screenWidth*0.02657
        fontSize_18 = screenWidth*0.04348
        fontSize_20 = screenWidth*0.04831
        fontSize_25 = screenWidth*0.06039
        
        loadImageView()
        loadTextFiledView()
        loadButton()
        loadLine()
        loadLabel()
        loadDatePicker()
        loadTable()
        loadTerms()
        
        textFieldBirthday.text = ""
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true)
        datePickerHideAnimation()
        tableImagePickerHideAnimation()
        firstNameValidation()
        lastNameValidation()
        birthdayValidation()
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: nil)
        textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: nil)
    }
    
    // Mark: -- functions to load various views
    
    func loadTerms() {
        let termsX = screenHeight*0.065
        let termsY = screenHeight*0.632
        let termsWidth = screenHeight*0.45
        let termsHeight = screenHeight*0.07
        
        labelTerms = UILabel(frame: CGRectMake(termsX, termsY, termsWidth, termsHeight))
        labelTerms.numberOfLines = 2
        
        let string = "Oops, you’re under the eligible age for full version of Fae, some contents will be filtered. Please check our Terms for more info." as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        
        let firstAttributes = [NSFontAttributeName:UIFont(name: "AvenirNext-Regular", size: fontSize_11)!]
        let secondAttributes = [NSFontAttributeName:UIFont(name: "AvenirNext-Bold", size: fontSize_11)!]
        let thirdAttributes = [NSFontAttributeName:UIFont(name: "AvenirNext-Regular", size: fontSize_11)!]
        
        attributedString.addAttributes(firstAttributes, range: string.rangeOfString("Oops, you’re under the eligible age for full version of Fae, some contents will be filtered. Please check our "))
        attributedString.addAttributes(secondAttributes, range: string.rangeOfString("Terms"))
        attributedString.addAttributes(thirdAttributes, range: string.rangeOfString(" for more info."))
        
        labelTerms.attributedText = attributedString
        
        labelTerms.textColor = colorFae
        self.view.addSubview(labelTerms)
        
        //        buttonTerms = UIButton(frame: labelTerms.frame)
        //        self.labelTerms.addSubview(buttonTerms)
        //        buttonTerms.addTarget(self, action: #selector(RegisterProfileViewController.actionTerms(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        labelTerms.hidden = true
    }
    
    func loadImageView() {
        
        let firstNameWidth = screenHeight*0.029
        let firstNameHeight = screenHeight*0.037
        let textFieldImageX = screenHeight*0.065
        
        imageFirstName = UIImageView(frame: CGRectMake(textFieldImageX, screenHeight*0.418, firstNameWidth, firstNameHeight))
        imageFirstName.image = UIImage(named: "name_unactive")
        self.view.addSubview(imageFirstName)
        
        imageLastName = UIImageView(frame: CGRectMake(textFieldImageX, screenHeight*0.505, firstNameWidth, firstNameHeight))
        imageLastName.image = UIImage(named: "name_unactive")
        self.view.addSubview(imageLastName)
        
        let birthWidth = screenHeight*0.031
        imageBirthday = UIImageView(frame: CGRectMake(textFieldImageX, screenHeight*0.597, birthWidth, birthWidth))
        imageBirthday.image = UIImage(named: "cake_unactive")
        self.view.addSubview(imageBirthday)
        
        let imageBirthdayArrowX = screenHeight*0.486
        let imageBirthdayArrowY = screenHeight*0.606
        let imageBirthdayArrowWidth = screenHeight*0.015
        let imageBirthdayArrowHeight = screenHeight*0.026
        imageBirthdayArrow = UIImageView(frame: CGRectMake(imageBirthdayArrowX, imageBirthdayArrowY, imageBirthdayArrowWidth, imageBirthdayArrowHeight))
        imageBirthdayArrow.image = UIImage(named: "birthday_arrow_unactive")
        self.view.addSubview(imageBirthdayArrow)
        
        imageBirthdayOkay = UIImageView(frame: CGRectMake(screenHeight*0.48, imageBirthdayArrowY, screenHeight*0.023, screenHeight*0.02))
        imageBirthdayOkay.image = UIImage(named: "birthday_okay")
        self.view.addSubview(imageBirthdayOkay)
        imageBirthdayOkay.hidden = true
        
        imageBirthdayIneligible = UIImageView(frame: CGRectMake(screenHeight*0.488, screenHeight*0.603, screenHeight*0.0086, screenHeight*0.026))
        imageBirthdayIneligible.image = UIImage(named: "birthday_ineligible")
        self.view.addSubview(imageBirthdayIneligible)
        imageBirthdayIneligible.hidden = true
    }
    
    func loadTextFiledView() {
        let textFieldX = screenHeight*0.120
        let textFieldWidth = screenHeight*0.318
        let textFieldHeight = screenHeight*0.034
        
        textFieldFirstName = UITextField(frame: CGRectMake(textFieldX, screenHeight*0.425, textFieldWidth, textFieldHeight))
        let placeholderFirstName = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldFirstName.delegate = self
        textFieldFirstName.attributedPlaceholder = placeholderFirstName
        textFieldFirstName.font = UIFont(name: "AvenirNext-Regular", size: fontSize_18)
        textFieldFirstName.textColor = colorFae
        textFieldFirstName.tintColor = colorFae
        self.view.addSubview(textFieldFirstName)
        textFieldFirstName.autocorrectionType = UITextAutocorrectionType.No
        
        textFieldLastName = UITextField(frame: CGRectMake(textFieldX, screenHeight*0.512, textFieldWidth, textFieldHeight))
        let placeholderLastName = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldLastName.delegate = self
        textFieldLastName.attributedPlaceholder = placeholderLastName
        textFieldLastName.font = UIFont(name: "AvenirNext-Regular", size: fontSize_18)
        textFieldLastName.textColor = colorFae
        textFieldLastName.tintColor = colorFae
        self.view.addSubview(textFieldLastName)
        textFieldLastName.autocorrectionType = UITextAutocorrectionType.No
        
        textFieldBirthday = UITextField(frame: CGRectMake(textFieldX, screenHeight*0.600, textFieldWidth, textFieldHeight))
        let placeholderBirthday = NSAttributedString(string: "Birthday", attributes: [NSForegroundColorAttributeName: colorUnactive])
        textFieldBirthday.delegate = self
        textFieldBirthday.attributedPlaceholder = placeholderBirthday
        textFieldBirthday.font = UIFont(name: "AvenirNext-Regular", size: fontSize_18)
        textFieldBirthday.textColor = colorFae
        textFieldBirthday.tintColor = colorFae
        self.view.addSubview(textFieldBirthday)
        textFieldBirthday.autocorrectionType = UITextAutocorrectionType.No
    }
    
    func loadButton(){
        let profileIcon = screenHeight * 0.189
        buttonProfileIcon = UIButton(frame: CGRectMake(screenWidth/2-profileIcon/2, screenHeight*0.145, profileIcon, profileIcon))
        buttonProfileIcon.setImage(UIImage(named: "fae_profile"), forState: .Normal)
        self.view.addSubview(buttonProfileIcon)
        buttonProfileIcon.addTarget(self, action: #selector(RegisterProfileViewController.actionProfileIcon(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonProfileIcon.layer.borderWidth = 5
        buttonProfileIcon.layer.masksToBounds = false
        buttonProfileIcon.layer.borderColor = colorFae.CGColor
        buttonProfileIcon.layer.cornerRadius = buttonProfileIcon.frame.height/2
        buttonProfileIcon.clipsToBounds = true
        
        let cameraWidth = screenHeight*0.043
        let cameraHeight = screenHeight*0.035
        buttonCamera = UIButton(frame: CGRectMake(screenWidth/2-cameraWidth/2, screenHeight*0.359, cameraWidth, cameraHeight))
        buttonCamera.setImage(UIImage(named: "camera_profile"), forState: .Normal)
        self.view.addSubview(buttonCamera)
        buttonCamera.addTarget(self, action: #selector(RegisterProfileViewController.actionCamera(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let genderIconY = screenHeight*0.711
        let maleIconWidth = screenHeight*0.086
        let maleIconHeight = screenHeight*0.080
        buttonMaleIcon = UIButton(frame: CGRectMake(screenHeight*0.133, genderIconY, maleIconWidth, maleIconHeight))
        buttonMaleIcon.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        self.view.addSubview(buttonMaleIcon)
        buttonMaleIcon.addTarget(self, action: #selector(RegisterProfileViewController.actionMale(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let femaleIconWidth = screenHeight*0.072
        let femaleIconHeight = maleIconHeight
        buttonFemaleIcon = UIButton(frame: CGRectMake(screenHeight*0.359, genderIconY, femaleIconWidth, femaleIconHeight))
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
        buttonFinish.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: fontSize_20)
        buttonFinish.addTarget(self, action: #selector(RegisterProfileViewController.actionFinish), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonFinish)
        
        let buttonBirthdayMaskBounds = textFieldBirthday.frame
        buttonBirthdayMask = UIButton(frame: buttonBirthdayMaskBounds)
        self.view.addSubview(buttonBirthdayMask)
        buttonBirthdayMask.addTarget(self, action: #selector(RegisterProfileViewController.actionBirthdayMask(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Mark: -- load lines under textfields
    
    func loadLine() {
        let lineX = screenHeight*0.057
        let lineWidth = screenHeight*0.448
        
        lineFirstName = UIView(frame: CGRectMake(lineX, screenHeight*0.465, lineWidth, 2))
        lineFirstName.layer.borderWidth = 1.0
        lineFirstName.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineFirstName)
        
        lineLastName = UIView(frame: CGRectMake(lineX, screenHeight*0.552, lineWidth, 2))
        lineLastName.layer.borderWidth = 1.0
        lineLastName.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineLastName)
        
        lineBirthday = UIView(frame: CGRectMake(lineX, screenHeight*0.639, lineWidth, 2))
        lineBirthday.layer.borderWidth = 1.0
        lineBirthday.layer.borderColor = colorUnactive.CGColor
        self.view.addSubview(lineBirthday)
    }
    
    func loadLabel() {
        let titleWidth = screenHeight*0.38
        let titleHeight = screenHeight*0.046
        labelTitle = UILabel(frame: CGRectMake(screenWidth/2-titleWidth/2, screenHeight*0.069, titleWidth, titleHeight))
        labelTitle.text = "A little bit about you..."
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: fontSize_25)
        labelTitle.textColor = colorFae
        labelTitle.textAlignment = .Center
        self.view.addSubview(labelTitle)
    }
    
    func loadTable() {
        let tableImagePickerHeight = screenHeight*0.2
        tableImagePicker = UITableView(frame: CGRectMake(0, screenHeight-tableImagePickerHeight, screenWidth, tableImagePickerHeight))
        tableImagePicker.delegate = self
        tableImagePicker.dataSource = self
        tableImagePicker.registerClass(ImagePickerCell.self, forCellReuseIdentifier: "imagePickerCell")
        tableImagePicker.scrollEnabled = false
        tableImagePicker.layer.masksToBounds = true
        self.view.addSubview(tableImagePicker)
        tableImagePicker.center.y = self.screenHeight+self.tableImagePicker.frame.height/2
        tableImagePicker.separatorInset = UIEdgeInsetsZero
        tableImagePicker.layoutMargins = UIEdgeInsetsZero
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
        
        buttonDatePickerDone = UIButton(frame:CGRectMake(screenWidth*0.85, screenHeight*0.017, screenHeight*0.07, screenHeight*0.034))
        buttonDatePickerDone.setTitle("Done", forState: .Normal)
        buttonDatePickerDone.setTitle("Done", forState: .Highlighted)
        buttonDatePickerDone.setTitleColor(colorFae, forState: .Normal)
        buttonDatePickerDone.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        buttonDatePickerDone.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: fontSize_18)
        self.uiviewDatePicker.addSubview(buttonDatePickerDone)
        buttonDatePickerDone.addTarget(self, action: #selector(RegisterProfileViewController.actionDone(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        uiviewDatePicker.center.y = self.screenHeight+self.uiviewDatePicker.frame.height/2
    }
    
    // Mark: -- handle date picker value into text field
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        sender.maximumDate = NSDate()
        textFieldBirthday.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func isEligibel(startDate: NSDate, endDate: NSDate) -> Bool {
        
        let gregorian = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)
        let components = gregorian?.components(NSCalendarUnit.Day, fromDate: startDate, toDate: endDate, options: .MatchFirst)
        
        let day = components?.day
        
        if day >= 6573 {
            return true
        } else {
            return false
        }
    }
    
    // Mark: -- image picker controller
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        buttonProfileIcon.setImage(image, forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == textFieldFirstName {
            imageFirstName.image = UIImage(named: "name_active")
            lineFirstName.layer.borderColor = colorFae.CGColor
            lastNameValidation()
            birthdayValidation()
            textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes:[NSForegroundColorAttributeName: colorFae])
        }
        else {
            textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: nil)
        }
        if textField == textFieldLastName {
            imageLastName.image = UIImage(named: "name_active")
            lineLastName.layer.borderColor = colorFae.CGColor
            firstNameValidation()
            birthdayValidation()
            textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes:[NSForegroundColorAttributeName: colorFae])
        }
        else {
            textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: nil)
        }
        datePickerHideAnimation()
    }
    
    // validation to check if text fields are empty or not
    
    func firstNameValidation() {
        if (textFieldFirstName.text == "") {
            imageFirstName.image = UIImage(named: "name_unactive")
            lineFirstName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageFirstName.image = UIImage(named: "name_active")
            lineFirstName.layer.borderColor = colorFae.CGColor
        }
    }
    func lastNameValidation() {
        if (textFieldLastName.text == "") {
            imageLastName.image = UIImage(named: "name_unactive")
            lineLastName.layer.borderColor = colorUnactive.CGColor
        }
        else {
            imageLastName.image = UIImage(named: "name_active")
            lineLastName.layer.borderColor = colorFae.CGColor
        }
    }
    func birthdayValidation() {
        if (textFieldBirthday.text == "" || textFieldBirthday.text == "Birthday") {
            textFieldBirthday.text = ""
            imageBirthday.image = UIImage(named: "cake_unactive")
            imageBirthdayArrow.image = UIImage(named: "birthday_arrow_unactive")
            lineBirthday.layer.borderColor = colorUnactive.CGColor
            imageBirthdayOkay.hidden = true
            imageBirthdayArrow.hidden = false
            imageBirthdayIneligible.hidden = true
            return
        }
        else {
            imageBirthday.image = UIImage(named: "cake_active")
            lineBirthday.layer.borderColor = colorFae.CGColor
            imageBirthdayOkay.hidden = true
            imageBirthdayArrow.hidden = false
            imageBirthdayIneligible.hidden = true
        }
        if isEligibel(datePicker.date, endDate: NSDate()) {
            imageBirthdayOkay.hidden = false
            imageBirthdayArrow.hidden = true
            imageBirthdayIneligible.hidden = true
            labelTerms.hidden = true
        }
        else {
            imageBirthdayOkay.hidden = true
            imageBirthdayArrow.hidden = true
            imageBirthdayIneligible.hidden = false
            labelTerms.hidden = false
        }
    }
    
    // Mark: -- actions of buttons
    
    //    func actionTerms(sender: UIButton!) {
    //        print("Terms and Policy")
    //    }
    
    func actionCamera(sender: UIButton!) {
        tableImagePickerShowAnimation()
        datePickerHideAnimation()
        firstNameValidation()
        lastNameValidation()
        birthdayValidation()
        view.endEditing(true)
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: nil)
        textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: nil)
    }
    
    func actionProfileIcon(sender: UIButton!) {
        actionCamera(buttonCamera)
    }
    
    func actionBirthdayMask(sender: UIButton!) {
        imageBirthday.image = UIImage(named: "cake_active")
        lineBirthday.layer.borderColor = colorFae.CGColor
        firstNameValidation()
        lastNameValidation()
        uiviewDatePicker.center.y = screenHeight+screenHeight*0.326/2
        uiviewDatePicker.hidden = false
        view.endEditing(true)
        datePickerShowAnimation()
        tableImagePickerHideAnimation()
        textFieldBirthday.text = "Birthday"
        imageBirthdayArrow.image = UIImage(named: "birthday_arrow_active")
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: nil)
        textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: nil)
    }
    
    func actionMale(sender: UIButton!) {
        if !maleSelected {
            buttonMaleIcon.setImage(UIImage(named: "male_selected"), forState: .Normal)
            maleSelected = true
        }
        buttonFemaleIcon.setImage(UIImage(named: "female_unselected"), forState: .Normal)
        femaleSelected = false
        tableImagePickerHideAnimation()
    }
    
    func actionFemale(sender: UIButton!) {
        if !femaleSelected {
            buttonFemaleIcon.setImage(UIImage(named: "female_selected"), forState: .Normal)
            femaleSelected = true
        }
        buttonMaleIcon.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        maleSelected = false
        tableImagePickerHideAnimation()
    }
    
    func actionDone(sender: UIButton!) {
        datePickerHideAnimation()
        handleDatePicker(datePicker)
        birthdayValidation()
    }
    func actionFinish(){
        ///verify here...
        var genders = "male"
        if maleSelected {
            genders = "male"
        }
        else{
            genders = "female"
        }
        let strBirthday = timeToString(datePicker.date)
        let user = FaeUser()
        user.whereKey("email", value: self.emailFromPrevious)
        user.whereKey("password", value: self.passwordFromPrevious)
        user.whereKey("first_name", value: self.textFieldFirstName.text!)
        user.whereKey("last_name", value: self.textFieldLastName.text!)
        user.whereKey("birthday", value: strBirthday)
        user.whereKey("gender", value: genders)
        user.signUpInBackground { (status:Int?, message:AnyObject?) in
//            print(status)//if status is 201
            if(status!/100 == 2){//success
                let alert = UIAlertController(title: String(status), message: "success", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: String(status), message: "fail", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Mark: -- tableview functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return screenHeight*0.01
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return screenHeight*0.06
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ImagePickerCell = self.tableImagePicker.dequeueReusableCellWithIdentifier("imagePickerCell") as! ImagePickerCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.labelCellContent.text = "Take a New Photo"
            }
            
            if indexPath.row == 1 {
                cell.labelCellContent.text = "Select from Photos"
            }
        }
        else {
            cell.labelCellContent.text = "Cancel"
            cell.labelCellContent.font = UIFont(name: "AvenirNext-Bold", size: fontSize_18)
        }
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableImagePicker.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                presentViewController(imagePicker, animated: true, completion: ({self.tableImagePickerHideAnimation()}))
            }
            else {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                presentViewController(imagePicker, animated: true, completion: ({self.tableImagePickerHideAnimation()}))
            }
        }
        
        if indexPath.section == 1 {
            self.tableImagePickerHideAnimation()
        }
    }
    
    // Mark: -- animations of image picker and date picker
    
    func tableImagePickerHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tableImagePicker.center.y = self.screenHeight+self.tableImagePicker.frame.height/2
        }), completion: nil)
    }
    
    func tableImagePickerShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tableImagePicker.center.y = self.screenHeight-self.tableImagePicker.frame.height/2
        }), completion: nil)
    }
    
    func datePickerHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.uiviewDatePicker.center.y = self.screenHeight+self.uiviewDatePicker.frame.height/2
        }), completion: nil)
    }
    
    func datePickerShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.uiviewDatePicker.center.y = self.screenHeight-self.uiviewDatePicker.frame.height/2
        }), completion: nil)
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

// Mark: -- customized tableview cell

class ImagePickerCell: UITableViewCell {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelCellContent: UILabel!
    
    func loadCellLabel() {
        let fontSize_18 = screenWidth*0.04348
        labelCellContent = UILabel(frame: CGRectMake(0, 0, screenWidth, screenHeight*0.06))
        labelCellContent.text = "Testing"
        labelCellContent.font = UIFont(name: "AvenirNext-Medium", size: fontSize_18)
        labelCellContent.textAlignment = .Center
        labelCellContent.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        addSubview(labelCellContent)
    }
    
}

