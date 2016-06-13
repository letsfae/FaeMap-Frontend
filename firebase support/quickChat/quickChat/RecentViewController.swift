//
//  RecentViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseUserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecents()
        
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let recent = recents[indexPath.row]
        
        //create recent for both users
        
        restartRecentChat(recent)
        
        performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let recent = recents[indexPath.row]
        
        //remove recent form the array
        
        recents.removeAtIndex(indexPath.row)
        
        //delect recent from firebase
        
        DeleteRecentItem(recent)
        
        tableView.reloadData()
    }

    
    
    //MARK: action
    
    @IBAction func startNewChatBarButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    //MARK : UItableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecentTableViewCell
        let recent = recents[indexPath.row]
        
        cell.bindData(recent)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recentToChooseUserVC" {
            let vc = segue.destinationViewController as! ChooseUserViewController
            
            vc.delegate = self
        } else if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! ChatViewController
            
            chatVC.hidesBottomBarWhenPushed = true
            
            let recent = recents[indexPath.row]
            
            chatVC.recent = recent
            
            chatVC.chatRoomId = recent["chatRoomId"] as? String
            
            // set chatVC recent to our recent.
            
        }
    }
    
    func createChatroom(withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatVC, animated: true)
        // set chatVC recent to our recent.
        
        chatVC.withUser = withUser
        
        chatVC.chatRoomId = startChat(backendless.userService.currentUser, user2: withUser)
        
    }
    
    //MARK: load recents form firebase
    
    func loadRecents() {
        
        firebase.child("Recent").queryOrderedByChild("userId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value) { (snapshot : FIRDataSnapshot) in
            self.recents.removeAll()
            
            if snapshot.exists() {
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                for recent in sorted {
                    self.recents.append(recent as! NSDictionary)
                    // add function to have offline access as well
                firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(recent["ChatRoomId"]).observeEventType(.Value, withBlock: { (snapshot : FIRDataSnapshot) in
                    })
                }
                self.tableView.reloadData()
            }
        }
    }
}
