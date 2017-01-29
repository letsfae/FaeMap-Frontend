//
//  FMMapFilterSlider.swift
//  faeBeta
//
//  Created by Yue on 1/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func loadMFilterSlider() {
        filterSlider = UISlider(frame: CGRect(x: 100, y: screenWidth, width: 448*screenWidthFactor, height: 28))
        filterSlider.setThumbImage(#imageLiteral(resourceName: "mapFilterSliderIcon"), for: .normal)
        filterSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        filterSlider.center = CGPoint(x: screenWidth-29, y: 340)
        filterSlider.maximumTrackTintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        filterSlider.minimumTrackTintColor = UIColor.faeAppRedColor()
        filterSlider.minimumValue = 10
        filterSlider.maximumValue = 36
        filterSlider.addTarget(self, action: #selector(self.printSliderValue(_:)), for: .valueChanged)
        view.addSubview(filterSlider)
        filterSlider.isHidden = true
        filterSlider.layer.zPosition = 600
        loadDistanceLabel()
    }
    
    func loadDistanceLabel() {
        
    }
    
    func printSliderValue(_ sender: UISlider) {
        print(sender.value)
        
    }
}
