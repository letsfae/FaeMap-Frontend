//
//  BoardSearchPlaceLocation.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-22.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation

extension MapBoardViewController: SelectLocationDelegate {
    // MARK: - Button actions
    // function for select loation or unfold people filter page
    @objc func selectLocation(_ sender: UIButton) {
        // in people page
        if sender.tag == 1 {
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            sender.tag = 0
            uiviewLineBelowLoc.frame.origin.x = 14
            uiviewLineBelowLoc.frame.size.width = screenWidth - 28
            uiviewPeopleNearyFilter.animateShow()
            
            self.tblPeople.delaysContentTouches = false
        } else {
            // in both place & people
            let vc = SelectLocationViewController()
            vc.delegate = self
            vc.mode = .part
            vc.boolFromExplore = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    // MARK: - SelectLocationDelegate
    func sendLocationBack(address: RouteAddress) {
        var arrNames = address.name.split(separator: ",")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        if array.count >= 3 {
            reloadBottomText(array[0], array[1] + ", " + array[2])
        } else if array.count == 1 {
            reloadBottomText(array[0], "")
        } else if array.count == 2 {
            reloadBottomText(array[0], array[1])
        }
        //        self.selectedLoc = address.coordinate
        viewModelCategories.location = address.coordinate
        viewModelPlaces.location = address.coordinate
        viewModelPeople.location = address.coordinate
        rollUpFilter()
    }
    
    func reloadBottomText(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
        //        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        //        let first_attch = InlineTextAttachment()
        //        first_attch.fontDescender = -2
        //        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
        //        let firstImg_attach = NSAttributedString(attachment: first_attch)
        //
        //        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
        //        let second_attch = InlineTextAttachment()
        //        second_attch.fontDescender = -1
        //        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
        //        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        //        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        //        fullAttrStr.append(secondImg_attach)
        DispatchQueue.main.async {
            self.lblCurtLoc.attributedText = fullAttrStr
        }
    }
}
