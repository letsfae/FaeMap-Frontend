//
//  UIViewExtension.swift
//  faeBeta
//
//  Created by Yue on 11/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addConstraintsWithFormat(_ format: String, options: NSLayoutFormatOptions, views: UIView...) {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: viewDictionary))
    }
    
    func returnConstraintsWithFormat(_ format: String, options: NSLayoutFormatOptions, views: UIView...) -> [NSLayoutConstraint] {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: viewDictionary)
    }
}
