//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation






public class ResultPromise<T, Error: ErrorType> {
  
  internal var callback: (Result<T, Error> -> Void)?
  
  public func then(f: T -> Void) -> ResultPromise {
    guard callback == nil else { fatalError("promise already has a subscriber") }

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
    guard callback == nil else { fatalError("promise already has a subscriber") }
    
    let nextPromise = ResultPromise<U, Error>()
    subscribe { result in
      nextPromise.execute(result.map(f))
    }
    return nextPromise
  }
  
  public func then<U>(f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    guard callback == nil else { fatalError("promise already has a subscriber") }

    let nextPromise = ResultPromise<U, Error>()
    subscribe { result in
      switch result {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe { result in
          nextPromise.execute(result)
        }
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    
    return nextPromise
  }

  
  public func catchAll(f: ErrorType -> Void) -> ResultPromise {
    guard let _ = callback else { fatalError("promise already has a subscriber") }

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
  
  internal func subscribe(callback: Result<T, Error> -> Void) {
    self.callback = callback
  }
  
  internal func execute(value: Result<T, Error>) {
    self.callback?(value)
    self.callback = nil
  }

}


