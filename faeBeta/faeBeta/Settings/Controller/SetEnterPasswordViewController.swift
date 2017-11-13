//
//  SetEnterPasswordViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/10/2.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetEnterPasswordViewController: UIViewController { // UNUSED
    
    var btnBack: UIButton!
    var lblEnterLabel: UILabel!
    
    override func viewDidLoad() {
        btnBack = UIButton(frame: CGRect(x: 0, y: 21, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        let lblEnterX = 200/414*screenWidth
        lblEnterLabel = UILabel(frame: CGRect(x: (screenWidth-lblEnterX)/2, y: 72/736*screenHeight, width: lblEnterX, height: 54))
        view.addSubview(lblEnterLabel)
        
        
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
