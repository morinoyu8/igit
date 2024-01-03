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
    
    init(oid: OID, point_x: Int, point_y: Int, color: UIColor) {
        self.oid = oid
        super.init(point_x: point_x, point_y: point_y, color: color)
    }
}
