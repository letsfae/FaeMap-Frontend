//
//  AppDelegate.swift
//  faeBeta
//
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Firebase
import FirebaseDatabase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let APP_ID = "60A2681A-584D-1FFF-FF96-54077F888200"
    let SECRET_KEY = "E6A7F879-B983-84D0-FFE4-B4140D42FC00"
    let VERSION_NUM = "v1"
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //        UIApplication.sharedApplication().registerForRemoteNotifications()
        GMSServices.provideAPIKey(GoogleMapKey)
        
        let notificationType: UIUserNotificationType = [.Alert , .Badge , .Sound]
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        FIRApp.configure()
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        FIRDatabase.database().persistenceEnabled = true
        
        
        return true
    }
    func openSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    func popUpEnableLocationViewController() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("EnableLocationViewController") as! EnableLocationViewController
        
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController!.presentViewController(vc, animated: true, completion:nil)
        
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
//        backendless.messaging.registerForRemoteNotifications()
        /*
         let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
         print(notificationType?.types)
         if notificationType?.types == UIUserNotificationType.None {
         jumpToNotificationEnable()
         }
         else{
         print("Notification enabled")
         }*/
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        //        let token=String(data: deviceToken, encoding: NSUTF8StringEncoding)
        let token = NSString(format: "%@", deviceToken)
        //        print(token)
        //        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        //        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        //        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        //        print(token)
        headerDeviceID = String(token)
        print(headerDeviceID)
        registerDevice(deviceToken)
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if identifier == "answerAction" {
            
        }else if identifier == "declineAction"{
        
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
        if error.code == 3010 {//work at simulate do nothing here
            print("simulator doesn't have token id")
        }
        //        self.openSettings()
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
        NSNotificationCenter.defaultCenter().postNotificationName("appWillEnterForeground", object: nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        let isFirstLaunch = shareAPI.isFirstPushLaunch()
        print(isFirstLaunch)
        //        let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
        //        print(notificationType?.types)
        if isFirstLaunch == true {
            //waiting
        }
        else {
            /*while (true) {
             let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
             print(notificationType?.types)
             }*/
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                let authstate = CLLocationManager.authorizationStatus()
                if(authstate != CLAuthorizationStatus.AuthorizedAlways){
                    self.popUpEnableLocationViewController()
                }
            })
            /*
             let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
             print(notificationType?.types)
             if notificationType?.types == UIUserNotificationType.None {
             jumpToNotificationEnable()
             }
             else{
             print("Notification enabled")
             }*/
        }
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "fae.faeBeta" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("faeBeta", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - backendless register
    func registerDevice(deviceToken:NSData){
        backendless.messagingService.registerDeviceToken(deviceToken,response: {(responseData: String!) -> Void in print("responseData: \(responseData)")
            
            },error :{(fault: Fault!) -> Void in
                print("Backendless register device fault: \(fault)")
        })
    }
    
}

