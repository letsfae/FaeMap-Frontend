//
//  FAEVerificationCodeView.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/21.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class FAEVerificationCodeView: UIView {

    // MARK: - Interface
    var uiview:UIView?

    @IBOutlet var numberLabels: [UILabel]!

    private var pointer = 0
    
    var displayValue: String{
        get{
            var s = ""
            for label in numberLabels{
                s += label.text!
            }
            return s
        }
    }
    
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
        uiview = NSBundle.mainBundle().loadNibNamed("FAEVerificationCodeView", owner: self, options: nil)![0] as? UIView
        self.insertSubview(uiview!, atIndex: 0)
        uiview!.frame = self.bounds
        uiview!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    private func setup()
    {
        for label in numberLabels{
            label.attributedText = NSAttributedString(string: "･" , attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .Center
        }
    }
    
    //MARK: - display methods
    
    /// add a digit to the code view
    ///
    /// - parameter digit: the int that need to be appended
    ///
    /// - returns: the numebr of digits appened
    func addDigit(digit:Int) -> Int
    {
        if(digit >= 0 && pointer < numberLabels.count){
            let label = numberLabels[pointer]
            label.attributedText = NSAttributedString(string: "\(digit)" , attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .Center
            pointer = pointer + 1
        }else if(digit < 0 && pointer > 0){
            pointer = pointer - 1
            let label = numberLabels[pointer]
            label.attributedText = NSAttributedString(string: "･" , attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .Center
        }
        return pointer
    }
    
    
}
