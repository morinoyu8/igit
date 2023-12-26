//
//  ViewController.swift
//  iGit
//
//  Created by morinoyu8 on 2023/12/27.
//

import UIKit

class ViewController: UIViewController {
    
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
