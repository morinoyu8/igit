//
//  GraphInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

class GraphInfo {
    
    // Next
    var nextDepth_x: [Int] = []
    
    // The color index of GraphConfig.colors
    let colorIndex: Int
    
    init(nextDepth_x: [Int], colorIndex: Int) {
        self.nextDepth_x = nextDepth_x
        self.colorIndex = colorIndex
    }
}
