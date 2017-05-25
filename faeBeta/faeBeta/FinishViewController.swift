//
//  FinishViewController.swift
//  faeBeta
//
//  Created by Yash on 23/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createView()
    }
    
    func createView() {
        
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        
        let btnBack = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        btnBack.setImage(UIImage(named: "BackArrow"), for: UIControlState())
        btnBack.setTitleColor(UIColor.blue, for: UIControlState())
        btnBack.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: viewHeight * 95/736.0, width: viewWidth, height: 35))
        lblTitle.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 25)
        lblTitle.textAlignment = .center
        lblTitle.text = "All Good to Go!"
        
        let imageView = UIImageView(frame: CGRect(x: 30, y: viewHeight * 185/736.0, width: viewWidth - 60, height: (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")
        
        let lblWelcomeTitle = UILabel(frame: CGRect(x: 0, y: viewHeight * 500/736.0, width: viewWidth, height: 35))
        lblWelcomeTitle.textColor = UIColor.init(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        lblWelcomeTitle.font = UIFont(name: "AvenirNext-Medium", size: 25)
        lblWelcomeTitle.textAlignment = .center
        lblWelcomeTitle.text = "Welcome to Fae!"
        
        let btnFinish = UIButton(frame: CGRect(x: viewWidth/2.0 - 150, y: viewHeight * 600/736.0, width: 300, height: 50))
        btnFinish.setImage(UIImage(named: "FinishButton"), for: UIControlState())
        
        view.addSubview(btnBack)
        view.addSubview(lblTitle)
        view.addSubview(imageView)
        view.addSubview(btnFinish)
        view.addSubview(lblWelcomeTitle)
    }
    
    func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
