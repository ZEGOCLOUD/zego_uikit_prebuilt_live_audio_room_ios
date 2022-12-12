//
//  UIView+ZGCall.swift
//  UIKitTestProject
//
//  Created by zego on 2022/9/1.
//

import Foundation
import UIKit

extension UIView {
    func liveAudio_removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func cornerCut(_ radius: Int, corner: UIRectCorner) {
        let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
