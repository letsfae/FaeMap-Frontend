//
//  WelcomeViewController.swift
//  faeBeta
//  write by wenye yu
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    var imageWelcome : UIImageView!
    var imageCat : UIImageView!
    var buttonSign : UIButton!
    var buttonJoin : UIButton!
    var buttonAround : UIButton!
    var labelWelcome : UILabel!
    var labelFoot : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadButton()
        loadLabel()
        print(screenWidth)
        print(screenHeigh)
        self.view.backgroundColor = UIColor.redColor()
        // Do any additional setup after loading the view.
    }
    func loadImageView(){
        //        let welcomeWidth = screenWidth*0.48309179
        let welcomeWidth: CGFloat = 200
        let welcomeHeight = screenHeigh*0.19701087
        imageWelcome = UIImageView(frame: CGRectMake(screenWidth/2-welcomeWidth/2, screenHeigh*0.11820652, welcomeWidth, welcomeHeight))
        imageWelcome.image = UIImage(named: "welcome_ballon")
        self.view.addSubview(imageWelcome)
        let catLength = screenHeigh*0.23369565
        imageCat = UIImageView(frame:CGRectMake(screenWidth/2-catLength/2, 0.34239130*screenHeigh, catLength,catLength))
        imageCat.image = UIImage(named: "smile_cat")
        self.view.addSubview(imageCat)
    }
    func loadLabel(){
        let bounds = imageWelcome.frame
        labelWelcome = UILabel(frame: CGRectMake(0,0,bounds.width,bounds.height*0.82))
        labelWelcome.text = "Welcome!"
        labelWelcome.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 36)
        labelWelcome.textColor = UIColor.redColor()
        labelWelcome.textAlignment = .Center
        self.imageWelcome.addSubview(labelWelcome)
        
        let ratioFoot : CGFloat = 0.0679347826
        labelFoot = UILabel(frame: CGRectMake(0,screenHeigh-ratioFoot*screenHeigh,screenWidth,ratioFoot*screenHeigh))
        labelFoot.text = "© 2016 Fae ::: Faevorite, Inc. All Rights Reserved."
        labelFoot.textColor = UIColor.whiteColor()
        labelFoot.textAlignment = .Center
        labelFoot.numberOfLines = 0
        labelFoot.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 11)
        self.view.addSubview(labelFoot)
    }
    func loadButton(){
        let buttonHeigh = screenHeigh*0.0679347826
        let buttonWidth = screenWidth*0.75362319
        buttonSign = UIButton(frame:CGRectMake(screenWidth/2-buttonWidth/2,screenHeigh-screenHeigh*0.38315217,buttonWidth,buttonHeigh))
        buttonSign.setTitle("Sign In!", forState: .Normal)
        buttonSign.titleLabel?.textColor = UIColor.whiteColor()
        buttonSign.titleLabel?.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 18)
        buttonSign.layer.cornerRadius = 10
        buttonSign.layer.masksToBounds = true
        buttonSign.layer.borderWidth = 3
        buttonSign.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.addSubview(buttonSign)
        
        buttonJoin = UIButton(frame:CGRectMake(screenWidth/2-buttonWidth/2,screenHeigh-screenHeigh*0.28260870,buttonWidth,buttonHeigh))
        buttonJoin.setTitle("Join Fae!", forState: .Normal)
        buttonJoin.titleLabel?.textColor = UIColor.whiteColor()
        buttonJoin.titleLabel?.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 18)
        buttonJoin.layer.cornerRadius = 10
        buttonJoin.layer.masksToBounds = true
        buttonJoin.layer.borderWidth = 3
        buttonJoin.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.addSubview(buttonJoin)
        
        let ratioAround : CGFloat = 0.18206522
        buttonAround = UIButton(frame:CGRectMake(screenWidth/2-buttonWidth/2,screenHeigh-screenHeigh*ratioAround,buttonWidth,buttonHeigh))
        buttonAround.setTitle("Let me look around!", forState: .Normal)
        buttonAround.titleLabel?.textColor = UIColor.whiteColor()
        buttonAround.titleLabel?.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 18)
        buttonAround.layer.cornerRadius = 10
        buttonAround.layer.masksToBounds = true
        buttonAround.layer.borderWidth = 3
        buttonAround.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.addSubview(buttonAround)
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
