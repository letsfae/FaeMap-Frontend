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
    // MARK: - Properties
    private var textField: FAETextField!
    private var dateOfBirth: String? = ""
    private var numKeyPad: FAENumberKeyboard!
    private var gender: String?
    private var btnMale: UIButton!
    private var btnFemale: UIButton!
    private var imgExclamationMark: UIImageView!
    private var boolMeetMinAge: Bool = true
    private var uiviewAtBottom: UIView!
    private var lblCont: UILabel!
    var faeUser: FaeUser!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTopView("ProgressBar4")
        createDateOfBirthView()
        createGenderView()
        uiviewAtBottom = setupBottomView()
        createBottomView(uiviewAtBottom)
        validation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        numKeyPad = FAENumberKeyboard(frame: CGRect(x: 0, y: view.frame.size.height - 244 * screenHeightFactor - device_offset_bot, width: view.frame.size.width, height: 244 * screenHeightFactor))
        view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        uiviewBottom.frame.origin.y = view.frame.height - 244 * screenHeightFactor - uiviewBottom.frame.size.height + 15 - device_offset_bot
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validation()
        FaeCoreData.shared.save("signup", value: "info")
    }
    
    private func createDateOfBirthView() {
        let uiviewDoB = UIView(frame: CGRect(x: 0, y: 99 * screenHeightFactor + 1.5 * device_offset_top, width: screenWidth, height: 120 * screenHeightFactor))
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 27))
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.text = "Birthday"
        
        textField = FAETextField(frame: CGRect(x: 15, y: 59 * screenHeightFactor, width: screenWidth - 30, height: 34))
        textField.placeholder = "MM/DD/YYYY"
        textField.isEnabled = false
        if let savedDateOfBirth = FaeCoreData.shared.readByKey("signup_dateofbirth") {
            textField.text = savedDateOfBirth as? String
            dateOfBirth = savedDateOfBirth as? String
        }
        
        imgExclamationMark = UIImageView(frame: CGRect(x: screenWidth / 2 + 70, y: 64 * screenHeightFactor, width: 7, height: 21))
        imgExclamationMark.image = #imageLiteral(resourceName: "exclamation_red_new")
        imgExclamationMark.isHidden = true
        
        uiviewDoB.addSubview(lblTitle)
        uiviewDoB.addSubview(textField)
        uiviewDoB.addSubview(imgExclamationMark)
        
        view.addSubview(uiviewDoB)
    }
    
    private func createGenderView() {
        let genderView = UIView(frame: CGRect(x: 0, y: 245 * screenHeightFactor + 1.5 * device_offset_top, width: screenWidth, height: 150 * screenHeightFactor))
        
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
        
        if let savedGender = FaeCoreData.shared.readByKey("signup_gender") {
            gender = savedGender as? String
            if (savedGender as? String) == "male" {
                btnMale.isSelected = true
                btnFemale.isSelected = false
            } else {
                btnMale.isSelected = false
                btnFemale.isSelected = true
            }
        }
    }
    
    private func setupBottomView() -> UIView {
        let uiviewBtm = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont.numberOfLines = 2
        lblCont.textAlignment = .center
        lblCont.textColor = UIColor._2499090()
        lblCont.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblCont.text = "Sorry! You don’t meet the minimum age\nrequirement for Fae Map."
        uiviewBtm.addSubview(lblCont)
        lblCont.isHidden = true
        return uiviewBtm
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    override func backButtonPressed() {
        view.endEditing(true)
        if gender != nil {
            FaeCoreData.shared.save("signup_gender", value: gender!)
        }
        if dateOfBirth != nil {
            FaeCoreData.shared.save("signup_dateofbirth", value: dateOfBirth!)            
        }
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        if Key.shared.is_Login {
            setValueInUser()
            faeUser.updateAccountBasicInfo({ (_, _) in
                self.jumpToRegisterNext()
            })
        } else {
            setValueInUser()
            jumpToRegisterNext()            
        }
        FaeCoreData.shared.save("signup_gender", value: gender!)
        FaeCoreData.shared.save("signup_dateofbirth", value: dateOfBirth!)
    }
    
    private func setValueInUser() {
        faeUser.whereKey("gender", value: gender!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date!)
        
        faeUser.whereKey("birthday", value: dateString)
    }
    
    private func jumpToRegisterNext() {
        let nextRegister = RegisterEmailViewController()
        nextRegister.faeUser = faeUser
        navigationController?.pushViewController(nextRegister, animated: false)
    }
    
    @objc private func maleButtonTapped() {
        showGenderSelected("male")
    }
    
    @objc private func femaleButtonTapped() {
        showGenderSelected("female")
    }
    
    private func showGenderSelected(_ gender: String) {
        self.gender = gender
        let isMaleSelected = gender == "male"
        btnMale.isSelected = isMaleSelected
        btnFemale.isSelected = !isMaleSelected
        validation()
    }
    
    private func validation() {
        if gender == nil || dateOfBirth == nil { return }
        boolMeetMinAge = true
        var boolIsValid = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        boolIsValid = date != nil && dateOfBirth!.count == 10
        
        if date == nil && dateOfBirth!.count == 10 {
            imgExclamationMark.isHidden = false
        }
        
        if boolIsValid {
            let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
            
            let intAge = calendar.dateComponents([.year], from: date!, to: Date()).year!
            boolIsValid = boolIsValid && intAge <= 99 && intAge >= 13
            boolMeetMinAge = intAge >= 13
            
            imgExclamationMark.isHidden = boolIsValid
        }
        
        if boolIsValid {
            boolIsValid = (date! as NSDate).earlierDate(Date()) == date!
        }
        
        boolIsValid = boolIsValid && gender != nil
        enableContinueButton(boolIsValid)
        lblCont.isHidden = boolMeetMinAge
    }
}

// MARK: - FAENumberKeyboardDelegate
extension RegisterInfoViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(_ num: Int) {
        if num != -1 {
            if dateOfBirth?.count < 10 {
                dateOfBirth = "\(dateOfBirth!)\(num)"
            }
            
            let numOfCharacters = dateOfBirth?.count
            if numOfCharacters == 2 || numOfCharacters == 5 {
                dateOfBirth = "\(dateOfBirth!)/"
            }
        } else {
            if dateOfBirth?.count >= 0 {
                dateOfBirth = String(dateOfBirth!.dropLast())
                let numOfCharacters = dateOfBirth?.count
                if numOfCharacters == 2 || numOfCharacters == 5 {
                    dateOfBirth = String(dateOfBirth!.dropLast())
                }
            }
            imgExclamationMark.isHidden = true
        }
        validation()
        textField.text = dateOfBirth
    }
}

// MARK: - Keyboard observer
extension RegisterInfoViewController {
    override func keyboardWillShow(_ notification: Notification) {
        textField.resignFirstResponder()
    }
    
    override func keyboardWillHide(_ notification: Notification) {
    }
}
