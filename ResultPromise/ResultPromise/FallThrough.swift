//
//  ResultPromise+FallThrough.swift
//  Irista
//
//  Created by Mark Aron Szulyovszky on 29/01/2016.
//  Copyright © 2016 Artjom Popov. All rights reserved.
//


public extension ResultPromise {
  
  // Executes the ResultPromise it was given, but ignores its result and takes the previous result instead.
  public func fallThrough<U, Error2: ErrorType>(f: T -> ResultPromise<U, Error2>) -> ResultPromise {
    
    let nextPromise = ResultPromise()
    subscribe { firstResult in
      switch firstResult {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe { result in
          nextPromise.execute(firstResult)
        }
      case .Failure(let error):
        nextPromise.execute(.Failure(error))
      }
    }
    
    return nextPromise
  }
  
}
