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
    func addConstraintsWithFormat(format: String, options: NSLayoutFormatOptions, views: UIView...) {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: nil, views: viewDictionary))
    }
}
