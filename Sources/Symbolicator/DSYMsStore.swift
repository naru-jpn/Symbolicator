//
//  DSYMsStore.swift
//  
//
//  Created by Naruki Chigira on 2021/09/10.
//

import Foundation

/// Store dSYM file paths and provide dSYM file path from module name.
final class DSYMsStore {
    /// [{module_name}: {file_path}]
    let store: [String: String]

    init(dSYMsDirectoryPath: String) throws {
        let contents = try FileManager.default.contentsOfDirectory(atPath: dSYMsDirectoryPath)
        let paths = contents.filter({ $0.hasSuffix(".dSYM") }).map({ dSYMsDirectoryPath + "/" + $0 })
        var store: [String: String] = [:]
        for path in paths {
            let path = path + "/Contents/Resources/DWARF/"
            if let content = try FileManager.default.contentsOfDirectory(atPath: path).first {
                store[content] = path + content
            }
        }
        self.store = store
    }

    /// Provide dSYM file path from module name.
    func dSYMFilePath(with name: String) -> String? {
        store[name]
    }
}
