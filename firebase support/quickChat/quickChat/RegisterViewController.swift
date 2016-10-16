//
//  RegisterViewController.swift
//  quickChat
//
//  Created by User on 6/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var paswordTextField: UITextField!
    
//    var backendless = Backendless.sharedInstance()
    
    var email : String?
    
    var username : String?
    
    var password : String?
    
    var avaterImage : UIImage?
    
    var newUser : BackendlessUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newUser = BackendlessUser()
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
    
    // MARK: -
    @IBAction func registerButtonPressed(sender: UIButton) {
        if emailTextField.text != "" && usernameTextField.text != ""
            && paswordTextField.text != "" {
            
            ProgressHUD.show("Registering...")
            
            email = emailTextField.text
            username = usernameTextField.text
            password = paswordTextField.text
            register(self.email!, username: self.username!, password: self.password!, avatarImage: self.avaterImage)
        } else {
            //warning
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func uploadPhotoButtonPressed(sender: UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let camera = Camera(delegate_ : self)

        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert) in
            camera.presentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library",style: .Default) { (alert) in
            
            camera.PresentPhotoLibrary(self, canEdit: true)
        }

        
        let cancelAction = UIAlertAction(title: "Cancel",style: .Cancel) { (alert) in
            
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK : UIImagepickercontroller delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.avaterImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Backendless user registeration
    func register(email : String, username : String, password : String, avatarImage : UIImage?) {
        if avaterImage == nil {
            newUser!.setProperty("Avatar", object: "")
        } else {
            
            uploadAvatar(avatarImage!, result: { (imageLink) in
                let properties = ["Avatar" : imageLink!]
                
                backendless.userService.currentUser!.updateProperties(properties)
                
                backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser) in
                    print("Updated current user avatar")
                    }, error: { (fault) in
                        print("error couldn't save avatar image \(fault)")
                })
            })
        }
        newUser!.email = email
        newUser!.name = username
        newUser!.password = password
        
        backendless.userService.registering(newUser, response: { (registeredUser : BackendlessUser!) -> Void in
            
            ProgressHUD.dismiss()
            
            self.loginUser(email, username: username, password: password)
            
            self.usernameTextField.text = ""
            
            self.emailTextField.text = ""
            
            self.paswordTextField.text = ""
            
        }) { (fault : Fault!) -> Void in
                print("Server reported an error, couldn't register new user: \(fault)")
        }
    }
    
    func loginUser(email : String, username : String, password : String) {
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) in
            
            //here segue to recents vc
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            
            vc.selectedIndex = 0

            self.presentViewController(vc, animated: true, completion: nil)
            
        }) { (fault : Fault!) in
                print("Server report an error: \(fault)")
        }
    }

}
