//
//  WelcomeImageContainerViews.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomeContentContainerFace: UIView {
    
    //MARK: container view properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var uiview:UIView?
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    //MARK: - setup
    private func loadNib()
    {
        uiview = NSBundle.mainBundle().loadNibNamed("WelcomeContentContainerFace", owner: self, options: nil)![0] as? UIView
        self.insertSubview(uiview!, atIndex: 0)
        uiview!.frame = self.bounds
        uiview!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    func populateContentContainer(imageName:String, title:String, description:String)
    {
        self.imageView.image = UIImage(named: imageName)
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
