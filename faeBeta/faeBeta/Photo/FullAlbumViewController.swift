//
//  FullAlbumViewController.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

protocol FullAlbumSelectionDelegate: class {
    func finishChoosing(with faePHAssets: [FaePHAsset])
}

class FullAlbumViewController: UIViewController {
    // MARK: - Properties
    var selectedAssets = [FaePHAsset]()
    private var faePhotoPicker: FaePhotoPicker!
    var prePhotoPicker: FaePhotoPicker?
    weak var delegate: FaeChatToolBarContentViewDelegate?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let configure = FaePhotoPickerConfigure()
        
        faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), with: configure)
        //faePhotoPicker.selectedAssets = selectedAssets
        if let photoPicker = prePhotoPicker {
            //faePhotoPicker.collections = photoPicker.collections
            faePhotoPicker.selectedAssets = photoPicker.selectedAssets
            faePhotoPicker.loadCameraRollCollection(collection: photoPicker.collections[0])
        }
        faePhotoPicker.rightBtnHandler = handleDone
        faePhotoPicker.leftBtnHandler = cancel
        faePhotoPicker.alertHandler = handleAlert
        view.addSubview(faePhotoPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button actions
    private func handleDone(_ results: [FaePHAsset], _ camera: Bool) {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        delegate?.sendMediaMessage(with: results)
    }
    
    private func cancel() {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    private func handleAlert(_ message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
