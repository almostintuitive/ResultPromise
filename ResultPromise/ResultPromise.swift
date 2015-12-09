//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation



func createPromise<T>(operation: (completed:(result: Result<T>) -> Void) -> Void) -> ResultPromise<T> {
  let promise = ResultPromise<T>()
  func complete(result: Result<T>) {
    promise.execute(result)
  }
  operation(completed: complete)
  return promise
}


public class ResultPromise<T> {
  
  private var callback: (Result<T> -> Void)?
  
  public func then(f: T -> Void) -> ResultPromise {
    let nextPromise = ResultPromise()
    subscribe { result in
      nextPromise.execute(result.onSuccess(f))
    }
    return nextPromise
  }
  
  public func map<U>(f: T -> U) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      nextPromise.execute(result.map(f))
    }
    return nextPromise
  }
  
  public func flatMap<U>(f: T -> ResultPromise<U>) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()

    subscribe { result in
      switch result {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe{ result in
          nextPromise.execute(result)
        }
      case .Error(let error):
        nextPromise.execute(Result.Error(error))
      }
    }
    
    return nextPromise
  }

  
  public func catchAll(f: ErrorType -> Void) -> ResultPromise {
    let nextPromise = ResultPromise<T>()
    subscribe { result in
      nextPromise.execute(result.onError(f))
    }
    return nextPromise
  }
  
  

  
}

internal extension ResultPromise {
  
  internal func subscribe(callback: Result<T> -> Void) -> ResultPromise<T> {
    self.callback = callback
    return self
  }
  
  internal func execute(value: Result<T>) {
    self.callback?(value)
    self.callback = nil
  }

}