//
//  GraphCommitInfo.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/04.
//

import UIKit
import SwiftGit2

class GraphCommitInfo: GraphInfo {
    
    // CommitID
    let oid: OID
    
    init(oid: OID, depth_x: Int, depth_y: Int, color: UIColor) {
        self.oid = oid
        super.init(depth_x: depth_x, depth_y: depth_y, color: color)
    }
}
