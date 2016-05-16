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
    
    var imageCat : UIImageView!
    var buttonSign : UIButton!
    var buttonJoin : UIButton!
    var buttonAround : UIButton!
    var labelFae : UILabel!
    var labelDescr : UILabel!
    var labelFoot  : UILabel!
    var buttonGuessTour : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadButton()
        loadLabel()
        self.view.frame.origin.y -= 44
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        self.navigationController?.navigationBar.topItem?.title = ""
//        let backItem = UIBarButtonItem(image: UIImage(named:"navigationBack" ), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
//        let backItem1 = UIBarButtonItem(title: "<", style: .Plain, target: nil, action: nil)
//        self.navigationController?.navigationItem.backBarButtonItem = backItem1
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    func loadImageView(){
        let catLength = screenHeigh*0.163043
        print(catLength)
        imageCat = UIImageView(frame:CGRectMake(screenWidth/2-catLength/2, 0.24184*screenHeigh, catLength,catLength))
        imageCat.image = UIImage(named: "welcome_cat")
        self.view.addSubview(imageCat)
    }
    func loadLabel(){
        
        labelFae = UILabel(frame: CGRectMake(screenWidth/2-40,screenHeigh*0.44429348,80,35))
        labelFae.text = "Fae"
        labelFae.textColor = UIColor.blackColor()
        labelFae.textAlignment = .Center
        labelFae.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightRegular)
        self.view.addSubview(labelFae)
        
        labelDescr = UILabel(frame:CGRectMake(screenWidth/2-122,screenHeigh*0.49320652,244,27))
        labelDescr.text = "fun, anytime, everywhere..."
        labelDescr.textColor = UIColor.grayColor()
        labelDescr.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
        self.view.addSubview(labelDescr)
        
        let ratioFoot : CGFloat = 0.06793478
        labelFoot = UILabel(frame: CGRectMake(screenWidth/2-140/2,screenHeigh-ratioFoot*screenHeigh,140,ratioFoot*screenHeigh))
        labelFoot.text = "© 2016 Fae ::: Faevorite, Inc. All Rights Reserved."
        labelFoot.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        labelFoot.textAlignment = .Center
        labelFoot.numberOfLines = 0
        labelFoot.font = UIFont(name: (buttonSign.titleLabel?.font?.fontName)!, size: 10)
        self.view.addSubview(labelFoot)
    }
    func loadButton(){
        
        buttonGuessTour = UIButton(frame: CGRectMake(screenWidth/2-118/2,screenHeigh-screenHeigh*0.29619565,118,22))
//        buttonGuessTour.currentBackgroundImage = UIImage(named: "guess_tours")
        buttonGuessTour.setBackgroundImage(UIImage(named: "guess_tours"), forState: .Normal)
        self.view.addSubview(buttonGuessTour)
        
        let buttonHeigh = screenHeigh*0.0679347826
        let buttonWidth = screenWidth*0.75362319
        buttonJoin = UIButton(frame:CGRectMake(screenWidth/2-buttonWidth/2,screenHeigh-screenHeigh*0.23913043,buttonWidth,buttonHeigh))
        buttonJoin.setTitle("Log In!", forState: .Normal)
        buttonJoin.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        buttonJoin.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
        buttonJoin.layer.cornerRadius = 7
        buttonJoin.layer.masksToBounds = true
        
        buttonJoin.layer.borderColor = UIColor.whiteColor().CGColor
        buttonJoin.addTarget(self, action: #selector(WelcomeViewController.jumpToLogIn), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonJoin)
        
        buttonSign = UIButton(frame:CGRectMake(screenWidth/2-buttonWidth/2,screenHeigh-screenHeigh*0.14402174,buttonWidth,buttonHeigh))
        buttonSign.setTitle("Sign up!", forState: .Normal)
        buttonSign.setTitleColor(UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0), forState: .Normal)
        buttonSign.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightRegular)
        buttonSign.layer.cornerRadius = 7
        buttonSign.layer.masksToBounds = true
        buttonSign.layer.borderWidth = 2
        buttonSign.layer.borderColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0).CGColor
        buttonSign.addTarget(self, action: #selector(WelcomeViewController.jumpToRegister), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonSign)
        
        
        
    }
    func jumpToRegister(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterViewController")as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToLogIn(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("LogInViewController")as! LogInViewController
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
