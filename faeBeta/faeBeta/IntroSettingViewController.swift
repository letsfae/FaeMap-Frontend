//
//  IntroSettingViewController.swift
//  faeBeta
//
//  Created by blesssecret on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class IntroSettingViewController: UIViewController , UITextViewDelegate{

    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    var labelTitle : UILabel!
    var textInput : UITextView!
    var buttonSave : UIButton!
    var labelDesc : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        // Do any additional setup after loading the view.
    }
    func loadTitle() {
        labelTitle = UILabel(frame: CGRectMake((screenWidth - 140) / 2, 99, 140, 27))
        labelTitle.text = "Your Nickname"
        labelTitle.font = UIFont(name:"AvenirNext-Medium", size: 20)
        self.view.addSubview(labelTitle)

        textInput = UITextView(frame: CGRectMake((screenWidth - 244) / 2, 174, 244, 102))
        textInput.textAlignment = .Center
        textInput.text = "Write a Short Intro"
        textInput.font = UIFont(name: "AvenirNext-Regular", size: 25)
        textInput.delegate = self
        self.view.addSubview(textInput)

        buttonSave = UIButton(frame: CGRectMake((screenWidth - 300) / 2,screenHeigh - 336, 300, 50))
        buttonSave.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSave.setTitle("Save", forState: .Normal)
        buttonSave.layer.cornerRadius = 25
        buttonSave.titleLabel?.textColor = UIColor.whiteColor()
        buttonSave.addTarget(self, action: #selector(NameSettingViewController.actionSave), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonSave)
        labelDesc = UILabel(frame: CGRectMake((screenWidth - 242) / 2, screenHeigh - 373, 242, 36))
        labelDesc.text = "30 Characters"
        labelDesc.textColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        labelDesc.textAlignment = .Center
//        labelDesc.numberOfLines = 0
        self.view.addSubview(labelDesc)
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    func textViewDidChange(textView: UITextView) {
        let count = textView.text.characters.count
        let num : Int = 30 - count
        labelDesc.text =  String(num) + " Characters"
    }
    func actionSave() {
        let user = FaeUser()
        if let str = textInput.text {
            user.whereKey("short_intro", value: str)
            user.updateNameCard { (status:Int, objects:AnyObject?) in
                print (status)
                if status / 100 == 2 {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {

                }
            }
        }
        //navi back
        //        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
