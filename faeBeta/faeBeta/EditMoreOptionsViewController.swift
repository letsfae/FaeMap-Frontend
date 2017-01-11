//
//  EditMoreOptionsViewController.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit


class EditMoreOptionsViewController: UIViewController {
    
    var delegate: EditCommentPinViewControllerDelegate!
    
    //Parameter passed by last view
    var pinID = ""
    var previousCommentContent = ""
    var pinGeoLocation: CLLocationCoordinate2D!
    var pinType = ""
    
    var tableViewHeight = 0
    
    //View Items
    var tableMoreOptions: UITableView!
    var labelTitle: UILabel!
    var buttonCancel: UIButton!
    var buttonSave: UIButton!
    var uiviewLine: UIView!
    var uiviewLineBottom: UIView!
    var labelFooter: UILabel!
    
    //Data Structure
    var optionImageArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        switch pinType {
        case "comment" :
            optionImageArray = [0,1,2,3]
            tableViewHeight = 232
            break
        case "media" :
            optionImageArray = [0,4,1,2,3]
            tableViewHeight = 290
            break
        case "chat_room" :
            optionImageArray = [0,4,5,1,2,3]
            tableViewHeight = 338
            break
        default:
            print("No Suitable PinType")
            break
        }
        loadDetailWindow()
        // Do any additional setup after loading the view.
    }
}
