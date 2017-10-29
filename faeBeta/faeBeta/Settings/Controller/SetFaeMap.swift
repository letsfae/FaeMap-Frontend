//
//  SetFaeMap.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/16.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
// Vicky 09/17/17 右边滑动条，参照Sketch文件，老板需要的是大红色 _2499090()，注意改一下。

class SetFaeMap: UIViewController, UIScrollViewDelegate {
    
    var scrollview: UIScrollView!
    var imgviewPic: UIImageView!
    var btnBack: UIButton!
    var lblTitle: UILabel!
    var lblSubtitle: UILabel!
    var textView: UITextView!
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        scrollview = UIScrollView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(scrollview)
        scrollview.isPagingEnabled = false
        scrollview.contentSize.height = 870 / screenHeightFactor
        scrollview.delegate = self
        scrollview.indicatorStyle = .white
        
        loadContent()
    }
    
    func loadContent() {
        
        //btnBack = UIButton(frame: CGRect(x: 15/414*screenWidth, y: 36/736*screenHeight, width: 18, height: 18))
        btnBack = UIButton(frame: CGRect(x: 0, y: 25, width: 48, height: 40))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        //imgviewPic = UIImageView(frame: CGRect(x:screenWidth/2-25/414*screenWidth, y: 50/736*screenHeight, width: 50/414*screenWidth, height: 50/414*screenWidth))
        imgviewPic = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imgviewPic.center.x = screenWidth / 2
        scrollview.addSubview(imgviewPic)
        imgviewPic.image = #imageLiteral(resourceName: "Settings_map")
        
        //let lblX = 315/414*screenWidth
        //lblTitle = UILabel(frame:CGRect(x: (screenWidth-lblX)/2, y: 114/736*screenHeight, width: lblX, height: 18))
        lblTitle = UILabel(frame: CGRect(x: 0, y: 54, width: 200, height: 18))
        lblTitle.center.x = screenWidth / 2
        scrollview.addSubview(lblTitle)
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        lblTitle.textColor = UIColor._898989()
        lblTitle.text = "About Fae Map"
        lblTitle.textAlignment = .center
        
        //lblSubtitle = UILabel(frame:CGRect(x: (screenWidth-lblX)/2, y: 132/736*screenHeight, width: lblX, height: 18))
        lblSubtitle = UILabel(frame: CGRect(x: 0, y: 72, width: 200, height: 18))
        lblSubtitle.center.x = screenWidth / 2
        scrollview.addSubview(lblSubtitle)
        lblSubtitle.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        lblSubtitle.textColor = UIColor._115115115()
        lblSubtitle.text = "Discover Favorite Places"
        lblSubtitle.textAlignment = .center
        
        let text = "Fae Map is a beautiful way to browse around cities and discover new places you love. Explore local communities, create custom collections, and share great places with friends!\n\nKey Features:\n\n-INTERACTIVE MAP: Browsing the map never felt this lively and fun. Fae Map cycles through Points of Interests as you pan around the map creating a new browsing experience.\n\n-EXPLORE: Intuitive features in Fae Map allow you to efficiently explore popular places in communities and save them in collections. You’ll never run out of ideas on where to go!\n\n-SMART SEARCH: Our search system enables you to search for specific places or general categories in customized locations.\n\n-NEARBY: Instantly view what’s around you. Fae Map shows you the locations of Points of Interests nearby and give you information about your surroundings. \n\n-COLLECTIONS: Create custom lists to save the places you love and add memos to specific places in your lists. You can choose to share lists with friends through chats!\n\n-MAKE NEW FRIENDS: Fae Map is about people and communities. You will see Map Avatars of users in the area that you can chat to and make friends with! \n\n-FUN CHATS: It’s more fun to be social. Send private messages, stickers, photos, videos, and voices. You can also share places, locations, and collections to plan a night out.\n\nSafety & Privacy:\nWe value your privacy and want you to be safe all the time; that’s why we are continuously developing and refining our security system to protect your information and data while you are on the map. Please respect your community and fellow users on Fae Map as we all want to have a great time. Learn more about the guidelines in our Terms of Service and how we collect and protect data in our Privacy Policy."
        
        textView = UITextView(frame: CGRect(x: 0, y: 100, width: screenWidth - 85 * screenWidthFactor, height: 752))
        textView.center.x = screenWidth / 2
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.attributedText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 12)!])
        textView.sizeToFit()
        scrollview.addSubview(textView)
        
        scrollview.contentSize.height = 100.0 + textView.frame.size.height + 42.5 * screenWidthFactor
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indicator = scrollView.subviews.last as? UIImageView {
            indicator.backgroundColor = UIColor._2499090()
            indicator.tintAdjustmentMode = .normal
            indicator.tintColor = UIColor._2499090()
            indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
