//
//  ResultPromise+Wait.swift
//  Irista
//
//  Created by Mark Aron Szulyovszky on 29/01/2016.
//  Copyright © 2016 Artjom Popov. All rights reserved.
//


public extension ResultPromise {
  
  /// Use it if you want to wait for another Promise to be completed, but you don't care about the other's return value.
  /// Executes the ResultPromise it was given, but ignores its result and takes the previous result instead.
  public func waitOnAll<U, Error2: ErrorType>(f: () -> ResultPromise<U, Error2>) -> ResultPromise {

    let nextPromise = ResultPromise()
    addCallback { firstResult in
      let nestedPromise = f()
      nestedPromise.addCallback { _ in
        nextPromise.execute(firstResult)
      }
    }
    
    return nextPromise
  }
  
  /// Use it if you want to wait for another Promise to be completed, but you don't care about the other's return value.
  /// This will only get executed if the result of the previous Promise is .Success.
  /// Executes the ResultPromise it was given, but ignores its result and takes the previous result instead.
  public func waitOnSuccess<U, Error2: ErrorType>(f: () -> ResultPromise<U, Error2>) -> ResultPromise {
    
    let nextPromise = ResultPromise()
    addCallback { firstResult in
      switch firstResult {
      case .Success:
        let nestedPromise = f()
        nestedPromise.addCallback { _ in
          nextPromise.execute(firstResult)
        }
      case .Failure(let error):
        nextPromise.execute(.Failure(error))
      }
    }
    
    return nextPromise
  }
  
  /// Use it if you want to wait for another Promise to be completed, but you don't care about the other's return value.
  /// This will only get executed if the result of the previous Promise is .Failure.
  /// Executes the ResultPromise it was given, but ignores its result and takes the previous result instead.
  public func waitOnError<U, Error2: ErrorType>(f: () -> ResultPromise<U, Error2>) -> ResultPromise {
    
    let nextPromise = ResultPromise()
    addCallback { firstResult in
      switch firstResult {
      case .Success:
        nextPromise.execute(firstResult)

      case .Failure(let error):
        let nestedPromise = f()
        nestedPromise.addCallback { _ in
          nextPromise.execute(.Failure(error))
        }
      }
    }
    
    return nextPromise
  }
  
}
