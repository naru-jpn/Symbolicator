//
//  Record.swift
//  
//
//  Created by Naruki Chigira on 2021/09/11.
//

import Foundation

public typealias SymbolicatedDLADDR = String

/// Call stack and architecture name of device causing call stack.
public struct Record<CallStackRow>: Identifiable {
    public var id = UUID()
    /// Architecture name of device causing call stack (e.g.: arm64, arm64e).
    public let architecture: String
    /// Representing raw call stack(DLADDR) or symbolicated call stack(String).
    public let callStack: [CallStackRow]
    /// Identifier to identify call stack. Empty if not symbolicated.
    public let symbolicationId: String

    public init(architecture: String, callStack: [CallStackRow], symbolicationId: String = "") {
        self.architecture = architecture
        self.callStack = callStack
        self.symbolicationId = symbolicationId
    }
}

extension Array where Element == Record<SymbolicatedDLADDR> {
    /// Count call stack having same identifier.
    public func aggregate() -> [(count: Int, callStack: String)] {
        let records: [Record<SymbolicatedDLADDR>] = self
        let symbolicationIds = Set(records.map(\.symbolicationId))
        var results: [(count: Int, callStack: String)] = []
        for symbolicationId in symbolicationIds {
            guard let record = records.first(where: { $0.symbolicationId == symbolicationId }) else {
                continue
            }
            let count = records.filter { $0.symbolicationId == symbolicationId }.count
            results.append((count: count, callStack: record.callStack.joined(separator: "\r")))
        }
        return results.sorted(by: { $0.count > $1.count })
    }
}
