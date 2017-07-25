//
//  WelcomeViewController.swift
//  faeBeta
//  write by wenye yu
//  Edited by Sophie
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

public var imgNavBarDefaultShadow: UIImage?

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    // MARK: - Interface
    var uipageImgContainer: UIPageViewController!
    var pageControl: WelcomePageControl!
    var btnLookAround: UIButton!
    var btnLogin: UIButton!
    var btnCreateAccount: UIButton!
//    var lblRight: UILabel!
    
    // MARK: - View did/will
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        imgNavBarDefaultShadow = UINavigationBar.appearance().shadowImage
        UINavigationBar.appearance().shadowImage = UIImage()
        setupViewFrame()
        setupImageContainerPageViewController()
        setupBottomPart()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    // MARK: - Setup
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.loginButtonTapped), name: NSNotification.Name(rawValue: "resetPasswordSucceed"), object: nil)
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setupViewFrame() {
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.backgroundColor = UIColor.white
    }
    
    fileprivate func setupImageContainerPageViewController() {
        pageControl = WelcomePageControl(frame: CGRect(x: 0, y: 56, width: 66, height: 10))
        pageControl.center.x = screenWidth / 2
        pageControl.numberOfPages = 5 //  hide trade was 5
        view.insertSubview(pageControl, at: 0)
        
        uipageImgContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionSpineLocationKey: NSNumber(value: 5 as Float)]) //  hide trade was 5
        
        uipageImgContainer.delegate = self
        uipageImgContainer.dataSource = self
        let arrVC = NSArray(object: viewControllerAtIndex(0))
        uipageImgContainer.setViewControllers((arrVC as! [UIViewController]), direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        addChildViewController(uipageImgContainer)
        view.addSubview(uipageImgContainer.view)
        uipageImgContainer.didMove(toParentViewController: self)
        uipageImgContainer.view.frame = CGRect(x: 0, y: 90 * screenHeightFactor, width: screenWidth, height: screenHeight - 336 * screenHeightFactor)
        uipageImgContainer.view.layoutIfNeeded()
        for view in uipageImgContainer.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    fileprivate func setupBottomPart() {
        // look around label
        btnLookAround = UIButton(frame: CGRect(x: 0, y: screenHeight - 198 * screenHeightFactor, width: 125, height: 22))
        btnLookAround.center.x = screenWidth / 2
        btnLookAround.setImage(#imageLiteral(resourceName: "btnLookAround"), for: .normal)
        view.insertSubview(btnLookAround, at: 0)
        
        // log in button
        var font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnLogin = UIButton(frame: CGRect(x: 0, y: screenHeight - 156 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnLogin.center.x = screenWidth / 2
        btnLogin.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]), for: UIControlState())
        btnLogin.layer.cornerRadius = 25 * screenHeightFactor
        btnLogin.backgroundColor = UIColor.faeAppRedColor()
        btnLogin.addTarget(self, action: #selector(WelcomeViewController.loginButtonTapped), for: .touchUpInside)
        view.insertSubview(btnLogin, at: 0)
        view.bringSubview(toFront: btnLogin)
        
        // create account button
        btnCreateAccount = UIButton(frame: CGRect(x: 0, y: screenHeight - 86 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnCreateAccount.center.x = screenWidth / 2
        btnCreateAccount.setAttributedTitle(NSAttributedString(string: "Create a Fae Account", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font!]), for: UIControlState())
        btnCreateAccount.backgroundColor = UIColor.white
        btnCreateAccount.layer.borderColor = UIColor.faeAppRedColor().cgColor
        btnCreateAccount.layer.borderWidth = 3
        btnCreateAccount.layer.cornerRadius = 25 * screenHeightFactor
        btnCreateAccount.addTarget(self, action: #selector(WelcomeViewController.jumpToSignUp), for: .touchUpInside)
        view.insertSubview(btnCreateAccount, at: 0)
        view.bringSubview(toFront: btnCreateAccount)
        
        // create copyright label
        font = UIFont(name: "AvenirNext-Regular", size: 10)
//        lblRight = UILabel(frame: CGRect(x: 0, y: screenHeight - 35, width: 300, height: 50))
//        lblRight.numberOfLines = 2
//        lblRight.attributedText = NSAttributedString(string: "© 2017 Fae Interactive ::: Faevorite, Inc.\nAll Rights Reserved.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font!])
//        lblRight.textAlignment = .center
//        lblRight.sizeToFit()
//        lblRight.center.x = screenWidth / 2
//        view.insertSubview(lblRight, at: 0)
    }
    
    // MARK: imageContainerGenerator
    fileprivate func viewControllerAtIndex(_ index: Int) -> WelcomeImageContainerViewController {
        let vc = WelcomeImageContainerViewController()
        vc.index = index
        return vc
    }
    
    // MARK: UIPageViewController delegate & dataSource
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let vcCurrent = pageViewController.viewControllers?.last as! WelcomeImageContainerViewController
            pageControl.currentPage = vcCurrent.index
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vcCurrent = viewController as! WelcomeImageContainerViewController
        if vcCurrent.index == 0 {
            return nil
        } else {
            return viewControllerAtIndex(vcCurrent.index - 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vcCurrent = viewController as! WelcomeImageContainerViewController
        if vcCurrent.index == 4 { // was 4, hide trade -- Yue Shen
            return nil
        } else {
            return viewControllerAtIndex(vcCurrent.index + 1)
        }
    }
    
    // MARK: UIScrollView delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let percentComplete = (point.x - screenWidth) / screenWidth
        pageControl.setscrollPercent(percentComplete)
    }
    
    // MARK: helper
    func loginButtonTapped() {
        let boardLogin = LogInViewController()
        navigationController?.pushViewController(boardLogin, animated: true)
    }
    func jumpToSignUp() {
        let boardRegister = RegisterNameViewController()
        navigationController?.pushViewController(boardRegister, animated: true)
    }
}
