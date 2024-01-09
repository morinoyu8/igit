//
//  GraphInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

class GraphInfo {
    
    // Next
    var nextDepth_y: [Int] = []
    
    // The color of this graph.
    let color: UIColor
    
    init(nextDepth_y: [Int], color: UIColor) {
        self.nextDepth_y = nextDepth_y
        self.color = color
    }
}
