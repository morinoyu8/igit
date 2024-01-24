//
//  Graph.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/11.
//

import UIKit
import SwiftGit2

class Graph {
    
    let repoManager: RepositoryManager
    
    let parentView: GraphView
    
    var infos: [[GraphInfo]] = [] {
        didSet {
            if oldValue.count > 0 {
                infos = oldValue
            }
        }
    }
    
    init(repo: RepositoryManager, parentView: GraphView) {
        self.repoManager = repo
        self.parentView = parentView
    }
    
    // Draw a line connecting commits
    private func drawLine(start: CGPoint, end: CGPoint, color: UIColor) {
        let margin: CGFloat = 5
        let origin = CGPoint(x: min(start.x, end.x) - margin, y: min(start.y, end.y) - margin)
        let size = CGSize(width: max(start.x, end.x) - min(start.x, end.x) + 2 * margin, height: end.y - start.y + 2 * margin)
        var startPoint: CGPoint = CGPoint(x: margin, y: margin)
        var endPoint: CGPoint = CGPoint(x: size.width - margin, y: size.height - margin)
        if end.x - start.x < 0 {
            startPoint = CGPoint(x: size.width - margin, y: margin)
            endPoint = CGPoint(x: margin, y: size.height - margin)
        }
        
        let line = Line(frame: CGRect(origin: origin, size: size), start: startPoint, end: endPoint, color: color, weight: GraphConfig.lineWeight)
        parentView.view.addSubview(line)
        parentView.view.sendSubviewToBack(line)
    }
   
    // Draw a commit point
    private func drawCommitPoint(point: CGPoint, color: UIColor) {
        let radius = GraphConfig.commitPointRadius
        let circle = Circle(frame: CGRect(origin: point - CGPoint(x: radius, y: radius), size: CGSize(width: radius * 2, height: radius * 2)), arcCenter: CGPoint(x: radius, y: radius), radius: CGFloat(radius), color: color)
        parentView.view.addSubview(circle)
    }
    
    
    private func drawCommitText(commitInfo info: GraphCommitInfo, point: CGPoint) {
        let message = UILabel(frame: CGRect(origin: point, size: CGSize(width: GraphConfig.messageWidth, height: GraphConfig.messageHeight)))
        message.font = UIFont(name: GraphConfig.fontName, size: GraphConfig.fontSize)
        
        var text = ""
        var refNameRange: [(start: Int, end: Int)] = []
        if info.branches.count > 0 {
            text = "( "
            var refNameLength = 2
            for (i, branch) in info.branches.enumerated() {
                text += branch.name
                refNameRange.append((refNameLength, branch.name.count))
                refNameLength += branch.name.count + 2
                
                if i != info.branches.count - 1 {
                    text += ", "
                }
            }
            text += " ) "
        }
        text += info.commit.message
        let attrText = NSMutableAttributedString(string: text)
        for range in refNameRange {
            attrText.addAttributes([
                .foregroundColor: GraphConfig.colors[info.colorIndex],
                    .font: UIFont(name: GraphConfig.boldFontName, size: GraphConfig.fontSize)!
            ], range: NSMakeRange(range.start, range.end))
        }

        message.attributedText = attrText
        parentView.view.addSubview(message)
        parentView.view.bringSubviewToFront(message)
    }
    
    private func depth2Position(depth_x: Int, depth_y: Int) -> CGPoint {
        return CGPoint(x: depth_x * GraphConfig.dist_x + GraphConfig.margin_x, y: depth_y * GraphConfig.dist_y + GraphConfig.margin_y)
    }
    
    private func drawCommit(commitInfo info: GraphCommitInfo, depth_x: Int, depth_y: Int) {
        let point = depth2Position(depth_x: depth_x, depth_y: depth_y)
        let textPoint = depth2Position(depth_x: infos[depth_y].count - 1, depth_y: depth_y) + CGPoint(x: GraphConfig.distGraphAndMessage, y: -GraphConfig.messageHeight / 2)
        drawCommitPoint(point: point, color: GraphConfig.colors[info.colorIndex])
        drawCommitText(commitInfo: info, point: textPoint)
    }
    
    private func drawOneTimeGraph(depth_y: Int) {
        // Draw commit points
        for (depth_x, info) in infos[depth_y].enumerated() {
            if let commitInfo = info as? GraphCommitInfo {
                drawCommit(commitInfo: commitInfo, depth_x: depth_x, depth_y: depth_y)
            }
        }
        
        // Draw Line
        for (depth_x, info) in infos[depth_y].enumerated() {
            for next in info.nextDepth_x {
                var color = GraphConfig.colors[info.colorIndex]
                if depth_x < next && next < infos[depth_y + 1].count {
                    color = GraphConfig.colors[infos[depth_y + 1][next].colorIndex]
                }
                
                drawLine(start: depth2Position(depth_x: depth_x, depth_y: depth_y), end: depth2Position(depth_x: next, depth_y: depth_y + 1), color: color)
            }
        }
    }
    
    func draw() throws {
        // Construct graph infos
        do {
            try constructGraphInfo()
        } catch {
            throw error
        }
        
        print("Graph construction done.")
        parentView.deleteGraph()
        
        var maxOneTimeInfoCount = 0
        for depth_y in 0..<infos.count {
            if maxOneTimeInfoCount < infos[depth_y].count {
                maxOneTimeInfoCount = infos[depth_y].count
            }
            drawOneTimeGraph(depth_y: depth_y)
        }
        
        let viewWidth = maxOneTimeInfoCount * GraphConfig.dist_x + GraphConfig.distGraphAndMessage + GraphConfig.messageWidth + 2 * GraphConfig.margin_x
        let viewHeight = (infos.count - 1) * GraphConfig.dist_y + 2 * GraphConfig.margin_y
        setContentViewSize(size: CGSize(width: viewWidth, height: viewHeight))
    }
    
    private func setContentViewSize(size: CGSize) {
        parentView.viewWidth.constant = size.width
        parentView.viewHeight.constant = size.height
        parentView.scrollViewHeight.constant = size.height
    }
    
    // Update colorCount and return the color index of the new branch
    private func newColor(colorCount: inout [Int]) -> Int {
        assert(colorCount.count == GraphConfig.colors.count)
        let min = colorCount.min()
        var index = 0
        for (i, x) in colorCount.enumerated() {
            if x == min {
                index = i
                break
            }
        }
        colorCount[index] += 1
        return index
    }
    
    
    private func constructGraphInfo() throws {
        let branches = repoManager.getOid2Branch()
        
        let head = repoManager.repo.HEAD().flatMap { repoManager.repo.commit($0.oid) }
        var infos: [[GraphInfo]] = []
        var colorCount = Array<Int>(repeating: 0, count: GraphConfig.colors.count)
        
        switch head {
        case let .success(commit):
            
            // Commit iterator
            let iter = repoManager.repo.commits(from: commit.oid)
            
            // HEAD initialization
            let head = GraphCommitInfo(commit: commit, nextDepth_x: [0], colorIndex: newColor(colorCount: &colorCount))
            head.branches = branches[commit.oid] ?? []
            infos.append([head])
            
            // Next commit oid of depth_x in the iteration
            var nexts: [OID] = []
            
            // Merge commit
            if commit.parents.count == 2 {
                let new1 = GraphInfo(nextDepth_x: [0], colorIndex: infos[0][0].colorIndex)
                let new2 = GraphInfo(nextDepth_x: [1], colorIndex: newColor(colorCount: &colorCount))
                infos.append([new1, new2])
                head.nextDepth_x.append(1)
                nexts = [commit.parents.first!.oid, commit.parents.last!.oid]
            } else if commit.parents.count == 1 {
                let new1 = GraphInfo(nextDepth_x: [0], colorIndex: infos[0][0].colorIndex)
                infos.append([new1])
                nexts = [commit.parents.first!.oid]
            } else {
                infos[0][0].nextDepth_x = []
                self.infos = infos
                return
            }
            
            let _ = iter.next()
            
            var currentDepth_y = 1
            
            while (true) {
                let result = iter.next()
                assert(infos.count > currentDepth_y)
                var deletedColor = Array<Int>(repeating: 0, count: GraphConfig.colors.count)
                
                switch result {
                case let .success(commit):
                    // print("Commit: \(commit.message)")
                    
                    // Add commit infomation
                    var commitDepth_y = -1
                    for (i, next) in nexts.enumerated() {
                        if next.description == commit.oid.description {
                            assert(infos[currentDepth_y].count > i)
                            
                            let color = infos[currentDepth_y][i].colorIndex
                            let new = GraphCommitInfo(commit: commit, nextDepth_x: [i], colorIndex: color)
                            new.branches = branches[commit.oid] ?? []
                            infos[currentDepth_y][i] = new
                            commitDepth_y = i
                            break
                        }
                    }
                    
                    if commitDepth_y < 0 {
                        // Unmerged commit
                        let new = GraphCommitInfo(commit: commit, nextDepth_x: [nexts.count], colorIndex: newColor(colorCount: &colorCount))
                        new.branches = branches[commit.oid] ?? []
                        infos[currentDepth_y].append(new)
                        nexts.append(commit.oid)
                        commitDepth_y = infos[currentDepth_y].count - 1
                    } else {
                        var new_i = commitDepth_y + 1
                        var old_i = commitDepth_y + 1
                        let count = nexts.count
                        
                        while old_i < count {
                            if (infos[currentDepth_y - 1].count <= old_i) {
                                break
                            }
                            infos[currentDepth_y - 1][old_i].nextDepth_x[0] = new_i
                            infos[currentDepth_y][new_i].nextDepth_x[0] = new_i
                            
                            // When create new branches
                            if nexts[new_i].description == commit.oid.description {
                                assert(infos[currentDepth_y - 1].count > old_i)
                                infos[currentDepth_y - 1][old_i].nextDepth_x = [commitDepth_y]
                                deletedColor[infos[currentDepth_y][new_i].colorIndex] += 1
                                infos[currentDepth_y].remove(at: new_i)
                                nexts.remove(at: new_i)
                                old_i += 1
                                continue
                            }
                            new_i += 1
                            old_i += 1
                        }
                    }
                    
        
                    // Add next information
                    infos.append([])
                    assert(infos.count > currentDepth_y + 1)
                    for (i, info) in infos[currentDepth_y].enumerated() {
                        // Update next infomation
                        if i == commitDepth_y && commit.parents.count > 0 {
                            nexts[i] = commit.parents.first!.oid
                        }
                        let new = GraphInfo(nextDepth_x: [i], colorIndex: info.colorIndex)
                        infos[currentDepth_y + 1].append(new)
                    }
                    
                    // Merge commit
                    if commit.parents.count == 2 {
                        var newBranch = true
                        for (i, next) in nexts.enumerated() {
                            if next == commit.parents.last!.oid {
                                infos[currentDepth_y][commitDepth_y].nextDepth_x.append(i)
                                newBranch = false
                                break
                            }
                        }
                        if newBranch {
                            infos[currentDepth_y][commitDepth_y].nextDepth_x.append(nexts.count)
                            let new = GraphInfo(nextDepth_x: [nexts.count], colorIndex: newColor(colorCount: &colorCount))
                            infos[currentDepth_y + 1].append(new)
                            nexts.append(commit.parents.last!.oid)
                        }
                    }
                    
                    // Color Setting
                    for i in 0..<colorCount.count {
                        colorCount[i] -= deletedColor[i]
                    }
                    
                case let .failure(error):
                    print("Commit iteration error: \(error)")
                    throw IGitError.iterateCommits
                case .none:
                    // Remove unnecessary informatiion
                    infos.removeLast()
                    if infos.count > 0 {
                        for info in infos[infos.count - 1] {
                            info.nextDepth_x = []
                        }
                    }
                    self.infos = infos
                    return
                }
                
                currentDepth_y += 1
            }

        case let .failure(error):
            print("Cannot get head: \(error)")
            throw IGitError.getRepositoryHead
        }
    }
}

struct GraphView {
    let view: UIView
    let viewWidth: NSLayoutConstraint
    let viewHeight: NSLayoutConstraint
    let scrollViewHeight: NSLayoutConstraint
    
    func deleteGraph() {
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
    }
}

struct GraphConfig {
    
    // margin
    static let margin_x: Int = 30
    static let margin_y: Int = 30
    
    // Distance of graph
    static let dist_x: Int = 30
    static let dist_y: Int = 50
    
    // Radius of commit point
    static let commitPointRadius: Int = 5
    
    // Distance between graph and commit messages
    static let distGraphAndMessage: Int = 40
    
    // Size of commit messages
    static let messageWidth: Int = 500
    static let messageHeight: Int = 30
    
    // Font size of commit messages
    static let fontSize: CGFloat = 14
    
    // Font of commit messages
    static let fontName: String = "Menlo-Regular"
    static let boldFontName: String = "Menlo-Bold"

    // Line Weight
    static let lineWeight: CGFloat = 1.8
    
    static let colors: [UIColor] = [
        color(red:   4, green: 133, blue: 218),
        color(red: 218, green:   0, blue: 143),
        color(red:   0, green: 218, blue:   8),
        color(red: 218, green: 133, blue:   0),
        color(red: 163, green:   0, blue: 217),
        color(red: 255, green:   1, blue:   0),
        color(red:   0, green: 218, blue: 204),
        color(red: 225, green:  55, blue: 233),
        color(red: 133, green: 218, blue:   0),
        color(red: 221, green:  91, blue:  35),
        color(red: 111, green:  35, blue: 214),
        color(red: 255, green: 204, blue:   3)
    ]
    
    static private func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
