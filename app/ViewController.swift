//
//  ViewController.swift
//  iGit
//
//  Created by morinoyu8 on 2023/12/27.
//

import UIKit

class ViewController: UIViewController {
    
    // Draw a line connecting commits
    func drawLine(start: CGPoint, end: CGPoint, color: UIColor) {
        let line = Line(frame: self.view.frame, start: start, end: end, color: color, weight: 1.8)
        self.view.addSubview(line)
    }
    
    // Draw a commit point
    func drawCommitPoint(point: CGPoint, color: UIColor) {
        let circle = Circle(frame: self.view.frame, arcCenter: point, radius: 5, color: color)
        self.view.addSubview(circle)
    }
    
    // Draw a frame for commit information
    func drawCommitInfoFrame(point: CGPoint, color: UIColor) {
        let rectangleSize = CGSize(width: 30, height: 30)
        let roundedRectAngle = RoundedRectangle(frame: self.view.frame, rect: CGRect(origin: point, size: rectangleSize), cornarRadius: 3.0, innerColor: .clear, lineColer: color, lineWiidth: 2.0)
        self.view.addSubview(roundedRectAngle)
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
        guard let url = urls.first else { return }
        print(url)
    }
}
