//
//  UITextField.swift
//  Prompt_Keeper
//
//  Created by Karen Khachatryan on 19.11.24.
//

import UIKit

extension UITextField {
    func setupLeftViewIcon(_ image: UIImage, size: CGSize) {
        let icon = UIImageView(frame:CGRect(x: 0, y: 0, width: size.width, height: size.height))
        icon.image = image
        icon.contentMode = .center
        let iconContainerView: UIView = UIView(frame:CGRect(x: 0, y: 0, width: size.width, height: size.height))
        iconContainerView.isUserInteractionEnabled = false
        iconContainerView.addSubview(icon)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
