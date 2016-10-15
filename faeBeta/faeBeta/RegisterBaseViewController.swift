//
//  RegisterBaseViewController.swift
//  faeBeta
//
//  Created by Yash on 28/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterBaseViewController: UIViewController {
    
    // MARK: - Variables
    
    var tableView: UITableView!
    var continueButton: UIButton!
    var bottomView: UIView!
    var activeIndexPath: NSIndexPath?
    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
        addTapGesture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForNotifications()
        createActivityIndicator()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        deRegisterForNotification()
    }
    
    // MARK: - Functions
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterBaseViewController {
    
    func createTopView(imageNamed: String) {
        let topView = UIView(frame: CGRectMake(0, 20, view.frame.size.width, 50))
        topView.backgroundColor = UIColor.whiteColor()
        
        let backButton = UIButton(frame: CGRectMake(10, 5, 40, 40))
        backButton.setImage(UIImage(named: "Fill 1"), forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed), forControlEvents: .TouchUpInside)
        
        let progressImageView = UIImageView(frame: CGRectMake(view.frame.size.width/2.0 - 45, 20, 90, 10))
        
        progressImageView.image = UIImage(named: imageNamed)
        
        
        topView.addSubview(backButton)
        topView.addSubview(progressImageView)
        
        view.addSubview(topView)
    }
    
    func backButtonPressed() {
        
    }
    
    func createBottomView(subview: UIView) {
        
        bottomView = UIView(frame: CGRectMake(0, screenHeight - 18 - subview.frame.size.height - 30 - 50 * screenHeightFactor, view.frame.size.width, subview.frame.size.height + 50 * screenHeightFactor + 30 + 18))
        
        continueButton = UIButton(frame: CGRectMake(0, subview.frame.size.height + 18, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        continueButton.center.x = screenWidth / 2
        continueButton.layer.cornerRadius = 25 * screenHeightFactor
        continueButton.layer.masksToBounds = true
        
        continueButton.setTitle("Continue", forState: .Normal)
        continueButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 20)
        
        continueButton.backgroundColor = UIColor(red: 255/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1.0)
        
        
        continueButton.enabled = false
        continueButton.addTarget(self, action: #selector(self.continueButtonPressed), forControlEvents: .TouchUpInside)
        
        bottomView.addSubview(subview)
        bottomView.addSubview(continueButton)
        
        view.addSubview(bottomView)
    }
    
    func continueButtonPressed() {
        
    }
    
    func enableContinueButton(enable: Bool) {
        continueButton.enabled = enable
        
        if enable {
            continueButton.backgroundColor = UIColor.faeAppRedColor()
        } else {
            continueButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        }
    }
    
    func createTableView(height: CGFloat) {
        tableView = UITableView(frame: CGRectMake(0, 70, view.frame.size.width, height))
        view.addSubview(tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        tableView.scrollEnabled = false
        
    }
    
    func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
    
    func showActivityIndicator() {
        shouldShowActivityIndicator(true)
    }
    
    func hideActivityIndicator() {
        shouldShowActivityIndicator(false)
    }
    
    func shouldShowActivityIndicator(show: Bool) {
        
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        view.userInteractionEnabled = !show
    }
    
}

extension RegisterBaseViewController {
    
    func registerForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func deRegisterForNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - keyboardFrame.size.height - bottomViewFrame.size.height + 15
        
        var tableViewFrame: CGRect?
        
        if tableView != nil {
            tableViewFrame = tableView.frame
            tableViewFrame!.origin.y = min(screenHeight - keyboardFrame.size.height - bottomViewFrame.size.height - tableViewFrame!.size.height, 70)
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
            if self.tableView != nil {
                self.tableView.frame = tableViewFrame!
            }
            
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        
        var tableViewFrame: CGRect?
        
        if tableView != nil {
            tableViewFrame = tableView.frame
            tableViewFrame!.origin.y = 70
            tableView.scrollEnabled = false
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
            if self.tableView != nil {
                self.tableView.frame = tableViewFrame!
            }
        })
    }
}
