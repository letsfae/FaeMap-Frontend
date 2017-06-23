//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import UIKit

struct PullToRefreshConst {
    static let pullTag = 810
    static let pushTag = 811
    static let alpha = true
    static let height: CGFloat = 85
    static let imageName: String = "pulltorefresharrow.png"
    static let animationDuration: Double = 0.3
    static let fixedTop = true // PullToRefreshView fixed Top
}

struct PullToRefreshOption {
    var backgroundColor: UIColor
    var indicatorColor: UIColor
    var autoStopTime: Double // 0 is not auto stop
    var fixedSectionHeader: Bool // Update the content inset for fixed section headers
    
    init(backgroundColor: UIColor = .clear, indicatorColor: UIColor = .gray, autoStopTime: Double = 0, fixedSectionHeader: Bool = false) {
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
        self.autoStopTime = autoStopTime
        self.fixedSectionHeader = fixedSectionHeader
    }
}
