//
//  BoardNoResultCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-20.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class BoardNoResultCell: UITableViewCell {
    var uiview: BoardNoResultView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        uiview = BoardNoResultView(frame: CGRect.zero)
        addSubview(uiview)
    }
    
    func setValueForCell(hint: String) {
        uiview.setBubbleHintVal(hint)
    }
}
