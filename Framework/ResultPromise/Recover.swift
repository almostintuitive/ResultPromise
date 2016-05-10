//
//  Recover.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 27/04/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

public extension ResultPromise {
  
  
  public func recover(f: Error -> T) -> ResultPromise {
    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    addCallback { result in
      if case .Failure(let error) = result {
        nextPromise.execute(.Success(f(error)))
      } else {
        nextPromise.execute(result)
      }
      
    }
    // return the next promise in the chain
    return nextPromise
  }
    
  public func recover(value: T) -> ResultPromise {
    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    addCallback { result in
      if case .Failure = result {
        nextPromise.execute(.Success(value))
      } else {
        nextPromise.execute(result)
      }
      
    }
    // return the next promise in the chain
    return nextPromise
  }
  

  public func recoverWith(f: Error -> ResultPromise) -> ResultPromise {
    
    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    addCallback { result in
      if case .Failure(let error) = result {
        let nestedPromise = f(error)
        nestedPromise.subscribe { result in
          nextPromise.execute(result)
        }
        
      } else {
        nextPromise.execute(result)
      }
    }
    
    return nextPromise
  }

  
}