//
//  DLADDR+Cache.swift
//  
//
//  Created by Naruki Chigira on 2021/09/10.
//

import CallStackSymbols

extension DLADDR: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(depth)
        hasher.combine(fname)
        hasher.combine(sname)
        hasher.combine(saddr)
    }
}

public func ==(lhs: DLADDR, rhs: DLADDR) -> Bool {
    lhs.depth == rhs.depth && lhs.fname == rhs.fname && lhs.sname == rhs.sname && lhs.saddr == rhs.saddr
}
