//
//  MenuItemCell.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-28.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit
import Foundation


protocol MenuItemCell {
    var delegate: MenuItemDelegate? { get set }
    var action: String? { get set }
    func buttonAction(_ sender: UIButton)
}
