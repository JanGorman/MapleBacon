//
//  MD5Tests.swift
//  MapleBacon
//

import Foundation
import XCTest
import MapleBacon

class MD5Tests: XCTestCase {

    func testMD5Hash() {
        XCTAssertEqual("".MD5()!, "D41D8CD98F00B204E9800998ECF8427E")
        XCTAssertEqual("a".MD5()!, "0CC175B9C0F1B6A831C399E269772661")
        XCTAssertEqual("abc".MD5()!, "900150983CD24FB0D6963F7D28E17F72")
        XCTAssertEqual("message digest".MD5()!, "F96B697D7CB7938D525A2F31AAF161D0")
        XCTAssertEqual("abcdefghijklmnopqrstuvwxyz".MD5()!, "C3FCD3D76192E4007DFB496CCA67E13B")
        XCTAssertEqual("The quick brown fox jumped over the lazy dog's back".MD5()!, "E38CA1D920C4B8B8D3946B2C72F01680")
    }

}
