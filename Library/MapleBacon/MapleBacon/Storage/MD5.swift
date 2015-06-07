//
//  MD5.swift
//  MapleBacon
//

import Foundation

class MD5 {

    private static let S: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                      5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                      4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                      6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]

    private static let K: [UInt32] = (0 ..< 64).map {
        UInt32(0x100000000 * abs(sin(Double($0 + 1))))
    }

    private enum HashChunks: UInt32 {
        case A = 0x67452301
        case B = 0xefcdab89
        case C = 0x98badcfe
        case D = 0x10325476
    }

    let message: NSData

    init(_ message: NSData) {
        self.message = message
    }

    func calculate() -> NSData {
        let lengthInBits = message.length * 8
        var lengthBytes = lengthInBits.bytes(64 / 8)
        var tmpMessage = prepare()
        tmpMessage.appendBytes(reverse(lengthBytes), length: lengthBytes.count)

        let chunkSizeBytes = 512 / 8
        var leftMessageBytes = tmpMessage.length
        var hh = [UInt32](count: 4, repeatedValue: 0)
        for var i = 0; i < tmpMessage.length; i += chunkSizeBytes, leftMessageBytes -= chunkSizeBytes {
            let chunk = tmpMessage.subdataWithRange(NSRange(location: i, length: min(chunkSizeBytes, leftMessageBytes)))
            let bytes = tmpMessage.bytes

            var M: [UInt32] = [UInt32](count: 16, repeatedValue: 0)
            let range = NSRange(location: 0, length: M.count * sizeof(UInt32))
            chunk.getBytes(UnsafeMutablePointer<Void>(M), range: range)

            var A = HashChunks.A.rawValue
            var B = HashChunks.B.rawValue
            var C = HashChunks.C.rawValue
            var D = HashChunks.D.rawValue

            for j in 0 ..< MD5.K.count {
                var g = 0
                var F: UInt32 = 0

                switch j {
                case 0 ... 15:
                    F = (B & C) | ((~B) & D)
                    g = j
                case 16 ... 31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                case 32 ... 47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                case 48 ... 63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                default:
                    break
                }

                let dTemp = D
                (D, C, B, A) = (C, B, B &+ rotateLeft((A &+ F &+ MD5.K[j] &+ M[g]), MD5.S[j]), dTemp)
            }
            hh[0] = HashChunks.A.rawValue &+ A
            hh[1] = HashChunks.B.rawValue &+ B
            hh[2] = HashChunks.C.rawValue &+ C
            hh[3] = HashChunks.D.rawValue &+ D
        }

        let buf = NSMutableData()
        hh.map {
            item -> Void in
            var i = item.littleEndian
            buf.appendBytes(&i, length: sizeofValue(i))
        }
        return buf.copy() as! NSData
    }

    private func prepare() -> NSMutableData {
        var paddedMessage = NSMutableData(data: message)
        paddedMessage.appendBytes([0x80], length: 1)
        var messageLength = paddedMessage.length
        var counter = 0
        while messageLength % 64 != 64 - 8 {
            ++counter
            ++messageLength
        }
        var buffer = UnsafeMutablePointer<UInt8>(calloc(counter, sizeof(UInt8)))
        paddedMessage.appendBytes(buffer, length: counter)
        buffer.destroy()
        buffer.dealloc(1)
        return paddedMessage
    }

    private func rotateLeft(x: UInt32, _ n: UInt32) -> UInt32 {
        return ((x << n) & 0xFFFFFFFF) | (x >> (32 - n))
    }

}

public extension String {

    public func MD5() -> String? {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.md5()?.hexString()
    }

}

extension NSData {

    func md5() -> NSData? {
        return MD5(self).calculate()
    }

    func hexString() -> String {
        let count = length / sizeof(UInt8)
        var bytesArray = [UInt8](count: count, repeatedValue: 0)
        getBytes(&bytesArray, length: count * sizeof(UInt8))
        return bytesArray.reduce("") { $0 + String(format: "%02X", $1) }
    }

}

extension Int {

    func bytes(_ totalBytes: Int = sizeof(Int)) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }

    private func arrayOfBytes(value: Int, length: Int) -> [UInt8] {
        var valuePointer = UnsafeMutablePointer<Int>.alloc(1)
        valuePointer.memory = value

        var bytesPointer = UnsafeMutablePointer<UInt8>(valuePointer)
        var bytes = [UInt8](count: length, repeatedValue: 0)
        for j in 0 ..< length {
            bytes[length - 1 - j] = (bytesPointer + j).memory
        }

        valuePointer.destroy()
        valuePointer.dealloc(1)

        return bytes
    }

}
