//
//  RoundedRectangle.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

//class RoundedRectangle: UIView {
//    
//    let rect: CGRect
//    let cornerRadius: CGFloat
//    let innerColor: UIColor
//    let lineColor: UIColor
//    let lineWidth: CGFloat
//    
//    init(frame: CGRect, rect: CGRect, cornarRadius: CGFloat, innerColor: UIColor, lineColer: UIColor, lineWiidth: CGFloat) {
//        self.rect = rect
//        self.cornerRadius = cornarRadius
//        self.innerColor = innerColor
//        self.lineColor = lineColer
//        self.lineWidth = lineWiidth
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func draw(_ rect: CGRect) {
//        let roundedRectangle = UIBezierPath(roundedRect: self.rect, cornerRadius: cornerRadius)
//        
//        innerColor.setFill()
//        
//        lineColor.setStroke()
//        roundedRectangle.lineWidth = lineWidth
//        roundedRectangle.stroke()
//        roundedRectangle.fill()
//    }
//}
