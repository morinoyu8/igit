//
//  RepositoryManager.swift
//  iGit
//
//  Created by morinoyu8 on 2024/01/11.
//

import SwiftGit2

class RepositoryManager {
    
    let repo: Repository
    
    init(repo: Repository) {
        self.repo = repo
    }
    
    func getOid2Branch() -> [OID: [Branch]] {
        
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
            print("Cannot get Oid2Branch map: \(error)")
        }
        return oid2Branch
    }
    
    static func clone(url: String) throws -> RepositoryManager {
        let fileManager = FileManager.default
        do {
            guard let fromURL = URL(string: url) else {
                print("URL Conversion Error")
                throw IGitError.clone
            }
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let toURL = documentsURL.appendingPathComponent("git-test", isDirectory: true)
            
            if fileManager.fileExists(atPath: toURL.path, isDirectory: nil) {
                try fileManager.removeItem(at: toURL)
            }
            
            let result = Repository.clone(from: fromURL, to: toURL)
            switch result {
            case let .success(repo):
                return RepositoryManager(repo: repo)
            case let .failure(error):
                print("Clone error: \(error)")
                throw IGitError.clone
            }

        } catch {
            print("Get document folder error: \(error)")
            throw IGitError.getDocumentFolder
        }
    }
}
