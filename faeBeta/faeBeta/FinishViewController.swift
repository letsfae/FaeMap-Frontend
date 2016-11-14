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
        
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        backButton.setImage(UIImage(named: "BackArrow"), for: UIControlState())
        backButton.setTitleColor(UIColor.blue, for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: viewHeight * 95/736.0, width: viewWidth, height: 35))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.text = "All Good to Go!"
        
        let imageView = UIImageView(frame: CGRect(x: 30, y: viewHeight * 185/736.0, width: viewWidth - 60, height: (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")
        
        let titleLabel1 = UILabel(frame: CGRect(x: 0, y: viewHeight * 500/736.0, width: viewWidth, height: 35))
        titleLabel1.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel1.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel1.textAlignment = .center
        titleLabel1.text = "Welcome to Fae!"
        
        let finishButton = UIButton(frame: CGRect(x: viewWidth/2.0 - 150, y: viewHeight * 600/736.0, width: 300, height: 50))
        finishButton.setImage(UIImage(named: "FinishButton"), for: UIControlState())
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(finishButton)
        view.addSubview(titleLabel1)

        
    }
    
    func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
