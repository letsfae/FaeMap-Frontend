//
//  SignInSupportViewController.swift
//  faeBeta
//
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInSupportViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568

    var labelSupport : UILabel!
    var imageTitle : UIImageView!
    var buttonCreate : UIButton!
    var buttonContact : UIButton!
    let upSpace :CGFloat = 64.0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLabelImage()
        loadButton()
        
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
    }
    func loadLabelImage(){
        labelSupport = UILabel(frame: CGRectMake(screenWidth/2-186/2,5,186,68))
        labelSupport.text = "Welcome to Sign In Support!"
        labelSupport.numberOfLines = 0
        labelSupport.textAlignment = .Center
        labelSupport.textColor = UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0)
        labelSupport.font = UIFont.systemFontOfSize(25.0, weight: UIFontWeightRegular)
        self.view.addSubview(labelSupport)
        let imageWidth : CGFloat = screenWidth*0.7971
        let imageHeight : CGFloat = screenHeigh*0.33559
        imageTitle = UIImageView(frame: CGRectMake(screenWidth/2-imageWidth/2, screenHeigh*0.24728-upSpace, imageWidth, imageHeight))
        imageTitle.image = UIImage(named: "welcomSignInSupport")
        self.view.addSubview(imageTitle)
    }
    func loadButton(){
        buttonCreate = UIButton(frame: CGRectMake(screenWidth/2-300/2,screenHeigh-screenHeigh*0.339673,300,50))
        buttonCreate.setTitle("Create New Password", forState: .Normal)
        buttonCreate.setTitleColor(UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0), forState: .Normal)
        buttonCreate.layer.cornerRadius = 7
        buttonCreate.layer.masksToBounds = true
        buttonCreate.layer.borderWidth = 2
        buttonCreate.layer.borderColor = UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0).CGColor
        buttonCreate.addTarget(self, action: #selector(SignInSupportViewController.jumpToEmail), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonCreate)
        
        buttonContact = UIButton (frame: CGRectMake(screenWidth/2-300/2,screenHeigh-screenHeigh*0.230978,300,50))
        buttonContact.setTitle("Contact Fae Support", forState: .Normal)
        buttonContact.backgroundColor = UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0)
        buttonContact.layer.cornerRadius = 7
        self.view.addSubview(buttonContact)
    }
    func jumpToEmail(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RetriveByEmailViewController")as! RetriveByEmailViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
