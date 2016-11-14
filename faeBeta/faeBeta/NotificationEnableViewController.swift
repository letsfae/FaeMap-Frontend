//
//  NotificationEnableViewController.swift
//  faeBeta
//  write by tianming li
//  Created by blesssecret on 6/10/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NotificationEnableViewController: UIViewController {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeigh = UIScreen.main.bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    var buttonTest : UIButton!
    var buttonTryAgain : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadGoToSettingButton()
        loadTryAgainButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.actionTry()
    }
    func loadGoToSettingButton(){
        let buttonTestWidth = screenWidth * 0.83091787
        let buttonTestHeight : CGFloat = 50.0
        //let buttonSubmitHeight = screenHeight * 0.05842391
        
        buttonTest = UIButton(frame: CGRect(x: 30, y: 100, width: buttonTestWidth, height: buttonTestHeight))
        //buttonSubmit = UIButton(frame: CGRectMake(screenWidth/2-172, 498, 344, 43))
        buttonTest.setTitle("Go to settings to enable notification", for: UIControlState())
        buttonTest.titleLabel?.textColor = UIColor.blue
        buttonTest.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonTest.layer.cornerRadius = 7
        buttonTest.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)
        //        buttonSubmit.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonTest)
    }
    //    go back to the initial view
    func loadTryAgainButton(){
        let buttonTryAgainWidth = screenWidth * 0.83091787
        let buttonTryAgainHeight : CGFloat = 50.0
        
        
        buttonTryAgain = UIButton(frame: CGRect(x: 30, y: 300, width: buttonTryAgainWidth, height: buttonTryAgainHeight))
        
        buttonTryAgain.setTitle("Try Again", for: UIControlState())
        buttonTryAgain.titleLabel?.textColor = UIColor.blue
        buttonTryAgain.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonTryAgain.layer.cornerRadius = 7
        buttonTryAgain.addTarget(self, action: #selector(NotificationEnableViewController.actionTry), for: .touchUpInside)
        
        self.view.addSubview(buttonTryAgain)
    }
    
    func openSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    func actionTry(){
        //        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("TabBarViewController")as! TabBarViewController
        //        self.presentViewController(vc, animated: true, completion: nil)
        let notificationType = UIApplication.shared.currentUserNotificationSettings
//        print(notificationType?.types)
        if notificationType?.types == UIUserNotificationType() {
            // waiting
        }
        else{
            self.dismiss(animated: true, completion: nil)
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

//    func showNotificationAlert() {
//        let alertView = UIAlertController(title: "Notification Disabled", message: "Go to settings to enable it", preferredStyle: .Alert)
//        let goToSettingsAction = UIAlertAction(title: "Go to settings", style: .Default){
//            UIAlertAction in
//            print("open settings")
//            self.openSettings()
//        }
//        alertView.addAction(goToSettingsAction)
//
//        let rootVC = self.window!.rootViewController
//        rootVC!.presentViewController(alertView, animated:true, completion:nil)
//    }
