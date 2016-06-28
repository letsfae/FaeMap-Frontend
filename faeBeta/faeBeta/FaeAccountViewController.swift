//
//  FaeAccountViewController.swift
//  faeBeta
//
//  Created by blesssecret on 6/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeAccountViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var myTableView : UITableView!
    let cellGeneralIdentifier = "cellGeneral"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTableView()
        // Do any additional setup after loading the view.
    }
    func addTableView(){
        myTableView = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight),style: .Grouped)
        myTableView.delegate = self
        myTableView.dataSource = self
        self.view.addSubview(myTableView)
        myTableView.rowHeight = 54
        myTableView.registerNib( UINib(nibName: "MyFaeGeneralTableViewCell", bundle: nil), forCellReuseIdentifier: cellGeneralIdentifier)
        myTableView.backgroundColor = UIColor.clearColor()
        myTableView.separatorColor = UIColor.clearColor()
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
extension FaeAccountViewController: UITableViewDelegate , UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 11
        if section == 0 {
            return 4
        }
        if section == 1 {
            return 4
        }
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellGeneralIdentifier)as! MyFaeGeneralTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        cell.labelTitle.text = String(indexPath.row)
        //section 0
        if indexPath.section == 0 && indexPath.row  == 0 {
            cell.labelTitle.text = "First name"
        }
        if indexPath.section == 0 && indexPath.row  == 1 {
            cell.labelTitle.text = "Last Name"
        }
        if indexPath.section == 0 && indexPath.row  == 2 {
            cell.labelTitle.text = "Birthday"
        }
        if indexPath.section == 0 && indexPath.row  == 3 {
            cell.labelTitle.text = "Gender"
        }
        //section 1
        if indexPath.section == 1 && indexPath.row  == 0 {
            cell.labelTitle.text = "Email"
        }
        if indexPath.section == 1 && indexPath.row  == 1 {
            cell.labelTitle.text = "Username"
        }
        if indexPath.section == 1 && indexPath.row  == 2 {
            cell.labelTitle.text = "Phone"
        }
        if indexPath.section == 1 && indexPath.row  == 3 {
            cell.labelTitle.text = "Change Password"
        }
        //section 2
        if indexPath.section == 2 && indexPath.row  == 0 {
            cell.labelTitle.text = "My Account"
        }
        if indexPath.section == 2 && indexPath.row  == 1 {
            cell.labelTitle.text = "Log Out"
        }
        if indexPath.section == 2 && indexPath.row  == 2 {
            cell.labelTitle.text = "Request Close Account"
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        section 0
        if indexPath.section == 0 && indexPath.row  == 0 {
            
        }
        if indexPath.section == 0 && indexPath.row  == 1 {
            
        }
        if indexPath.section == 0 && indexPath.row  == 2 {
//            cell.labelTitle.text = "Birthday"
        }
        if indexPath.section == 0 && indexPath.row  == 3 {
//            cell.labelTitle.text = "Gender"
        }
        //section 1
        if indexPath.section == 1 && indexPath.row  == 0 {
//            cell.labelTitle.text = "Email"
        }
        if indexPath.section == 1 && indexPath.row  == 1 {
//            cell.labelTitle.text = "Username"
        }
        if indexPath.section == 1 && indexPath.row  == 2 {
//            cell.labelTitle.text = "Phone"
        }
        if indexPath.section == 1 && indexPath.row  == 3 {
//            cell.labelTitle.text = "Change Password"
        }
        //section 2
        if indexPath.section == 2 && indexPath.row  == 0 {
//            cell.labelTitle.text = "My Account"
        }
        if indexPath.section == 2 && indexPath.row  == 1 {
//            cell.labelTitle.text = "Log Out"
        }
        if indexPath.section == 2 && indexPath.row  == 2 {
//            cell.labelTitle.text = "Request Close Account"
        }

    }
}
