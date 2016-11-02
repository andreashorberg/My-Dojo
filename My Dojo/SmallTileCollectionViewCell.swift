//
//  SmallTileCollectionViewCell.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-26.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class SmallTileCollectionViewCell: UICollectionViewCell, MenuItemCell {
    @IBOutlet weak var button: UIButton!
    
    var action: String?
    var delegate: MenuItemDelegate?
    @IBAction func buttonAction(_ sender: UIButton) {
        if let actionToPerform = action, !(action?.isEmpty)! {
            delegate?.menuButtonAction(with: actionToPerform)
        }
    }
}
