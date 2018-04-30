//
//  SetFaeInc.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/16.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetFaeInc: UIViewController {
    // MARK: - Properties
    private var lblTitle: UILabel!
    private var btnBack: UIButton!
    private var imgviewFae: UIImageView!
    private var lblContent: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadContent()
    }
    
    private func loadContent() {
        btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        imgviewFae = UIImageView(frame: CGRect(x: 50, y: 120 + device_offset_top, w: 50, h: 40))
        view.addSubview(imgviewFae)
        imgviewFae.image = #imageLiteral(resourceName: "Settings_fae")
        
        lblTitle = UILabel(frame: CGRect(x: 50, y: 190 + device_offset_top, w: 140 / screenWidthFactor, h: 28 / screenHeightFactor))
        view.addSubview(lblTitle)
        lblTitle.text = "Faevorite, Inc."
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblTitle.textColor = UIColor._898989()
        
        lblContent = UILabel(frame: CGRect(x: 50, y: 242 + device_offset_top, w: screenWidth / screenWidthFactor - 100 , h: 220 / screenHeightFactor))
        view.addSubview(lblContent)
        lblContent.text = "Faevorite is a company that focuses on happiness and lifestyle. \n\nWe empower individuals to find wellness and inspiration through discovering more things they love.\n\nOur goal is to build a trustworthy lifestyle brand that guides people to a joyful and healthy way of living."
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblContent.textColor = UIColor._898989()
        lblContent.tintColor = UIColor._2499090()
        lblContent.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblContent.numberOfLines = 0
    }
    
    // MARK: - Button action
    @objc private func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
