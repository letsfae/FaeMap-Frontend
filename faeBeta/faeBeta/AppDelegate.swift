//
//  AppDelegate.swift
//  faeBeta
//
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseDatabase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navRealMap = UINavigationController()
    var navMapBoard = UINavigationController()
    
    // Reachability variables
    var vcPresented = false
    var reachaVCPresented = false
    var reachaVC = DisconnectionViewController()
    private var reachability: Reachability!
    
    // Q: Firebase? - Yue Shen
    let APP_ID = "60A2681A-584D-1FFF-FF96-54077F888200"
    let SECRET_KEY = "E6A7F879-B983-84D0-FFE4-B4140D42FC00"
    let VERSION_NUM = "v1"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        self.reachability = Reachability.init()
        do {
            try self.reachability.startNotifier()
        } catch {
        }
        
        GMSServices.provideAPIKey(GoogleMapKey)
        GMSPlacesClient.provideAPIKey(GoogleMapKey)
        
        let notificationType: UIUserNotificationType = [.alert, .badge, .sound]
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        // Config Realm Database
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { _, _ in
                //                migration.enumerateObjects(ofType: NewFaePin.className()) { oldObject, newObject in
                //                    if oldSchemaVersion < 3 {
                //                        newObject!["pinType"] = "\(oldObject?["pinType"])"
                //                    }
                //                }
        }
        )
        
        // Delete all realm swift database data
        do {
            try FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {}
        
        headerUserAgent = UIDevice.current.modelName + " " + UIDevice.current.systemVersion
        
        let vcEmptyRoot = EmptyRootViewController()
        navRealMap.viewControllers = [vcEmptyRoot]
        navRealMap.navigationBar.isHidden = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navRealMap
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Network Check
    func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        if reachability.isReachable && self.reachaVCPresented {
            // print("[AppDelegate | reachabilityChanged] vc.isBeingPresented")
            self.reachaVC.dismiss(animated: true, completion: nil)
            self.reachaVCPresented = false
        } else if !reachability.isReachable && !self.reachaVCPresented {
            // print("[AppDelegate | reachabilityChanged] Network not reachable")
            self.reachaVCPresented = true
            self.window?.makeKeyAndVisible()
            self.window?.visibleViewController?.present(self.reachaVC, animated: true, completion: nil)
        }
    }
    
    func openSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func popUpEnableLocationViewController() {
        let vc: UIViewController = UIStoryboard(name: "EnableLocationAndNotification", bundle: nil).instantiateViewController(withIdentifier: "EnableLocationViewController") as! EnableLocationViewController
        self.window?.makeKeyAndVisible()
        self.window?.visibleViewController?.present(vc, animated: true, completion: nil)
    }
    
    func popUpWelcomeView() {
        let vc = WelcomeViewController()
        self.window?.makeKeyAndVisible()
        self.window?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        headerDeviceID = token
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        if identifier == "answerAction" {
            
        } else if identifier == "declineAction" {
            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UIApplication.shared.applicationIconBadgeNumber += 1
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        if error._code == 3010 { // work at simulate do nothing here
            print("simulator doesn't have token id")
        }
        //        self.openSettings()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("[applicationWillResignActive]")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("[applicationDidEnterBackground]")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "appWillEnterForeground"), object: nil)
        print("[applicationWillEnterForeground]")
        let authstate = CLLocationManager.authorizationStatus()
        if authstate != .authorizedAlways {
            print("[applicationWillEnterForeground]")
            self.popUpEnableLocationViewController()
        }
    }
    
    func runSync() {
        if is_Login == 0 {
            print("not log in, sync fail")
        } else {
            let push = FaePush()
            push.getSync({ (status: Int!, _: Any?) in
                //                print("[runSync] status", status)
                if status / 100 == 2 {
                    self.reachaVCPresented = false
                    // success
                } else if status == 401 {
                    self.reachaVCPresented = false
                    is_Login = 0
                    self.popUpWelcomeView()
                } else if !self.reachaVCPresented {
                    self.reachaVCPresented = true
                    self.window?.makeKeyAndVisible()
                    self.window?.visibleViewController?.present(self.reachaVC, animated: true, completion: nil)
                }
            })
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let shareAPI = LocalStorageManager()
        _ = shareAPI.readLogInfo()
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(AppDelegate.runSync), userInfo: nil, repeats: true)
        
        self.runSync()
        let isFirstLaunch = shareAPI.isFirstPushLaunch()
        //        let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
        //        print(notificationType?.types)
        if isFirstLaunch == true {
            // waiting
        } else {
            /* while (true) {
             let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()
             print(notificationType?.types)
             } */
            let seconds = 30.0
            let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                let authstate = CLLocationManager.authorizationStatus()
                if authstate != .authorizedAlways {
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
        if let vc = self.window?.visibleViewController {
            if vc is FaeMapViewController {
                //                print("is FaeMap")
                if let faeMapVC = vc as? FaeMapViewController {
                    faeMapVC.appBackFromBackground()
                    faeMapVC.animateMapFilterArrow()
                    faeMapVC.filterCircleAnimation()
                }
            } else if vc is PinDetailViewController {
                //                print("is PinDetail")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "fae.faeBeta" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "faeBeta", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(vc: self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(vc: nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(vc: tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: pvc)
            } else {
                return vc
            }
        }
    }
}
