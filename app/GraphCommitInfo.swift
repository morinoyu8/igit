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
    
    init(commit: Commit, nextDepth_x: [Int], colorIndex: Int) {
        self.commit = commit
        super.init(nextDepth_x: nextDepth_x, colorIndex: colorIndex)
    }
}
