//
//  SetWebViewController.swift
//  faeBeta
//
//  Created by Jichao on 2017/10/25.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class SetWebViewController: UIViewController, UIWebViewDelegate {
    var uiviewNavBar: FaeNavBar!
    var webView: UIWebView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Fae Map"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(leftBtnTapped), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        
        webView = UIWebView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight))
        webView.delegate = self
        view.addSubview(webView)
        if let url = URL(string: "https://www.faemaps.com") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }

    }
    
    @objc func leftBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
}
