//
//  GenericSingleTagWriter.swift
//  mamba
//
//  Created by David Coufal on 7/12/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// Generic writer for playlist tags that have just one single value (e.g. `#EXT-X-TARGETDURATION:10`)
public struct GenericSingleTagWriter: PlaylistTagWriter {
    
    fileprivate let singleTagValueIdentifier: PlaylistTagValueIdentifier
    
    public init(singleTagValueIdentifier: PlaylistTagValueIdentifier) {
        self.singleTagValueIdentifier = singleTagValueIdentifier
    }
    
    public func write(tag: PlaylistTag, toStream stream: OutputStream) throws {
        
        guard tag.keys.count == 1 else {
            throw OutputStreamError.invalidData(description:"\(tag.tagDescriptor.toString()) PlaylistTag requires a \(singleTagValueIdentifier.toString()) value. Found \(tag.keys.count) values instead. Keys found: \(tag.keys)")
        }
        
        guard let value: String = tag.value(forValueIdentifier: singleTagValueIdentifier) else {
            throw OutputStreamError.invalidData(description:"\(tag.tagDescriptor.toString()) PlaylistTag requires a \(singleTagValueIdentifier.toString()) value. The key found instead was \"\(tag.keys[0])\"")
        }
        
        try stream.write(stringRef: tag.tagName!)
        try stream.write(unicodeScalar: PlaylistTagWritingSeparators.colon)
        try stream.write(string: value)
    }
}
