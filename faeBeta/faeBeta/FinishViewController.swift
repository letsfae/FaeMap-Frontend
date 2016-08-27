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
        
        
        let backButton = UIButton(frame: CGRectMake(10, 25, 40, 40))
        backButton.setImage(UIImage(named: "BackArrow"), forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed), forControlEvents: .TouchUpInside)
        
        let titleLabel = UILabel(frame: CGRectMake(0, viewHeight * 95/736.0, viewWidth, 35))
        titleLabel.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel.textAlignment = .Center
        titleLabel.text = "All Good to Go!"
        
        let imageView = UIImageView(frame: CGRectMake(30, viewHeight * 185/736.0, viewWidth - 60, (viewWidth - 60) * 300/351.0))
        imageView.image = UIImage(named: "FaePic")
        
        let titleLabel1 = UILabel(frame: CGRectMake(0, viewHeight * 500/736.0, viewWidth, 35))
        titleLabel1.textColor = UIColor.init(red: 89/255.0, green: 89/255.0, blue: 89/255.0, alpha: 1.0)
        titleLabel1.font = UIFont(name: "AvenirNext-Medium", size: 25)
        titleLabel1.textAlignment = .Center
        titleLabel1.text = "Welcome to Fae!"
        
        let finishButton = UIButton(frame: CGRectMake(viewWidth/2.0 - 150, viewHeight * 600/736.0, 300, 50))
        finishButton.setImage(UIImage(named: "FinishButton"), forState: .Normal)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(finishButton)
        view.addSubview(titleLabel1)

        
    }
    
    func backButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
