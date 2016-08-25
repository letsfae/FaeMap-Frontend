//
//  WelcomeViewController.swift
//  faeBeta
//  write by wenye yu
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    // MARK: - Interface
    var screenWidth : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.width
        }
    }
    var screenHeight : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.height
        }
    }
    var imageContainerPageViewController : UIPageViewController! 
    var pageControl: WelcomePageControl!
    var lookAroundButton: UIButton!
    var loginButton:UIButton!
    var createAccountButton:UIButton!
    var rightLabel:UILabel!
    
    // MARK: - View did/will
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewFrame()
        setupImageContainerPageViewController()
        setupBottomPart()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupNavigationBar()
    {
        self.navigationController?.navigationBarHidden = true
    }
    
    private func setupViewFrame()
    {
        self.view.frame = CGRectMake(0, 0, self.screenWidth, screenHeight)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    private func setupImageContainerPageViewController()
    {
        pageControl = WelcomePageControl(frame: CGRectMake(screenWidth / 2 - 45, 56, 90, 10))
        pageControl.numberOfPages = 5
        self.view.insertSubview(pageControl, atIndex: 0)
        
        self.imageContainerPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation:.Horizontal, options: [UIPageViewControllerOptionSpineLocationKey:NSNumber(float: 5)])
        
        self.imageContainerPageViewController.delegate = self
        self.imageContainerPageViewController.dataSource = self
        let viewControllers = NSArray(object: viewControllerAtIndex(0))
        self.imageContainerPageViewController.setViewControllers((viewControllers as! [UIViewController]), direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.addChildViewController(self.imageContainerPageViewController)
        self.view.addSubview(self.imageContainerPageViewController.view)
        self.imageContainerPageViewController.didMoveToParentViewController(self)
        self.imageContainerPageViewController.view.frame = CGRectMake(0, 110, self.screenWidth, 400);
        
        for view in self.imageContainerPageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    private func setupBottomPart()
    {
        // look around label
        lookAroundButton = UIButton(frame: CGRectMake(0,screenHeight - 216,125,22))
        lookAroundButton.center.x = self.screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        lookAroundButton.setAttributedTitle(NSAttributedString(string: "Look around ➜", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), forState: .Normal)
        self.view.insertSubview(lookAroundButton, atIndex: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        loginButton = UIButton(frame: CGRectMake(0, screenHeight - 176, 300, 50))
        loginButton.center.x = self.screenWidth / 2
        loginButton.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font! ]), forState: .Normal)
        loginButton.layer.cornerRadius = 25
        loginButton.backgroundColor = UIColor.faeAppRedColor()
        loginButton.addTarget(self, action: #selector(WelcomeViewController.loginButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(loginButton, atIndex: 0)
        
        
        // create account button
        createAccountButton = UIButton(frame: CGRectMake(0, screenHeight - 106, 300, 50))
        createAccountButton.center.x = self.screenWidth / 2
        createAccountButton.setAttributedTitle(NSAttributedString(string: "Create a Fae Account", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), forState: .Normal)
        createAccountButton.backgroundColor = UIColor.whiteColor()
        createAccountButton.layer.borderColor = UIColor.faeAppRedColor().CGColor
        createAccountButton.layer.borderWidth = 2
        createAccountButton.layer.cornerRadius = 25
        self.view.insertSubview(createAccountButton, atIndex: 0)
        
        // create copyright label
        font = UIFont(name: "AvenirNext-Regular", size: 10)
        
        rightLabel = UILabel(frame: CGRectMake(0, screenHeight - 35, 300, 50))
        rightLabel.numberOfLines = 2
        rightLabel.attributedText = NSAttributedString(string: "© 2016 Fae ::: Faevorite, Inc.\nAll Rights Reserved.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ])
        rightLabel.textAlignment = .Center
        rightLabel.sizeToFit()
        rightLabel.center.x = self.screenWidth / 2
        self.view.insertSubview(rightLabel, atIndex: 0)
        
    }
    
    // MARK: imageContainerGenerator
    private func viewControllerAtIndex(index: Int) -> WelcomeImageContainerViewController
    {
        let vc = WelcomeImageContainerViewController()
        vc.index = index
        return vc
    }
    
    // MARK: UIPageViewController delegate & dataSource
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed){
            let currentViewController = pageViewController.viewControllers?.last as! WelcomeImageContainerViewController
            pageControl.currentPage = currentViewController.index
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let currentViewController = viewController as! WelcomeImageContainerViewController
        if(currentViewController.index == 0){
            return nil
        }
        else{
            return viewControllerAtIndex(currentViewController.index - 1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let currentViewController = viewController as! WelcomeImageContainerViewController
        if(currentViewController.index == 4){
            return nil
        }
        else{
            return viewControllerAtIndex(currentViewController.index + 1)
        }
    }
    
    //MARK: UIScrollView delegate
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let point = scrollView.contentOffset;
        let percentComplete = (point.x - screenWidth) / screenWidth
        self.pageControl.setscrollPercent(percentComplete);
    }
    
    //MARK: helper
    func loginButtonTapped()
    {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController")as! LogInViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
