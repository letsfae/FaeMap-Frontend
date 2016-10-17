//
//  RegisterInfoViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterInfoViewController: RegisterBaseViewController {
    
    // MARK: Variables
    
    var textField: FAETextField!
    var dateOfBirth: String? = ""
    var numKeyPad: FAENumberKeyboard!
    var gender: String?
    var maleButton: UIButton!
    var femaleButton: UIButton!
    var faeUser: FaeUser!
    var exclamationMarkButton : UIImageView!
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("ProgressBar5")
        createDateOfBirthView()
        createGenderView()
        createBottomView(UIView(frame: CGRectZero))
        validation()
        //        addTapGesture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        numKeyPad = FAENumberKeyboard(frame:CGRectMake(0,view.frame.size.height - 244 * screenHeightFactor, view.frame.size.width, 244 * screenHeightFactor))
        self.view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        self.bottomView.frame.origin.y = self.view.frame.height - 244 * screenHeightFactor - self.bottomView.frame.size.height + 15
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        setValueInUser()
        jumpToRegisterConfirm()
    }
    
    func jumpToRegisterConfirm() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterConfirmViewController") as! RegisterConfirmViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createDateOfBirthView() {
        
        let dobView = UIView(frame: CGRectMake(0, 90 * screenHeightFactor, view.frame.size.width, 120 * screenHeightFactor))
        
        let titleLabel = UILabel(frame: CGRectMake(0, 10, dobView.frame.size.width, 26))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textAlignment = .Center
        titleLabel.text = "Birthday"
        
        textField = FAETextField(frame: CGRectMake(15, 65 * screenHeightFactor, screenWidth - 30, 34))
        textField.placeholder = "MM/DD/YYYY"
        textField.enabled = false
        
        exclamationMarkButton = UIImageView(frame: CGRectMake(screenWidth / 2 + 70, 72 * screenHeightFactor, 6, 17))
        exclamationMarkButton.image = UIImage(named:"exclamation_red_new")
        exclamationMarkButton.hidden = true
        
        dobView.addSubview(titleLabel)
        dobView.addSubview(textField)
        dobView.addSubview(exclamationMarkButton)
        
        view.addSubview(dobView)
        
    }
    
    func createGenderView() {
        let genderView = UIView(frame: CGRectMake(0, 240 * screenHeightFactor, view.frame.size.width, 130 * screenHeightFactor))
        
        let titleLabel = UILabel(frame: CGRectMake(0, 10, genderView.frame.size.width, 26))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textAlignment = .Center
        titleLabel.text = "Gender"
        
        maleButton = UIButton(frame: CGRectMake(genderView.frame.size.width/3.0 - 30, 60 * screenHeightFactor, 60, 60))
        maleButton.setImage(UIImage(named: "male_unselected"), forState: .Normal)
        maleButton.setImage(UIImage(named: "male_selected"), forState: .Selected)
        maleButton.addTarget(self, action: #selector(self.maleButtonTapped), forControlEvents: .TouchUpInside)
        
        
        femaleButton = UIButton(frame: CGRectMake(2 * genderView.frame.size.width/3.0 - 30, 60 * screenHeightFactor, 60, 60))
        femaleButton.setImage(UIImage(named: "female_unselected"), forState: .Normal)
        femaleButton.setImage(UIImage(named: "female_selected"), forState: .Selected)
        femaleButton.addTarget(self, action: #selector(self.femaleButtonTapped), forControlEvents: .TouchUpInside)
        
        
        genderView.addSubview(titleLabel)
        genderView.addSubview(maleButton)
        genderView.addSubview(femaleButton)
        
        view.addSubview(genderView)
        
    }
    
    
    func maleButtonTapped() {
        showGenderSelected("male")
    }
    
    func femaleButtonTapped() {
        showGenderSelected("female")
    }
    
    func showGenderSelected(gender: String) {
        self.gender = gender
        
        let isMaleSelected = gender == "male"
        
        maleButton.selected = isMaleSelected
        femaleButton.selected = !isMaleSelected
        
        validation()
    }
    
    func validation() {
        var isValid = false
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.dateFromString(dateOfBirth!)
        isValid = date != nil && dateOfBirth!.characters.count == 10
        
        if(date == nil && dateOfBirth!.characters.count == 10){
            exclamationMarkButton.hidden = false
        }
        
        if isValid {
            let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
            
            let currentYearInt = (calendar?.component(NSCalendarUnit.Year, fromDate: date!))!
            
            
            isValid = isValid && currentYearInt > 1901 && currentYearInt < (calendar?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
            exclamationMarkButton.hidden = isValid
        }
        

        if isValid {
            isValid = date!.earlierDate(NSDate()).isEqualToDate(date!)
        }

        isValid = isValid && gender != nil

        
        enableContinueButton(isValid)
    }
    
    func setValueInUser() {
        faeUser.whereKey("gender", value: gender!)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.dateFromString(dateOfBirth!)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(date!)
        
        faeUser.whereKey("birthday", value: dateString)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterInfoViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(num: Int) {
        if num != -1 {
            if dateOfBirth?.characters.count < 10 {
                dateOfBirth = "\(dateOfBirth!)\(num)"
            }
            
            let numberOfCharacters = dateOfBirth?.characters.count
            
            if  numberOfCharacters == 2 || numberOfCharacters == 5 {
                dateOfBirth = "\(dateOfBirth!)/"
            }
            
        } else {
            if dateOfBirth?.characters.count >= 0 {
                
                dateOfBirth = String(dateOfBirth!.characters.dropLast())
                
                let numberOfCharacters = dateOfBirth?.characters.count
                
                if  numberOfCharacters == 2 || numberOfCharacters == 5 {
                    dateOfBirth = String(dateOfBirth!.characters.dropLast())
                }
            }
            exclamationMarkButton.hidden = true
        }
        
        validation()
        
        textField.text = dateOfBirth
    }
}


extension RegisterInfoViewController {
    override func keyboardWillShow(notification: NSNotification) {
        textField.resignFirstResponder()
    }
    
    func hideNumKeyboard() {
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
        })
        
    }
    
}
