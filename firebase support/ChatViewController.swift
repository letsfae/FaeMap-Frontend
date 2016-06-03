//
//  ChatViewController.swift
//  iPark
//
//  Created by blesssecret on 9/1/15.
//  Copyright (c) 2015 carryof. All rights reserved.
//

import UIKit


class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var tableViewChat: UITableView!
    
//    @IBOutlet weak var tableViewChat: UITableView!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let cellIdentifier = "chatCell1"
    var textField : UITextField!
    
    var dictChatIDNameSorted : [String: String] = [:]
    var dictChatIDLastMessage: [String: String] = [:]
    var dictChatIDUserImageURL : [String : String] = [:]
    var arrayChat : NSArray!
    
    var chatIDSorted = [String]()
    let defaultImageURL = "http://www.5525.org/Upload/doc/20150318/3bb54498f22e4359bc5b040bd6975e9c.jpg"
    
    let firebaseURLPrefix = "https://parku.firebaseio.com/chat/"
    //parku.firebaseio.com/chat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewChat = UITableView(frame: CGRectMake(0,0 , screenWidth, screenHeight-64), style: .Plain)
        tableViewChat.delegate=self
        tableViewChat.dataSource=self
        tableViewChat.rowHeight = 60
        tableViewChat.registerNib(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.view.addSubview(tableViewChat)
        //        self.createTypingView()
        
    }
    override func viewWillAppear(animated: Bool) {
        let currentInstallation : PFInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveInBackground()
        }
    }
    func queryForChatInfo(){
        var UserID : PFUser!
        if let user = PFUser.currentUser()  {
            UserID = user
        }
        var lastMessage_value = [String]()
        
        var query_sender = PFQuery(className: "Notification")
        query_sender.whereKey("userFrom", equalTo: UserID)
//        query_sender.includeKey("userFrom")
        
        var query_receiver = PFQuery(className: "Notification")
        query_receiver.whereKey("userTo", equalTo: UserID)
//        query_sender.includeKey("userTo")
        
        var username = ""
        var faceURL : String? = ""
        var query = PFQuery.orQueryWithSubqueries([query_sender, query_receiver])
//        var query=PFQuery(className: "Notification")
//        query.whereKey("userFrom", equalTo: UserID)
//        query.whereKey("userTo", equalTo: UserID)
//        query.includeKey("userFrom")
//        query.includeKey("userTo")
        
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            
            if (error != nil) {
                println("There is an error loading parse database")
                println(error)
            } else {
                self.chatIDSorted = []
                if objects!.isEmpty {
                    println("Empty Query")
                }
                else {
                    self.arrayChat = objects as! NSArray
                    
                    if let notificationEntries = objects {
                        for entry in notificationEntries{
                            
                            var authorId = entry["userFrom"] as! PFUser
                            var UserToId = entry["userTo"] as! PFUser
                            var authorId_value = authorId.objectId
                            var UserToId_value = UserToId.objectId
                            
                            lastMessage_value.append(entry["authorMessage"] as! String)
                            
                            
                            if (authorId_value == UserID.objectId) {
                                self.chatIDSorted.append(UserToId_value!)
                            } else {
                                self.chatIDSorted.append(authorId_value!)
                            }
                            
                            println("chat id value sorted \(self.chatIDSorted)")
                        }
                    }
                }
            }
            
            for chatID in self.chatIDSorted{
                var userQuery : PFQuery = PFUser.query()!
                userQuery.whereKey("objectId", equalTo: chatID)
                userQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                    if (error != nil) {
                        println("error querying user")
                    } else {
                        if (objects!.isEmpty){
                            println("Empty query")
                        } else {
                            println(objects)
                            if let userobject = objects {
                                for object in userobject {
                                    
//                                    username = object["nickname"] as? String
                                    username="Anoymous"
                                    if let nickname=object["nickname"] as? String{
                                        username=nickname
                                    }
                                    faceURL  = object["faceURL"] as? String
                                    let user=object as! PFUser
                                    let chatID:String = user.objectId!
                                    if let i = find(self.chatIDSorted, chatID) {
                                        self.dictChatIDLastMessage[chatID] = lastMessage_value[i]
                                    } else {
                                        println("chat id not in the list, not possible")
                                    }
                                    
                                    self.dictChatIDNameSorted[chatID] = username
                                    println(faceURL)
                                    if let ImgURL = faceURL {
                                        self.dictChatIDUserImageURL[chatID] = ImgURL
                                    } else {
                                        self.dictChatIDUserImageURL[chatID] = self.defaultImageURL
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    /* chatIDSorted stores all the IDs sorted. Iterate through this array, it will give you the order and key to access other dictionaries */
                    
                    if self.dictChatIDUserImageURL.count == self.chatIDSorted.count {
                        self.tableViewChat.reloadData()
                    }
                    
                    println("chatId sorted \(self.chatIDSorted)")
                    println("username sorted \(self.dictChatIDNameSorted)")
                    println("last message \(self.dictChatIDLastMessage)")
                    println("image url \(self.dictChatIDUserImageURL)")
                    
                })
            }
            
        }

    }
    override func viewDidAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        if let currentUser = PFUser.currentUser(){
            //            println("user has already logged in, ready to chat")
            self.queryForChatInfo()
        }
        else {
            var alert = UIAlertView(title: "Error", message: "User has not logged in.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        
        /* clear the push notification badges */
        let currentInstallation : PFInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveInBackground()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)as! ChatTableViewCell
        let object = arrayChat[indexPath.row] as! PFObject
//        let url = NSURL(string: object["authorImg"]as! String)
        var url = NSURL(string: defaultImageURL)
//        if let strUrl=object["authorImg"]as? String
        let userTo=object.objectForKey("userTo") as! PFUser
        let userFrom=object.objectForKey("userFrom") as! PFUser
        
//        if let strUrl = object.objectForKey("authorImg")as? String
//        {
//            url=NSURL(string:strUrl);
//        }
        if userTo.objectId == PFUser.currentUser()?.objectId {
            //send to me
            cell.labelTitle.text=self.dictChatIDNameSorted[userFrom.objectId!]
            url=NSURL(string:dictChatIDUserImageURL[userFrom.objectId!]!)
        }
        else {
//            send to him
//            cell.labelTitle.text=userTo.objectForKey("nickname") as? String
//            if let strUrl=userTo.objectForKey("faceURL")as? String {
//                url=NSURL(string: strUrl)
//            }
            cell.labelTitle.text=self.dictChatIDNameSorted[userTo.objectId!]
            println(userTo.objectId)
            println(userTo)
            url=NSURL(string:dictChatIDUserImageURL[userTo.objectId!]!)
        }
        
        if object.objectForKey("isRead")as! Bool == false {
            if object.objectForKey("userToId")as! String == PFUser.currentUser()?.objectId {
                //send to me
                cell.viewNewMessage.backgroundColor = UIColor.redColor()
            }
            else {
                cell.viewNewMessage.backgroundColor = UIColor.clearColor()
            }
        }
        else {
            cell.viewNewMessage.backgroundColor = UIColor.clearColor()
        }
//        if let name = object.objectForKey("authorName") as? String {
//            cell.labelTitle.text = name
//        }
        cell.imageViewProfile.sd_setImageWithURL(url)
        //        cell.labelNameAndTime.text =
//        cell.labelDetail.text=object["authorMessage"] as! String
        cell.labelDetail.text=object.objectForKey("authorMessage")as? String
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = self.arrayChat {
            return self.arrayChat.count
        }
        //        return self.arrayChat.count
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DetailedChatViewController") as! DetailedChatViewController
        let rowIndex = indexPath.row;
        
//        println(self.chatIDSorted)
//        println(rowIndex)
        let targetUserChatId = self.chatIDSorted[rowIndex]

        vc.targetUserID = targetUserChatId
        let object = arrayChat[indexPath.row]as! PFObject
        if object.objectForKey("userToId")as! String == PFUser.currentUser()?.objectId {
            //send to me
            object.setObject(true, forKey: "isRead")
        }
        object.saveInBackground()
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
