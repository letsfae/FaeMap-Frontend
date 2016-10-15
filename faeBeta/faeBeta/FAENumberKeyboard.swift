//
//  FAENumberKeyboard.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/21.
//  Copyright © 2016年 fae. All rights reserved.
//

import Foundation
import UIKit

protocol FAENumberKeyboardDelegate
{
    // num can be -1 ~ 9. -1 means delete.
    func keyboardButtonTapped(num:Int)
}

class FAENumberKeyboard: UIView {
    // MARK: - Interface
    var uiview:UIView?
    var delegate : FAENumberKeyboardDelegate!

    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - init
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        loadNib()
        setup()
    }
    
    //MARK: - setup
    private func loadNib()
    {
        uiview = NSBundle.mainBundle().loadNibNamed("FAENumberKeyboard", owner: self, options: nil)![0] as? UIView
        self.insertSubview(uiview!, atIndex: 0)
        uiview!.frame = self.bounds
        uiview!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    private func setup()
    {
        for button in numberButtons
        {
            button.backgroundColor = UIColor.clearColor()
            button.setAttributedTitle(NSAttributedString(string: "\(button.tag)" , attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 38)!]), forState: .Normal)
            button.addTarget(self, action: #selector(FAENumberKeyboard.numberButtonTapped(_:)), forControlEvents: .TouchUpInside)
        }
        let deleteIcon = UIImageView(frame: CGRectMake(screenWidth / 6 - 20 , 20 * screenHeightFactor * screenHeightFactor, 31, 22))
        deleteIcon.image = UIImage(named: "erase")
        deleteButton.addSubview(deleteIcon)
        deleteButton.addTarget(self, action: #selector(FAENumberKeyboard.numberButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func numberButtonTapped(sender:AnyObject)
    {
        let button = sender as! UIButton
        if(delegate != nil){
            delegate.keyboardButtonTapped(button.tag)
        }
    }
}
