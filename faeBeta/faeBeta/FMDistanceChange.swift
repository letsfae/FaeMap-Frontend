//
//  FMDistanceChange.swift
//  faeBeta
//
//  Created by Yue on 4/11/17.
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
        filterSlider.minimumValue = 4
        filterSlider.maximumValue = 200
        filterSlider.addTarget(self, action: #selector(self.printSliderValue(_:)), for: .valueChanged)
        view.addSubview(filterSlider)
        filterSlider.isHidden = true
        filterSlider.layer.zPosition = 600
        loadDistanceLabel()
        loadDistanceRadiusCircle()
    }
    
    fileprivate func loadDistanceLabel() {
        lblDistanceDisplay = UILabel(frame: CGRect(x: 0, y: 68, width: 80, height: 35))
        lblDistanceDisplay.center.x = screenWidth / 2
        lblDistanceDisplay.layer.cornerRadius = 17.5
        lblDistanceDisplay.clipsToBounds = true
        lblDistanceDisplay.textColor = UIColor.faeAppRedColor()
        lblDistanceDisplay.textAlignment = .center
        lblDistanceDisplay.text = "1 km"
        lblDistanceDisplay.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        lblDistanceDisplay.isHidden = true
        lblDistanceDisplay.backgroundColor = UIColor.white
        self.view.addSubview(lblDistanceDisplay)
    }
    
    fileprivate func loadDistanceRadiusCircle() {
        uiviewDistanceRadius = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        uiviewDistanceRadius.backgroundColor = UIColor(red: 255/255, green: 160/255, blue: 160/255, alpha: 0.2)
        uiviewDistanceRadius.layer.borderWidth = 2
        uiviewDistanceRadius.layer.borderColor = UIColor.faeAppDisabledRedColor().cgColor
        uiviewDistanceRadius.isHidden = true
        self.view.addSubview(uiviewDistanceRadius)
    }
    
    func printSliderValue(_ sender: UISlider) {
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        let position = CLLocationCoordinate2DMake(latitude, longitude)
        let points = self.faeMapView.projection.point(for: position)
        uiviewDistanceRadius.frame.size.width = CGFloat(sender.value)
        uiviewDistanceRadius.frame.size.height = CGFloat(sender.value)
        uiviewDistanceRadius.layer.cornerRadius = CGFloat(sender.value / 2)
        uiviewDistanceRadius.center = points
        
        lblDistanceDisplay.text = "\(Int(sender.value/4)) km"
    }
}
