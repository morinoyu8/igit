//
//  GraphCommitInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit
import SwiftGit2

class GraphCommitInfo: GraphInfo {
    
    // Commit
    let commit: Commit
    
    init(commit: Commit, depth_x: Int, depth_y: Int, color: UIColor) {
        self.commit = commit
        super.init(depth_x: depth_x, depth_y: depth_y, color: color)
    }
}
