/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

public class InfoCollections {
    private let collections: [String: Timestamp]

    init(collections: [String: Timestamp]) {
        self.collections = collections
    }

    public class func fromJSON(json: JSON) -> InfoCollections? {
        if let dict = json.asDictionary {
            var coll = [String: Timestamp]()
            for (key, value) in dict {
                if let value = value.asDouble {
                    coll[key] = Timestamp(value * 1000)
                } else {
                    return nil       // Invalid, so bail out.
                }
            }
            return InfoCollections(collections: coll)
        }
        return nil
    }

    public func collectionNames() -> [String] {
        return Array(self.collections.keys)
    }

    public func modified(collection: String) -> Timestamp? {
        return self.collections[collection]
    }

    // Two I/Cs are the same if they have the same modified times for a set of
    // collections. If no collections are specified, they're considered the same
    // if the other I/C has the same values for this I/C's collections, and
    // they have the same collection array.
    public func same(other: InfoCollections, collections: [String]?) -> Bool {
        if let collections = collections {
            return collections.every({ self.modified($0) == other.modified($0) })
        }

        // Same collections?
        let ours = self.collectionNames()
        let theirs = other.collectionNames()
        return ours.sameElements(theirs, f: ==) && same(other, collections: ours)
    }
}

// Data structure containing information from the /info/configuration endpoint
// for various limits and sizes the server supports with regards to uploading.
public struct InfoConfiguration {
    // Maximum size in bytes of the overall HTTP request body that will be accepted by the server.
    public let maxRequestBytes: Int

    // Maximum number of records that can be uploaded to a collection in a single POST request.
    public let maxPostRecords: Int

    // Maximum combined size in bytes of the record payloads that can be uploaded to a
    // collection in a single POST request.
    public let maxPostBytes: Int

    // Maximum number of records that can be uploaded to a collection as part of a batched upload.
    public let maxTotalRecords: Int

    // Maximum combined size in bytes of the record payloads that can be uploaded 
    // to a collection as part of a batched upload.
    public let maxTotalBytes: Int

    static func fromJSON(json: JSON) -> InfoConfiguration? {
        // Convert for easier handling.
        guard let dict = json.asDictionary else {
            return nil
        }

        // Extract required fields
        guard let maxPostRecords = dict["max_post_records"]?.asInt,
              let maxRequestBytes = dict["max_request_bytes"]?.asInt,
              let maxPostBytes = dict["max_post_bytes"]?.asInt,
              let maxTotalRecords = dict["max_total_records"]?.asInt,
              let maxTotalBytes = dict["max_total_bytes"]?.asInt
        else {
            return nil
        }

        return InfoConfiguration(
            maxRequestBytes: maxRequestBytes,
            maxPostRecords: maxPostRecords,
            maxPostBytes: maxPostBytes,
            maxTotalRecords: maxTotalRecords,
            maxTotalBytes: maxTotalBytes
        )
    }
}

//public static let maxRecordSizeBytes: Int = 262_140       // A shade under 256KB.
//public static let maxPayloadSizeBytes: Int = 1_000_000    // A shade under 1MB.
//public static let maxPayloadItemCount: Int = 100          // Bug 1250747 will raise this.

//public static let DefaultInfoConfiguration = InfoConfiguration(maxRequestBytes: <#T##Int#>, maxPostRecords: <#T##Int#>, maxPostBytes: <#T##Int#>, maxTotalRecords: <#T##Int#>, maxTotalBytes: <#T##Int#>)
