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
    
    // The color index of GraphConfig.colors
    let colorIndex: Int
    
    init(nextDepth_y: [Int], colorIndex: Int) {
        self.nextDepth_y = nextDepth_y
        self.colorIndex = colorIndex
    }
}
