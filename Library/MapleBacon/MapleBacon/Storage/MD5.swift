import Foundation

private let shift : [UInt32] = [7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21]
private let table: [UInt32] = (0 ..< 64).map { UInt32(0x100000000 * abs(sin(Double($0 + 1)))) }

public extension String {
    func MD5() -> String {
        return toHexString(md5(Array(self.utf8)))
    }
}

internal func md5(message: [UInt8]) -> [UInt8] {
    var message = message
    let messageLenBits = UInt64(message.count) * 8
    message.append(0x80)
    while message.count % 64 != 56 {
        message.append(0)
    }
    
    let lengthBytes = [UInt8](count: 8, repeatedValue: 0)
    UnsafeMutablePointer<UInt64>(lengthBytes).memory = messageLenBits.littleEndian
    message += lengthBytes
    
    var a : UInt32 = 0x67452301
    var b : UInt32 = 0xEFCDAB89
    var c : UInt32 = 0x98BADCFE
    var d : UInt32 = 0x10325476
    for chunkOffset in 0.stride(to: message.count, by: 64) {
        let chunk = UnsafePointer<UInt32>(UnsafePointer<UInt8>(message) + chunkOffset)
        let originalA = a
        let originalB = b
        let originalC = c
        let originalD = d
        for j in 0 ..< 64 {
            var f : UInt32 = 0
            var bufferIndex = j
            let round = j >> 4
            switch round {
            case 0:
                f = (b & c) | (~b & d)
            case 1:
                f = (b & d) | (c & ~d)
                bufferIndex = (bufferIndex*5 + 1) & 0x0F
            case 2:
                f = b ^ c ^ d
                bufferIndex = (bufferIndex*3 + 5) & 0x0F
            case 3:
                f = c ^ (b | ~d)
                bufferIndex = (bufferIndex * 7) & 0x0F
            default:
                assert(false)
            }
            let sa = shift[(round<<2)|(j&3)]
            let tmp = a &+ f &+ UInt32(littleEndian: chunk[bufferIndex]) &+ table[j]
            a = d
            d = c
            c = b
            b = b &+ (tmp << sa | tmp >> (32-sa))
        }
        a = a &+ originalA
        b = b &+ originalB
        c = c &+ originalC
        d = d &+ originalD
    }
    
    let result = [UInt8](count: 16, repeatedValue: 0)
    for (i, n) in [a, b, c, d].enumerate() {
        UnsafeMutablePointer<UInt32>(result)[i] = n.littleEndian
    }
    return result
}

private func toHexString(bytes: [UInt8]) -> String {
    return bytes.map { String(format:"%02x", $0) }.joinWithSeparator("")
}
