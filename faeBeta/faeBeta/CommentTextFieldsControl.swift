//
//  CommentTextFieldsControl.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var arrNum = 0
        
        if let arrayNum = textFieldArray.indexOf(textField) {
            arrNum = arrayNum
        }
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        let backSpace = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(backSpace, "\\b")
        if isBackSpace == -92 {
            if newLength == 0 {
                textFieldArray[arrNum].text = ""
                if arrNum != 0 {
                    textFieldArray[arrNum].resignFirstResponder()
                    textFieldArray[arrNum-1].becomeFirstResponder()
                }
                if textFieldArray.count > 2 {
                    if arrNum < uiviewArray.count-1 {
                        moveAllTextFieldUpFromIndex(arrNum)
                    }
                    self.uiviewArray[arrNum].removeFromSuperview()
                    self.uiviewArray.removeAtIndex(arrNum)
                    self.textFieldArray.removeAtIndex(arrNum)
                    self.borderArray.removeAtIndex(arrNum)
                }
                else {
                    exist1stLine = false
                    exist4thLine = false
                }
                return false
            }
        }
        
        if newLength <= 25 {
            if let selectedRange = textField.selectedTextRange {
                
                let cursorPosition = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: selectedRange.start)
                
                print("\(cursorPosition)")
            }
            return true
        }
        else {
            if arrNum == textFieldArray.count-1 {
                createNewTextField()
                addNewTextfieldAnimation()
                textFieldArray[arrNum].resignFirstResponder()
                textFieldArray[arrNum+1].becomeFirstResponder()
                if let currentText = textFieldArray[arrNum+1].text {
                    if string != " " {
                        let parts = textFieldArray[arrNum].text!.componentsSeparatedByString(" ")
                        print(parts)
                        if parts.count >= 2 {
                            var reTypeString = ""
                            for i in 0...parts.count-2 {
                                reTypeString += "\(parts[i]) "
                            }
                            textFieldArray[arrNum].text = reTypeString
                            textFieldArray[arrNum+1].text = "\(parts.last!)\(string)\(currentText)"
                        }
                        if parts.count == 1 {
                            textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                        }
                    }
                    else {
                        textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                    }
                }
            }
            else {
                
                textFieldArray[arrNum].resignFirstResponder()
                textFieldArray[arrNum+1].becomeFirstResponder()
                if let currentText = textFieldArray[arrNum+1].text {
                    if string != " " {
                        let parts = textFieldArray[arrNum].text!.componentsSeparatedByString(" ")
                        print(parts)
                        if parts.count >= 2 {
                            var reTypeString = ""
                            for i in 0...parts.count-2 {
                                reTypeString += "\(parts[i]) "
                            }
                            textFieldArray[arrNum].text = reTypeString
                            textFieldArray[arrNum+1].text = "\(parts.last!)\(string)\(currentText)"
                        }
                        if parts.count == 1 {
                            textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                        }
                    }
                    else {
                        textFieldArray[arrNum+1].text = "\(string)\(currentText)"
                    }
                }
            }
            return false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var arrNum = 0
        
        if let arrayNum = textFieldArray.indexOf(textField) {
            arrNum = arrayNum
        }
        
        if arrNum > 0 {
            if let checkEmptyTextField = textFieldArray[arrNum-1].text {
                if checkEmptyTextField == "" {
                    textFieldArray[arrNum].resignFirstResponder()
                    textFieldArray[arrNum-1].becomeFirstResponder()
                }
            }
        }
        
        if uiviewArray[arrNum].lineNumber == 1 {
            if arrNum == 0 {
                moveAllTextFieldDown()
            }
            else {
                moveAllTextFieldDown()
                moveAllTextFieldDown()
            }
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 2 {
            if arrNum != 0 {
                moveAllTextFieldDown()
                return
            }
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 3 {
            return
        }
        
        if uiviewArray[arrNum].lineNumber == 4 {
            moveAllTextFieldUp()
            return
        }
    }
    
    func someActionUp() {
        if uiviewArray.last?.lineNumber < 4 {
            self.exist4thLine = false
        }
        if self.exist4thLine {
            moveAllTextFieldUp()
        }
    }
    
    func someActionDown() {
        if uiviewArray.first?.lineNumber > 1 {
            self.exist1stLine = false
        }
        if self.exist1stLine {
            moveAllTextFieldDown()
        }
    }
    
    func revertBool() {
        token = true
    }
    
    func userDragged_1(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 246 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 296 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_2(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 296 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 346 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_3(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 346 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 396 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func userDragged_4(gesture: UIPanGestureRecognizer) {
        let loc = gesture.locationInView(self.view)
        if loc.y < 396 && token {
            someActionUp()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
        if loc.y > 446 && token {
            someActionDown()
            token = false
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(FaeMapViewController.revertBool), userInfo: nil, repeats: false)
        }
    }
    
    func moveAllTextFieldUp() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 1 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            if lineNumber > 5 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                self.exist1stLine = true
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 5:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func moveAllTextFieldDown() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 0 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
            }
            
            if lineNumber > 4 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 0:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                self.exist1stLine = true
                break
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber + 1
            nums -= 1
        }
    }
    
    func moveAllTextFieldUpFromIndex(index: Int!) {
        let gesture_4 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_4(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= index {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber > 5 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 5:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_4)
                self.exist4thLine = true
                break
            default:
                break
            }
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func deleteFromIndexTextfieldAnimation() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 0 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
            }
            
            switch lineNumber {
            case 0:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                break
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y + 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].lineNumber = lineNumber + 1
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                self.uiviewArray.removeLast()
                self.textFieldArray.removeLast()
                self.borderArray.removeLast()
                break
            default:
                break
            }
            
            nums -= 1
        }
    }
    
    func addNewTextfieldAnimation() {
        let gesture_1 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_1(_:)))
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        var nums = self.uiviewArray.count-1
        while nums >= 0 {
            let lineNumber = self.uiviewArray[nums].lineNumber
            
            if lineNumber < 1 {
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
            }
            
            switch lineNumber {
            case 1:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.0
                }), completion: nil)
                break
            case 2:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 0.25
                }), completion: nil)
                self.exist1stLine = true
                self.uiviewArray[nums].addGestureRecognizer(gesture_1)
                break
            case 3:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_2)
                break
            case 4:
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionFlipFromBottom, animations: ({
                    self.uiviewArray[nums].center.y = self.uiviewArray[nums].center.y - 50.0
                    self.uiviewArray[nums].alpha = 1.0
                }), completion: nil)
                self.uiviewArray[nums].addGestureRecognizer(gesture_3)
                break
            default:
                break
            }
            
            self.uiviewArray[nums].lineNumber = lineNumber - 1
            nums -= 1
        }
    }
    
    func loadBasicTextField() {
        createNewTextField()
        createNewTextField()
        uiviewArray[0].alpha = 1.0
        uiviewArray[0].center.y = uiviewArray[0].center.y - 100.0
        let placeholder = NSAttributedString(string: "Type a comment...", attributes: [NSForegroundColorAttributeName: colorPlaceHolder])
        uiviewArray[0].customTextField.attributedPlaceholder = placeholder
        uiviewArray[0].lineNumber = 2
        uiviewArray[0].customTextField.autocapitalizationType = UITextAutocapitalizationType.None
        uiviewArray[1].alpha = 1.0
        uiviewArray[1].center.y = uiviewArray[1].center.y - 50.0
        uiviewArray[1].lineNumber = 3
        
        let gesture_2 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_2(_:)))
        let gesture_3 = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.userDragged_3(_:)))
        uiviewArray[0].addGestureRecognizer(gesture_2)
        uiviewArray[1].addGestureRecognizer(gesture_3)
    }
    
    func createNewTextField() {
        let newTextField = CustomUIViewForScrollableTextField()
        self.uiviewCreateCommentPin.addSubview(newTextField)
        newTextField.customTextField.delegate = self
        uiviewArray.append(newTextField)
        textFieldArray.append(newTextField.customTextField)
        borderArray.append(newTextField.customBorder)
        newTextField.alpha = 0.0
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
    }
    func actionSelectLocation(sender: UIButton!) {
        submitPinsHideAnimation()
        faeMapView.addSubview(imagePinOnMap)
        buttonToNorth.hidden = true
        buttonChatOnMap.hidden = true
        buttonPinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = false
        imagePinOnMap.hidden = false
        self.navigationController?.navigationBar.hidden = true
        searchBarSubview.alpha = 1.0
        searchBarSubview.hidden = false
        tblSearchResults.hidden = false
        uiviewTableSubview.hidden = false
        self.customSearchController.customSearchBar.text = ""
        buttonSelfPosition.center.x = 368.5
        buttonSelfPosition.center.y = 625.5
        buttonSelfPosition.hidden = false
        buttonCancelSelectLocation.hidden = false
        isInPinLocationSelect = true
    }
    
    func actionCancelSelectLocation(sender: UIButton!) {
        submitPinsShowAnimation()
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonSelfPosition.center.x = 362.5
        buttonSelfPosition.center.y = 611.5
        buttonCancelSelectLocation.hidden = true
    }
    
    func actionCreateCommentPin(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
            self.uiviewCreateCommentPin.alpha = 1.0
        }), completion: nil)
        labelSelectLocationContent.text = "Current Location"
    }
    
    func actionBackToPinSelections(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 1.0
            self.uiviewCreateCommentPin.alpha = 0.0
        }), completion: nil)
        for textFiled in textFieldArray {
            textFiled.endEditing(true)
        }
    }
    
    func actionSetLocationForComment(sender: UIButton!) {
        // May have bug here
        submitPinsShowAnimation()
        let valueInSearchBar = self.customSearchController.customSearchBar.text
        if valueInSearchBar == "" {
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
            GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
                (response, error) -> Void in
                if let fullAddress = response?.firstResult()?.lines {
                    var addressToSearchBar = ""
                    for line in fullAddress {
                        if fullAddress.indexOf(line) == fullAddress.count-1 {
                            addressToSearchBar += line + ""
                        }
                        else {
                            addressToSearchBar += line + ", "
                        }
                    }
                    self.labelSelectLocationContent.text = addressToSearchBar
                }
            })
        }
        else {
            self.labelSelectLocationContent.text = valueInSearchBar
        }
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonSelfPosition.center.x = 362.5
        buttonSelfPosition.center.y = 611.5
        buttonCancelSelectLocation.hidden = true
    }
    
    func actionSubmitComment(sender: UIButton) {
        
        let postSingleComment = FaeMap()
        var submitLatitude = ""
        var submitLongitude = ""
        
        if self.labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(self.currentLatitude)"
            submitLongitude = "\(self.currentLongitude)"
        }
        else {
            submitLatitude = "\(self.latitudeForPin)"
            submitLongitude = "\(self.longitudeForPin)"
        }
        
        var commentContent = ""
        for everyTextField in textFieldArray {
            if let textContent = everyTextField.text {
                commentContent += textContent
            }
        }
        
        if commentContent == "" {
            let alertUIView = UIAlertView(title: "Content Field is Empty!", message: nil, delegate: self, cancelButtonTitle: "OK, I got it")
            alertUIView.show()
            return
        }
        
        postSingleComment.whereKey("geo_latitude", value: submitLatitude)
        postSingleComment.whereKey("geo_longitude", value: submitLongitude)
        postSingleComment.whereKey("content", value: commentContent)
        postSingleComment.postComment{(status:Int,message:AnyObject?) in
            if let getMessage = message {
                if let getMessageID = getMessage["comment_id"] {
                    self.submitPinsHideAnimation()
                    let commentMarker = GMSMarker()
                    var mapCenter = self.faeMapView.center
                    // Attention: the actual location of this marker is 6 points different from the displayed one
                    mapCenter.y = mapCenter.y + 6.0
                    let mapCenterCoordinate = self.faeMapView.projection.coordinateForPoint(mapCenter)
                    commentMarker.icon = UIImage(named: "comment_pin_marker")
                    commentMarker.position = mapCenterCoordinate
                    commentMarker.appearAnimation = kGMSMarkerAnimationPop
                    commentMarker.map = self.faeMapView
                    self.buttonToNorth.hidden = false
                    self.buttonSelfPosition.hidden = false
                    self.buttonChatOnMap.hidden = false
                    self.buttonPinOnMap.hidden = false
                    self.buttonSetLocationOnMap.hidden = true
                    self.imagePinOnMap.hidden = true
                    self.navigationController?.navigationBar.hidden = false
                    
                    let getJustPostedComment = FaeMap()
                    getJustPostedComment.getComment("\(getMessageID!)"){(status:Int,message:AnyObject?) in
                        let mapInfoJSON = JSON(message!)
                        var pinData = [String: AnyObject]()
                        
                        pinData["comment_id"] = getMessageID!
                        pinData["type"] = "comment"
                        
                        if let userIDInfo = mapInfoJSON["user_id"].int {
                            pinData["user_id"] = userIDInfo
                        }
                        if let createdTimeInfo = mapInfoJSON["created_at"].string {
                            pinData["created_at"] = createdTimeInfo
                        }
                        if let contentInfo = mapInfoJSON["content"].string {
                            pinData["content"] = contentInfo
                        }
                        if let latitudeInfo = mapInfoJSON["geolocation"]["latitude"].double {
                            pinData["latitude"] = latitudeInfo
                        }
                        if let longitudeInfo = mapInfoJSON["geolocation"]["longitude"].double {
                            pinData["longitude"] = longitudeInfo
                        }
                        commentMarker.userData = pinData
                    }
                    self.textFieldArray.removeAll()
                    self.borderArray.removeAll()
                    for every in self.uiviewArray {
                        every.removeFromSuperview()
                    }
                    self.uiviewArray.removeAll()
                    self.loadBasicTextField()
                }
                else {
                    print("Cannot get comment_id of this posted comment")
                }
            }
            else {
                print("Post Comment Fail")
            }
        }
    }
}