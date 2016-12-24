//
//  LocationEnableViewController.swift
//  faeBeta
//  wirte by tianming li
//  Created by blesssecret on 6/10/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

class LocationEnableViewController: UIViewController ,CLLocationManagerDelegate {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeigh = UIScreen.main.bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    var buttonSubmit : UIButton!
    var buttonTryAgain : UIButton!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadButton()
        loadTryAgainButton()
        self.locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.actionTry()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus ++++")
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
//            print(".Authorized")
            self.dismiss(animated: true, completion: nil)
            break
        case .denied:
            print(".Denied")
//            jumpToLocationEnable()
            break
        default:
            print("Unhandled authorization status")
            break
            
        }
    }
    func loadButton(){
        let buttonSubmitWidth = screenWidth * 0.83091787
        let buttonSubmitHeight : CGFloat = 50.0
        //let buttonSubmitHeight = screenHeight * 0.05842391
        
        
        buttonSubmit = UIButton(frame: CGRect(x: 20, y: 20, width: buttonSubmitWidth, height: buttonSubmitHeight))
        //buttonSubmit = UIButton(frame: CGRectMake(screenWidth/2-172, 498, 344, 43))
        buttonSubmit.setTitle("Go to Setting to enable location access!", for: UIControlState())
        buttonSubmit.titleLabel?.textColor = UIColor.white
        buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonSubmit.layer.cornerRadius = 7
        
        buttonSubmit.addTarget(self, action: #selector(self.openSettings), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonSubmit)
    }
    
    func loadTryAgainButton(){
        let buttonTryAgainWidth = screenWidth * 0.83091787
        let buttonTryAgainHeight : CGFloat = 50.0
        
        
        buttonTryAgain = UIButton(frame: CGRect(x: 30, y: 300, width: buttonTryAgainWidth, height: buttonTryAgainHeight))
        
        buttonTryAgain.setTitle("Try Again", for: UIControlState())
        buttonTryAgain.titleLabel?.textColor = UIColor.blue
        buttonTryAgain.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonTryAgain.layer.cornerRadius = 7
        buttonTryAgain.addTarget(self, action: #selector(LocationEnableViewController.actionTry), for: .touchUpInside)
        
        self.view.addSubview(buttonTryAgain)
    }
    func openSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    func actionTry(){
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate == .authorizedAlways){
            self.dismiss(animated: true, completion: nil)
        }
        else{
            //nothing here
        }
        
    }    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
