//
//  ShadowView.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import Foundation

import UIKit

class ShadowView: UIView {
    
    override init(frame: CGRect) {
         super.init(frame: frame)
        addShadow()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         addShadow()
     }
}
