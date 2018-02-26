//
//  FullAlbumViewController.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class FullAlbumViewController: UIViewController {
    var selectedAssets = [FaePHAsset]()
    var faePhotoPicker: FaePhotoPicker!
    var prePhotoPicker: FaePhotoPicker?
    weak var delegate: FaeChatToolBarContentViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configure = FaePhotoPickerConfigure()
        
        faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), with: configure)
        //faePhotoPicker.selectedAssets = selectedAssets
        if let photoPicker = prePhotoPicker {
            //faePhotoPicker.collections = photoPicker.collections
            faePhotoPicker.loadCameraRollCollection(collection: photoPicker.collections[0])
        }
        faePhotoPicker.rightBtnHandler = handleDone
        faePhotoPicker.leftBtnHandler = cancel
        view.addSubview(faePhotoPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleDone(_ results: [FaePHAsset], _ camera: Bool) {
        print(results.count)
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        delegate?.sendMediaMessage(with: results)
        //complete?(results, camera)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}
