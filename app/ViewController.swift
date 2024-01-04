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
    
    // Horizontal distance of commit points
    let dist_x: Int = 40
    
    // Vertical distance of commit points
    let dist_y: Int = 80
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        do {

            let fromURL = URL(string: "https://github.com/morinoyu8/glab.git")!
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let toURL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
            
            if fileManager.fileExists(atPath: toURL.path, isDirectory: nil) {
                try fileManager.removeItem(at: toURL)
            }
            
            let result = Repository.clone(from: fromURL, to: toURL)

        } catch {
            print("ERROR: \(error)")
        }
    }
    
    // Draw a line connecting commits
    func drawLine(start: CGPoint, end: CGPoint, color: UIColor) {
        let line = Line(frame: self.view.frame, start: start, end: end, color: color, weight: 1.8)
        contentView.addSubview(line)
    }
    
    // Draw a commit point
    func drawCommitPoint(point: CGPoint, color: UIColor) {
        let circle = Circle(frame: self.view.frame, arcCenter: point, radius: 5, color: color)
        contentView.addSubview(circle)
    }
    
    // Draw a frame for commit information
    func drawCommitInfoFrame(point: CGPoint, color: UIColor) {
        let rectangleSize = CGSize(width: 30, height: 30)
        let roundedRectAngle = RoundedRectangle(frame: self.view.frame, rect: CGRect(origin: point, size: rectangleSize), cornarRadius: 3.0, innerColor: .clear, lineColer: color, lineWiidth: 2.0)
        contentView.addSubview(roundedRectAngle)
    }
    
    // Draw a commit
    func drawCommit(graphCommitInfo info: GraphCommitInfo) {
        
        let commitPointPosition = CGPoint(x: info.depth_x + dist_x, y: info.depth_y * dist_y)
        let commitInfoPosition = commitPointPosition + CGPoint(x: 0, y: 200)
        
        drawCommitPoint(point: commitPointPosition, color: info.color)
    }
    
    func drawCommitInfoText(graphCommitInfo info: GraphCommitInfo) {
        let basePoint_x = info.depth_x * 50 + 20
        let basePoint_y = info.depth_y * 200 + 20
        let width = 500
        let height = 20
        
        let id = UILabel(frame: CGRect(x: basePoint_x, y: basePoint_y, width: width, height: height))
        let author = UILabel(frame: CGRect(x: basePoint_x, y: basePoint_y + 30, width: width, height: height))
        let date = UILabel(frame: CGRect(x: basePoint_x, y: basePoint_y + 60, width: width, height: height))
        let message = UILabel(frame: CGRect(x: basePoint_x + 50, y: basePoint_y + 100, width: width - 50, height: height))
        
        id.text = "commit \(info.commit.oid.description)"
        author.text = "Author: \(info.commit.author.name) <\(info.commit.author.email)>"
        date.text = "Date: \(info.commit.author.time.description)"
        message.text = info.commit.message
        
        let fontSize: CGFloat = 16
        id.font = UIFont(name: "Menlo-Regular", size: fontSize)
        author.font = UIFont(name: "Menlo-Regular", size: fontSize)
        date.font = UIFont(name: "Menlo-Regular", size: fontSize)
        message.font = UIFont(name: "Menlo-Regular", size: fontSize)
        
        contentView.addSubview(id)
        contentView.addSubview(author)
        contentView.addSubview(date)
        contentView.addSubview(message)
    }
    
    func drawGraph(graphInfos infos: [GraphInfo]) {
        var max_depth_x = 0
        var max_depth_y = 0
        for info in infos {
            if max_depth_x < info.depth_x {
                max_depth_x = info.depth_x
            }
            if max_depth_y < info.depth_y {
                max_depth_y = info.depth_y
            }
            guard let commitInfo = info as? GraphCommitInfo else { continue }
            drawCommitInfoText(graphCommitInfo: commitInfo)
        }
        setContentViewSize(size: CGSize(width: max_depth_x * 50 + 540, height: max_depth_y * 200 + 200))
    }
    
    func setContentViewSize(size: CGSize) {
        contentViewWidth.constant = size.width
        contentViewHeight.constant = size.height
        scrollViewHeight.constant = size.height
    }
    
    
    func iterateCommit(repo: Repository) -> [GraphInfo] {
        
        let head = repo.HEAD().flatMap { repo.commit($0.oid) }
        var infos: [GraphInfo] = []
        switch head {
        case let .success(commit):
            
            // Commit iterator
            let iter = CommitIterator(repo: repo, root: commit.oid.oid)
            
            var currentDepth_y = 0
            
            
            // Operate for HEAD
            print("Latest Commit: \(commit.message) by \(commit.author.name)")
            let latestCommitInfo = GraphCommitInfo(commit: commit, depth_x: 0, depth_y: 0, color: .red)
            infos.append(latestCommitInfo)
            
            
            //
            while (true) {
                currentDepth_y += 1
                let result = iter.next()
                if result == nil {
                    break
                }
                
                switch result {
                case let .success(commit):
                    print("Commit: \(commit.message)")
                    let commitInfo = GraphCommitInfo(commit: commit, depth_x: 0, depth_y: currentDepth_y, color: .red)
                    infos.append(commitInfo)
                    
                case let .failure(error):
                    print("Commit itrator error: \(error)")
                    return []
                case .none:
                    print("result nil")
                    return infos
                }
            }

        case let .failure(error):
            print("Could not get head: \(error)")
            return []
        }
        
        return infos
    }
    
    
    // Called when "Select folder" button is pushed
    @IBAction func showDocumentPicker(_ sender: Any) {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let URL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
            let result = Repository.at(URL)
    
            switch result {
            case let .success(repo):
                let graphInfos = iterateCommit(repo: repo)
                drawGraph(graphInfos: graphInfos)
    
            case let .failure(error):
                print("Could not open repository: \(error)")
            }
            
        } catch {
            print("ERROR: \(error)")
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    // Called when a folder selected
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        
//        let fileManager = FileManager.default
//        do {
//            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let URL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
//            let result = Repository.at(URL)
//    
//            switch result {
//            case let .success(repo):
//                let graphInfos = iterateCommit(repo: repo)
//                drawGraph(graphInfos: graphInfos)
//    
//            case let .failure(error):
//                print("Could not open repository: \(error)")
//            }
//            
//        } catch {
//            print("ERROR: \(error)")
//        }
//    }
}
