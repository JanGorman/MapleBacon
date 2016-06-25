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
     */
    convenience init(namespace ns: UUID, name: String) {
        
        var uuidBytes: UInt8 = 0
        (ns as NSUUID).getBytes(&uuidBytes)
        
        let namespaceData: Data = NSData(bytes: &uuidBytes, length: 16) as Data
        let nameData: Data      = NSData(bytes: name.cString(using: String.Encoding.utf8), length: name.characters.count) as Data
        
        var concatData = Data()
        concatData.append(namespaceData)
        concatData.append(nameData)
        
        var digest: [UInt8] = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        
        let dataBytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(allocatingCapacity: concatData.count)
        concatData.copyBytes(to: dataBytes, count: concatData.count)
        
        CC_SHA1(dataBytes, CC_LONG(concatData.count), &digest)
        
        let bytes: [UInt8] = [
            digest[0],
            digest[1],
            digest[2],
            digest[3],
            digest[4],
            digest[5],
            ((digest[6] & 0x0F) | 0x50),
            digest[7],
            ((digest[8] & 0x3F) | 0x80),
            digest[9],
            digest[10],
            digest[11],
            digest[12],
            digest[13],
            digest[14],
            digest[15]
        ]
        
        self.init(uuidBytes: bytes)
    }
}
