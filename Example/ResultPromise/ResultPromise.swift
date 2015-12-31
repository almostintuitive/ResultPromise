//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation



func createPromise<T, Error: ErrorType>(operation: (completed:(result: Result<T, Error>) -> Void) -> Void) -> ResultPromise<T, Error> {
  let promise = ResultPromise<T, Error>()
  func complete(result: Result<T, Error>) {
    promise.execute(result)
  }
  operation(completed: complete)
  return promise
}


public class ResultPromise<T, Error: ErrorType> {
  
  private var callback: (Result<T, Error> -> Void)?
  
  public func then(f: T -> Void) -> ResultPromise {
    return thenOn(.Same, f: f)
  }
  
  public func then<U>(f: T -> U) -> ResultPromise<U, Error> {
    return thenOn(.Same, f: f)
  }
  
  public func then<U>(f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    return thenOn(.Same, f: f)
  }

  
  public func catchAll(f: ErrorType -> Void) -> ResultPromise {
    let nextPromise = ResultPromise<T, Error>()
    subscribe(.Same) { result in
      nextPromise.execute(result.mapError {
        f($0)
        return $0
      })
    }
    return nextPromise
  }

  
}

internal extension ResultPromise {
  
  internal func subscribe(thread: Thread, body: Result<T, Error> -> Void) {
    self.callback = { result in
      executeOnThread(thread) {
        body(result)
      }
    }
  }
  
  internal func execute(value: Result<T, Error>) {
    self.callback?(value)
    self.callback = nil
  }

}


private func executeOnThread(thread: Thread, f: () -> Void) {
  guard let queue = thread.queue else {
    f()
    return
  }
  guard !(NSThread.currentThread() == NSThread.mainThread() && thread == .Main) else {
    f()
    return
  }
  dispatch_async(queue, f)
}