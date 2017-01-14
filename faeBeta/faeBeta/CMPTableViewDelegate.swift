//
//  CMPTableViewDelegate.swift
//  faeBeta
//
//  Created by Jacky on 1/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: UITableViewDelegate,UITableViewDataSource {
    enum CMPMoreOptions: Int {
        case AddTags = 0
        case Duration = 1
        case Interaction = 2
        case Promotion = 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePinOptionsTableView.cellReuseIdentifier, for: indexPath) as! CreatePinOptionsTableViewCell
        switch indexPath.row {
        case CMPMoreOptions.AddTags.rawValue:
            var tagsString = "Add Tags"
            if(textAddTags != nil && textAddTags.tagNames.count != 0){
                tagsString = ""
                for tag in textAddTags.tagNames{
                    tagsString.append("\(tag), ")
                }
                tagsString = tagsString.substring(to: tagsString.characters.index(tagsString.endIndex, offsetBy: -2))
            }
            cell.setupCell(withTitle: tagsString, leadingIcon: #imageLiteral(resourceName: "addTagsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
            break
        case CMPMoreOptions.Duration.rawValue:
            cell.setupCell(withTitle: "Duration on Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "3HR", trailingIcon: nil)
            break
        case CMPMoreOptions.Interaction.rawValue:
            cell.setupCell(withTitle: "Interaction Radius", leadingIcon: #imageLiteral(resourceName: "radiusIcon"), trailingText: "C.S", trailingIcon: nil)
            break
        case CMPMoreOptions.Promotion.rawValue:
            cell.setupCell(withTitle: "Pin Promotions", leadingIcon: #imageLiteral(resourceName: "promotionIcon"), trailingText: "C.S", trailingIcon: nil)
            break
        default:
            break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case CMPMoreOptions.AddTags.rawValue:
            switchToAddTags()
            break
        case CMPMoreOptions.Duration.rawValue:
            break
        case CMPMoreOptions.Interaction.rawValue:
            break
        case CMPMoreOptions.Promotion.rawValue:
            break
        default:
            break
        }
    }
}
