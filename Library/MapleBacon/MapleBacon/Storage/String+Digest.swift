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
    @available(*, deprecated:0.1, message:"slow and collisons are possible") func md5() -> String {
        
        let digest = self.digest {
            (bytes, length) -> ([UInt8]) in
            
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(length), &digest)
            return digest
        }
        return self.convert(digest: digest)
    }
    
    /**
     Returns the current string sha1 digested
     
     - returns: sha1 of the string
     */
    func sha1() -> String {
        
        let digest = self.digest {
            (bytes, length) -> ([UInt8]) in
            
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(bytes, CC_LONG(length), &digest)
            return digest
        }
        return self.convert(digest: digest)
    }
    
    /**
     Converts the calculated digest to string
     
     - parameter digest the result of digest algo
 
     - result the string
    */
    private func convert(digest: [UInt8]) -> String {
        
        var output = String()
        for byte in digest {
            
            output.append(String(format: "%02x", byte))
        }
        return output.lowercased()
    }
    
    /**
     Prequisites the digest and applies the fkt
 
     - parameter digestion the closure that contains the actual digest algo

     - return the result
    */
    private func digest(_ digestion: (UnsafeMutablePointer<UInt8>?, Int) -> ([UInt8])) -> [UInt8] {
        
        let data = self.data(using: String.Encoding.utf8)!
        let dataBytes: UnsafeMutablePointer<UInt8>? = nil
        data.copyBytes(to: dataBytes!, count: data.count)
        
        return digestion(dataBytes, data.count)
    }
    
    /**
     Returns the UUID representation of the current string
     
     - parameter ns: the uuid namespace (@see UUIDv5)
     
     - returns: the UUID of this string
     */
    func uuidWithNamespace(ns: UUID) -> UUID {
        return NSUUID(namespace: ns, name: self) as UUID
    }
}
