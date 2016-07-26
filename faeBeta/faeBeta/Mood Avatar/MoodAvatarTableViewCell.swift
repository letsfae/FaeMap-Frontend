//
//  MoodAvatarTableViewCell.swift
//  faeBeta
//
//  Created by User on 7/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol MoodAvatarDelegate {
    func changeCurrentAvatar(index : Int)
}

class MoodAvatarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var maleImage: UIImageView!
    
    @IBOutlet weak var moodLabel: UILabel!
    
    @IBOutlet weak var femaleImage: UIImageView!
    
    @IBOutlet weak var femaleButton: UIButton!

    @IBOutlet weak var maleIdicateImage: UIImageView!
    
    @IBOutlet weak var femaleIdicateImage: UIImageView!
    
    var cellIndex : NSInteger!
    
    var maleIndex : Int = 0
    var femaleIndex : Int = 0
    
    var isMaleSelect = false
    
    var isFemaleSelect = false
    
    var moodDelegate : MoodAvatarDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moodLabel.textAlignment = .Center
        moodLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        moodLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        moodLabel.adjustsFontSizeToFitWidth = true
        maleButton.setTitle("", forState: .Normal)
        femaleButton.setTitle("", forState: .Normal)
        maleButton.addTarget(self, action: #selector(MoodAvatarTableViewCell.clickMale), forControlEvents: .TouchUpInside)
        femaleButton.addTarget(self, action: #selector(MoodAvatarTableViewCell.clickFemale), forControlEvents: .TouchUpInside)
        maleButton.layer.zPosition = 10
        femaleButton.layer.zPosition = 10
        maleIdicateImage.layer.zPosition = 1
        femaleIdicateImage.layer.zPosition = 1
        maleImage.contentMode = .ScaleAspectFit
        femaleImage.contentMode = .ScaleAspectFit
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func clickMale() {
        print("male is clicked")
        moodDelegate.changeCurrentAvatar(maleIndex)
    }
    
    func clickFemale() {
        print("female is clicked")
        moodDelegate.changeCurrentAvatar(femaleIndex)
    }
    
}
