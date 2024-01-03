//
//  GraphInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit

class GraphInfo {
    
    // The point of the vertical axis of the graph.
    // On the commit graph, the value increases when a new branch is introduced.
    //
    // ex) point_y of A = 0, point_y of B = 1 and point_y of C = 0, if
    //
    //     * (A)
    //     | \
    //     |  * (B)
    //     | /
    //     * (C)
    //
    let point_x: Int
    
    // The point of the vertical axis of the graph.
    // On the commit graph, the order increases from newest to oldest.
    //
    // ex) point_y of A = 0, point_y of B = 1 and point_y of C = 2, if
    //
    //     * (A)
    //     | \
    //     |  * (B)
    //     | /
    //     * (C)
    //
    let point_y: Int
    
    // The color of this graph.
    let color: UIColor
    
    init(point_x: Int, point_y: Int, color: UIColor) {
        self.point_x = point_x
        self.point_y = point_y
        self.color = color
    }
}
