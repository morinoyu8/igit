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
        let mergin: CGFloat = 5
        let origin = CGPoint(x: min(start.x, end.x) - mergin, y: min(start.y, end.y) - mergin)
        let size = CGSize(width: max(start.x, end.x) - min(start.x, end.x) + 2 * mergin, height: end.y - start.y + 2 * mergin)
        var startPoint: CGPoint = CGPoint(x: mergin, y: mergin)
        var endPoint: CGPoint = CGPoint(x: size.width - mergin, y: size.height - mergin)
        if end.x - start.x < 0 {
            startPoint = CGPoint(x: size.width - mergin, y: mergin)
            endPoint = CGPoint(x: mergin, y: size.height - mergin)
        }
        
        let line = Line(frame: CGRect(origin: origin, size: size), start: startPoint, end: endPoint, color: color, weight: 1.8)
        parentView.view.addSubview(line)
        parentView.view.sendSubviewToBack(line)
    }
   
    // Draw a commit point
    private func drawCommitPoint(point: CGPoint, color: UIColor) {
        let radius = 5
        let circle = Circle(frame: CGRect(origin: point - CGPoint(x: radius, y: radius), size: CGSize(width: radius * 2, height: radius * 2)), arcCenter: CGPoint(x: radius, y: radius), radius: CGFloat(radius), color: color)
        parentView.view.addSubview(circle)
    }
    
    
    private func drawCommitText(commitInfo info: GraphCommitInfo, depth_x: Int, depth_y: Int) {
        let width = 500
        let height = 30
        let fontSize: CGFloat = 14
        
        let message = UILabel(frame: CGRect(origin: CGPoint(x: depth_x * 50 + 50, y: depth_y * 50 + 35), size: CGSize(width: width, height: height)))
        message.font = UIFont(name: "Menlo-Regular", size: fontSize)
        
        var text = ""
        var refNameRange: [(Int, Int)] = []
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
                    .foregroundColor: info.color,
                    .font: UIFont(name: "Menlo-Bold", size: fontSize)!
            ], range: NSMakeRange(range.0, range.1))
        }

        message.attributedText = attrText
        parentView.view.addSubview(message)
        parentView.view.bringSubviewToFront(message)
    }
    
    private func depth2Position(depth_x: Int, depth_y: Int) -> CGPoint {
        return CGPoint(x: depth_x * 50 + 20, y: depth_y * 50 + 50)
    }
    
    private func drawOneTimeGraph(infos: [GraphInfo], index: Int) {
        for (i, info) in infos.enumerated() {
            if let commitInfo = info as? GraphCommitInfo {
                drawCommitPoint(point: depth2Position(depth_x: i, depth_y: index), color: info.color)
                drawCommitText(commitInfo: commitInfo, depth_x: infos.count - 1, depth_y: index)
            }
            for x in info.nextDepth_y {
                drawLine(start: depth2Position(depth_x: i, depth_y: index), end: depth2Position(depth_x: x, depth_y: index + 1), color: .red)
            }
        }
    }
    
    func draw() throws {
        
        // Construct graph infos
        do {
            try construct()
        } catch {
            throw error
        }
        
        var maxOneTimeInfoCount = 0
        for (i, info) in infos.enumerated() {
            if maxOneTimeInfoCount < info.count {
                maxOneTimeInfoCount = info.count
            }
            drawOneTimeGraph(infos: info, index: i)
        }
        setContentViewSize(size: CGSize(width: maxOneTimeInfoCount * 50 + 540, height: infos.count * 50 + 200))
    }
    
    private func setContentViewSize(size: CGSize) {
        parentView.viewWidth.constant = size.width
        parentView.viewHeight.constant = size.height
        parentView.scrollViewHeight.constant = size.height
    }
    
    private func construct() throws {
        let branches = repoManager.getOid2Branch()
        
        let head = repoManager.repo.HEAD().flatMap { repoManager.repo.commit($0.oid) }
        var infos: [[GraphInfo]] = []
        
        switch head {
        case let .success(commit):
            
            // Commit iterator
            let iter = CommitIterator(repo: repoManager.repo, root: commit.oid.oid)
            
            // HEAD initialization
            let head = GraphCommitInfo(commit: commit, nextDepth_y: [0], color: .red)
            head.branches = branches[commit.oid] ?? []
            infos.append([head])
            
            // Next commit oid of depth_x in the iteration
            var nexts: [OID] = []
            
            // Merge commit
            if commit.parents.count == 2 {
                let new1 = GraphInfo(nextDepth_y: [0], color: .blue)
                let new2 = GraphInfo(nextDepth_y: [1], color: .blue)
                infos.append([new1, new2])
                nexts = [commit.parents.first!.oid, commit.parents.last!.oid]
            } else if commit.parents.count == 1 {
                let new1 = GraphInfo(nextDepth_y: [0], color: .blue)
                infos.append([new1])
                nexts = [commit.parents.first!.oid]
            }
            
            let _ = iter.next()
            
            var currentDepth_y = 1
            
            while (true) {
                let result = iter.next()
                assert(infos.count > currentDepth_y)
                
                switch result {
                case let .success(commit):
                    print("Commit: \(commit.message)")
                    
                    // Add commit infomation
                    var commitDepth_y = -1
                    for (i, next) in nexts.enumerated() {
                        if next.description == commit.oid.description {
                            assert(infos[currentDepth_y].count > i)
                            
                            let new = GraphCommitInfo(commit: commit, nextDepth_y: [i], color: .red)
                            new.branches = branches[commit.oid] ?? []
                            infos[currentDepth_y][i] = new
                            commitDepth_y = i
                            break
                        }
                    }
                    
                    if commitDepth_y < 0 {
                        // Unmerged commit
                        let new = GraphCommitInfo(commit: commit, nextDepth_y: [nexts.count], color: .red)
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
                            infos[currentDepth_y - 1][old_i].nextDepth_y[0] = new_i
                            infos[currentDepth_y][new_i].nextDepth_y[0] = new_i
                            
                            // When create new branches
                            if nexts[new_i].description == commit.oid.description {
                                assert(infos[currentDepth_y - 1].count > old_i)
                                infos[currentDepth_y - 1][old_i].nextDepth_y = [commitDepth_y]
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
                        let new = GraphInfo(nextDepth_y: [i], color: .blue)
                        infos[currentDepth_y + 1].append(new)
                    }
                    
                    // Merge commit
                    if commit.parents.count == 2 {
                        var newBranch = true
                        for (i, next) in nexts.enumerated() {
                            if next == commit.parents.last!.oid {
                                infos[currentDepth_y][commitDepth_y].nextDepth_y.append(i)
                                newBranch = false
                                break
                            }
                        }
                        if newBranch {
                            infos[currentDepth_y][commitDepth_y].nextDepth_y.append(nexts.count)
                            let new = GraphInfo(nextDepth_y: [nexts.count], color: .blue)
                            infos[currentDepth_y + 1].append(new)
                            nexts.append(commit.parents.last!.oid)
                        }
                    }
                    
                case let .failure(error):
                    print("Commit iteration error: \(error)")
                    throw IGitError.iterateCommits
                case .none:
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
}
