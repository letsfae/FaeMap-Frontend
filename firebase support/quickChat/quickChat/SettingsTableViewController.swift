//
//  SettingsTableViewController.swift
//  quickChat
//
//  Created by User on 6/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var avatarSwitch: UISwitch!
    
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var termCell: UITableViewCell!
    
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var privacyCell: UITableViewCell!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var headerView: UIView!
    var avatarSwitchStatus = true
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var firstLoad : Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = headerView
        
        imageUser.layer.cornerRadius = imageUser.frame.size.width/2
        imageUser.layer.masksToBounds = true
        
        loadUserDefault()
        updateUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didClickAvatarImage(sender: AnyObject) {
        changePhoto()
    }
    
    @IBAction func avatarSwitchValueChanged(switchState: UISwitch) {
        if switchState.on {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
            print("it is off")
        }
        //save setting
        saveUserDefaults()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return privacyCell
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            return termCell
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            return avatarCell
        }
        if indexPath.section == 1 {
            return logoutCell
        }
        
        return UITableViewCell()
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 25.0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
        
    }
    
    //MARK : change photo
    
    func changePhoto() {
        
        let camera = Camera(delegate_:self)
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert : UIAlertAction) in
            //take photo
            camera.presentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert : UIAlertAction) in
            //choose photo
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert : UIAlertAction) in
            print("cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK : UIImagePickerControllerDelegate function
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        uploadAvatar(image) { (imageLink) in
            
            let properties = ["Avatar" : imageLink!]
            
            backendless.userService.currentUser!.updateProperties(properties)
            
            backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser : BackendlessUser!) in
                
                print("Updated current user \(updatedUser)")
                
                }, error: { (fault : Fault!) in
                    print("error:\(fault)")
            })
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK : user defaults
    
    func saveUserDefaults() {
        userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
    }
    
    func loadUserDefault() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        if !firstLoad! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.boolForKey(kAVATARSTATE)
    }
   
    //MARK : TableView Delegate function
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            showLogoutView()
        }
    }
    
    //MARK : UPDATE UI
    func updateUI() {
        usernameLabel.text = backendless.userService.currentUser.name
        
        avatarSwitch.setOn(avatarSwitchStatus, animated: false)
        
        if let imageLink = backendless.userService.currentUser.getProperty("Avatar") {
            getImageFromURL(imageLink as! String, result: { (image) in
                self.imageUser.image = image
            })
        }
    }
    
    //MARK : helper function
    
    func showLogoutView() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Log out", style: .Destructive) { (alert) in
            // logout user
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in
            print("cancelled")
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func logout() {
        
        backendless.userService.logout()
        //show login view
        
        let loginView = storyboard!.instantiateViewControllerWithIdentifier("loginView")
        self.presentViewController(loginView, animated: true, completion: nil)
        
    }
}
