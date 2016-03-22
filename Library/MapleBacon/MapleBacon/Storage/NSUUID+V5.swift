//
//  NSUUID+V5.swift
//  vault
//
//  Created by Danilo Topalovic on 14.02.16.
//  Copyright (c)  2016 nerdsee. All rights reserved.
//

import Foundation
import CommonCrypto

// MARK: - V5 UUID
extension NSUUID {
    
    /**
     Convenience init for building a uuid from V5 Standard using a
     UUID namespace and a string "name"
     
     - parameter ns:   the namespace UUID
     - parameter name: the string
     
     - returns: the instance of NSUUID
     */
    convenience init(namespace ns: NSUUID, name: String) {
        
        var uuidBytes: UInt8 = 0
        ns.getUUIDBytes(&uuidBytes)
        
        let nsname                = name as NSString
        let namespaceData: NSData = NSData(bytes: &uuidBytes, length: 16)
        let nameData: NSData      = NSData(bytes: nsname.cStringUsingEncoding(NSUTF8StringEncoding), length: nsname.length)
        
        let concatData: NSMutableData = NSMutableData()
        concatData.appendData(namespaceData)
        concatData.appendData(nameData)
        
        var digest: [UInt8] = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(concatData.bytes, CC_LONG(concatData.length), &digest)
        
        let bytes: [UInt8] = [
            digest[0],
            digest[1],
            digest[2],
            digest[3],
            digest[4],
            digest[5],
            ((digest[6] & 0x0F) | 0x50),
            digest[7],
            ((digest[8] & 0x3F) | 0xB0),
            digest[9],
            digest[10],
            digest[11],
            digest[12],
            digest[13],
            digest[14],
            digest[15]
        ]
        
        self.init(UUIDBytes: bytes)
    }
}
