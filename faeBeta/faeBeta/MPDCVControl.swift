//
//  MPDCVControl.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension MomentPinDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! MPDCollectionViewCell
            return cell
        }
        else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
}
