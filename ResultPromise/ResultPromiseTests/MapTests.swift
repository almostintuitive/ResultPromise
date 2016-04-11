//
//  MapTests.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 01/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import XCTest
@testable import ResultPromise

class MapTests: XCTestCase {
  
  var readyExpectation: XCTestExpectation!
  var promise: ResultPromise<Int, TestError>!
  
  override func setUp() {
    super.setUp()
    readyExpectation = expectationWithDescription("ready")
    promise = ResultPromise<Int, TestError>()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: - Map - single
  
  func testMapSuccess() {
    promise.map { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  
  func testMapFailure() {
    promise.map { number in
      XCTAssert(false)
      self.readyExpectation.fulfill()
    }
    delay(0.08) {
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Failure(TestError.Test))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  func testMultipleMapSuccess() {
    var readyExpectation2 = expectationWithDescription("ready 2")
    
    promise.map { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.map { number in
      XCTAssert(number == 1)
      readyExpectation2.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }


  }

}


  