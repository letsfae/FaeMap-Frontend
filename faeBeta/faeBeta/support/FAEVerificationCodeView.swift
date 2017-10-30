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

    fileprivate var pointer = 0
    
    var displayValue: String {
        get {
            var s = ""
            for label in numberLabels {
                s += label.text!
            }
            return s
        }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
        setup()
    }
    
    //MARK: - setup
    fileprivate func loadNib() {
        uiview = Bundle.main.loadNibNamed("FAEVerificationCodeView", owner: self, options: nil)![0] as? UIView
        self.insertSubview(uiview!, at: 0)
        uiview!.frame = self.bounds
        uiview!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    fileprivate func setup() {
        for label in numberLabels {
            label.attributedText = NSAttributedString(string: "･", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .center
        }
    }
    
    //MARK: - display methods
    func addDigit(_ digit:Int) -> Int {
        if digit >= 0 && pointer < numberLabels.count {
            let label = numberLabels[pointer]
            label.attributedText = NSAttributedString(string: "\(digit)", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .center
            pointer = pointer + 1
        } else if digit < 0 && pointer > 0 {
            pointer = pointer - 1
            let label = numberLabels[pointer]
            label.attributedText = NSAttributedString(string: "･", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 60)!])
            label.textAlignment = .center
        }
        return pointer
    }
}
