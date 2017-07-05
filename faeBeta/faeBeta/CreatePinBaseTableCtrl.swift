//
//  CreatePinBaseTableCtrl.swift
//  faeBeta
//
//  Created by vicky on 2017/6/29.
//  Copyright © 2017年 fae. All rights reserved.
//

import UIKit

extension CreatePinBaseViewController: UITableViewDelegate, UITableViewDataSource {

//    enum CreateChatStoryPinNormalOptions: Int {
//        case AddDescription = 0
//        case ChooseLocation = 1
//        case MoreOptions = 2
//    }
//    
//    enum CreateCommentPinOptions: Int {
//        case ChooseLocation = 0
//        case MoreOptions = 1
//    }
//    
//    enum CreateChatPinBubbleOptions: Int {
//        case ChooseLocation = 0
//        case DurationOnMap = 1
//    }
//    
//    enum CreateChatPinMoreOptions: Int {
//        case AddTags = 0
//        case RoomCapacity = 1
//        case DurationOnMap = 2
//        case InteractionRadius = 3
//        case PinPromotions = 4
//    }
//    
//    enum CreateComtStoryPinMoreOptions: Int {
//        case DurationOnMap = 0
//        case InteractionRadius = 1
//        case PinPromotions = 2
//    }
//    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch optionViewMode{
        case .pin:
            if pinType == .comment {
                return 2
            }
            return 3
        case .bubble:
            return 2
        case .more:
            if pinType == .chat {
                return 5
            }
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePinOptionsTableView.cellReuseIdentifier) as! CreatePinOptionsTableViewCell
        
        switch optionViewMode {
        case .pin:
            if pinType == .comment {
                switch indexPath.row{
                case 0:
                    cell.setupCell(withTitle: strSelectedLocation ?? "Current Map View", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                    break
                case 1:
                    cell.setupCell(withTitle: "More Options", leadingIcon: #imageLiteral(resourceName: "optionsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row{
                case 0:
                    cell.setupCell(withTitle: ((textviewDescrip != nil && textviewDescrip.text != "" ) ? textviewDescrip.text! : "Add Description"), leadingIcon: #imageLiteral(resourceName: "addDescription"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
                    break
                case 1:
                    cell.setupCell(withTitle: strSelectedLocation ?? "Current Map View", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                    break
                case 2:
                    cell.setupCell(withTitle: "More Options", leadingIcon: #imageLiteral(resourceName: "optionsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                    break
                default:
                    break
                }
            }
            break
            
        case .bubble:
            switch indexPath.row{
            case 0:
                cell.setupCell(withTitle: strSelectedLocation ?? "Current Map View", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                break
            case 1:
                cell.setupCell(withTitle: "Duration on Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "30 min", trailingIcon: nil)
                break
            default:
                break
            }
            break
            
        case .more:
            if pinType == .chat {
                switch indexPath.row {
                case 0:
                    strTags = "Add Tags"
                    if(textviewAddTags != nil && textviewAddTags.tagNames.count != 0){
                        strTags = ""
                        for tag in textviewAddTags.tagNames{
                            strTags.append("\(tag), ")
                        }
                        strTags = strTags.substring(to: strTags.characters.index(strTags.endIndex, offsetBy: -2))
                    }
                    cell.setupCell(withTitle: strTags, leadingIcon: #imageLiteral(resourceName: "addTagsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
                    break
                case 1:
                    cell.setupCell(withTitle: "Room Capacity", leadingIcon: #imageLiteral(resourceName: "RoomCapacityIcon"), trailingText: "50", trailingIcon: nil)
                    break
                case 2:
                    cell.setupCell(withTitle: "Duration on Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "1D", trailingIcon: nil)
                    break
                case 3:
                    cell.setupCell(withTitle: "Interaction Radius", leadingIcon: #imageLiteral(resourceName: "radiusIcon"), trailingText: "C.S", trailingIcon: nil)
                    break
                case 4:
                    cell.setupCell(withTitle: "Pin Promotions", leadingIcon: #imageLiteral(resourceName: "promotionIcon"), trailingText: "C.S", trailingIcon: nil)
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    cell.setupCell(withTitle: "Duration on Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "1D", trailingIcon: nil)
                    break
                case 1:
                    cell.setupCell(withTitle: "Interaction Radius", leadingIcon: #imageLiteral(resourceName: "radiusIcon"), trailingText: "C.S", trailingIcon: nil)
                    break
                case 2:
                    cell.setupCell(withTitle: "Pin Promotions", leadingIcon: #imageLiteral(resourceName: "promotionIcon"), trailingText: "C.S", trailingIcon: nil)
                    break
                default:
                    break
                }
            }
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch optionViewMode {
        case .pin:
            if pinType == .comment {
                switch indexPath.row{
                case 0:
                    actionSelectLocation()
                    break
                case 1:
                    switchToMoreOptions()
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row{
                case 0:
                    switchToDescription()
                    break
                case 1:
                    actionSelectLocation()
                    break
                case 2:
                    switchToMoreOptions()
                    break
                default:
                    break
                }
            }
            break
            
        case .bubble:
            switch indexPath.row{
            case 0:
                actionSelectLocation()
                break
            case 1:
                break
            default:
                break
            }
            break
        case .more:
            if pinType == .chat {
                switch indexPath.row {
                case 0:
                    switchToAddTags()
                    break
                case 1:
                    break
                case 2:
                    break
                case 3:
                    break
                case 4:
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    break
                case 1:
                    break
                case 2:
                    break
                default:
                    break
                }
            }
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
