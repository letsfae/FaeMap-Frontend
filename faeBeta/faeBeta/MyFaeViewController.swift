//
//  MyFaeViewController.swift
//  faeBeta
//
//  Created by blesssecret on 6/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MyFaeViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    //navigation button at top
    var navigationItemLeft : UIBarButtonItem!
    var navigationItemRight : UIBarButtonItem!
    //uitableview
    var myTableView : UITableView!
    var myFaeGeneralCell : UITableViewCell!
    let cellGeneralIdentifier = "cellGeneral"
    let cellStatusIdentifier = "cellStatus"
    //headerView
    let imageWidth : CGFloat = 125.0
    var viewBackground : UIView!
    var headerView : UIView!
    var headerImageView : UIImageView!
    var headerTitle : UILabel!
    var headerName : UILabel!
    var headerPhone : UILabel!
    //status view
    var viewStatusBackground : UIView!
    var viewStatus : UIView!
    var textInputView : UITextField!
    var stringStatus : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
//        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
        addNavigationBarButton()
        addTableView()
        addHeaderView()
    }
    func addNavigationBarButton(){
        navigationItemLeft = UIBarButtonItem(image: UIImage(named: "MyFaeLeftQR"), style: .Plain, target: self, action: nil)
//        navigationItemLeft.setBackgroundImage(UIImage(named: "MyFaeLeftQR"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        self.navigationItem.leftBarButtonItem = navigationItemLeft
        navigationItemRight = UIBarButtonItem(image: UIImage(named: "MyFaeRightSelf"), style: .Plain, target: self, action: nil)
//        navigationItemRight.setBackgroundImage(UIImage(named: "MyFaeRightSelf"), forState: .Normal, barMetrics: .Default)
        self.navigationItem.rightBarButtonItem = navigationItemRight
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
    func addHeaderView(){
        var heightNow :CGFloat = 0;
        let underLine = UIView(frame: CGRectMake(31,240,screenWidth - 31*2,2 ))
        underLine.backgroundColor = UIColor.grayColor()
        viewBackground = UIView(frame: CGRectMake(0,0,screenWidth,305-64))
        
        headerView = UIView(frame: CGRectMake(0,0,screenWidth,305-64))
        headerView.clipsToBounds = true
        
        headerImageView = UIImageView(frame: CGRectMake((screenWidth-imageWidth)/2, 0, imageWidth, imageWidth))
//        headerImageView.image = UIImage(named: "profile-placeholder")
//        headerImageView.faeSetSelfAvatar(UIImage(named: "profile-placeholder")!)
        
        headerImageView.layer.cornerRadius = imageWidth/2
        headerImageView.layer.masksToBounds = true
        headerImageView.sd_setImageWithURL(NSURL(string: "https://api.letsfae.com/files/avatar/23"))
        
        heightNow += imageWidth
        
        headerTitle = UILabel(frame: CGRectMake((screenWidth-282)/2,imageWidth+19,282,38))
        headerTitle.textAlignment = .Center
        headerTitle.text = "fasdfj;lasdf jk;lasdjflk;asdf"
        heightNow += 38 + 19
        
        headerName = UILabel(frame: CGRectMake(0,heightNow+3,screenWidth,25))
        headerName.textAlignment = .Center
        headerName.clipsToBounds = true
        headerName.text = "unkown people"
        heightNow += 25 + 3
        
        headerPhone = UILabel(frame:CGRectMake(0, heightNow, screenWidth, 22))
        headerPhone.textAlignment = .Center
        headerPhone.text = "123-456-7890"
        headerPhone.clipsToBounds = true
        
//        headerView.addSubview(headerImageView)
        viewBackground.addSubview(underLine)
        viewBackground.addSubview(headerImageView)
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerName)
        headerView.addSubview(headerPhone)
        viewBackground.addSubview(headerView)
        myTableView.tableHeaderView = viewBackground
        myTableView.tableHeaderView?.frame = CGRectMake(0, 0, screenWidth, viewBackground.frame.height)
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
extension MyFaeViewController {//my status
    func addStatusView(){
        viewStatusBackground = UIView(frame:CGRectMake(0,0,screenWidth,screenHeight))
        let buttonBackgroudn = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroudn.addTarget(self, action: "statusViewCancel", forControlEvents: .TouchUpInside)
        viewStatusBackground.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        viewStatusBackground.addSubview(buttonBackgroudn)
        self.view.addSubview(viewStatusBackground)
        
        viewStatus = UIView(frame: CGRectMake(32,106,350,333))
        viewStatus.layer.cornerRadius = 26
        viewStatus.backgroundColor = UIColor.whiteColor()
        viewStatusBackground.addSubview(viewStatus)
        
        let buttonOnline = UIButton(frame: CGRectMake(50,67,50,50))
        buttonOnline.setBackgroundImage(UIImage(named: "online"), forState: .Normal)
        viewStatus.addSubview(buttonOnline)
        
        let buttonNoDistrub = UIButton(frame: CGRectMake(150,67,50,50))
        buttonNoDistrub.setBackgroundImage(UIImage(named: "noDisturb"), forState: .Normal)
        viewStatus.addSubview(buttonNoDistrub)
        
        let buttonBusy = UIButton(frame: CGRectMake(250,67,50,50))
        buttonBusy.setBackgroundImage(UIImage(named: "busy"), forState: .Normal)
        viewStatus.addSubview(buttonBusy)
        
        let buttonAway = UIButton(frame: CGRectMake(50,160,50,50))
        buttonAway.setBackgroundImage(UIImage(named: "away"), forState: .Normal)
        viewStatus.addSubview(buttonAway)
        
        let buttonInvisible = UIButton(frame: CGRectMake(150,160,50,50))
        buttonInvisible.setBackgroundImage(UIImage(named: "invisible"), forState: .Normal)
        viewStatus.addSubview(buttonInvisible)
        
        let buttonOffline = UIButton(frame: CGRectMake(250,160,50,50))
        buttonOffline.setBackgroundImage(UIImage(named: "offline"), forState: .Normal)
        viewStatus.addSubview(buttonOffline)
        
        textInputView = UITextField(frame: CGRectMake(44,249,262,21))
        textInputView.placeholder = "Add a short status message"
        viewStatus.addSubview(textInputView)
        
        let buttonCancel = UIButton(frame: CGRectMake(42,274,266,59))
        buttonCancel.setTitle("Cancel", forState: .Normal)
        buttonCancel.setTitleColor(UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1.0), forState: .Normal)
        viewStatus.addSubview(buttonCancel)

    }
    func statusViewCancel(){
        self.viewStatusBackground.removeFromSuperview()
    }
}
extension MyFaeViewController: UITableViewDelegate,UITableViewDataSource {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let move = scrollView.contentOffset.y
        if move < -64.0 {//scroll down
            /*
             let length = -(64 + move)//length > 0
             print(length)
             headerImageView.frame = CGRectMake((screenWidth-imageWidth)/2.0 - length/2, -length, imageWidth+length, imageWidth+length)
             headerImageView.layer.cornerRadius = headerImageView.frame.width / 2
             */
            //            headerView = UIView(frame: CGRectMake(0,0,screenWidth,241))
            
        }else{
            let length = (64 + move)//length > 0
            //            print(length)
            //view height = 241 image + name = 182; 241 - 182 = 59
            if length < 91 { // max compress
                headerView.frame = CGRectMake(0, length, screenWidth, 241-length)
                headerImageView.frame = CGRectMake((screenWidth - imageWidth)/2 , length, imageWidth, imageWidth)
                //                headerTitle.frame = CGRectMake((screenWidth-282)/2,imageWidth+19+length,282,38)
            }
            if length >= 59 && length < 91 {//hide the name and phone
                var newWidth = imageWidth - (length - 59)//>imageWidth
                //                print(newWidth)
                if newWidth > imageWidth{
                    newWidth = imageWidth
                }
                //                print(newWidth)
                headerImageView.frame = CGRectMake((screenWidth - newWidth)/2, length, newWidth, newWidth)
                
                headerTitle.frame = CGRectMake((screenWidth-282)/2,imageWidth+19-(length-59),282,38)
                //                headerImageView.frame = CGRectMake((screenWidth - imageWidth)/2, length, imageWidth, imageWidth)
            }
            if length >= 91{//stop compress
                headerView.frame = CGRectMake(0, 91, screenWidth, 241-91)
            }
            if length < 59 {//stop hide the name and phone
                
            }
        }
        headerImageView.layer.cornerRadius = headerImageView.frame.width / 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            addStatusView()
        }
        if indexPath.row == 5 {
            jumpToAccount()
        }
    }
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("FaeAccountViewController")as! FaeAccountViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell2 = tableView.dequeueReusableCellWithIdentifier(cellGeneralIdentifier)as! MyFaeGeneralTableViewCell
        cell2.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == 0 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell0")
            cell2.labelTitle.text = "Status"
            return cell2
        }
        else if indexPath.row == 1 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell1")
            cell2.labelTitle.text = "Favorites"
            return cell2
        }
        else if indexPath.row == 2 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell2")
            cell2.labelTitle.text = "My Albums"
            return cell2
        }
        else if indexPath.row == 3 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell3")
            cell2.labelTitle.text = "My Store"
            return cell2
        }
        else if indexPath.row == 4 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell4")
            cell2.labelTitle.text = "Membership"
            return cell2
        }
        else if indexPath.row == 5 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell5")
            cell2.labelTitle.text = "Account"
            return cell2
        }
        else if indexPath.row == 6 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell6")
            cell2.labelTitle.text = "Setting"
            return cell2
        }
        else if indexPath.row == 7 {
            cell2.imageViewTitle.image = UIImage(named: "myFaeCell7")
            cell2.labelTitle.text = "About"
            return cell2
        }
        //else == 8
        cell2.imageViewTitle.image = UIImage(named: "myFaeCell8")
        cell2.labelTitle.text = "Suggest"
        return cell2
    }
    
}

