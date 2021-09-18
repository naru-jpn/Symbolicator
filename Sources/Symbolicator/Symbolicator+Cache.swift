//
//  Symbolicator+Cache.swift
//  
//
//  Created by Naruki Chigira on 2021/09/10.
//

import CallStackSymbols

extension Symbolicator {
    /// Cache for result of symbolication.
    public class Cache {
        public static let `default` = Cache()

        private var store: [DLADDR: SymbolicatedDLADDR] = [:]

        /// Clear all cache.
        public func clear() {
            store = [:]
        }

        /// Store symbolicated string.
        ///
        /// - Parameters:
        ///   - symbolicated: Output of atos with dladdr.
        ///   - for dladdr: DLADDR as a input of atos.
        func store(symbolicated: SymbolicatedDLADDR, for dladdr: DLADDR) {
            store[dladdr] = symbolicated
        }

        /// Return cached symbolicated string.
        ///
        /// - Parameters:
        ///   - for dladdr: DLADDR as a input of atos.
        func cached(for dladdr: DLADDR) -> SymbolicatedDLADDR? {
            store[dladdr]
        }
    }
}
