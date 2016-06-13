//
//  WelcomeViewController.swift
//  quickChat
//
//  Created by User on 6/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        backendless.userService.setStayLoggedIn(true)
        
        if backendless.userService.currentUser != nil {
            dispatch_async(dispatch_get_main_queue(), {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
                
                vc.selectedIndex = 0
                
                self.presentViewController(vc, animated: true, completion: nil)
            })
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
