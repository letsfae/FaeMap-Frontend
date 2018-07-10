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
    private var scrollView: UIScrollView!
    private var uiviewView1: UIView!
    private var uiviewView2: UIView!
    private var pageCtrl: UIPageControl!
    
    private var placeNames = [String]()
    private var btnCats1 = [UIButton]()
    private var btnCats2 = [UIButton]()
    private var lblCats1 = [UILabel]()
    private var lblCats2 = [UILabel]()
    
    weak var delegate: BoardCategorySearchDelegate?
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 246))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
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
        
        for _ in 0..<6 {
            btnCats1.append(UIButton(frame: CGRect(x: 60, y: 20, width: 58, height: 58)))
            lblCats1.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
            btnCats2.append(UIButton(frame: CGRect(x: 60, y: 20, width: 58, height: 58)))
            lblCats2.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        loadPlaceHeaderView(uiview: uiviewView1, btnCats: btnCats1, lblCats: lblCats1, tag: 0)
        loadPlaceHeaderView(uiview: uiviewView2, btnCats: btnCats2, lblCats: lblCats2, tag: 6)
        
        // draw bottom space
        let uiviewBottomSeparator = UIView(frame: CGRect(x: 0, y: 241, width: screenWidth, height: 5))
        uiviewBottomSeparator.backgroundColor = UIColor(r: 241, g: 241, b: 241, alpha: 100)
        addSubview(uiviewBottomSeparator)
    }
    
    private func loadPlaceHeaderView(uiview: UIView, btnCats: [UIButton], lblCats: [UILabel], tag: Int) {
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
            btnCats[i].tag = i + tag
            btnCats[i].addTarget(self, action: #selector(search(_:)), for: .touchUpInside)
            lblCats[i].textAlignment = .center
            lblCats[i].textColor = UIColor._138138138()
            lblCats[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
        
    }
    
    private func setButtonsUI() {
        for i in 0..<12 {
            let img_id = i < placeNames.count ? Category.shared.categories[placeNames[i]] ?? -1 : -1
            if img_id == -1 {
                if i < 6 {
                    btnCats1[i].setImage(nil, for: .normal)
                    lblCats1[i].text = ""
                } else {
                    btnCats2[i - 6].setImage(nil, for: .normal)
                    lblCats2[i - 6].text = ""
                }
            } else {
                if i < 6 {
                    btnCats1[i].setImage(UIImage(named: "place_result_\(img_id)"), for: .normal)
                    lblCats1[i].text = placeNames[i]
                } else {
                    btnCats2[i - 6].setImage(UIImage(named: "place_result_\(img_id)"), for: .normal)
                    lblCats2[i - 6].text = placeNames[i]
                }
            }
        }
    }
    
    // MARK: - Process data about shortcut menu
    func getShortcutMenu() {
        let shortcutCategory = Category.shared.filterShortcutMenu()
        placeNames = []
        for idx in 0..<min(12, shortcutCategory.count) {
            placeNames.append(shortcutCategory[idx].name)
        }
        
        setButtonsUI()
    }
    
    // MARK: - Button actions
    @objc func search(_ sender: UIButton) {
        let content = placeNames[sender.tag]
        delegate?.searchByCategories(category: content)
        
        Category.shared.visitCategory(category: content)
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
