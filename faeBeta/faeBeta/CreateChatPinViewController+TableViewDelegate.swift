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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePinOptionsTableView.cellReuseIdentifier) as! CreatePinOptionsTableViewCell
        switch indexPath.row{
        case CreateChatPinNormalOptions.AddDescription.rawValue:
            cell.setupCell(withTitle: "Add Description", leadingIcon: #imageLiteral(resourceName: "addDescription"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "plusIcon"))
            break
        case CreateChatPinNormalOptions.ChooseLocation.rawValue:
            cell.setupCell(withTitle: "Choose Location", leadingIcon: #imageLiteral(resourceName: "pinSelectLocation01"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))

            break
        case CreateChatPinNormalOptions.MoreOptions.rawValue:
            cell.setupCell(withTitle: "More Options", leadingIcon: #imageLiteral(resourceName: "optionsIcon"), trailingText: nil, trailingIcon: #imageLiteral(resourceName: "whiteRightPointer"))
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
