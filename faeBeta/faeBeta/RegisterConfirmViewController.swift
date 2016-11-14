//
//  RegisterConfirmViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterConfirmViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    
    var faeUser: FaeUser!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createView()
    }
    
    // MARK: Functions
    
    func createView() {
        
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        backButton.setImage(UIImage(named: "NavigationBackNew"), for: UIControlState())
        backButton.setTitleColor(UIColor.blue, for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: viewHeight * 95/736.0, width: viewWidth, height: 35))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.text = "All Good to Go!"
        
        let imageView = UIImageView(frame: CGRect(x: 30, y: viewHeight * 185/736.0, width: viewWidth - 60, height: (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")
        
        let titleLabel1 = UILabel(frame: CGRect(x: 0, y: viewHeight * 500/736.0, width: viewWidth, height: 35))
        titleLabel1.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel1.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel1.textAlignment = .center
        titleLabel1.text = "Welcome to Fae!"
        
        let finishButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 131 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        //        finishButton.setImage(UIImage(named: "FinishButton"), forState: .Normal)
        finishButton.layer.cornerRadius = 25 * screenHeightFactor
        finishButton.layer.masksToBounds = true
        finishButton.center.x = screenWidth / 2
        
        finishButton.setTitle("Finish!", for: UIControlState())
        finishButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 20)
        
        finishButton.backgroundColor = UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        finishButton.addTarget(self, action: #selector(self.finishButtonPressed), for: .touchUpInside)
        
        
        let termsOfServiceLabel = UILabel(frame: CGRect(x: 0, y: screenHeight - 56, width: screenWidth, height: 50))
        termsOfServiceLabel.numberOfLines = 2
        termsOfServiceLabel.textAlignment = .center
        
        let myString = "By signing up, you agree to Fae's Terms of Service \n and Privacy Policy."
        let myAttribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 138/255.0, green: 138/255.0, blue: 138/255.0, alpha: 1.0), range: NSRange(location: 0, length: 61))
        
        
        let myRange1 = NSRange(location: 34, length: 16)
        let myRange2 = NSRange(location: 57, length: 14)
        
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253/255.0, green: 114/255.0, blue: 109/255.0, alpha: 1.0), range: myRange1)
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 253/255.0, green: 114/255.0, blue: 109/255.0, alpha: 1.0), range: myRange2)
        
        
        myAttrString.addAttribute(NSFontAttributeName, value:UIFont(name: "AvenirNext-Bold", size: 13)!, range: myRange1)
        myAttrString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-Bold", size: 13)!, range: myRange2)
        
        
        termsOfServiceLabel.attributedText = myAttrString
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(finishButton)
        view.addSubview(titleLabel1)
        view.addSubview(termsOfServiceLabel)
        view.bringSubview(toFront: backButton)
        
    }
    
    override func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func finishButtonPressed() {
        signUpUser()
    }
    
    func signUpUser() {
        showActivityIndicator()
        print(faeUser.keyValue)
        faeUser.signUpInBackground { (status, message) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    self.loginUser()
                }
            })
        }
    }
    
    func loginUser() {
        showActivityIndicator()
        faeUser.logInBackground({(status:Int, error:Any?) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status / 100 == 2 {
                    print("login success")
                    self.jumpToEnableLocation()
                }
            })
        })
    }
    
    func jumpToEnableLocation() {
        let authstate = CLLocationManager.authorizationStatus()
        
        if(authstate != CLAuthorizationStatus.authorizedAlways){
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "EnableLocationViewController")as! EnableLocationViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let notificationType = UIApplication.shared.currentUserNotificationSettings
            if notificationType?.types == UIUserNotificationType() {
                self.navigationController?.pushViewController(UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "EnableNotificationViewController") , animated: true)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
