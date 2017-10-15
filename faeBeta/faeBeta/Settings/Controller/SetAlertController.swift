//
//  SetAlertController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetalertController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "", message: "Oops, please verify your Email to Subscribe!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Got it!", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
