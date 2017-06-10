//
//  EmptyRootViewController.swift
//  faeBeta
//
//  Created by Yue on 6/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol SwitchMapModeDelegate: class {
    func pushRealMap()
    func pushMapBoard()
}

class EmptyRootViewController: UIViewController, SwitchMapModeDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadTransparentNavBarItems()
        pushRealMap()
    }
    
    fileprivate func loadTransparentNavBarItems() {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
    }

    func pushRealMap() {
        let vcRealMap = FaeMapViewController()
        vcRealMap.delegate = self
        self.navigationController?.pushViewController(vcRealMap, animated: true)
    }
    
    func pushMapBoard() {
        let vcMapBoard = MapBoardViewController()
        vcMapBoard.delegate = self
        self.navigationController?.pushViewController(vcMapBoard, animated: true)
    }
}
