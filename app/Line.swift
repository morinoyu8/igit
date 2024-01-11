//
//  Line.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

class Line: UIView {
    
    let start: CGPoint
    let end: CGPoint
    let color: UIColor
    let weight: CGFloat
    
    init(frame: CGRect, start: CGPoint, end: CGPoint, color: UIColor, weight: CGFloat) {
        self.start = start
        self.end = end
        self.color = color
        self.weight = weight
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        line.move(to: start)
        if start.x == end.x {
            line.addLine(to: end)
        } else {
            let diff_y = end.y - start.y
            let cp1 = CGPoint(x: start.x, y: start.y + diff_y * 2 / 3)
            let cp2 = CGPoint(x: end.x, y: start.y + diff_y * 1 / 3)
            line.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        }
        color.setStroke()
        line.lineWidth = weight
        line.stroke()
    }
}
