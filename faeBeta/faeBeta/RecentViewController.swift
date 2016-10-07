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
import SwiftyJSON

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseUserDelegate, SwipeableCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: JSON? // an array of dic to store recent chatting informations
    var cellsCurrentlyEditing: NSMutableSet! = NSMutableSet()
    
    // MARK: - View did/will funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.tableFooterView = UIView()
        navigationBarSet()
        addGestureRecognizer()
        firebase.keepSynced(true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        firebase.removeAllObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadRecents(false, removeIndexPaths: nil)
    }
    
    /*
     // MARK: - setup
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func navigationBarSet() {

        let sortButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        sortButton.titleLabel?.text = ""
        sortButton.addTarget(self, action: #selector(RecentViewController.sortAlert), forControlEvents: .TouchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = "Social"
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "locationPin"), style: .Plain, target: self, action: #selector(RecentViewController.navigationLeftItemTapped))
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(RecentViewController.navigationRightItemTapped)),UIBarButtonItem.init(image: UIImage(named: "cross"), style: .Plain, target: self, action: #selector(RecentViewController.crossTapped))]
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 86 , bottom: 0, right: 0)
    }
    
    func addGestureRecognizer()
    {
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecentViewController.closeAllCell)))
    }
    
    func crossTapped() {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    func navigationLeftItemTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func navigationRightItemTapped() {
        
    }
    
    //MARK:- tableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(cellsCurrentlyEditing.count == 0){
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
//            let recent = recents![indexPath.row]
            
            //create recent for both users
            
//            restartRecentChat(recent)
            
            performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRowAtIndexPath(indexP as! NSIndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //        let recent = recents[indexPath.row]
        //
        //        //remove recent form the array
        //
        //        recents.removeAtIndex(indexPath.row)
        //
        //        //delect recent from firebase
        //
        //        DeleteRecentItem(recent)
        //
        //        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    //MARK: action
    
    @IBAction func startNewChatBarButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    //MARK: - UItableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents == nil ? 0 : recents!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecentTableViewCell
        cell.delegate = self
        let recent = recents![indexPath.row]
        
        cell.bindData(recent)
        if (self.cellsCurrentlyEditing.containsObject(indexPath)) {
            cell.openCell()
        }
        return cell
    }
    
    //MARK: - helpers
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recentToChooseUserVC" {
            let vc = segue.destinationViewController as! ChooseUserViewController
            vc.delegate = self
        }
        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            
            
            let recent = recents![indexPath.row]
            
//            chatVC.recent = recent
            chatVC.chatRoomId = user_id.compare(recent["with_user_id"].number!).rawValue < 0 ? "\(user_id)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(user_id)"
            let withUserUserId = recent["with_user_id"].number?.stringValue
            let withUserName = "default"
            chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserUserId, userAvatar: nil)
        }
    }
    
    func createChatroom(withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        // set chatVC recent to our recent.
        
//        chatVC.withUser = withUser
        
        chatVC.chatRoomId = startChat(backendless.userService.currentUser, user2: withUser)
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: load recents form firebase
    
    func loadRecents(animated:Bool, removeIndexPaths indexPathSet:[NSIndexPath]? ) {
        getFromURL("chats", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            let json = JSON(result!)
            self.recents = json
            if(animated){
//                let range = NSMakeRange(0, self.tableView.numberOfSections)
//                let sections = NSIndexSet(indexesInRange: range)
//                self.tableView.reloadSections(sections, withRowAnimation: .Left)
                self.tableView.deleteRowsAtIndexPaths(indexPathSet!, withRowAnimation: .Left)
            }else{
                self.tableView.reloadData()
            }
        }

    }
    
    //MARK: sortAlertView
    
    func sortAlert() {
        print("clicked")
        
        let grey = UIColor(red: 146 / 255, green: 146 / 255, blue: 146 / 255, alpha: 1.0)
        
        let meunMessage = NSMutableAttributedString(string: "Sort Chats By")
        
        meunMessage.addAttributes([NSFontAttributeName : UIFont(name: "Avenir Next", size: 18)!, NSForegroundColorAttributeName : grey], range: NSRange(location: 0, length: meunMessage.length))
        
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .ActionSheet)
        
        optionMenu.setValue(meunMessage, forKey: "attributedMessage")
        
        
        let time = UIAlertAction(title: "Time Received", style: .Default) { (aler : UIAlertAction!) in
            print("Take photo")
            
        }
        
        let unread = UIAlertAction(title: "Unread Messages", style: .Default) { (aler : UIAlertAction) in
            print("photo library")
        }
        
        let markers = UIAlertAction(title: "Markers", style: .Default) { (aler : UIAlertAction) in
            print("Share location")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (aler : UIAlertAction) in
            print("Cancel")
        }
        
        optionMenu.addAction(time)
        optionMenu.addAction(unread)
        optionMenu.addAction(markers)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func closeAllCell(recognizer:UITapGestureRecognizer){
        let point = recognizer.locationInView(tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(point) {
            self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRowAtIndexPath(indexP as! NSIndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    //MARK: - swipeable cell delegate
    
    func cellwillOpen(cell: UITableViewCell) {
        closeAllCell(UITapGestureRecognizer())
    }
    
    func cellDidOpen(cell: UITableViewCell)
    {
        let currentEditingIndexPath = self.tableView.indexPathForCell(cell)
        if(currentEditingIndexPath != nil){
            self.cellsCurrentlyEditing.addObject(currentEditingIndexPath!)
        }
    }
    
    func cellDidClose(cell: UITableViewCell)
    {
        if(self.tableView.indexPathForCell(cell) != nil){
            self.cellsCurrentlyEditing.removeObject(self.tableView.indexPathForCell(cell)!)
        }
    }
    
    func deleteButtonTapped(cell: UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let recent = recents![indexPath.row]
        
        //remove recent form the array
//        recents.
        
        //delect recent from firebase
        DeleteRecentItem(recent, completion: {(statusCode, result) -> Void in
            if statusCode / 100 == 2{
                self.loadRecents(true, removeIndexPaths: [indexPath])
            }
        })
        
        cellsCurrentlyEditing.removeObject(indexPath)
    }
}
