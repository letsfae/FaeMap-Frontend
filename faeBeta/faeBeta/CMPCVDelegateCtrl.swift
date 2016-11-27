//
//  CMPCVDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedMedia", for: indexPath) as! CMPCollectionViewCell
            cell.media.image = selectedMediaArray[indexPath.row]
            return cell
        }
        else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
}
