//
//  RegisterBaseViewController.swift
//  faeBeta
//
//  Created by Yash on 28/08/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterBaseViewController: UIViewController {

    var tableView: UITableView!
    var btnContinue: UIButton!
    var uiviewBottom: UIView!
    var activeIndexPath: IndexPath?
    var activityIndicator: UIActivityIndicatorView!
    var imgProgress: UIImageView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = true
        addTapGesture()
        self.view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
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
        tap.cancelsTouchesInView = true
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
        let uiviewTop = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70))
        uiviewTop.backgroundColor = .white
        let btnBack = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        btnBack.setImage(#imageLiteral(resourceName: "Fill 1"), for: UIControlState())
        btnBack.setTitleColor(UIColor.blue, for: UIControlState())
        btnBack.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        imgProgress = UIImageView(frame: CGRect(x: view.frame.size.width/2.0 - 45, y: 40, width: 90, height: 10))
        imgProgress.image = UIImage(named: imageNamed)
    
        uiviewTop.addSubview(btnBack)
        uiviewTop.addSubview(imgProgress)
        view.addSubview(uiviewTop)
    }
    
    func backButtonPressed() {}
    
    func createBottomView(_ subview: UIView) {
        uiviewBottom = UIView(frame: CGRect(x: 0, y: screenHeight - 18 - subview.frame.size.height - 30 - 50 * screenHeightFactor, width: view.frame.size.width, height: subview.frame.size.height + 50 * screenHeightFactor + 30 + 18))
        btnContinue = UIButton(frame: CGRect(x: 0, y: subview.frame.size.height + 18, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnContinue.center.x = screenWidth / 2
        btnContinue.layer.cornerRadius = 25 * screenHeightFactor
        btnContinue.layer.masksToBounds = true
        btnContinue.setTitle("Continue", for: UIControlState())
        btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnContinue.backgroundColor = UIColor(red: 255/255, green: 160/255, blue: 160/255, alpha: 1.0)
        
        btnContinue.isEnabled = false
        btnContinue.addTarget(self, action: #selector(self.continueButtonPressed), for: .touchUpInside)
        
        uiviewBottom.addSubview(subview)
        uiviewBottom.addSubview(btnContinue)
        
        view.addSubview(uiviewBottom)
    }
    
    func continueButtonPressed() {}
    
    func enableContinueButton(_ enable: Bool) {
        btnContinue.isEnabled = enable
        if enable {
            btnContinue.backgroundColor = UIColor._2499090()
        } else {
            btnContinue.backgroundColor = UIColor._255160160()
        }
    }
    
    func createTableView(_ height: CGFloat) {
        tableView = UITableView(frame: CGRect(x: 0, y: 72, width: view.frame.size.width, height: height))
        view.addSubview(tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
    }
    
    func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        
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
        var frameBottom = uiviewBottom.frame
        frameBottom.origin.y = view.frame.height - keyboardFrame.size.height - frameBottom.size.height + 15
        
        var frameTable: CGRect?
        if tableView != nil {
            frameTable = tableView.frame
            frameTable!.origin.y = min(screenHeight - keyboardFrame.size.height - frameBottom.size.height - frameTable!.size.height, 70)
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.uiviewBottom.frame = frameBottom
            if self.tableView != nil {
                self.tableView.frame = frameTable!
            }
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var frameBottom = uiviewBottom.frame
        frameBottom.origin.y = view.frame.height - frameBottom.size.height
        
        var frameTable: CGRect?
        if tableView != nil {
            frameTable = tableView.frame
            frameTable!.origin.y = 70
            tableView.isScrollEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.uiviewBottom.frame = frameBottom
            if self.tableView != nil {
                self.tableView.frame = frameTable!
            }
        })
    }
}
