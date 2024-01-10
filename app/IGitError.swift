//
//  IGitError.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/11.
//

import UIKit

enum IGitError: Error {
    case clone
    case getDocumentFolder
    case getRepositoryHead
    case iterateCommits
    
    func showErrorAlert(viewController vc: UIViewController) {
        let message: String
        switch self {
        case .clone:
            message = "Failed to clone repository"
        case .getDocumentFolder:
            message = "Failed to get app document folder"
        case .getRepositoryHead:
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
        
        vc.present(alert, animated: true, completion: nil)
    }
}
