//
//  Circle.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

//import UIKit
//
//class Circle: UIView {
//    
//    var arcCenter: CGPoint = .zero
//    var radius: CGFloat = .zero
//    var color: UIColor = .gray
//    
//    init(frame: CGRect, arcCenter: CGPoint, radius: CGFloat, color: UIColor) {
//        super.init(frame: frame)
//        self.arcCenter = arcCenter
//        self.radius = radius
//        self.color = color
//        self.backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func draw(_ rect: CGRect) {
//        let circle = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi) * 2, clockwise: true)
//        color.setFill()
//        circle.fill()
//    }
//}

