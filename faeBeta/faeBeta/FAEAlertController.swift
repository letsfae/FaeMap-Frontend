//
//  FAEAlertController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/30/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FAEAlertController: UIAlertController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.tintColor = UIColor.faeAppRedColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set background color to white
        let subview = self.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.white
        alertContentView.layer.cornerRadius = 15
        
        //update the title font
        let attributedTitle = NSAttributedString(string:self.title!, attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        self.setValue(attributedTitle, forKey: "attributedTitle")
    }
    
//    override func addAction(_ action: UIAlertAction)
//    {
//        action.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
