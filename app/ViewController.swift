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
            print("Latest Commit: \(commit.message) by \(commit.author.name)")
            let latestCommit = GraphCommitInfo(oid: commit.oid, depth_x: 0, depth_y: 0, color: .red)
            infos.append(latestCommit)
            
            // Commit iterator
            let iter = CommitIterator(repo: repo, root: commit.oid.oid)
            let result: SwiftGit2.CommitIterator.Element?
            
            //
            while (true) {
                let result = iter.next()
                if result == nil {
                    print("result nil")
                    break
                }
                
                switch result {
                case let .success(commit):
                    print("Commit: \(commit.message)")
                    
                case let .failure(error):
                    print("Commit itrator error: \(error)")
                    return []
                case .none:
                    print("result nil")
                    break
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
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIDocumentPickerDelegate {
    
    // Called when a folder selected
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let URL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
            let result = Repository.at(URL)
    
            switch result {
            case let .success(repo):
                let a = iterateCommit(repo: repo)
    
            case let .failure(error):
                print("Could not open repository: \(error)")
            }
            
        } catch {
            print("ERROR: \(error)")
        }
    }
}
