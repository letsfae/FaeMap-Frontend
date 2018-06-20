//
//  BoardNoResultView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class BoardNoResultView: UIView {
    fileprivate var lblBubbleHint: UILabel!
    fileprivate var imgBubbleHint: UIImageView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114))
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupUI() {
        imgBubbleHint = UIImageView(frame: CGRect(x: 82 * screenWidthFactor, y: 142 * screenHeightFactor, width: 252, height: 209))
        imgBubbleHint.image = #imageLiteral(resourceName: "mb_bubbleHint")
        addSubview(imgBubbleHint)
        
        lblBubbleHint = UILabel(frame: CGRect(x: 24, y: 9, width: 206, height: 75))
        lblBubbleHint.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBubbleHint.textColor = UIColor._898989()
        lblBubbleHint.lineBreakMode = .byWordWrapping
        lblBubbleHint.numberOfLines = 0
        imgBubbleHint.addSubview(lblBubbleHint)
    }
    
    func setBubbleHintVal(_ hint: String) {
        lblBubbleHint.text = hint
    }
}
