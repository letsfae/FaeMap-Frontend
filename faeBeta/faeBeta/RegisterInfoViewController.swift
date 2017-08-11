//
//  RegisterInfoViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
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
fileprivate func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

class RegisterInfoViewController: RegisterBaseViewController {
    
    var textField: FAETextField!
    var dateOfBirth: String? = ""
    var numKeyPad: FAENumberKeyboard!
    var gender: String?
    var btnMale: UIButton!
    var btnFemale: UIButton!
    var faeUser: FaeUser!
    var imgExclamationMark: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTopView("ProgressBar5")
        createDateOfBirthView()
        createGenderView()
        createBottomView(UIView(frame: CGRect.zero))
        validation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        numKeyPad = FAENumberKeyboard(frame: CGRect(x: 0, y: view.frame.size.height - 244 * screenHeightFactor, width: view.frame.size.width, height: 244 * screenHeightFactor))
        view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        uiviewBottom.frame.origin.y = view.frame.height - 244 * screenHeightFactor - uiviewBottom.frame.size.height + 15
    }
    
    // MARK: - Functions
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        setValueInUser()
        jumpToRegisterConfirm()
    }
    
    func jumpToRegisterConfirm() {
        let boardRegister = RegisterConfirmViewController()
        boardRegister.faeUser = faeUser
        navigationController?.pushViewController(boardRegister, animated: true)
    }
    
    func createDateOfBirthView() {
        let uiviewDoB = UIView(frame: CGRect(x: 0, y: 99 * screenHeightFactor, width: screenWidth, height: 120 * screenHeightFactor))
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 27))
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.text = "Birthday"
        
        textField = FAETextField(frame: CGRect(x: 15, y: 59 * screenHeightFactor, width: screenWidth - 30, height: 34))
        textField.placeholder = "MM/DD/YYYY"
        textField.isEnabled = false
        
        imgExclamationMark = UIImageView(frame: CGRect(x: screenWidth / 2 + 70, y: 64 * screenHeightFactor, width: 7, height: 21))
        imgExclamationMark.image = #imageLiteral(resourceName: "exclamation_red_new")
        imgExclamationMark.isHidden = true
        
        uiviewDoB.addSubview(lblTitle)
        uiviewDoB.addSubview(textField)
        uiviewDoB.addSubview(imgExclamationMark)
        
        view.addSubview(uiviewDoB)
    }
    
    func createGenderView() {
        let genderView = UIView(frame: CGRect(x: 0, y: 245 * screenHeightFactor, width: screenWidth, height: 150 * screenHeightFactor))
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 27))
        titleLabel.textColor = UIColor._898989()
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Gender"
        
        btnMale = UIButton(frame: CGRect(x: screenWidth / 2 - 120, y: 50 * screenHeightFactor, width: 80, height: 80))
        btnMale.setImage(#imageLiteral(resourceName: "male_unselected"), for: .normal)
        btnMale.setImage(#imageLiteral(resourceName: "male_selected"), for: .selected)
        btnMale.addTarget(self, action: #selector(self.maleButtonTapped), for: .touchUpInside)
        
        btnFemale = UIButton(frame: CGRect(x: screenWidth / 2 + 40, y: 50 * screenHeightFactor, width: 80, height: 80))
        btnFemale.setImage(#imageLiteral(resourceName: "female_unselected"), for: .normal)
        btnFemale.setImage(#imageLiteral(resourceName: "female_selected"), for: .selected)
        btnFemale.addTarget(self, action: #selector(self.femaleButtonTapped), for: .touchUpInside)
        
        genderView.addSubview(titleLabel)
        genderView.addSubview(btnMale)
        genderView.addSubview(btnFemale)
        
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
        btnMale.isSelected = isMaleSelected
        btnFemale.isSelected = !isMaleSelected
        validation()
    }
    
    func validation() {
        var boolIsValid = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        boolIsValid = date != nil && dateOfBirth!.characters.count == 10
        
        if date == nil && dateOfBirth!.characters.count == 10 {
            imgExclamationMark.isHidden = false
        }
        
        if boolIsValid {
            let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
            let currentYearInt = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: date!))!
            
            boolIsValid = boolIsValid && currentYearInt > ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))! - 99 && currentYearInt < ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))!
            imgExclamationMark.isHidden = boolIsValid
        }
        
        if boolIsValid {
            boolIsValid = (date! as NSDate).earlierDate(Date()) == date!
        }
        
        boolIsValid = boolIsValid && gender != nil
        enableContinueButton(boolIsValid)
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
            
            let numOfCharacters = dateOfBirth?.characters.count
            if numOfCharacters == 2 || numOfCharacters == 5 {
                dateOfBirth = "\(dateOfBirth!)/"
            }
        } else {
            if dateOfBirth?.characters.count >= 0 {
                dateOfBirth = String(dateOfBirth!.characters.dropLast())
                let numOfCharacters = dateOfBirth?.characters.count
                if numOfCharacters == 2 || numOfCharacters == 5 {
                    dateOfBirth = String(dateOfBirth!.characters.dropLast())
                }
            }
            imgExclamationMark.isHidden = true
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
        var frameBottom = uiviewBottom.frame
        frameBottom.origin.y = view.frame.height - frameBottom.size.height
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.uiviewBottom.frame = frameBottom
        })
    }
}
