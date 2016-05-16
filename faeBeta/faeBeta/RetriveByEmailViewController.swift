//
//  RetriveByEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 5/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RetriveByEmailViewController: UIViewController,UITextFieldDelegate {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    var labelTitle:UILabel!
    var imageTitle: UIImageView!
    var textEmail : UITextField!
    var viewText : UIView!
    let space : CGFloat = UIScreen.mainScreen().bounds.width * 0.1134
    var imageEmail : UIImageView!
    var viewLine:UIView!
    var buttonBackground : UIButton!
    var buttonNext : UIButton!
    var buttonContact : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLabelImage()
        loadTextView()
        loadButton()
        // Do any additional setup after loading the view.
    }
    func loadLabelImage(){
        labelTitle = UILabel(frame: CGRectMake(screenWidth/2-267/2,screenHeight*0.08423,267,68))
        labelTitle.text = "Enter you Email to find your Account!"
        labelTitle.textColor = UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0)
        labelTitle.numberOfLines = 0
        labelTitle.textAlignment = .Center
        labelTitle.font = UIFont.systemFontOfSize(25.0, weight: UIFontWeightRegular)
        self.view.addSubview(labelTitle)
        
        imageTitle = UIImageView(frame: CGRectMake(space, screenHeight*0.24184, screenWidth - space*2, screenHeight*0.1576))
        imageTitle.image = UIImage(named: "threePeopleEmail")
        self.view.addSubview(imageTitle)
    }
    func loadTextView(){
        buttonBackground = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackground.backgroundColor = UIColor.clearColor()
        buttonBackground.addTarget(self, action: #selector(RetriveByEmailViewController.anctionCancel), forControlEvents: .TouchDown)
        self.view.addSubview(buttonBackground)
        
        viewText = UIView(frame: CGRectMake(space,screenHeight*0.481,screenWidth-2*space,31))
        self.view.addSubview(viewText)
        imageEmail = UIImageView(frame: CGRectMake(0, 7, 21, 16))
        imageEmail.image = UIImage(named: "emaiRed")
        self.viewText.addSubview(imageEmail)
        viewLine = UIView(frame: CGRectMake(0,29,screenWidth-2*space,2))
        viewLine.backgroundColor = UIColor(colorLiteralRed: 249.0/250.0, green: 90.0/250.0, blue: 90.0/250.0, alpha: 1.0)
        viewText.addSubview(viewLine)
        textEmail = UITextField(frame: CGRectMake(21+5, 0, screenWidth-2*space-21-5, 30))
        
        textEmail.placeholder = "Email"
        textEmail.restorationIdentifier = "Email"
        self.viewText.addSubview(textEmail)
        textEmail.delegate = self
        textEmail.becomeFirstResponder()
    }
    func anctionCancel(){
        self.view.endEditing(true)
    }
    func loadButton(){
        buttonNext = UIButton(frame: CGRectMake(space,screenHeight*0.591,screenWidth-2*space,50))
        buttonNext.setTitle("Next", forState: .Normal)
        buttonNext.backgroundColor = UIColor(colorLiteralRed: 255.0/250.0, green: 160.0/250.0, blue: 160.0/250.0, alpha: 1.0)
        buttonNext.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonNext.layer.cornerRadius = 7
        buttonNext.addTarget(self, action: #selector(RetriveByEmailViewController.jumpToAccount), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonNext)
        buttonContact = UIButton(frame: CGRectMake(screenWidth/2-184/2,screenHeight*0.724,184,22))
        buttonContact.setImage(UIImage(named: "contactFaeSupport"), forState: .Normal)
        self.view.addSubview(buttonContact)
    }
    func jumpToAccount(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("AccountFoundViewController")as! AccountFoundViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
