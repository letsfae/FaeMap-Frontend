//
//  InitialPageController.swift
//  faeBeta
//
//  Created by Yue on 6/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class InitialPageController: UIPageViewController {
    
    lazy var arrViewCtrl: [UIViewController] = {
        let faeMap = FaeMapViewController()
        let mapBoard = MapBoardViewController()
        return [faeMap, mapBoard]
    }()
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .forward, animated: false, completion: nil)
        }
        //loadRecents()
    }
    
    func goToFaeMap() {
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func goToMapBoard() {
        if let mapBoard = arrViewCtrl.last {
            self.setViewControllers([mapBoard], direction: .forward, animated: true, completion: nil)
        }
    }
    
}
