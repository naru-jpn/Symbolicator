//
//  CSV.swift
//  Example
//
//  Created by Naruki Chigira on 2021/09/18.
//

import CallStackSymbols
import Foundation
import Symbolicator

struct CSV {
    let records: [Record<DLADDR>]
}

extension CSV {
    init(path: String) {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue == false else {
            fatalError()
        }
        guard let csvData = FileManager.default.contents(atPath: path), csvData.isEmpty == false else {
            fatalError()
        }
        guard let contents = String(data: csvData, encoding: .utf8) else {
            fatalError()
        }
        let parser = CSVParser()
        self = try! parser.parse(input: contents)
    }
}
