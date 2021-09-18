//
//  Symbolicator.swift
//  
//
//  Created by Naruki Chigira on 2021/09/10.
//

import CallStackSymbols
import CryptoKit
import Foundation

public protocol SymbolicatorDelegate {
    /// Notify start to process symbolication.
    func didStartSymbolicate(_ symbolicator: Symbolicator, total: Int)
    /// Notify progress of processing symbolication.
    func didUpdateProgressToSymbolicate(_ symbolicator: Symbolicator, completed: Int, total: Int)
    /// Notify start to complete symbolication.
    func didCompleteSymbolicate(_ symbolicator: Symbolicator, total: Int)
}

public final class Symbolicator {
    public static let atosDefaultPath: String = "/usr/bin/atos"

    /// Store to fetch dSYM file from module name.
    private let dSYMsStore: DSYMsStore

    /// Path of atos.
    public let atos: String
    /// Cache.
    public var cache: Cache = Cache.default
    /// Flag to use cache or not.
    public var useCache: Bool = true

    /// Create new symbolicator.
    ///
    /// - Parameters:
    ///   - dSYMsDirectoryPath: Path of directory containing app dSYM files.
    public init(dSYMsDirectoryPath: String, atos: String = atosDefaultPath) throws {
        dSYMsStore = try DSYMsStore(dSYMsDirectoryPath: dSYMsDirectoryPath)
        self.atos = atos
    }

    /// Symbolicate dladdr.
    ///
    /// - Parameters:
    ///   - dladdr: dladdr to symbolicate.
    ///   - architecture: e.g.: arm64, arm64e
    public func symbolicate(dladdr: DLADDR, architecture: String) -> (Bool, String) {
        if useCache, let cached = cache.cached(for: dladdr) {
            return (true, cached)
        }
        guard let dSYMFilePath = dSYMsStore.dSYMFilePath(with: dladdr.fname) else {
            // Return non-symbolicated string here if corresponding dSYM file is not found.
            return (false, dladdr.callStackSymbolRepresentation)
        }
        let pipe = Pipe()
        let process = Process()
        process.launchPath = atos
        process.arguments = ["-arch", architecture, "-o", dSYMFilePath, "-l", dladdr.laddr16Radix, dladdr.fbase16Radix]
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self).dropLast()
        let symbolicated = String(format: "%-4d", dladdr.depth) + output
        if useCache {
            Cache.default.store(symbolicated: symbolicated, for: dladdr)
        }
        return (true, symbolicated)
    }

    /// Symbolicate record contained call stack of DLADDR.
    ///
    /// - Parameters:
    ///   - record: Record to symbolicate.
    public func symbolicate(record: Record<DLADDR>) -> Record<SymbolicatedDLADDR> {
        func makeSymbolicationId(_ symbolicated: [String]) -> String {
            let data = Data(symbolicated.joined().utf8)
            let hashed = SHA256.hash(data: data)
            return String(hashed.compactMap { String(format: "%02x", $0) }.joined().prefix(8))
        }

        let result: [(Bool, String)] = record.callStack.map { (dladdr: DLADDR) -> (Bool, String) in
            symbolicate(dladdr: dladdr, architecture: record.architecture)
        }
        let callStack: [String] = result.map { $0.1 }
        let symbolicated: [String] = result.filter { $0.0 }.map { $0.1 }

        return .init(
            architecture: record.architecture,
            callStack: callStack,
            symbolicationId: makeSymbolicationId(symbolicated)
        )
    }

    /// Symbolicate records contained call stack of DLADDR.
    ///
    /// - Parameters:
    ///   - records: Array of records to symbolicate.
    ///   - delegate: Delegate to notify symbolicating progress.   
    public func symbolicate(records: [Record<DLADDR>], delegate: SymbolicatorDelegate? = nil) -> [Record<SymbolicatedDLADDR>] {
        let total = records.count
        delegate?.didStartSymbolicate(self, total: total)
        let results: [Record<SymbolicatedDLADDR>] = records.enumerated().map { (offset, record) in
            let result = symbolicate(record: record)
            delegate?.didUpdateProgressToSymbolicate(self, completed: offset + 1, total: total)
            return result
        }
        delegate?.didCompleteSymbolicate(self, total: total)
        return results
    }
}
