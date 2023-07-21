//
//  PaddingLabel.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import Foundation
import UIKit

@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topPadding: CGFloat = 0.0
    @IBInspectable var bottomPadding: CGFloat = 0.0
    @IBInspectable var leftPadding: CGFloat = 0.0
    @IBInspectable var rightPadding: CGFloat = 0.0
    @IBInspectable var borderColor : UIColor = UIColor.white
    @IBInspectable var borderWidth : CGFloat = 0
    @IBInspectable var cornerRadius : CGFloat = 0
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.topPadding = padding.top
        self.leftPadding = padding.left
        self.bottomPadding = padding.bottom
        self.rightPadding = padding.right
    }
    
    override func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        super.drawText(in: rect.inset(by: padding))
    }
    
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += self.leftPadding + self.rightPadding
        contentSize.height += self.topPadding + self.bottomPadding
        return contentSize
    }
    override func draw(_ rect: CGRect) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        super.draw(rect)
    }
}
