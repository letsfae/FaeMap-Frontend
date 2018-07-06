
//  AppDelegate.swift
//  faeBeta
//
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import RealmSwift
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let navMain = UINavigationController()
    
    // Reachability variables
    var reachaVCPresented = false 
    var reachaVC = DisconnectionViewController()
    var reachability: Reachability!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        configureReachability()
        configureRealm()
        setupNavigationController()
        GMSServices.provideAPIKey("AIzaSyBVHv0Lp-MfiigWhrcEgYv-aTsvrLQ3trE")
//        General.shared.convertCoordinateToAddress(coordinate: CLLocationCoordinate2D(latitude: 37.37643563606646, longitude: -121.95652692326185)) { (result) in
//            if let error = result as? Error {
//                print(error.localizedDescription)
//                return
//            }
//            if let address = result as? String {
//                print(address)
//                return
//            }
//            if let lines = result as? [String] {
//                print(lines)
//            }
//        }
        
        return true
    }
    
    fileprivate func sync(_ completion: @escaping (Int) -> Void) {
        FaePush.shared.getSync { (status, _) in
            completion(status)
        }
    }
    
    fileprivate func setupNavigationController() {
        
        FaeCoreData.shared.readLogInfo()
        
        let vc = LaunchLoadingController()
        navMain.viewControllers = [vc]
        navMain.navigationBar.isHidden = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navMain
        window?.makeKeyAndVisible()
        
        if Key.shared.isFirstUse() {
            let vcRoot = WelcomeViewController()
            Key.shared.navOpenMode = .welcomeFirst
            navMain.setViewControllers([vcRoot], animated: false)
            LocManager.shared.updateCurtLoc() // update user current location
            configureNotifications()
            testReachability()
        } else {
            sync { (status) in
                guard status / 100 == 2 else {
                    let vcRoot = WelcomeViewController()
                    Key.shared.navOpenMode = .welcomeFirst
                    self.navMain.setViewControllers([vcRoot], animated: false)
                    LocManager.shared.updateCurtLoc() // update user current location
                    self.configureNotifications()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                        // if unauthorized, the following will be triggerred when authorization fail, meaning that other device has login to this account
                        if status == 401 {
                            // meaning that current device has been notified with "Another device has logged on" message
                            guard Key.shared.userTokenEncode != "session_lost" else {
                                return
                            }
                            showAlert(title: "Connection Lost", message: "Another device has logged on to Fae Map with this Account!", viewCtrler: vcRoot)
                            FaeCoreData.shared.save("userTokenEncode", value: "session_lost")
                        }
                        // if status is not 401, meaning that connection is lost due to network issues
                        else {
                            showAlert(title: "Connection Lost", message: "please re-login your account!", viewCtrler: vcRoot)
                            FaeCoreData.shared.save("userTokenEncode", value: "session_lost")
                        }
                        self.testReachability()
                    })
                    return
                }
                Key.shared.is_Login = true
                FaeCoreData.shared.save("is_Login", value: Key.shared.is_Login)
                if Key.shared.is_Login, let _ = FaeCoreData.shared.readByKey("signup") {
                    for key in ["signup", "signup_first_name", "signup_last_name", "signup_username", "signup_password", "signup_gender", "signup_dateofbirth", "signup_email"] {
                        FaeCoreData.shared.removeByKey(key)
                    }
                }
                DispatchQueue.main.async {
                    let vcRoot = InitialPageController()
                    Key.shared.navOpenMode = .mapFirst
                    self.navMain.setViewControllers([vcRoot], animated: false)
                    LocManager.shared.updateCurtLoc() // update user current location
                    self.configureNotifications()
                    self.testReachability()
                }
            }
        }
    }
    
    fileprivate func configureNotifications() {
        let notificationType: UIUserNotificationType = [.alert, .badge, .sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    fileprivate func testReachability() {
        if reachability.currentReachabilityStatus == .notReachable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.window?.makeKeyAndVisible()
                self.window?.visibleViewController?.present(DisconnectionViewController.shared, animated: true, completion: nil)
            })
        }
    }
    
    fileprivate func configureReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        reachability = Reachability.init()
        do {
            try reachability.startNotifier()
        } catch {
        
        }
    }
    
    fileprivate func configureRealm() {
        // Config Realm Database
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 14,
            migrationBlock: { _, oldSchemaVersion in
                //                migration.enumerateObjects(ofType: NewFaePin.className()) { oldObject, newObject in
                if oldSchemaVersion < 9 { }
                //                        newObject!["pinType"] = "\(oldObject?["pinType"])"
                //                    }
                //                }
        }
        )
        // Delete all realm swift database data
        /*do {
         try FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
         } catch {}*/
    }
    
    // MARK: - Network Check
    @objc func reachabilityChanged(notification: Notification) {
        let reach = notification.object as! Reachability
        if reach.isReachable && reachaVCPresented {
            // joshprint("[AppDelegate | reachabilityChanged] vc.isBeingPresented")
            DisconnectionViewController.shared.dismiss(animated: true, completion: {
                DisconnectionViewController.shared.lblFailMessage.isHidden = true
            })
            reachaVCPresented = false
        } else if !reach.isReachable && !reachaVCPresented {
            // joshprint("[AppDelegate | reachabilityChanged] Network not reachable")
            reachaVCPresented = true
            window?.makeKeyAndVisible()
            window?.visibleViewController?.present(DisconnectionViewController.shared, animated: true, completion: nil)
        }
    }
    
    func openSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func popUpWelcomeView() {
        let vc = WelcomeViewController()
        window?.makeKeyAndVisible()
        window?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        Key.shared.headerDeviceID = token
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
        if error._code == 3010 { // work at simulate do nothing here
            // print(error)
            // print("simulator doesn't have token id")
        }
        //        self.openSettings()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        // print("[applicationWillResignActive]")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // print("[applicationDidEnterBackground]")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "appWillEnterForeground"), object: nil)
        // print("[applicationWillEnterForeground]")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mapFilterAnimationRestart"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // print("[applicationDidBecomeActive]")
        
        if EnableNotificationViewController.boolCurtVCisNoti {
            checkNotificationStatus()
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
    
    fileprivate func checkNotificationStatus() {
        //        let center = UNUserNotificationCenter.current()
        //        center.getNotificationSettings { (settings) in
        //            if settings.authorizationStatus == .authorized {
        //                print("Push authorized")
        //            } else {
        //                print("Push not authorized")
        //            }
        //        }
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
        if notificationType?.rawValue == 7 {   // notification is on
            // print("notification on")
            UIApplication.shared.keyWindow?.visibleViewController?.dismiss(animated: true)
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
