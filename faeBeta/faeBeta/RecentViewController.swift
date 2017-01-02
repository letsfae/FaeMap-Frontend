//
//  RecentViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SwiftyJSON

public var isDraggingRecentTableViewCell = false
public var avatarDic = [NSNumber:UIImage]() // an dictionary to store avatar, this should be moved to else where later

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeableCellDelegate {
    
    //MARK: - properties
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var recents: JSON? // an array of dic to store recent chatting informations
    private var cellsCurrentlyEditing: NSMutableSet! = NSMutableSet() // a set storing all the cell that the delete button is displaying
    private var loadingRecentTimer: Timer!
    
    // MARK: - View did/will funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        navigationBarSet()
        addGestureRecognizer()
        downloadCurrentUserAvatar()

        if let recentData = UserDefaults.standard.array(forKey: user_id.stringValue + "recentData"){
            self.recents = JSON(recentData)
            self.tableView.reloadData()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingRecentTimer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingRecentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startCheckingRecent), userInfo: nil, repeats: true)
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
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = "Social"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "locationPin"), style: .plain, target: self, action: #selector(RecentViewController.navigationLeftItemTapped))
        
        //ATTENTION: Temporary comment it here because it's not used for now
//        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(RecentViewController.navigationRightItemTapped)),UIBarButtonItem.init(image: UIImage(named: "cross"), style: .Plain, target: self, action: #selector(RecentViewController.crossTapped))]
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 86 , bottom: 0, right: 0)
    }
    
    private func addGestureRecognizer()
    {
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecentViewController.closeAllCell)))
    }
    
    func navigationLeftItemTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(cellsCurrentlyEditing.count == 0){
            tableView.deselectRow(at: indexPath, animated: true)
            
            if let recent = recents?[indexPath.row]{
                if recent["with_user_id"].number != nil{
                    performSegue(withIdentifier: "recentToChatSeg", sender: indexPath)
                }
            }
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    //MARK: - UItableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents == nil ? 0 : recents!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        cell.delegate = self
        let recent = recents![indexPath.row]
        
        cell.bindData(recent)

        if (self.cellsCurrentlyEditing.contains(indexPath)) {
            cell.openCell()
        }
        return cell
    }
    //MARK: - helpers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! IndexPath
            let chatVC = segue.destination as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let recent = recents![indexPath.row]
            chatVC.chatRoomId = user_id.compare(recent["with_user_id"].number!).rawValue < 0 ? "\(user_id.stringValue)-\(recent["with_user_id"].number!)" : "\(recent["with_user_id"].number!)-\(user_id.stringValue)"
            chatVC.chat_id = recent["chat_id"].number?.stringValue
            let withUserUserId = recent["with_user_id"].number?.stringValue
            let withUserName = recent["with_user_name"].string
            chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserUserId, userAvatar: nil)
        }
    }
    
    @objc private func startCheckingRecent(){
        loadRecents(false, removeIndexPaths: nil)
    }
    
    /// download current user's avatar from server
    private func downloadCurrentUserAvatar()
    {
        if(avatarDic[user_id] == nil){
            getImageFromURL(("files/users/" + user_id.stringValue + "/avatar/"), authentication: headerAuthentication(), completion: {(status:Int, image:Any?) in
                if status / 100 == 2 {
                    avatarDic[user_id] = image as? UIImage
                }
            })
        }
    }
    
    //MARK: load recents form server
    
    /// load recent list from server, also used to reload the recent list after deletion
    ///
    /// - Parameters:
    ///   - animated: update the table with/without animation
    ///   - indexPathSet: the specific indexpath set needed to update, set nil if you want to update the whole recent list
    private func loadRecents(_ animated:Bool, removeIndexPaths indexPathSet:[IndexPath]? ) {
        getFromURL("chats", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            if let cacheRecent = result as? NSArray {
//                getFromURL("chat_rooms", parameter: nil, authentication: headerAuthentication()) { (status2, result2) in
//                    if let cacheRecent2 = result2 as? NSArray {
//                        cacheRecent.addingObjects(from: cacheRecent2 as! [Any])
//                        
//                    }
//                }

                let json = JSON(result!)
                self.recents = json
                    UserDefaults.standard.set(cacheRecent, forKey: (user_id.stringValue + "recentData"))

                if(animated && indexPathSet != nil){
                    self.tableView.deleteRows(at: indexPathSet!, with: .left)
                }else{
                    if(!isDraggingRecentTableViewCell){
                        self.tableView.reloadData()
                    }
                }
            }else{
                self.recents = JSON([])
            }
        }

    }
    
    func closeAllCell(_ recognizer:UITapGestureRecognizer){
        let point = recognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            self.tableView(tableView, didSelectRowAt: indexPath)
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRow(at: indexP as! IndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    //MARK: - swipeable cell delegate
    
    func cellwillOpen(_ cell: UITableViewCell) {
        closeAllCell(UITapGestureRecognizer())
    }
    
    func cellDidOpen(_ cell: UITableViewCell)
    {
        let currentEditingIndexPath = self.tableView.indexPath(for: cell)
        if(currentEditingIndexPath != nil){
            self.cellsCurrentlyEditing.add(currentEditingIndexPath!)
        }
    }
    
    func cellDidClose(_ cell: UITableViewCell)
    {
        if(self.tableView.indexPath(for: cell) != nil){
            self.cellsCurrentlyEditing.remove(self.tableView.indexPath(for: cell)!)
        }
    }
    
    func deleteButtonTapped(_ cell: UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let recent = recents![indexPath.row]
        
        //remove recent form the array
        DeleteRecentItem(recent, completion: {(statusCode, result) -> Void in
            if statusCode / 100 == 2{
                self.loadRecents(true, removeIndexPaths: [indexPath])
            }
        })
        
        cellsCurrentlyEditing.remove(indexPath)
    }
}
