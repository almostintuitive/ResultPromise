//
//  ResultPromise+Threading.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 17/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation


func waitUntilDone(queue: dispatch_queue_t, block: () -> Void) {
  let group = dispatch_group_create()
  dispatch_group_async(group, queue, {
    block()
  })
  dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
}


public enum Thread {
  case Main
  case Background
  var queue: dispatch_queue_t {
    switch self {
    case .Main:
      return dispatch_get_main_queue()
    case .Background:
      return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    }
  }
}

public extension ResultPromise {
  
  public func thenOn(thread: Thread, f: T -> Void) -> ResultPromise {
    var promise: ResultPromise?
    waitUntilDone(thread.queue) {
      promise = self.then(f)
    }
    return promise!
  }
  
  public func thenOn<U>(thread: Thread, f: T -> U) -> ResultPromise<U, Error> {
    var promise: ResultPromise<U, Error>?
    waitUntilDone(thread.queue) {
      promise = self.then(f)
    }
    return promise!
  }
  
  public func thenOn<U>(thread: Thread, f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    var promise: ResultPromise<U, Error>?
    waitUntilDone(thread.queue) {
      promise = self.then(f)
    }
    return promise!
  }
  

  
}