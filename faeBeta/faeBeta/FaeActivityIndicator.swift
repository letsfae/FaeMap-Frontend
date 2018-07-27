//
//  FaeActivityIndicator.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import Gifu

class FaeActivityIndicator: UIView {
    
    var lblMessage: FaeLabel!
    private var gifUnicorn: GIFImageView!
    
    init(frame: CGRect = CGRect.zero, message: String) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        loadContent()
        lblMessage.text = message
        self.layer.zPosition = 9999
    }
    
//    override init(frame: CGRect = CGRect.zero) {
//        super.init(frame: frame)
//        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//        loadContent()
//        self.layer.zPosition = 9999
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadContent() {
        let uiviewBkgd = UIView(frame: self.frame)
        uiviewBkgd.backgroundColor = UIColor(r: 115, g: 115, b: 115, alpha: 30)
        addSubview(uiviewBkgd)
        
        let imgGifHolder = UIImageView(frame: CGRect(x: 0, y: 0, w: 246, h: 222))
        imgGifHolder.center.x = self.frame.size.width / 2
        imgGifHolder.center.y = self.frame.size.height / 2
        imgGifHolder.image = #imageLiteral(resourceName: "fae_activity_indicator")
        addSubview(imgGifHolder)
        
        gifUnicorn = GIFImageView(frame: CGRect(x: 0, y: 20, w: 200, h: 140))
        gifUnicorn.center.x = imgGifHolder.frame.size.width / 2
        gifUnicorn.contentMode = .scaleAspectFit
        gifUnicorn.animate(withGIFNamed: "GIF_alpha")
        imgGifHolder.addSubview(gifUnicorn)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//            self.gifUnicorn.stopAnimatingGIF()
//        }
        
        lblMessage = FaeLabel(CGRect(x: 0, y: 149 * screenHeightFactor, width: imgGifHolder.frame.size.width, height: 25), .center, .medium, 18, ._898989())
        imgGifHolder.addSubview(lblMessage)
    }
    
}
