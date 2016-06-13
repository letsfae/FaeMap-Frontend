//
//  AppDelegate.swift
//  quickChat
//
//  Created by User on 6/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    //NSLocationWhenInUseUsageDescription = your text
    
    var locationManager : CLLocationManager?
    var coordinate : CLLocationCoordinate2D?
    
    let APP_ID = "D0956627-FB0B-3962-FFF9-34E6AD3A7600"
    let SECRET_KEY = "53419A71-7646-43AB-FF96-7C5D37B00500"
    let VERSION_NUM = "v1"
    
//    var backendless = Backendless.sharedInstance()
    
    var window: UIWindow?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        FIRDatabase.database().persistenceEnabled = true
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        locationManagerStart()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        locationManagerStop()
    }
    
    //Mark: locationManager

    func locationManagerStart() {
        if locationManager == nil {
            print("init locationManager")
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        locationManager!.stopUpdatingLocation()
    }
    //MARK : CLLocation
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        coordinate = newLocation.coordinate
        
    }
}

