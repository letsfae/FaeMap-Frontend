//
//  PDCllcViewCtrl.swift
//  faeBeta
//
//  Created by Yue on 4/13/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell",
                                                      for: indexPath)
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            cell.layer.borderWidth = 2
            let cellbordercolor: UIColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 100)
            cell.layer.borderColor = cellbordercolor.cgColor
        }
        else {
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            cell.layer.borderWidth = 0
        }
        return cell
    }
}
