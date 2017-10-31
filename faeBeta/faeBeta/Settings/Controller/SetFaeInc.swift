//
//  SetFaeInc.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/16.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetFaeInc: UIViewController {
    
    var lblTitle: UILabel!
    var btnBack: UIButton!
    var imgviewFae: UIImageView!
    var lblContent: UILabel!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        loadContent()
    }
    
    func loadContent() {
        btnBack = UIButton(frame: CGRect(x: 15/414*screenWidth, y: 36/736*screenHeight, width: 18, height: 18))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        imgviewFae = UIImageView(frame:CGRect(x: 50/414*screenWidth, y: 120/736*screenHeight, width: 50, height: 40))
        view.addSubview(imgviewFae)
        imgviewFae.image = #imageLiteral(resourceName: "Settings_fae")
        
        let contentX = 284/414*screenWidth
        
        lblTitle = UILabel(frame:CGRect(x: (screenWidth-contentX)/2, y: 190/736*screenHeight, width: 140, height: 28))
        view.addSubview(lblTitle)
        lblTitle.text = "Faevorite, Inc."
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblTitle.textColor = UIColor._898989()
        
        lblContent = UILabel(frame: CGRect(x: (screenWidth-contentX)/2, y: 242/736*screenHeight, width: contentX, height: 300))
        view.addSubview(lblContent)
        lblContent.text = "Faevorite is a company that focuses on happiness and lifestyle. \n\nWe empower individuals to find wellness and inspiration through discovering more things they love.\n\nOur goal is to build a trustworthy lifestyle brand that guides people to a joyful and healthy way of living."
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblContent.textColor = UIColor._898989()
        lblContent.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent.numberOfLines = 0
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
