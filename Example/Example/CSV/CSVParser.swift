//
//  CSVParser.swift
//  Example
//
//  Created by Naruki Chigira on 2021/09/18.
//

import Foundation
import CallStackSymbols
import Symbolicator

enum CSVParserError: Error {
    case failedToParseCSV
}

/// Parse CSV to create record.
class CSVParser {
    /// Parse CSV contents and create record representing call stack.
    func parse(input: String) throws -> CSV {
        func parse(input: String, parser: DLADDRParser) throws -> Record<DLADDR> {
            let components: [String] = input.components(separatedBy: ",")
            guard components.count == 2 else {
                throw CSVParserError.failedToParseCSV
            }
            let architecture: String = components[0]
            let callStackLines = components[1].replacingOccurrences(of: "\"", with: "").components(separatedBy: .newlines).filter({ $0.isEmpty == false })
            let callStack: [DLADDR] = try callStackLines.map { line in
                try parser.parse(input: line)
            }
            return Record(architecture: architecture, callStack: callStack)
        }

        let lines = input.components(separatedBy: .newlines).filter({ $0.isEmpty == false })
        var isContinuous = false
        var row: String = ""
        var rows: [String] = []
        for line in lines {
            row += isContinuous ? ("\n" + line) : line
            if isContinuous {
                if (line.components(separatedBy: "\"").count - 1) % 2 != 0 {
                    isContinuous = false
                    rows.append(row)
                    row = ""
                }
            } else {
                if (line.components(separatedBy: "\"").count - 1) % 2 != 0 {
                    isContinuous = true
                } else {
                    rows.append(row)
                    row = ""
                }
            }
        }
        rows = Array(rows.dropFirst())
        let dladdrParser = DLADDRParser()
        let records: [Record] = try rows.map({ try parse(input: $0, parser: dladdrParser) })
        return CSV(records: records)
    }
}
