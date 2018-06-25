//
//  FaeSearchController.swift
//  FaeMap
//
//  Created by Yue on 6/3/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit

protocol FaeSearchControllerDelegate: class {
    func didStartSearching()
    func didTapOnSearchButton()
    func didTapOnCancelButton()
    func didChangeSearchText(_ searchText: String)
}


class FaeSearchController: UISearchController, UISearchBarDelegate {
    var faeSearchBar: FaeSearchBar!
    weak var faeDelegate: FaeSearchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Initialization
    
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        configureSearchBar(searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Custom functions
    
    func configureSearchBar(_ frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        faeSearchBar = FaeSearchBar(frame: frame, font: font , textColor: textColor)
        faeSearchBar.barTintColor = bgColor
        faeSearchBar.tintColor = textColor
        faeSearchBar.showsBookmarkButton = false
        faeSearchBar.showsCancelButton = false
        faeSearchBar.setImage(#imageLiteral(resourceName: "Search"), for: UISearchBarIcon.search, state: UIControlState())
        faeSearchBar.delegate = self
    }
    
    // MARK: UISearchBarDelegate functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        faeDelegate?.didStartSearching()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        faeSearchBar.resignFirstResponder()
        faeDelegate?.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        faeSearchBar.resignFirstResponder()
        faeDelegate?.didTapOnCancelButton()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        faeDelegate?.didChangeSearchText(searchText)
    }
}
