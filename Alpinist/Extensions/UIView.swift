//
//  UIView.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addShadow(color: UIColor = UIColor.black.withAlphaComponent(0.25),
                   offset: CGSize = CGSize(width: 0, height: 4),
                   radius: CGFloat = 4,
                   opacity: Float = 1.0) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    func addBottomBorder(color: UIColor, thickness: CGFloat) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
        bottomBorder.backgroundColor = color.cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
//    func addTopBorder(color: UIColor, thickness: CGFloat) {
//        let topBorder = CALayer()
//        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
//        topBorder.backgroundColor = color.cgColor
//        self.layer.addSublayer(topBorder)
//    }
    
    func addTopBorder(color: UIColor, thickness: CGFloat) {
        // Define a unique name for the top border layer
        let borderLayerName = "topBorderLayer"
        
        // Check if a layer with this name already exists and remove it
        if let sublayers = self.layer.sublayers {
            for sublayer in sublayers where sublayer.name == borderLayerName {
                sublayer.removeFromSuperlayer()
            }
        }
        
        // Create a new top border layer
        let topBorder = CALayer()
        topBorder.name = borderLayerName // Assign the unique name
        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
        topBorder.backgroundColor = color.cgColor
        
        // Add the new layer to the view
        self.layer.addSublayer(topBorder)
    }

    
    func toImage() -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {

        var borders = [UIView]()

        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }


        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
    
    func addRoundedBorder(cornerRadius: CGFloat = 8, borderColor: UIColor = .black, borderWidth: CGFloat = 2) {
            // Remove existing border if any
            layer.sublayers?.forEach { sublayer in
                if let shapeLayer = sublayer as? CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                }
            }
            
            // Create CAShapeLayer
            let shapeLayer = CAShapeLayer()
            
            // Set the path for rounded corners with a border
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            
            // Set the layer's path
            shapeLayer.path = path.cgPath
            
            // Set the stroke color and line width
            shapeLayer.strokeColor = borderColor.cgColor
            shapeLayer.lineWidth = borderWidth
            
            // Set the fill color to clear, so only the border is visible
            shapeLayer.fillColor = UIColor.clear.cgColor
            
            // Add the shapeLayer to the view's layer
            layer.addSublayer(shapeLayer)
        }
}

