//
//  WelcomeImageContainerViewController.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomeImageContainerViewController: UIViewController {
    var index: Int!
    var containerView : WelcomeContentContainerFace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView = WelcomeContentContainerFace()
        self.view.insertSubview(containerView, at: 0)
        self.containerView.frame = self.view.bounds
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupContentContainer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.containerView.frame = self.view.bounds

    }
    
    func setupContentContainer()
    {
        let imageName = "Welcome_" + "\(index+1)"
        var title: String = ""
        var description : String = ""
        switch index {
        case 0:
            title = " "
            self.containerView.titleIcon.image = UIImage(named: "FaeMapLabelIcon")
            description = "Connecting People & Communities \non a Real Time Social Map"
            break
        case 1:
            title = "Chat"
            description = "Chat & Interact with people\nin any area near or far!"
            break
        case 2:
            title = "Trade"
            description = "Fastest Way to Buy/Sell in\nthe most diverse Marketplace!"
            break
        case 3:
            title = "Discover"
            description = "Explore any City in the World\nand instantly get involved!"
            break
        case 4:
            title = "Always Secure"
            description = "Our system protects your privacy\nso you can focus on having fun!"
            break
        default:
            break
        }
        self.containerView.populateContentContainer(imageName, title: title, description: description)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
