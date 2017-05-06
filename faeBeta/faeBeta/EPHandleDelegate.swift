//
//  ECPHandleDelegate.swift
//  faeBeta
//
//  Created by Jacky on 1/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

extension EditPinViewController: UITextViewDelegate, CreatePinInputToolbarDelegate, SendStickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate, EditMediaCollectionCellDelegate, EditPinMoreOptionsDelegate {
    
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar) {
        self.view.endEditing(true)
        if(isShowingEmoji){
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
    }
    
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if(!isShowingEmoji){
            isShowingEmoji = true
            self.view.endEditing(true)
            showEmojiViewAnimated(animated: true)
        }else{
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: false)
        }
    }
    
    func sendStickerWithImageName(_ name : String) {
        // do nothing here, won't send sticker
    }
    func appendEmojiWithImageName(_ name: String) {
        self.textViewUpdateComment.insertText("[\(name)]")
        self.textViewDidChange(textViewUpdateComment) //Don't forget adding this line, otherwise there will be a little bug if textfield is null while appending Emoji
    }
    func deleteEmoji() {
        self.textViewUpdateComment.text = self.textViewUpdateComment.text.stringByDeletingLastEmoji()
        self.textViewDidChange(self.textViewUpdateComment)
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewUpdateComment {
            let spacing = CharacterSet.whitespacesAndNewlines
            print(textViewUpdateComment.text)
            if textViewUpdateComment.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonSave.isEnabled = true
                labelTextViewPlaceholder.isHidden = true
            }else {
                buttonSave.isEnabled = false
                labelTextViewPlaceholder.isHidden = false
            }
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            var numlineOnDevice = 3
            if screenWidth == 375 {
                numlineOnDevice = 4
            }
            else if screenWidth == 414 {
                numlineOnDevice = 7
            }
            if numLines <= numlineOnDevice {
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                textView.isScrollEnabled = false
            }
            else if numLines > numlineOnDevice {
                textView.isScrollEnabled = true
            }
            inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
            checkButtonState()
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
        if isShowingEmoji == true {
            isShowingEmoji = false
            UIView.animate(withDuration: 0.3, animations: {
                self.emojiView.frame.origin.y = self.screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
            })
            self.textViewUpdateComment.becomeFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewUpdateComment {
            if (text == "\n")  {
                textViewUpdateComment.resignFirstResponder()
                return false
            }
            let countChars = textView.text.characters.count + (text.characters.count - range.length)
            return countChars <= 200
        }
        return true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinMediaImageArray.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinMedia", for: indexPath) as! EditPinCollectionViewCell
        if indexPath.row == 0 {
            cell.media.image = #imageLiteral(resourceName: "editPinAddMedia")
            cell.buttonCancel.isHidden = true
        }else {
            cell.media.image = pinMediaImageArray[indexPath.row-1].image
            cell.buttonCancel.isHidden = false
        }
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EditPinCollectionViewCell
        if indexPath.row == 0 {
            pickMedia()
        }else {
            let image = cell.media.image
            let photos = IDMPhoto.photos(withImages: [image!])
            let browser = IDMPhotoBrowser(photos: photos)
            self.present(browser!, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newAddedImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 95, height: 95))
        newAddedImage.image = image
        self.pinMediaImageArray.append(newAddedImage)
        self.newAddedImageArray.append(image)
        loadIndicator()
        checkButtonState()
        uploadFile(image: newAddedImageArray[0], count: 0, total: 1)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func sendImages(_ images: [UIImage]) {
        newAddedImageArray.removeAll()
        for image in images {
            let newAddedView = UIImageView(frame: CGRect(x: 0, y: 0, width: 95, height: 95))
            newAddedView.image = image
            pinMediaImageArray.append(newAddedView)
            newAddedImageArray.append(image)
        }
        if images.count > 0 {
            loadIndicator()
            uploadFile(image: newAddedImageArray[0], count: 0, total: images.count)
            checkButtonState()
        }
    }
    
    func sendMapCameraInfo(latitude: String, longitude: String, zoom: Float) {
        pinGeoLocation = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        zoomLevelCallBack = zoom
    }
}
