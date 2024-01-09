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
    
    // Branches
    var branches: [Branch] = []
    
    init(commit: Commit, nextDepth_y: [Int], color: UIColor) {
        self.commit = commit
        super.init(nextDepth_y: nextDepth_y, color: color)
    }
}
