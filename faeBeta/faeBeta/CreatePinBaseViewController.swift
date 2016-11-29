//
//  CreatePinBaseViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CreatePinBaseDelegate: class {
    func backFromCMP(back: Bool)
    func closePinMenuCMP(close: Bool)
}


class CreatePinBaseViewController: UIViewController {
    //MARK: - properties
    weak var delegate : CreatePinBaseDelegate!
    private var submitButton: UIButton!
    var titleImageView: UIImageView!
    var titleLabel: UILabel!
    
    //MARK: - life cycles
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupBaseUI()
        // Do any additional setup after loading the view.
    }

    //MARK: - setup
    private func setupBaseUI()
    {
        //back button
        let buttonBackToPinSelection = UIButton()
        buttonBackToPinSelection.setImage(UIImage(named: "backToPinMenu"), for: UIControlState())
        self.view.addSubview(buttonBackToPinSelection)
        self.view.addConstraintsWithFormat("H:|-0-[v0(48)]", options: [], views: buttonBackToPinSelection)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonBackToPinSelection)
        buttonBackToPinSelection.addTarget(self, action: #selector(self.actionBackToPinSelections(_:)), for: UIControlEvents.touchUpInside)
        
        //close button
        let buttonCloseCreateComment = UIButton()
        buttonCloseCreateComment.setImage(UIImage(named: "closePinCreation"), for: UIControlState())
        self.view.addSubview(buttonCloseCreateComment)
        self.view.addConstraintsWithFormat("H:[v0(48)]-0-|", options: [], views: buttonCloseCreateComment)
        self.view.addConstraintsWithFormat("V:|-21-[v0(48)]", options: [], views: buttonCloseCreateComment)
        buttonCloseCreateComment.addTarget(self, action: #selector(self.actionCloseSubmitPins(_:)), for: .touchUpInside)
        
        //bottom button
        submitButton = UIButton()
        submitButton.setTitle("Submit!", for: UIControlState())
        submitButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
        submitButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        submitButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        submitButton.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
        self.view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(CreateMomentPinViewController.actionSubmitMedia(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: submitButton)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: submitButton)
        
        
        titleImageView = UIImageView(frame: CGRect(x: 166, y: 36, width: 84, height: 91))
        self.view.addSubview(titleImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 109, y: 146, width: 196, height: 27))
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        self.view.addSubview(titleLabel)
        self.view.addConstraintsWithFormat("V:|-36-[v0(91)]-19-[v1(27)]", options: [], views: titleImageView, titleLabel)
        NSLayoutConstraint(item: titleImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func setSubmitButton(withTitle title: String, backgroundColor color: UIColor)
    {
        submitButton.setTitle(title, for: UIControlState())
        submitButton.backgroundColor = color
    }
    
    
    //MARK: - button actions
    @objc private func actionBackToPinSelections(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.view.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromCMP(back: true)
            }
        })
    }
    
    @objc private func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenuCMP(close: true)
        })
    }

}
