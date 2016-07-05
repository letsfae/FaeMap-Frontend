//
//  AccountEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 7/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class AccountEmailViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    // label and button
    var labelTitle : UILabel!
    var labelEmail : UILabel!
    var buttonVerify : UIButton!
    var buttonChange : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account Emails"
        self.initialView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initialView(){
        labelTitle = UILabel(frame: CGRectMake(0,89,screenWidth,25))
        labelTitle.textAlignment = .Center
        labelTitle.text = "Your Primary/Log In Email"
        self.view.addSubview(labelTitle)
        
        labelEmail = UILabel(frame: CGRectMake(0,122,screenWidth,30))
        labelEmail.textAlignment = .Center
        labelEmail.text = userEmail
        self.view.addSubview(labelEmail)
        
        buttonVerify = UIButton(frame: CGRectMake(99,213,217,39))
        buttonVerify.setTitle("Verify", forState: .Normal)
        buttonVerify.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonVerify.layer.cornerRadius = 7
        self.view.addSubview(buttonVerify)
        
        buttonChange = UIButton(frame: CGRectMake(99,283,217,39))
        buttonChange.setTitle("Change", forState: .Normal)
        buttonChange.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonChange.layer.cornerRadius = 7
        self.view.addSubview(buttonChange)
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
