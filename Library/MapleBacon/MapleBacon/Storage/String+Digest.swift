//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation
import CommonCrypto


/**
 * Extends the String struct by digest algos
 */
public extension String {
    
    /**
     Returns the current string MD5 digested
     
     - returns: md5 of the string
     */
    @available(*, deprecated=0.1, message="slow and collisons are possible") func md5() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH))
        for byte in digest {
            
            output.appendFormat("%02x", byte)
        }
        return (output as String).lowercaseString
    }
    
    /**
     Returns the current string sha1 digested
     
     - returns: sha1 of the string
     */
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
    
    /**
     Returns the UUID representation of the current string
     
     - parameter ns: the uuid namespace (@see UUIDv5)
     
     - returns: the UUID of this string
     */
    func uuidWithNamespace(ns: NSUUID) -> NSUUID {
        return NSUUID(namespace: ns, name: self)
    }
}
