//
//  WelcomeViewController.swift
//  faeBeta
//  write by wenye yu
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

public var navBarDefaultShadowImage: UIImage?

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    // MARK: - Interface

    var imageContainerPageViewController : UIPageViewController! 
    var pageControl: WelcomePageControl!
    var lookAroundButton: UIButton!
    var loginButton:UIButton!
    var createAccountButton:UIButton!
    var rightLabel:UILabel!
    // MARK: - View did/will
    override func viewDidLoad() {
        super.viewDidLoad()
       
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        navBarDefaultShadowImage = UINavigationBar.appearance().shadowImage
        UINavigationBar.appearance().shadowImage = UIImage()
        setupViewFrame()
        setupImageContainerPageViewController()
        setupBottomPart()
        addObservers()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    // MARK: - Setup
    fileprivate func addObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.loginButtonTapped), name: NSNotification.Name(rawValue: "resetPasswordSucceed"), object: nil)

    }
    
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setupViewFrame()
    {
        self.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.backgroundColor = UIColor.white
    }
    
    fileprivate func setupImageContainerPageViewController()
    {
        pageControl = WelcomePageControl(frame: CGRect(x: screenWidth / 2 - 45, y: 56, width: 90, height: 10))
        pageControl.numberOfPages = 5
        self.view.insertSubview(pageControl, at: 0)
        
        self.imageContainerPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation:.horizontal, options: [UIPageViewControllerOptionSpineLocationKey:NSNumber(value: 5 as Float)])
        
        self.imageContainerPageViewController.delegate = self
        self.imageContainerPageViewController.dataSource = self
        let viewControllers = NSArray(object: viewControllerAtIndex(0))
        self.imageContainerPageViewController.setViewControllers((viewControllers as! [UIViewController]), direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.addChildViewController(self.imageContainerPageViewController)
        self.view.addSubview(self.imageContainerPageViewController.view)
        self.imageContainerPageViewController.didMove(toParentViewController: self)
        self.imageContainerPageViewController.view.frame = CGRect(x: 0, y: 90 * screenHeightFactor, width: screenWidth, height: screenHeight - 336 * screenHeightFactor);
        self.imageContainerPageViewController.view.layoutIfNeeded()
        for view in self.imageContainerPageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    fileprivate func setupBottomPart()
    {
        // look around label
        lookAroundButton = UIButton(frame: CGRect(x: 0,y: screenHeight - 216 * screenHeightFactor,width: 125,height: 22))
        lookAroundButton.center.x = screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        lookAroundButton.setAttributedTitle(NSAttributedString(string: "Look around ➜", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), for: UIControlState())
//        self.view.insertSubview(lookAroundButton, atIndex: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        loginButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 176 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        loginButton.center.x = screenWidth / 2
        loginButton.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font! ]), for: UIControlState())
        loginButton.layer.cornerRadius = 25*screenHeightFactor
        loginButton.backgroundColor = UIColor.faeAppRedColor()
        loginButton.addTarget(self, action: #selector(WelcomeViewController.loginButtonTapped), for: .touchUpInside)
        self.view.insertSubview(loginButton, at: 0)
        self.view.bringSubview(toFront: loginButton)
        
        // create account button
        createAccountButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 106 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        createAccountButton.center.x = screenWidth / 2
        createAccountButton.setAttributedTitle(NSAttributedString(string: "Create a Fae Account", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), for: UIControlState())
        createAccountButton.backgroundColor = UIColor.white
        createAccountButton.layer.borderColor = UIColor.faeAppRedColor().cgColor
        createAccountButton.layer.borderWidth = 3
        createAccountButton.layer.cornerRadius = 25*screenHeightFactor
        createAccountButton.addTarget(self, action: #selector(WelcomeViewController.jumpToSignUp), for: .touchUpInside)
        self.view.insertSubview(createAccountButton, at: 0)
        self.view.bringSubview(toFront: createAccountButton)

        // create copyright label
        font = UIFont(name: "AvenirNext-Regular", size: 10)
        
        rightLabel = UILabel(frame: CGRect(x: 0, y: screenHeight - 35, width: 300, height: 50))
        rightLabel.numberOfLines = 2
        rightLabel.attributedText = NSAttributedString(string: "© 2017 Fae Interactive ::: Faevorite, Inc.\nAll Rights Reserved.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ])
        rightLabel.textAlignment = .center
        rightLabel.sizeToFit()
        rightLabel.center.x = screenWidth / 2
        self.view.insertSubview(rightLabel, at: 0)
        
    }
    
    // MARK: imageContainerGenerator
    fileprivate func viewControllerAtIndex(_ index: Int) -> WelcomeImageContainerViewController
    {
        let vc = WelcomeImageContainerViewController()
        vc.index = index
        return vc
    }
    
    // MARK: UIPageViewController delegate & dataSource
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed){
            let currentViewController = pageViewController.viewControllers?.last as! WelcomeImageContainerViewController
            pageControl.currentPage = currentViewController.index
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let currentViewController = viewController as! WelcomeImageContainerViewController
        if(currentViewController.index == 0){
            return nil
        }
        else{
            return viewControllerAtIndex(currentViewController.index - 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
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
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let point = scrollView.contentOffset;
        let percentComplete = (point.x - screenWidth) / screenWidth
        self.pageControl.setscrollPercent(percentComplete);
    }
    
    //MARK: helper
    func loginButtonTapped()
    {
        let controller = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController")as! LogInViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func jumpToSignUp() {
        let controller = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterNameViewController")as! RegisterNameViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
