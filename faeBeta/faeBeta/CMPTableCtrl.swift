////
////  CMPTableViewDelegate.swift
////  faeBeta
////
////  Created by Jacky on 1/12/17.
////  Copyright © 2017 fae. All rights reserved.
////
//
//import UIKit
//
//extension CreateMomentPinViewController: UITableViewDelegate,UITableViewDataSource {
//    enum CreateMomentPinOptions: Int {
//        case AddDescription = 0
//        case ChooseLocation = 1
//        case MoreOptions = 2
//    }
//    
//    enum CMPMoreOptions: Int {
//        case Duration = 0
//        case Interaction = 1
//        case Promotion = 2
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePinOptionsTableView.cellReuseIdentifier, for: indexPath) as! CreatePinOptionsTableViewCell
//        switch indexPath.row {
////        case CMPMoreOptions.AddTags.rawValue:
////            var strTags = "Add Tags"
////            if(textAddTags != nil && textAddTags.tagNames.count != 0){
////                strTags = ""
////                for tag in textAddTags.tagNames{
////                    strTags.append("\(tag), ")
////                }
////                strTags = strTags.substring(to: strTags.characters.index(strTags.endIndex, offsetBy: -2))
////            }
////            cell.setupCell(withTitle: strTags, leadingIcon: #imageLiteral(resourceName: "addTagsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
////            break
//        case CMPMoreOptions.Duration.rawValue:
//            cell.setupCell(withTitle: "Duration on Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "3HR", trailingIcon: nil)
//            break
//        case CMPMoreOptions.Interaction.rawValue:
//            cell.setupCell(withTitle: "Interaction Radius", leadingIcon: #imageLiteral(resourceName: "radiusIcon"), trailingText: "C.S", trailingIcon: nil)
//            break
//        case CMPMoreOptions.Promotion.rawValue:
//            cell.setupCell(withTitle: "Pin Promotions", leadingIcon: #imageLiteral(resourceName: "promotionIcon"), trailingText: "C.S", trailingIcon: nil)
//            break
//        default:
//            break
//        }
//        return cell
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch indexPath.row {
////        case CMPMoreOptions.AddTags.rawValue:
////            switchToAddTags()
////            break
//        case CMPMoreOptions.Duration.rawValue:
//            break
//        case CMPMoreOptions.Interaction.rawValue:
//            break
//        case CMPMoreOptions.Promotion.rawValue:
//            break
//        default:
//            break
//        }
//    }
//}
