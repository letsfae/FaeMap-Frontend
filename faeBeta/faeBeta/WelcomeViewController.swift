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

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private var uipageImgContainer: UIPageViewController!
    private var pageControl: WelcomePageControl!
    private var btnLookAround: UIButton!
    private var btnLogin: UIButton!
    private var btnCreateAccount: UIButton!
    
    // MARK: - Life cycle
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
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Setup UI
    private func setupViewFrame() {
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.backgroundColor = UIColor.white
    }
    
    private func setupImageContainerPageViewController() {
        pageControl = WelcomePageControl(frame: CGRect(x: 0, y: 56 + device_offset_top, width: 90, height: 10))
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
        uipageImgContainer.view.frame = CGRect(x: 0, y: 90 * screenHeightFactor + device_offset_top, width: screenWidth, height: screenHeight - 300 * screenHeightFactor)
        uipageImgContainer.view.layoutIfNeeded()
        for view in uipageImgContainer.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    private func viewControllerAtIndex(_ index: Int) -> WelcomeImageContainerViewController {
        let vc = WelcomeImageContainerViewController()
        vc.index = index
        return vc
    }
    
    private func setupBottomPart() {
        // look around label
        btnLookAround = UIButton(frame: CGRect(x: 0, y: screenHeight - 198 * screenHeightFactor - device_offset_bot, width: 125, height: 22))
        btnLookAround.center.x = screenWidth / 2
        btnLookAround.setTitle("Look Around", for: .normal)
        btnLookAround.setTitleColor(UIColor._2499090(), for: .normal)
        btnLookAround.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        btnLookAround.addTarget(self, action: #selector(actionLookAround(_:)), for: .touchUpInside)
        view.insertSubview(btnLookAround, at: 0)
        
        // log in button
        btnLogin = UIButton(frame: CGRect(x: 0, y: screenHeight - 156 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnLogin.center.x = screenWidth / 2
        btnLogin.setTitle("Log in", for: .normal)
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnLogin.layer.cornerRadius = 25 * screenHeightFactor
        btnLogin.backgroundColor = UIColor._2499090()
        btnLogin.adjustsImageWhenHighlighted = false
        btnLogin.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.insertSubview(btnLogin, at: 0)
        view.bringSubview(toFront: btnLogin)
        
        // create account button
        btnCreateAccount = UIButton(frame: CGRect(x: 0, y: screenHeight - 86 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnCreateAccount.center.x = screenWidth / 2
        btnCreateAccount.setTitle("Join Faevorite", for: .normal)
        btnCreateAccount.setTitleColor(UIColor._2499090(), for: .normal)
        btnCreateAccount.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnCreateAccount.backgroundColor = UIColor.white
        btnCreateAccount.layer.borderColor = UIColor._2499090().cgColor
        btnCreateAccount.layer.borderWidth = 3
        btnCreateAccount.layer.cornerRadius = 25 * screenHeightFactor
        btnCreateAccount.adjustsImageWhenHighlighted = false
        btnCreateAccount.addTarget(self, action: #selector(jumpToSignUp), for: .touchUpInside)
        view.insertSubview(btnCreateAccount, at: 0)
        view.bringSubview(toFront: btnCreateAccount)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.loginButtonTapped), name: NSNotification.Name(rawValue: "resetPasswordSucceed"), object: nil)
    }
    
    // MARK: - Button actions
    @objc private func loginButtonTapped() {
        let boardLogin = LogInViewController()
        navigationController?.pushViewController(boardLogin, animated: true)
    }
    
    @objc private func jumpToSignUp() {
        if let signup = FaeCoreData.shared.readByKey("signup") {
            if (signup as? String) == "email" {
                let faeUser = FaeUser()
                if let savedFirstName = FaeCoreData.shared.readByKey("signup_first_name") {
                    faeUser.whereKey("first_name", value: (savedFirstName as? String)!)
                }
                if let savedLastName = FaeCoreData.shared.readByKey("signup_last_name") {
                    faeUser.whereKey("last_name", value: (savedLastName as? String)!)
                }
                if let savedUsername = FaeCoreData.shared.readByKey("signup_username") {
                    faeUser.whereKey("user_name", value: (savedUsername as? String)!)
                }
                if let savedPassword = FaeCoreData.shared.readByKey("signup_password") {
                    faeUser.whereKey("password", value: (savedPassword as? String)!)
                }
                if let savedDateOfBirth = FaeCoreData.shared.readByKey("signup_dateofbirth") {
                    faeUser.whereKey("birthday", value: (savedDateOfBirth as? String)!)
                }
                if let savedGender = FaeCoreData.shared.readByKey("signup_gender") {
                    faeUser.whereKey("gender", value: (savedGender as? String)!)
                }
                let nextRegister = RegisterEmailViewController()
                nextRegister.faeUser = faeUser
                nextRegister.boolSavedSignup = true
                navigationController?.pushViewController(nextRegister, animated: false)
            } else {
                FaeCoreData.shared.removeByKey("signup")
                FaeCoreData.shared.removeByKey("signup_first_name")
                FaeCoreData.shared.removeByKey("signup_last_name")
                FaeCoreData.shared.removeByKey("signup_username")
                FaeCoreData.shared.removeByKey("signup_password")
                FaeCoreData.shared.removeByKey("signup_gender")
                FaeCoreData.shared.removeByKey("signup_dateofbirth")
                FaeCoreData.shared.removeByKey("signup_email")
                let boardRegister = RegisterNameViewController()
                navigationController?.pushViewController(boardRegister, animated: false)
            }
        } else {
            let boardRegister = RegisterNameViewController()
            navigationController?.pushViewController(boardRegister, animated: false)
        }
    }
    
    @objc private func actionLookAround(_ sender: UIButton) {
        //        let vc = ()
        //        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UIPageViewController delegate & dataSource
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
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let percentComplete = (point.x - screenWidth) / screenWidth
        pageControl.setscrollPercent(percentComplete)
    }
}
