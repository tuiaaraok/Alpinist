//
//  CheckBoxButton.swift
//  Graffity
//
//  Created by Karen Khachatryan on 27.11.24.
//

import UIKit

class CheckBoxButton: UIButton {
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .baseGreen : .baseGray
        }
    }
    
    func commonInit() {
        self.setImage(.checkMark, for: .selected)
        self.setImage(nil, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
