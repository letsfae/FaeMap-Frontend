//
//  CreateChatPinViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreateChatPinViewController: CreatePinBaseViewController {

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - setup
    private func setupUI()
    {
        self.titleImageView.image = UIImage(named: "chatPinTitleImage")
        self.titleLabel.isHidden = true
        setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 0.65))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
