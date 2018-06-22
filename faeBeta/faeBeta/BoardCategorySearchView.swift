//
//  BoardCategorySearchView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

protocol BoardCategorySearchDelegate: class {
    func searchByCategories(category: String)
}

class BoardCategorySearchView: UIView, UIScrollViewDelegate {
    fileprivate var scrollView: UIScrollView!
    fileprivate var uiviewView1: UIView!
    fileprivate var uiviewView2: UIView!
    fileprivate var pageCtrl: UIPageControl!
    fileprivate var imgCats1: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    fileprivate var arrCatNames1: [String] = ["Restaurant", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    fileprivate var imgCats2: [UIImage] = [#imageLiteral(resourceName: "place_result_69"), #imageLiteral(resourceName: "place_result_20"), #imageLiteral(resourceName: "place_result_46"), #imageLiteral(resourceName: "place_result_6"), #imageLiteral(resourceName: "place_result_21"), #imageLiteral(resourceName: "place_result_29")]
    fileprivate var arrCatNames2: [String] = ["Fast Food", "Beer Bar", "Cosmetics", "Fitness", "Groceries", "Pharmacy"]
    fileprivate var lblCats: UILabel!
    fileprivate var btnCats: UIButton!
    
    weak var delegate: BoardCategorySearchDelegate?
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 246))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupUI() {
        // set self properties
        backgroundColor = .white
        
        // draw scroll view
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 241))
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: screenWidth * 2, height: 241)
        
        // draw two dots - page control
        pageCtrl = UIPageControl(frame: CGRect(x: 0, y: 212, width: screenWidth, height: 8))
        pageCtrl.numberOfPages = 2
        pageCtrl.currentPage = 0
        pageCtrl.pageIndicatorTintColor = UIColor._182182182()
        pageCtrl.currentPageIndicatorTintColor = UIColor._2499090()
        pageCtrl.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        addSubview(pageCtrl)
        
        // draw two uiview of Map Options
        uiviewView1 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 241))
        uiviewView2 = UIView(frame: CGRect(x: screenWidth, y: 0, width: screenWidth, height: 241))
        scrollView.addSubview(uiviewView1)
        scrollView.addSubview(uiviewView2)
        loadPlaceHeaderView(uiview: uiviewView1, tag: 0)
        loadPlaceHeaderView(uiview: uiviewView2, tag: 6)
        
        // draw bottom space
        let uiviewBottomSeparator = UIView(frame: CGRect(x: 0, y: 241, width: screenWidth, height: 5))
        uiviewBottomSeparator.backgroundColor = UIColor(r: 241, g: 241, b: 241, alpha: 100)
        addSubview(uiviewBottomSeparator)
    }
    
    fileprivate func loadPlaceHeaderView(uiview: UIView, tag: Int) {
        var btnCats = [UIButton]()
        var lblCats = [UILabel]()
        
        let imgPlace: [UIImage] = tag == 0 ? imgCats1 : imgCats2
        let arrCatName: [String] = tag == 0 ? arrCatNames1 : arrCatNames2
        
        for _ in 0..<6 {
            btnCats.append(UIButton(frame: CGRect(x: 60, y: 20, width: 58, height: 58)))
            lblCats.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            if i >= 3 {
                btnCats[i].frame.origin.y = 117
            }
            if i == 1 || i == 4 {
                btnCats[i].frame.origin.x = (screenWidth - 58) / 2
            } else if i == 2 || i == 5 {
                btnCats[i].frame.origin.x = screenWidth - 118
            }
            
            lblCats[i].center = CGPoint(x: btnCats[i].center.x, y: btnCats[i].center.y + 43)
            
            uiview.addSubview(btnCats[i])
            uiview.addSubview(lblCats[i])
            
            btnCats[i].layer.borderColor = UIColor._225225225().cgColor
            btnCats[i].layer.borderWidth = 2
            btnCats[i].layer.cornerRadius = 8.0
            btnCats[i].contentMode = .scaleAspectFit
            btnCats[i].layer.masksToBounds = true
            btnCats[i].setImage(imgPlace[i], for: .normal)
            btnCats[i].tag = i + tag
            btnCats[i].addTarget(self, action: #selector(search(_:)), for: .touchUpInside)
            lblCats[i].text = arrCatName[i]
            lblCats[i].textAlignment = .center
            lblCats[i].textColor = UIColor._138138138()
            lblCats[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
    }
    
    // MARK: - Button actions
    @objc func search(_ sender: UIButton) {
        var content = ""
        switch sender.tag {
        case 0:
            content = "Restaurants"
        case 1:
            content = "Bars"
        case 2:
            content = "Shopping"
        case 3:
            content = "Coffee"
        case 4:
            content = "Parks"
        case 5:
            content = "Hotels"
        case 6:
            content = "Fast Food"
        case 7:
            content = "Beer Bar"
        case 8:
            content = "Cosmetics"
        case 9:
            content = "Fitness"
        case 10:
            content = "Groceries"
        case 11:
            content = "Pharmacy"
        default: break
        }

        delegate?.searchByCategories(category: content)
    }
    
    // MARK: - PageControl actions
    @objc func changePage(_ sender: Any?) {
        scrollView.contentOffset.x = screenWidth * CGFloat(pageCtrl.currentPage)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCtrl.currentPage = scrollView.contentOffset.x == 0 ? 0 : 1
    }
}
