//
//  MyFaeViewController.swift
//  faeBeta
//
//  Created by blesssecret on 6/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

//MARK: 已经作废
import UIKit
//MARK: bug if user not log in
class MyFaeViewController: UIViewController  {
    
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
//    var stringStatus : String!
    var stringInput : String!
    var labelInputNumber : UILabel!
    enum statusForUser{
        case online
        case noDisturb
        case busy
        case away
        case invisible
        case offline
    }
    var statusNow : statusForUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account"
        
        /*
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()//read user id
        let user = FaeUser()
        user.getSelfStatus { (status:Int, message:AnyObject?) in
            print(status)
            print(message)
        }
        user.whereKeyInt("status", value: 0)
        user.whereKey("message", value: "online___")
        user.setSelfStatus { (status:Int, message:AnyObject?) in
            print(status)
            print(message)
        }*/
//        print(user_id)
        
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        
//        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
        addNavigationBarButton()
        addTableView()
        addHeaderView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
    }
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
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
    func refreshHeaderView(){
        
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
//        headerImageView.sd_setImageWithURL(NSURL(string: "https://api.letsfae.com/files/avatar/23"))
        //MARK: image download
        let stringHeaderURL = "https://api.letsfae.com/files/users/" + user_id.stringValue + "/avatar"
        print(user_id)
        headerImageView.sd_setImageWithURL(NSURL(string: stringHeaderURL))//MARK: BUG here
        
        heightNow += imageWidth
        
        headerTitle = UILabel(frame: CGRectMake((screenWidth-282)/2,imageWidth+19,282,38))
        headerTitle.textAlignment = .Center
        headerTitle.text = "fasdfj;lasdf jk;lasdjflk;asdf"
        headerTitle.font = UIFont(name: "AvenirNext-Medium", size: 28.0)
        headerTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        heightNow += 38 + 19
        
        headerName = UILabel(frame: CGRectMake(0,heightNow+3,screenWidth,25))
        headerName.textAlignment = .Center
        headerName.clipsToBounds = true
        headerName.text = "linlinz"
        headerName.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        headerName.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        heightNow += 25 + 3
        
        headerPhone = UILabel(frame:CGRectMake(0, heightNow, screenWidth, 22))
        headerPhone.textAlignment = .Center
        headerPhone.text = "123-456-7890"
        headerPhone.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
        headerPhone.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
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
extension MyFaeViewController: UITextFieldDelegate {//my status
    
    func addStatusView(){
        let fontSize:CGFloat = 12.0
        viewStatusBackground = UIView(frame:CGRectMake(0,0,screenWidth,screenHeight))
        let buttonBackgroudn = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroudn.addTarget(self, action: #selector(MyFaeViewController.statusViewCancel), forControlEvents: .TouchUpInside)
        viewStatusBackground.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        viewStatusBackground.addSubview(buttonBackgroudn)
        self.view.addSubview(viewStatusBackground)
        
        viewStatus = UIView(frame: CGRectMake(32,106,350,333))
        viewStatus.layer.cornerRadius = 26
        viewStatus.backgroundColor = UIColor.whiteColor()
        viewStatusBackground.addSubview(viewStatus)
        
        let buttonOnline = UIButton(frame: CGRectMake(50,67,50,50))
        buttonOnline.setBackgroundImage(UIImage(named: "online"), forState: .Normal)
        buttonOnline.tag = 0
        buttonOnline.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonOnline)
        let labelOnline = UILabel(frame: CGRectMake(87-32,230-106,39,10))
        labelOnline.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelOnline.text = "Online"
        labelOnline.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelOnline)
        
        let buttonNoDistrub = UIButton(frame: CGRectMake(150,67,50,50))
        buttonNoDistrub.setBackgroundImage(UIImage(named: "noDisturb"), forState: .Normal)
        buttonNoDistrub.tag = 1
        buttonNoDistrub.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonNoDistrub)
        let labelNoDistrub = UILabel(frame: CGRectMake(175-32,230-106,63,10))
        labelNoDistrub.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelNoDistrub.text = "No Disturb"
        labelNoDistrub.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelNoDistrub)
        
        let buttonBusy = UIButton(frame: CGRectMake(250,67,50,50))
        buttonBusy.setBackgroundImage(UIImage(named: "busy"), forState: .Normal)
        buttonBusy.tag = 2
        buttonBusy.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonBusy)
        let labelBusy = UILabel(frame: CGRectMake(294-32,230-106,27,13))
        labelBusy.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelBusy.text = "Busy"
        labelBusy.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelBusy)
        
        let buttonAway = UIButton(frame: CGRectMake(50,160,50,50))
        buttonAway.setBackgroundImage(UIImage(named: "away"), forState: .Normal)
        buttonAway.tag = 3
        buttonAway.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonAway)
        let labelAway = UILabel(frame: CGRectMake(91-32,323-106,32,13))
        labelAway.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelAway.text = "Away"
        labelAway.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelAway)
        
        let buttonInvisible = UIButton(frame: CGRectMake(150,160,50,50))
        buttonInvisible.setBackgroundImage(UIImage(named: "invisible"), forState: .Normal)
        buttonInvisible.tag = 4
        buttonInvisible.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonInvisible)
        let labelInvisible = UILabel(frame: CGRectMake(184-32,323-106,46,10))
        labelInvisible.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelInvisible.text = "Invisible"
        labelInvisible.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelInvisible)
        
        let buttonOffline = UIButton(frame: CGRectMake(250,160,50,50))
        buttonOffline.setBackgroundImage(UIImage(named: "offline"), forState: .Normal)
        buttonOffline.tag = 5
        buttonOffline.addTarget(self, action: #selector(MyFaeViewController.actionStatus(_:)), forControlEvents: .TouchUpInside)
        viewStatus.addSubview(buttonOffline)
        let labelOffline = UILabel(frame: CGRectMake(288-32,323-106,39,11))
        labelOffline.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        labelOffline.text = "Offline"
        labelOffline.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 107/255, alpha: 1)
        viewStatus.addSubview(labelOffline)
        
        textInputView = UITextField(frame: CGRectMake(44,249,262,21))
        textInputView.placeholder = "Add a short status message"
        textInputView.textAlignment = .Center
        textInputView.delegate = self
        textInputView.addTarget(self, action: #selector(MyFaeViewController.textInputIsChange), forControlEvents: .EditingChanged)
        viewStatus.addSubview(textInputView)
        
        let underlineInputView = UIView(frame: CGRectMake(42,273,266,2))
        underlineInputView.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewStatus.addSubview(underlineInputView)
        
        labelInputNumber = UILabel(frame: CGRectMake(276,275,50,21))
        labelInputNumber.text = "0/20"
        labelInputNumber.textColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        viewStatus.addSubview(labelInputNumber)
        
        let buttonCancel = UIButton(frame: CGRectMake(42,274,266,59))
        buttonCancel.setTitle("Cancel", forState: .Normal)
        buttonCancel.addTarget(self, action: #selector(MyFaeViewController.statusViewCancel), forControlEvents: .TouchUpInside)
        buttonCancel.setTitleColor(UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1.0), forState: .Normal)
        viewStatus.addSubview(buttonCancel)

    }
    func statusToImageStr(status:statusForUser)->String{
        switch status {
        case .online:
            return "online"
            
        case .noDisturb:
            return "noDisturb"
            
        case .busy:
            return "busy"
            
        case .away:
            return "away"
            
        case .invisible:
            return "invisible"
            
        case .offline:
            return "offline"
            
        default:
            return "online"
        }

    }
    func statusToString(status:statusForUser)->String?{
        switch status {
        case .online:
            return "Online"
            
        case .noDisturb:
            return "No Disturb"
            
        case .busy:
            return "Busy"
            
        case .away:
            return "Away"
            
        case .invisible:
            return "Invisible"
            
        case .offline:
            return "Offline"
            
        default:
            return nil
        }
    }
    func actionStatus(sender:UIButton){
        
        if sender.tag == 0{
            //online
            stringInput = statusToString(.online)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.online
//            print(statusNow)
        }else if sender.tag == 1 {
            stringInput = statusToString(.noDisturb)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.noDisturb
        }else if sender.tag == 2 {
            stringInput = statusToString(.busy)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.busy
        }else if sender.tag == 3 {
            stringInput = statusToString(.away)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.away
        }else if sender.tag == 4 {
            stringInput = statusToString(.invisible)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.invisible
        }else if sender.tag == 5 {
            stringInput = statusToString(.offline)
            if textInputView.text != nil || textInputView.text != "" {
                stringInput = textInputView.text
            }
            statusNow = statusForUser.offline
        }
        let fae = FaeUser()
        fae.whereKeyInt("status", value: sender.tag)
        fae.whereKey("message", value: stringInput)
        fae.setSelfStatus({ (status:Int, message:AnyObject?) in
            if status / 100 == 2 {
                //success
            }else {
                
            }
            })
        statusViewCancel()
        self.myTableView.reloadData()
    }
    func textInputIsChange(){
        let count = textInputView.text!.characters.count
        labelInputNumber.text = String(count) + "/20"
//        print(count)
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        print(newLength)
        return newLength <= 20
    }
    func statusViewCancel(){
        self.viewStatusBackground.removeFromSuperview()
    }
}
extension MyFaeViewController: UITableViewDelegate,UITableViewDataSource {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let move = scrollView.contentOffset.y
        let maxCompress : CGFloat = 120//91
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
            if length < maxCompress { // max compress
                headerView.frame = CGRectMake(0, length, screenWidth, 241-length)
                headerImageView.frame = CGRectMake((screenWidth - imageWidth)/2 , length, imageWidth, imageWidth)
                //                headerTitle.frame = CGRectMake((screenWidth-282)/2,imageWidth+19+length,282,38)
            }
            if length >= 59 && length < maxCompress {//hide the name and phone
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
            if length >= maxCompress {//stop compress
                headerView.frame = CGRectMake(0, maxCompress, screenWidth, 241-maxCompress)
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
            if statusNow != nil {
                if stringInput == nil || stringInput == "" {
                    cell2.labelStatus.text = statusToString(statusNow)
                }else{
                    cell2.labelStatus.text = stringInput
                }
                cell2.imageViewStatus.image = UIImage(named: statusToImageStr(statusNow))
            }
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

