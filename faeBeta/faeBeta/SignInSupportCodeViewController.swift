//
//  SignInSupportCodeViewController.swift
//  faeBeta
//
//  Created by Yash on 28/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInSupportCodeViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    var cellEnterCode: EnterCodeTableViewCell!
    var code = ""
    var numKeyPad: FAENumberKeyboard!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTopView("")
        createTableView(view.frame.size.height - 175)
        createBottomView(resendCodeView())
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cellEnterCode.makeFirstResponder()
    }
    
    // MARK: - Functions
    func resendCodeView() -> UIView {
        let uiviewResend = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let label = UILabel(frame: CGRect(x: view.frame.size.width/2.0 - 125, y: 0, width: 250, height: 25))
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Medium", size: 13)
        label.textColor = UIColor.init(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        label.text = "Resend Code."
        uiviewResend.addSubview(label)
        return uiviewResend
    }
    
    func loginButtonPressed() {}
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        jumpToRegisterUsername()
    }
    
    func jumpToRegisterUsername() {
        let vc: UIViewController = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "RegisterUsernameViewController")as! RegisterUsernameViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validation() {
        var isValid = false
        isValid = code.characters.count == 6
        enableContinueButton(isValid)
    }
    
    func registerCell() {
        tableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(UINib(nibName: "SpacerTableViewCell", bundle: nil), forCellReuseIdentifier: "SpacerTableViewCellIdentifier")
        tableView.register(UINib(nibName: "EnterCodeTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterCodeTableViewCellIdentifier")
    }
    
    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SignInSupportCodeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Enter the Code we just \nsent to your Email to continue")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerTableViewCellIdentifier") as! SpacerTableViewCell
            return cell
        case 2:
            if cellEnterCode == nil {
                cellEnterCode = tableView.dequeueReusableCell(withIdentifier: "EnterCodeTableViewCellIdentifier") as! EnterCodeTableViewCell
            }
            return cellEnterCode
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
        }
    }
}

extension SignInSupportCodeViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(_ num: Int) {
        if num != -1 {
            if code.characters.count < 6 {
                code = "\(code)\(num)"
            }
        } else {
            if code.characters.count >= 0 {
                code = String(code.characters.dropLast())
            }
        }
        cellEnterCode.showText(code)
        validation()
    }
}

extension SignInSupportCodeViewController {
    override func keyboardWillShow(_ notification: Notification) {
        view.endEditing(true)
        if numKeyPad == nil {
            numKeyPad = FAENumberKeyboard(frame: CGRect(x: 57, y: view.frame.size.height, width: 300, height: 244))
            self.view.addSubview(numKeyPad)
            numKeyPad.delegate = self
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            var frame = self.numKeyPad!.frame
            self.uiviewBottom.frame.origin.y = self.view.frame.height - 244 - self.uiviewBottom.frame.size.height
            frame.origin.y = self.view.frame.size.height - 244
            self.numKeyPad.frame = frame
        }) 
    }
    
    func hideNumKeyboard() {
        var bottomViewFrame = uiviewBottom.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.uiviewBottom.frame = bottomViewFrame
        })
    }
}
