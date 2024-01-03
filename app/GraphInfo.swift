//
//  GraphInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

class GraphInfo {
    
    // The depth of the horizontal axis of the graph.
    // On the commit graph, the value increases when a new branch is introduced.
    //
    // ex) depth_x of A = 0, depth_x of B = 1 and depth_x of C = 0, if
    //
    //     * (A)
    //     | \
    //     |  * (B)
    //     | /
    //     * (C)
    //
    let depth_x: Int
    
    // The depth of the vertical axis of the graph.
    // On the commit graph, the order increases from newest to oldest.
    //
    // ex) depth_y of A = 0, depth_y of B = 1 and depth_y of C = 2, if
    //
    //     * (A)
    //     | \
    //     |  * (B)
    //     | /
    //     * (C)
    //
    let depth_y: Int
    
    // The color of this graph.
    let color: UIColor
    
    init(depth_x: Int, depth_y: Int, color: UIColor) {
        self.depth_x = depth_x
        self.depth_y = depth_y
        self.color = color
    }
}
