//
//  AccountFoundViewController.swift
//  faeBeta
//
//  Created by blesssecret on 5/12/16.
//  edited by mingjie jin
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class AccountFoundViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var imageViewIcon : UIImageView!
    //    var arrowImage : UIImageView!
    
    let navigationBarOffset : CGFloat = 0
    
    var titleLabel : UILabel!
    var usernameLabel : UILabel!
    var questionLabel : UILabel!
    var contantLabel : UILabel!
    
    var buttonContact : UIButton!
    var buttonEmail : UIButton!
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    let questionLabelYposition = 0.724 * UIScreen.mainScreen().bounds.height
    
    var emailNeedToBeVerifed = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(screenWidth)
        print(screenHeight)
        loadIcon()
        loadLabel()
        loadButton()
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        //        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadIcon() {
        imageViewIcon = UIImageView(frame: CGRectMake(0.312*screenWidth, 0.223*screenHeight - navigationBarOffset, 0.377*screenWidth, 0.377*screenWidth))
        imageViewIcon.image = UIImage(named: "account_found_icon")
        self.view.addSubview(imageViewIcon)
        
        //        arrowImage = UIImageView(frame: CGRectMake(0.683*screenWidth, 0.7554*screenHeight, 0.03768*screenWidth, 0.0245*screenHeight))
        //        arrowImage.image = UIImage(named: "account_found_arrow")
        //        self.view.addSubview(arrowImage)
    }
    
    func loadLabel() {
        titleLabel = UILabel(frame: CGRectMake(0, 0.133 * screenHeight - navigationBarOffset, screenWidth, 0.0462*screenHeight))
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.text = "Found Account!"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = colorFae
        self.view.addSubview(titleLabel)
        
        usernameLabel = UILabel(frame: CGRectMake(0, 0.48 * screenHeight - navigationBarOffset, screenWidth, 0.037*screenHeight))
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        usernameLabel.textColor = colorFae
        usernameLabel.text = "Beta Tester 1"
        usernameLabel.textAlignment = .Center
        self.view.addSubview(usernameLabel)
        
        questionLabel = UILabel(frame: CGRectMake(0, questionLabelYposition - navigationBarOffset, screenWidth, 0.03*screenHeight))
        questionLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        questionLabel.textColor = colorFae
        questionLabel.textAlignment = .Center
        questionLabel.text = "Not your Account?"
        self.view.addSubview(questionLabel)
    }
    
    func loadButton() {
        let height = 0.07 * screenHeight
        buttonEmail = UIButton(frame: CGRectMake(0.1*screenWidth, 0.59*screenHeight - navigationBarOffset, 0.78*screenWidth, 50))
        buttonEmail.backgroundColor = colorFae
        buttonEmail.setTitle("Email Code", forState: .Normal)
        buttonEmail.layer.cornerRadius = 7
        buttonEmail.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        buttonEmail.addTarget(self, action: #selector(AccountFoundViewController.sendCodeToEmail), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonEmail)
        
        buttonContact = UIButton(frame: CGRectMake(0, questionLabelYposition + 25 - navigationBarOffset, screenWidth, 0.03*screenHeight))
        buttonContact.setTitle("Contact Fae Support", forState: .Normal)
        buttonContact.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
        buttonContact.setTitleColor(colorFae, forState: .Normal)
        self.view.addSubview(buttonContact)
    }
    
    func jumpToVerification(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("VerificationCodeViewController")as! VerificationCodeViewController
        vc.emailNeedToBeVerified = self.emailNeedToBeVerifed
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendCodeToEmail() {
        let user = FaeUser()
        user.whereKey("email", value: emailNeedToBeVerifed)
        user.sendCodeToEmail{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                print("Email sent")
                self.jumpToVerification()
            }
            else{
                //failure
            }
        }
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
