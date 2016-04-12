//
//  MD5Tests.swift
//  MapleBacon
//

import Foundation
import XCTest
import MapleBacon

class MD5Tests: XCTestCase {

    func testMD5Hash() {
        XCTAssertEqual("".MD5(), "d41d8cd98f00b204e9800998ecf8427e")
        XCTAssertEqual("a".MD5(), "0cc175b9c0f1b6a831c399e269772661")
        XCTAssertEqual("abc".MD5(), "900150983cd24fb0d6963f7d28e17f72")
        XCTAssertEqual("message digest".MD5(), "f96b697d7cb7938d525a2f31aaf161d0")
        XCTAssertEqual("abcdefghijklmnopqrstuvwxyz".MD5(), "c3fcd3d76192e4007dfb496cca67e13b")
        XCTAssertEqual("The quick brown fox jumped over the lazy dog's back".MD5(), "e38ca1d920c4b8b8d3946b2c72f01680")
        let md51 = "http://i4.ztat.net/detail/L4/62/1C/05/4T/11/L4621C054-T11@10.jpg".MD5()
        let md52 = "http://i4.ztat.net/detail/VL/02/1C/00/PJ/11/VL021C00P-J11@14.jpg".MD5()
        XCTAssertNotEqual(md51, md52)
    }

}
