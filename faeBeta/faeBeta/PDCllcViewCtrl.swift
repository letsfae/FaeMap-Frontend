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
        return self.chatRoomUserIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pdChatUserCell", for: indexPath) as! PDChatUserCell
        
        cell.layer.borderWidth = indexPath.row == 0 ? 2 : 0
        cell.setValueForCell(userId: chatRoomUserIds[indexPath.row])
        
        return cell
    }
}
