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
    var arrowImage : UIImageView!
    
    var titleLabel : UILabel!
    var usernameLabel : UILabel!
    var questionLabel : UILabel!
    var contantLabel : UILabel!
    
    var buttonEmail : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(screenWidth)
        print(screenHeight)
        loadIcon()
        loadLabel()
        loadButton()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadIcon() {
        imageViewIcon = UIImageView(frame: CGRectMake(0.3116*screenWidth, 0.223*screenHeight, 0.3768*screenWidth, 0.3768*screenWidth))
        imageViewIcon.image = UIImage(named: "account_found_icon")
        self.view.addSubview(imageViewIcon)
        
        arrowImage = UIImageView(frame: CGRectMake(0.683*screenWidth, 0.7554*screenHeight, 0.03768*screenWidth, 0.0245*screenHeight))
        arrowImage.image = UIImage(named: "account_found_arrow")
        self.view.addSubview(arrowImage)
        
    }
    
    func loadLabel() {
        titleLabel = UILabel(frame: CGRectMake(0, 0.133*screenHeight, screenWidth, 0.0462*screenHeight))
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.text = "Found Account!"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        self.view.addSubview(titleLabel)
        
        usernameLabel = UILabel(frame: CGRectMake(0, 0.481*screenHeight, screenWidth, 0.037*screenHeight))
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        usernameLabel.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        usernameLabel.text = "Beta Tester 1"
        usernameLabel.textAlignment = .Center
        self.view.addSubview(usernameLabel)
        
        questionLabel = UILabel(frame: CGRectMake(0, 0.724*screenHeight, screenWidth, 0.03*screenHeight))
        questionLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        questionLabel.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        questionLabel.textAlignment = .Center
        questionLabel.text = "Not your Account?"
        self.view.addSubview(questionLabel)
        
        contantLabel = UILabel(frame: CGRectMake(0, 0.7527*screenHeight, 0.662*screenWidth, 0.03*screenHeight))
        contantLabel.textAlignment = .Right
        contantLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
        contantLabel.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        contantLabel.text = "Contact Fae Support"
        self.view.addSubview(contantLabel)
        
    }
    
    func loadButton() {
        buttonEmail = UIButton(frame: CGRectMake(0.1*screenWidth, 0.591*screenHeight, 0.797*screenWidth, 0.068*screenHeight))
        buttonEmail.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        buttonEmail.setTitle("Email Code", forState: .Normal)
        buttonEmail.layer.cornerRadius = 7
        buttonEmail.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        buttonEmail.addTarget(self, action: #selector(AccountFoundViewController.jumpToVerification), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonEmail)
    }
    func jumpToVerification(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("VerificationCodeViewController")as! VerificationCodeViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
