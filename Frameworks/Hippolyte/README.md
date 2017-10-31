# Hippolyte

[![Build Status](https://travis-ci.org/JanGorman/Hippolyte.svg?branch=master)](https://travis-ci.org/JanGorman/Hippolyte)
[![codecov](https://codecov.io/gh/JanGorman/Hippolyte/branch/master/graph/badge.svg)](https://codecov.io/gh/JanGorman/Hippolyte)
[![Version](https://img.shields.io/cocoapods/v/Hippolyte.svg?style=flat)](http://cocoapods.org/pods/Hippolyte)
[![License](https://img.shields.io/cocoapods/l/Hippolyte.svg?style=flat)](http://cocoapods.org/pods/Hippolyte)
[![Platform](https://img.shields.io/cocoapods/p/Hippolyte.svg?style=flat)](http://cocoapods.org/pods/Hippolyte)

An HTTP stubbing library written in Swift.

## Requirements

- Swift 4
- iOS 9.3+
- Xcode 9+

## Install

Hippolyte is available on [Cocoapods](http://cocoapods.org). Add it to your `Podfile`'s test target:

```ruby
pod 'Hippolyte'
```

## Usage

To stub a request, first you need to create a `StubRequest` and `StubResponse`. You then register this stub with `Hippolyte` and tell it to intercept network requests by calling the `start()` method.

```swift
func testStub() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    let body = "Hippolyte".data(using: .utf8)!
    response.body = body
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)
    Hippolyte.shared.start()

    let expectation = self.expectation(description: "Stubs network call")
    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      expectation.fulfill()
    }
    task.resume()

    wait(for: [expectation], timeout: 1)
}
```

It's also possible to configure a `StubRequest` to use a regular expression matcher to intercept URLs. The following example also shows a `StubResponse` that returns a certain status code:

```swift
func testStub() throws {
    let regex = try NSRegularExpression(pattern: "http://www.google.com/+", options: [])
    var stub = StubRequest(method: .GET, urlMatcher: RegexMatcher(regex: regex))
    stub.response = StubResponse(statusCode: 404)
    Hippolyte.shared.add(stubbedRequest: stub)
    Hippolyte.shared.start()

    myFictionalDataSource.get(URL(string: "http://www.google.com/foo.html")!) {
        …
    }
}
```

There are convenient Builder classes for both requests and responses:

```swift
func testStub() {
    let response = StubResponse.Builder()
        .stubResponse(withStatusCode: 204)
        .addHeader(withKey: "X-Foo", value: "Bar")
        .build()
    let request = StubRequest.Builder()
        .stubRequest(withMethod: .GET, url: URL(string: "http://www.apple.com")!)
        .addResponse(response)
        .build()
    
    …
}
```

Remember to tear down stubbing in your tests:

```swift
override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
}
```

You can configure your stub response in a number of ways, such as having it return different HTTP status codes, headers, and errors.

## License

Hippolyte is released under the MIT license. See LICENSE for details
