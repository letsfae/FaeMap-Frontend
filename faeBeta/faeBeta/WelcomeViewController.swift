//
//  WelcomeViewController.swift
//  faeBeta
//  write by wenye yu
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    
    var imageWelcome : UIImageView!
    var imageCat : UIImageView!
    var buttonSign : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadButton()
        self.view.backgroundColor = UIColor.redColor()
        // Do any additional setup after loading the view.
    }
    func loadImageView(){
        imageWelcome = UIImageView(frame: CGRectMake(screenWidth/2-100, 87, 200, 145))
        imageWelcome.image = UIImage(named: "welcome_ballon")
        self.view.addSubview(imageWelcome)
        imageCat = UIImageView(frame:CGRectMake(screenWidth/2-86, 252, 172, 172))
        imageCat.image = UIImage(named: "smile_cat")
        self.view.addSubview(imageCat)
    }
    func loadButton(){
        buttonSign = UIButton(frame:CGRectMake(screenWidth/2-156,380,312,198))
        buttonSign.setTitle("Sign In!", forState: .Normal)
        buttonSign.titleLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(buttonSign)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
