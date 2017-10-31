//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public enum HippolyteError: Error {
  case unmatchedRequest
}

open class Hippolyte {

  public static var shared = Hippolyte()

  public private(set) var stubbedRequests: [StubRequest] = []
  public private(set) var isStarted = false

  private var hooks: [HTTPClientHook] = []

  private init() {
    registerHook(URLHook())
    registerHook(URLSessionHook())
  }

  /// The start method to call for Hippolyte to start intercepting and stubbing HTTP calls
  public func start() {
    guard !isStarted else { return }
    loadHooks()
    isStarted = true
  }

  private func loadHooks() {
    hooks.forEach { $0.unload() }
  }

  /// The stop method to tell Hippolyte to stop stubbing.
  public func stop() {
    unloadHooks()
    clearStubs()
    isStarted = false
  }

  private func unloadHooks() {
    hooks.forEach { $0.load() }
  }

  /// Add a stubbed request
  ///
  /// - Parameter stubbedRequest: A configured `StubRequest`
  public func add(stubbedRequest request: StubRequest) {
    if let idx = stubbedRequests.index(of: request) {
      stubbedRequests[idx] = request
      return
    }
    stubbedRequests.append(request)
  }

  /// Clear all stubs
  public func clearStubs() {
    stubbedRequests.removeAll()
  }

  /// Register a hook
  ///
  /// - Parameter hook: A configured `HTTPClientHook`
  public func registerHook(_ hook: HTTPClientHook) {
    if !isHookRegistered(hook) {
      hooks.append(hook)
    }
  }

  private func isHookRegistered(_ hook: HTTPClientHook) -> Bool {
    for registeredHook in hooks {
      if hook == registeredHook {
        return true
      }
    }
    return false
  }

  /// Retrieve a stubbed response for an `HTTPRequest`
  ///
  /// - throws: A `.unmatchedRequest` for requests that haven't been registered before
  ///
  /// - Parameter request: The request to retrieve a response for
  public func response(for request: HTTPRequest) throws -> StubResponse {
    guard let response = stubbedRequests.first(where: { $0.matchesRequest(request) })?.response else {
      throw HippolyteError.unmatchedRequest
    }
    return response
  }

}
