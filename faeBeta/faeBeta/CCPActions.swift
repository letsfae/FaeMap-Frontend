////
////  CCPActions.swift
////  faeBeta
////
////  Created by Yue on 11/15/16.
////  Copyright © 2016 fae. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//import CoreLocation
//
//extension CreateCommentPinViewController {
//    
//    func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .destructive)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
//    
//    func actionAnonymous(_ sender: UIButton) {
//        if sender.tag == 0 {
//            sender.tag = 1
//            sender.setImage(#imageLiteral(resourceName: "anonymousClicked"), for: UIControlState())
//            anonymous = true
//        }
//        else {
//            sender.tag = 0
//            sender.setImage(#imageLiteral(resourceName: "anonymousUnclicked"), for: UIControlState())
//            anonymous = false
//        }
//    }
//    
//    func actionFinishEditing(_ sender: UIButton) {
//        textViewForCommentPin.endEditing(true)
//        textViewForCommentPin.resignFirstResponder()
//    }
//    
//    func actionBackToPinSelections(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
////            self.uiviewCreateCommentPin.alpha = 0.0
//            self.view.alpha = 1.0
//        }), completion: { (done: Bool) in
//            if done {
//                self.dismiss(animated: false, completion: nil)
//                self.delegate?.backFromPinCreating(back: true)
//            }
//        })
//    }
//    
//    func actionCloseSubmitPins(_ sender: UIButton!) {
//        self.dismiss(animated: false, completion: {
//            self.delegate?.closePinMenu(close: true)
//        })
//    }
//}
