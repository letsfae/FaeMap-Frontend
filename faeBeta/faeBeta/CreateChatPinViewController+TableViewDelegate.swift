//
//  CreateChatPinViewController+TableViewDelegate.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateChatPinViewController : UITableViewDelegate, UITableViewDataSource{
    
    enum CreateChatPinNormalOptions: Int {
        case AddDescription = 0
        case ChooseLocation = 1
        case MoreOptions = 2
    }
    
    enum CreateChatPinBubbleOptions: Int {
        case ChooseLocation = 0
        case DurationOnMap = 1
    }
    
    enum CreateChatPinMoreOptions: Int {
        case AddTags = 0
        case RoomCapacity = 1
        case DurationOnMap = 2
        case InteractionRadius = 3
        case PinPromotions = 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch optionViewMode{
        case .pin:
            return 3
        case .bubble:
            return 2
        case .more:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePinOptionsTableView.cellReuseIdentifier) as! CreatePinOptionsTableViewCell
        
        switch optionViewMode {
        case .pin:
            switch indexPath.row{
            case CreateChatPinNormalOptions.AddDescription.rawValue:
                cell.setupCell(withTitle: ((descriptionTextView != nil && descriptionTextView.text != "" ) ? descriptionTextView.text! : "Add Description"), leadingIcon: #imageLiteral(resourceName: "addDescription"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
                break
            case CreateChatPinNormalOptions.ChooseLocation.rawValue:
                cell.setupCell(withTitle: labelSelectLocationContent ?? "Choose Location", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                
                break
            case CreateChatPinNormalOptions.MoreOptions.rawValue:
                cell.setupCell(withTitle: "More Options", leadingIcon: #imageLiteral(resourceName: "optionsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                break
            default:
                break
            }
            break
            
        case .bubble:
            switch indexPath.row{
            case CreateChatPinBubbleOptions.ChooseLocation.rawValue:
                cell.setupCell(withTitle: labelSelectLocationContent ?? "Choose Location", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
                break
            case CreateChatPinBubbleOptions.DurationOnMap.rawValue:
                cell.setupCell(withTitle: "Duration On Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "30 min", trailingIcon: nil)
                break
            default:
                break
            }
            break
        case .more:
            switch indexPath.row {
            case CreateChatPinMoreOptions.AddTags.rawValue:
                var tagsString = "Add Tags"
                if(addTagsTextView != nil && addTagsTextView.tagNames.count != 0){
                    tagsString = ""
                    for tag in addTagsTextView.tagNames{
                        tagsString.append("\(tag), ")
                    }
                    tagsString = tagsString.substring(to: tagsString.characters.index(tagsString.endIndex, offsetBy: -2))
                }
                cell.setupCell(withTitle: tagsString, leadingIcon: #imageLiteral(resourceName: "addTagsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
                break
            case CreateChatPinMoreOptions.RoomCapacity.rawValue:
                cell.setupCell(withTitle: "Room Capacity", leadingIcon: #imageLiteral(resourceName: "RoomCapacityIcon"), trailingText: "50", trailingIcon: nil)
                break
            case CreateChatPinMoreOptions.DurationOnMap.rawValue:
                cell.setupCell(withTitle: "Duration On Map", leadingIcon: #imageLiteral(resourceName: "durationIcon"), trailingText: "1D", trailingIcon: nil)
                break
            case CreateChatPinMoreOptions.InteractionRadius.rawValue:
                cell.setupCell(withTitle: "Interaction Radius", leadingIcon: #imageLiteral(resourceName: "radiusIcon"), trailingText: "C.S", trailingIcon: nil)
                break
            case CreateChatPinMoreOptions.PinPromotions.rawValue:
                cell.setupCell(withTitle: "Pin Promotions", leadingIcon: #imageLiteral(resourceName: "promotionIcon"), trailingText: "C.S", trailingIcon: nil)
                break
            default:
                break
            }
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch optionViewMode {
        case .pin:
            switch indexPath.row{
            case CreateChatPinNormalOptions.AddDescription.rawValue:
                switchToDescription()
                break
            case CreateChatPinNormalOptions.ChooseLocation.rawValue:
                actionSelectLocation()
                break
            case CreateChatPinNormalOptions.MoreOptions.rawValue:
                switchToMoreOptions()
                break
            default:
                break
            }
            break
            
        case .bubble:
            switch indexPath.row{
            case CreateChatPinBubbleOptions.ChooseLocation.rawValue:
                actionSelectLocation()
                break
            case CreateChatPinBubbleOptions.DurationOnMap.rawValue:
                break
            default:
                break
            }
            break
        case .more:
            switch indexPath.row {
            case CreateChatPinMoreOptions.AddTags.rawValue:
                swtichToAddTags()
                break
            case CreateChatPinMoreOptions.RoomCapacity.rawValue:
                break
            case CreateChatPinMoreOptions.DurationOnMap.rawValue:
                break
            case CreateChatPinMoreOptions.InteractionRadius.rawValue:
                break
            case CreateChatPinMoreOptions.PinPromotions.rawValue:
                break
            default:
                break
            }
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
