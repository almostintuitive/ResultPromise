//
//  ResultPromise+FallThrough.swift
//  Irista
//
//  Created by Mark Aron Szulyovszky on 29/01/2016.
//  Copyright © 2016 Artjom Popov. All rights reserved.
//


public extension ResultPromise {
  
  public func fallThrough<U, Error2: ErrorType>(f: T -> ResultPromise<U, Error2>) -> ResultPromise {
    guard callback == nil else { fatalError("promise already has a subscriber") }
    
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
