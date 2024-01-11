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
    
    func drawGraph(repo: RepositoryManager) {
        let graphView = GraphView(view: contentView, viewWidth: contentViewWidth, viewHeight: contentViewHeight, scrollViewHeight: scrollViewHeight)
        let graph = Graph(repo: repo, parentView: graphView)
        
        do {
            try graph.draw()
        } catch {
            if let iGitError = error as? IGitError {
                iGitError.showErrorAlert(viewController: self)
                return
            }
            print(error)
        }
    }
    
    func cloneRepositoryAndDrawGraph(url: String) {
        do {
            let repo = try RepositoryManager.clone(url: url)
            headerTitle.title = url.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
            drawGraph(repo: repo)
        } catch {
            if let iGitError = error as? IGitError {
                iGitError.showErrorAlert(viewController: self)
                return
            }
            print(error)
        }
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
                        self.cloneRepositoryAndDrawGraph(url: text)
                    }
                }
        )

        self.present(alert, animated: true, completion: nil)
    }
}
