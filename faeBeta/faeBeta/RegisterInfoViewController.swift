//
//  RegisterInfoViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
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
        createBottomView(UIView(frame: CGRect.zero))
        validation()
        //        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        numKeyPad = FAENumberKeyboard(frame:CGRect(x: 0,y: view.frame.size.height - 244 * screenHeightFactor, width: view.frame.size.width, height: 244 * screenHeightFactor))
        self.view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        self.bottomView.frame.origin.y = self.view.frame.height - 244 * screenHeightFactor - self.bottomView.frame.size.height + 15
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ =  navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        setValueInUser()
        jumpToRegisterConfirm()
    }
    
    func jumpToRegisterConfirm() {
        let vc = UIStoryboard(name: "Register", bundle: nil) .instantiateViewController(withIdentifier: "RegisterConfirmViewController") as! RegisterConfirmViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createDateOfBirthView() {
        
        let dobView = UIView(frame: CGRect(x: 0, y: 90 * screenHeightFactor, width: view.frame.size.width, height: 120 * screenHeightFactor))
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: dobView.frame.size.width, height: 26))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Birthday"
        
        textField = FAETextField(frame: CGRect(x: 15, y: 65 * screenHeightFactor, width: screenWidth - 30, height: 34))
        textField.placeholder = "MM/DD/YYYY"
        textField.isEnabled = false
        
        exclamationMarkButton = UIImageView(frame: CGRect(x: screenWidth / 2 + 70, y: 72 * screenHeightFactor, width: 6, height: 17))
        exclamationMarkButton.image = UIImage(named:"exclamation_red_new")
        exclamationMarkButton.isHidden = true
        
        dobView.addSubview(titleLabel)
        dobView.addSubview(textField)
        dobView.addSubview(exclamationMarkButton)
        
        view.addSubview(dobView)
        
    }
    
    func createGenderView() {
        let genderView = UIView(frame: CGRect(x: 0, y: 240 * screenHeightFactor, width: view.frame.size.width, height: 130 * screenHeightFactor))
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: genderView.frame.size.width, height: 26))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Gender"
        
        maleButton = UIButton(frame: CGRect(x: genderView.frame.size.width/3.0 - 30, y: 60 * screenHeightFactor, width: 60, height: 60))
        maleButton.setImage(UIImage(named: "male_unselected"), for: UIControlState())
        maleButton.setImage(UIImage(named: "male_selected"), for: .selected)
        maleButton.addTarget(self, action: #selector(self.maleButtonTapped), for: .touchUpInside)
        
        
        femaleButton = UIButton(frame: CGRect(x: 2 * genderView.frame.size.width/3.0 - 30, y: 60 * screenHeightFactor, width: 60, height: 60))
        femaleButton.setImage(UIImage(named: "female_unselected"), for: UIControlState())
        femaleButton.setImage(UIImage(named: "female_selected"), for: .selected)
        femaleButton.addTarget(self, action: #selector(self.femaleButtonTapped), for: .touchUpInside)
        
        
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
    
    func showGenderSelected(_ gender: String) {
        self.gender = gender
        
        let isMaleSelected = gender == "male"
        
        maleButton.isSelected = isMaleSelected
        femaleButton.isSelected = !isMaleSelected
        
        validation()
    }
    
    func validation() {
        var isValid = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        isValid = date != nil && dateOfBirth!.characters.count == 10
        
        if(date == nil && dateOfBirth!.characters.count == 10){
            exclamationMarkButton.isHidden = false
        }
        
        if isValid {
            let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
            
            let currentYearInt = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: date!))!
            
            
            isValid = isValid && currentYearInt > ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))! - 99 && currentYearInt < ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))!
            exclamationMarkButton.isHidden = isValid
        }
        

        if isValid {
            isValid = (date! as NSDate).earlierDate(Date()) == date!
        }

        isValid = isValid && gender != nil

        
        enableContinueButton(isValid)
    }
    
    func setValueInUser() {
        faeUser.whereKey("gender", value: gender!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date!)
        
        faeUser.whereKey("birthday", value: dateString)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterInfoViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(_ num: Int) {
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
            exclamationMarkButton.isHidden = true
        }
        
        validation()
        
        textField.text = dateOfBirth
    }
}


extension RegisterInfoViewController {
    override func keyboardWillShow(_ notification: Notification) {
        textField.resignFirstResponder()
    }
    
    func hideNumKeyboard() {
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
        })
        
    }
    
}
