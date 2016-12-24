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
    var activeIndexPath: IndexPath?
    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForNotifications()
        createActivityIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        deRegisterForNotification()
    }
    
    // MARK: - Functions
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterBaseViewController {
    
    func createTopView(_ imageNamed: String) {
        let topView = UIView(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: 50))
        topView.backgroundColor = UIColor.white
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 5, width: 40, height: 40))
        backButton.setImage(UIImage(named: "Fill 1"), for: UIControlState())
        backButton.setTitleColor(UIColor.blue, for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let progressImageView = UIImageView(frame: CGRect(x: view.frame.size.width/2.0 - 45, y: 20, width: 90, height: 10))
        
        progressImageView.image = UIImage(named: imageNamed)
        
        
        topView.addSubview(backButton)
        topView.addSubview(progressImageView)
        
        view.addSubview(topView)
    }
    
    func backButtonPressed() {
        
    }
    
    func createBottomView(_ subview: UIView) {
        
        bottomView = UIView(frame: CGRect(x: 0, y: screenHeight - 18 - subview.frame.size.height - 30 - 50 * screenHeightFactor, width: view.frame.size.width, height: subview.frame.size.height + 50 * screenHeightFactor + 30 + 18))
        
        continueButton = UIButton(frame: CGRect(x: 0, y: subview.frame.size.height + 18, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        continueButton.center.x = screenWidth / 2
        continueButton.layer.cornerRadius = 25 * screenHeightFactor
        continueButton.layer.masksToBounds = true
        
        continueButton.setTitle("Continue", for: UIControlState())
        continueButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold",size: 20)
        
        continueButton.backgroundColor = UIColor(red: 255/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1.0)
        
        
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(self.continueButtonPressed), for: .touchUpInside)
        
        bottomView.addSubview(subview)
        bottomView.addSubview(continueButton)
        
        view.addSubview(bottomView)
    }
    
    func continueButtonPressed() {
        
    }
    
    func enableContinueButton(_ enable: Bool) {
        continueButton.isEnabled = enable
        
        if enable {
            continueButton.backgroundColor = UIColor.faeAppRedColor()
        } else {
            continueButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        }
    }
    
    func createTableView(_ height: CGFloat) {
        tableView = UITableView(frame: CGRect(x: 0, y: 70, width: view.frame.size.width, height: height))
        view.addSubview(tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
    }
    
    func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func showActivityIndicator() {
        shouldShowActivityIndicator(true)
    }
    
    func hideActivityIndicator() {
        shouldShowActivityIndicator(false)
    }
    
    func shouldShowActivityIndicator(_ show: Bool) {
        
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        view.isUserInteractionEnabled = !show
    }
    
}

extension RegisterBaseViewController {
    
    func registerForNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func deRegisterForNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - keyboardFrame.size.height - bottomViewFrame.size.height + 15
        
        var tableViewFrame: CGRect?
        
        if tableView != nil {
            tableViewFrame = tableView.frame
            tableViewFrame!.origin.y = min(screenHeight - keyboardFrame.size.height - bottomViewFrame.size.height - tableViewFrame!.size.height, 70)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
            if self.tableView != nil {
                self.tableView.frame = tableViewFrame!
            }
            
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        
        var tableViewFrame: CGRect?
        
        if tableView != nil {
            tableViewFrame = tableView.frame
            tableViewFrame!.origin.y = 70
            tableView.isScrollEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
            if self.tableView != nil {
                self.tableView.frame = tableViewFrame!
            }
        })
    }
}
