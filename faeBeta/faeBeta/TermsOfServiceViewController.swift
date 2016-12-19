//
//  TermsOfServiceViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup()
    {
        let backButton = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        backButton.setImage(UIImage(named: "Fill 1"), for: UIControlState())
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        self.view.backgroundColor = UIColor.white
    }
    
    func backButtonTapped(_ sender:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
