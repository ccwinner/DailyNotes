//
//  MemCacheManager.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/4/19.
//

import Foundation

class MemCacheManager {
    var audioMarked: Bool = false
    var videoMarked: Bool = false
    private var cache: [String: Data] = [:]
    
    static let shared = MemCacheManager()
    
    subscript(_ key: String) -> Data? {
        cache[key]
    }

    func setData(_ key: String, data: Data) {
        cache[key] = data
    }
    
    func reset() {
        cache = [:]
    }
}
