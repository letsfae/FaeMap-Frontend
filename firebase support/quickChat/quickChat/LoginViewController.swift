//
//  LoginViewController.swift
//  quickChat
//
//  Created by User on 6/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let backendless = Backendless.sharedInstance()
    
    var email : String?
    
    var password : String?

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
    
    //MARK:
    @IBAction func loginBarButtonPressed(sender: UIBarButtonItem) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.email = emailTextField.text
            self.password = passwordTextField.text
            
            //login user
            loginUser(email!, password: password!)
        
        } else {
            //show an error to user
            ProgressHUD.showError("All fields are required")
        }
    }
    
    func loginUser(email : String, password : String) {
        
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) in
            
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
            //segue to recents view
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            
            vc.selectedIndex = 0
            
            self.presentViewController(vc, animated: true, completion: nil)
            
            print("log in!")
            
        }) { (fault : Fault!) in
                print("couldn't log in user: \(fault)")
        }
        
    }

}
