//
//  ViewController.swift
//  iGit
//
//  Created by morinoyu8 on 2023/12/27.
//

import Foundation
import UIKit
import SwiftGit2
import Clibgit2

class ViewController: UIViewController {
    
    // View to display a git graph
    @IBOutlet weak var contentView: UIView!
    
    // Width of contentView
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    
    // Height of contentView
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    // It must be the same value as contentViewHeight
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerTitle: UINavigationItem!
    
    // Horizontal distance of commit points
    let dist_x: Int = 40
    
    // Vertical distance of commit points
    let dist_y: Int = 80
    
    enum RepositoryError {
        case clone
        case getDocument
        case getReposiitoryHead
        case iterateCommits
    }
    
    
     // Draw a line connecting commits
     func drawLine(start: CGPoint, end: CGPoint, color: UIColor) {
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
         contentView.addSubview(line)
         contentView.sendSubviewToBack(line)
     }
    
     // Draw a commit point
     func drawCommitPoint(point: CGPoint, color: UIColor) {
         let radius = 5
         let circle = Circle(frame: CGRect(origin: point - CGPoint(x: radius, y: radius), size: CGSize(width: radius * 2, height: radius * 2)), arcCenter: CGPoint(x: radius, y: radius), radius: CGFloat(radius), color: color)
         contentView.addSubview(circle)
     }
    
     // Draw a frame for commit information
     func drawCommitInfoFrame(point: CGPoint, color: UIColor) {
         let rectangleSize = CGSize(width: 30, height: 30)
         let roundedRectAngle = RoundedRectangle(frame: self.view.frame, rect: CGRect(origin: point, size: rectangleSize), cornarRadius: 3.0, innerColor: .clear, lineColer: color, lineWiidth: 2.0)
         contentView.addSubview(roundedRectAngle)
     }
    
    func drawCommitText(commit: Commit, depth_x: Int, depth_y: Int) {
        let width = 500
        let height = 30
        let message = UILabel(frame: CGRect(origin: CGPoint(x: depth_x * 50 + 50, y: depth_y * 50 + 35), size: CGSize(width: width, height: height)))
        message.text = commit.message
        let fontSize: CGFloat = 14
        message.font = UIFont(name: "Menlo-Regular", size: fontSize)
        message.backgroundColor = .white
        contentView.addSubview(message)
        contentView.bringSubviewToFront(message)
    }
    
    func depth2Position(depth_x: Int, depth_y: Int) -> CGPoint {
        return CGPoint(x: depth_x * 50 + 20, y: depth_y * 50 + 50)
    }
    
    func drawOneTimeGraph(infos: [GraphInfo], index: Int) {
        for (i, info) in infos.enumerated() {
            if let commitInfo = info as? GraphCommitInfo {
                drawCommitPoint(point: depth2Position(depth_x: i, depth_y: index), color: info.color)
                drawCommitText(commit: commitInfo.commit, depth_x: infos.count - 1, depth_y: index)
            }
            for x in info.nextDepth_y {
                drawLine(start: depth2Position(depth_x: i, depth_y: index), end: depth2Position(depth_x: x, depth_y: index + 1), color: .red)
            }
        }
    }
    
    func drawGraph(graphInfos infos: [[GraphInfo]]) {
        var maxOneTimeInfoCount = 0
        for (i, info) in infos.enumerated() {
            if maxOneTimeInfoCount < info.count {
                maxOneTimeInfoCount = info.count
            }
            drawOneTimeGraph(infos: info, index: i)
        }
        setContentViewSize(size: CGSize(width: maxOneTimeInfoCount * 50 + 540, height: infos.count * 40 + 200))
    }
    
    func setContentViewSize(size: CGSize) {
        contentViewWidth.constant = size.width
        contentViewHeight.constant = size.height
        scrollViewHeight.constant = size.height
    }
    
    func getOid2Branch(repo: Repository) -> [OID: [Branch]] {
        
        var oid2Branch: [OID: [Branch]] = [:]
        let result = repo.references(withPrefix: "")
        switch result {
        case let .success(refs):
            for ref in refs {
                if let branch = ref as? Branch {
                    if oid2Branch.keys.contains(branch.oid) {
                        oid2Branch[branch.oid]?.append(branch)
                    } else {
                        oid2Branch[branch.oid] = [branch]
                    }
                }
            }
        case let .failure(error):
            print(error)
        }
        return oid2Branch
    }

    
    func constructGraphInfo(repo: Repository) -> [[GraphInfo]] {
        
        // Get a map [OID: Branch]
        let branches = getOid2Branch(repo: repo)
        
        let head = repo.HEAD().flatMap { repo.commit($0.oid) }
        var infos: [[GraphInfo]] = []
        switch head {
        case let .success(commit):
            
            // Commit iterator
            let iter = CommitIterator(repo: repo, root: commit.oid.oid)
            
            // HEAD initialization
            let head = GraphCommitInfo(commit: commit, nextDepth_y: [0], color: .red)
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
            } else {
                return infos
            }
            
            
            let _ = iter.next()
            
            var currentDepth_y = 1
            
            while (true) {
                let result = iter.next()
                if result == nil {
                    break
                }
                assert(infos.count > currentDepth_y)
                
                switch result {
                case let .success(commit):
                    // print("Commit: \(commit.message)")
                    
                    // Add commit infomation
                    var commitDepth_y = -1
                    for (i, next) in nexts.enumerated() {
                        if next.description == commit.oid.description {
                            assert(infos[currentDepth_y].count > i)
                            
                            infos[currentDepth_y][i] = GraphCommitInfo(commit: commit, nextDepth_y: [i], color: .red)
                            commitDepth_y = i
                            break
                        }
                    }
                    
                    if commitDepth_y < 0 {
                        // Unmerged commit
                        let new = GraphCommitInfo(commit: commit, nextDepth_y: [nexts.count], color: .red)
                        infos[currentDepth_y].append(new)
                        nexts.append(commit.oid)
                        commitDepth_y = infos[currentDepth_y].count - 1
                    } else {
                        var new_i = commitDepth_y + 1
                        var old_i = commitDepth_y + 1
                        let count = nexts.count
                        
                        while old_i < count {
                            
                            infos[currentDepth_y][new_i].nextDepth_y[0] -= old_i - new_i
                            
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
                        let c = infos[currentDepth_y][commitDepth_y] as! GraphCommitInfo
                        print(c.commit.message)
                        if branches.keys.contains(commit.parents.last!.oid) {
                            // New branch
                            infos[currentDepth_y][commitDepth_y].nextDepth_y.append(nexts.count)
                            let new = GraphInfo(nextDepth_y: [nexts.count], color: .blue)
                            infos[currentDepth_y + 1].append(new)
                            nexts.append(commit.parents.last!.oid)
                        } else {
                            for (i, next) in nexts.enumerated() {
                                if next == commit.parents.last!.oid {
                                    infos[currentDepth_y][commitDepth_y].nextDepth_y.append(i)
                                    break
                                }
                            }
                        }
                    }
                    
                case let .failure(error):
                    showErrorAlert(repoError: .iterateCommits)
                    print("Commit itrator error: \(error)")
                    return []
                case .none:
                    print("result nil")
                    return infos
                }
                
                currentDepth_y += 1
            }

        case let .failure(error):
            showErrorAlert(repoError: .getReposiitoryHead)
            print("Could not get head: \(error)")
            return []
        }
        
        return infos
    }
    
    func cloneAndGetRepository(inputText: String) {
        let fileManager = FileManager.default
        do {
            guard let fromURL = URL(string: inputText) else { return }
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let toURL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
            
            if fileManager.fileExists(atPath: toURL.path, isDirectory: nil) {
                try fileManager.removeItem(at: toURL)
            }
            
            let result = Repository.clone(from: fromURL, to: toURL)
            switch result {
            case let .success(repo):
                for subview in self.contentView.subviews {
                    subview.removeFromSuperview()
                }
                headerTitle.title = inputText.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
                let infos = constructGraphInfo(repo: repo)
                drawGraph(graphInfos: infos)
            case let .failure(error):
                showErrorAlert(repoError: .clone)
                print("error: \(error)")
            }

        } catch {
            showErrorAlert(repoError: .getDocument)
            print("error: \(error)")
        }
    }
    
    func showErrorAlert(repoError err: RepositoryError) {
        var message: String = "Error"
        switch err {
        case .clone:
            message = "Failed to clone repository"
        case .getDocument:
            message = "Failed to get app document folder"
        case .getReposiitoryHead:
            message = "Failed to get repository HEAD"
        case .iterateCommits:
            message = "Failed to iterate commits"
        }
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: UIAlertController.Style.alert)
    
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Called when "Repo" button is pushed
    @IBAction func showAlertForNewRepository(_ sender: Any) {
        var alertTextField: UITextField?

        let alert = UIAlertController(
            title: "Show Commit Log",
            message: "Enter remote git URL",
            preferredStyle: UIAlertController.Style.alert)
    
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
        })
    
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
    
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                    if let text = alertTextField?.text {
                        self.cloneAndGetRepository(inputText: text)
                    }
                }
        )

        self.present(alert, animated: true, completion: nil)
    }
}
