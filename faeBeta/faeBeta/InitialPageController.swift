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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func goToFaeMap() {
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func goToMapBoard() {
        if let mapBoard = arrViewCtrl.last {
            self.setViewControllers([mapBoard], direction: .forward, animated: true, completion: nil)
        }
    }
    
}
