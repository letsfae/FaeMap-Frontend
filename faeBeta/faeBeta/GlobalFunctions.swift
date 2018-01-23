//
//  GlobalFunctions.swift
//  faeBeta
//
//  Created by Yue Shen on 1/15/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

func addBorder(_ view: UIView, color: UIColor = .black) {
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = 1
}

func vibrate(type: Int) {
    
    if #available(iOS 10.0, *) {
        switch type {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    } else {
        // Fallback on earlier versions
    }
    
}

func showAlert(title: String, message: String, viewCtrler: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .destructive)
    alertController.addAction(okAction)
    viewCtrler.present(alertController, animated: true, completion: nil)
}
