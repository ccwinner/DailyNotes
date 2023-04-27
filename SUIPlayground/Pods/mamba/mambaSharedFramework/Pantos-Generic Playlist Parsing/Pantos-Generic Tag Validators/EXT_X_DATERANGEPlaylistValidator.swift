//
//  EXT_X_DATERANGEPlaylistValidator.swift
//  mamba
//
//  Created by Robert Galluccio on 28/03/2020.
//  Copyright © 2020 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import Foundation

/// This class provides the validation for EXT-X-DATERANGE tags for rules which require the whole playlist information.
///
/// All validation issues for EXT-X-DATERANGE are treated as `.warning` due to this comment in the HLS specification:
///
///     Clients SHOULD ignore EXT-X-DATERANGE tags with illegal syntax.
///
class EXT_X_DATERANGEPlaylistValidator: VariantPlaylistValidator {
    
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue] {
        
        var programDateTimeTagsCount = 0
        var daterangeTags = [PlaylistTag]()
        for tag in variantPlaylist.tags {
            if tag.tagDescriptor == PantosTag.EXT_X_PROGRAM_DATE_TIME {
                programDateTimeTagsCount += 1
            } else if tag.tagDescriptor == PantosTag.EXT_X_DATERANGE {
                daterangeTags.append(tag)
            }
        }
        
        var validationIssues = [PlaylistValidationIssue]()
        validationIssues.append(contentsOf: validateProgramDateTime(programDateTimeTagsCount: programDateTimeTagsCount, daterangeTagsCount: daterangeTags.count))
        validationIssues.append(contentsOf: validateMultipleTags(daterangeTags: daterangeTags))
        
        return validationIssues
    }
    
    // If a Playlist contains an EXT-X-DATERANGE tag, it MUST also contain
    // at least one EXT-X-PROGRAM-DATE-TIME tag.
    private static func validateProgramDateTime(programDateTimeTagsCount: Int, daterangeTagsCount: Int) -> [PlaylistValidationIssue] {
        
        guard daterangeTagsCount > 0, programDateTimeTagsCount == 0 else {
            return []
        }
        return [PlaylistValidationIssue(description: .EXT_X_DATERANGEExistsWithNoEXT_X_PROGRAM_DATE_TIME, severity: .warning)]
    }
    
    // If a Playlist contains two EXT-X-DATERANGE tags with the same ID
    // attribute value, then any AttributeName that appears in both tags
    // MUST have the same AttributeValue.
    private static func validateMultipleTags(daterangeTags: [PlaylistTag]) -> [PlaylistValidationIssue] {
        
        // first fill out a map of ID to tags to group tags with matching ID
        var idTagMap = [String: [PlaylistTag]]()
        for tag in daterangeTags {
            guard let id = tag.value(forValueIdentifier: PantosValue.id) else {
                // This should not happen, but if it does, this is a validation issue that will be caught by the tag validator
                continue
            }
            if let matchingTags = idTagMap[id] {
                idTagMap[id] = matchingTags + [tag]
            } else {
                idTagMap[id] = [tag]
            }
        }
        // next we pick out ID values with multiple tags and validate the attributes match between them
        var validationIssues = [PlaylistValidationIssue]()
        for (_, tags) in idTagMap {
            guard tags.count > 1 else {
                continue
            }
            // make a map of attributes to values to ensure any matching attributes also match value
            var attributeToValueMap = [String: String]()
            for tag in tags {
                for attribute in tag.keys {
                    guard let attributeValue = tag.value(forKey: attribute) else {
                        assertionFailure("tag.keys gave us a key that had no value in the tag - key: \(attribute), tag: \(tag), tag.keys: \(tag.keys)")
                        continue
                    }
                    if let matchingAttributeValue = attributeToValueMap[attribute] {
                        if attributeValue != matchingAttributeValue {
                            validationIssues.append(PlaylistValidationIssue(description: .EXT_X_DATERANGEAttributeMismatchForTagsWithSameID, severity: .warning))
                        }
                    } else {
                        attributeToValueMap[attribute] = attributeValue
                    }
                }
            }
        }
        
        return validationIssues
    }
}
