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
        
        
        let backButton = UIButton(frame: CGRectMake(10, 25, 40, 40))
        backButton.setImage(UIImage(named: "NavigationBackNew"), forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed), forControlEvents: .TouchUpInside)
        
        let titleLabel = UILabel(frame: CGRectMake(0, viewHeight * 95/736.0, viewWidth, 35))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.textAlignment = .Center
        titleLabel.text = "All Good to Go!"
        
        let imageView = UIImageView(frame: CGRectMake(30, viewHeight * 185/736.0, viewWidth - 60, (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")
        
        let titleLabel1 = UILabel(frame: CGRectMake(0, viewHeight * 500/736.0, viewWidth, 35))
        titleLabel1.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel1.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel1.textAlignment = .Center
        titleLabel1.text = "Welcome to Fae!"
        
        let finishButton = UIButton(frame: CGRectMake(0, screenHeight - 131 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        //        finishButton.setImage(UIImage(named: "FinishButton"), forState: .Normal)
        finishButton.layer.cornerRadius = 25 * screenHeightFactor
        finishButton.layer.masksToBounds = true
        finishButton.center.x = screenWidth / 2
        
        finishButton.setTitle("Finish!", forState: .Normal)
        finishButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 20)
        
        finishButton.backgroundColor = UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        finishButton.addTarget(self, action: #selector(self.finishButtonPressed), forControlEvents: .TouchUpInside)
        
        
        let termsOfServiceLabel = UILabel(frame: CGRectMake(0, screenHeight - 56, screenWidth, 50))
        termsOfServiceLabel.numberOfLines = 2
        termsOfServiceLabel.textAlignment = .Center
        
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
        view.bringSubviewToFront(backButton)
        
    }
    
    override func backButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func finishButtonPressed() {
        signUpUser()
    }
    
    func signUpUser() {
        showActivityIndicator()
        print(faeUser.keyValue)
        faeUser.signUpInBackground { (status, message) in
            dispatch_async(dispatch_get_main_queue(), {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    self.loginUser()
                }
            })
        }
    }
    
    func loginUser() {
        showActivityIndicator()
        faeUser.logInBackground({(status:Int, error:AnyObject?) in
            dispatch_async(dispatch_get_main_queue(), {
                self.hideActivityIndicator()
                if status / 100 == 2 {
                    print("login success")
                    
                    // WARNING: this code should be deleted afterward, it's here just to test chat function
                    postToURL("chats", parameter: ["receiver_id": "21", "message": "Hi there, I just registered. Let's chat!", "type": "text"], authentication: headerAuthentication(), completion: { (statusCode, result) in
                    })
                    
                    self.jumpToEnableLocation()
                }
            })
        })
    }
    
    func jumpToEnableLocation() {
        let authstate = CLLocationManager.authorizationStatus()
        
        if(authstate != CLAuthorizationStatus.AuthorizedAlways){
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("EnableLocationViewController")as! EnableLocationViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
            if notificationType?.types == UIUserNotificationType.None {
                self.navigationController?.pushViewController(UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("EnableNotificationViewController") , animated: true)
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // MARK: Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
