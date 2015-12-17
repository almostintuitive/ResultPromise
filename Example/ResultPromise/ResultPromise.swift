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
    let nextPromise = ResultPromise()
    subscribe { result in
      nextPromise.execute(result.map {
        f($0)
        return $0
      })
    }
    return nextPromise
  }
  
  public func then<U>(f: T -> U) -> ResultPromise<U, Error> {
    let nextPromise = ResultPromise<U, Error>()
    subscribe { result in
      nextPromise.execute(result.map(f))
    }
    return nextPromise
  }
  
  public func then<U>(f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    let nextPromise = ResultPromise<U, Error>()

    subscribe { result in
      switch result {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe{ result in
          nextPromise.execute(result)
        }
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    
    return nextPromise
  }

  
  public func catchAll(f: ErrorType -> Void) -> ResultPromise {
    let nextPromise = ResultPromise<T, Error>()
    subscribe { result in
      nextPromise.execute(result.mapError {
        f($0)
        return $0
      })
    }
    return nextPromise
  }
  

  

  
}

internal extension ResultPromise {
  
  internal func subscribe(callback: Result<T, Error> -> Void) -> ResultPromise {
    self.callback = callback
    return self
  }
  
  internal func execute(value: Result<T, Error>) {
    self.callback?(value)
    self.callback = nil
  }

}