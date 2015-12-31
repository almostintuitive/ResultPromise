//
//  ResultPromise+Threading.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 17/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation





public enum Thread {
  case Main
  case Background
  case Same
  
  var queue: dispatch_queue_t? {
    switch self {
    case .Main:
      return dispatch_get_main_queue()
    case .Background:
      return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    default:
      return nil
    }
  }
}

public extension ResultPromise {
  
  public func thenOn(thread: Thread, f: T -> Void) -> ResultPromise {
    let nextPromise = ResultPromise()
    subscribe(thread) { result in
      nextPromise.execute(result.map {
        f($0)
        return $0
      })
    }
    return nextPromise
  }
  
  public func thenOn<U>(thread: Thread, f: T -> U) -> ResultPromise<U, Error> {
    let nextPromise = ResultPromise<U, Error>()
    subscribe(thread) { result in
      nextPromise.execute(result.map(f))
    }
    return nextPromise
  }

  public func thenOn<U>(thread: Thread, f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    let nextPromise = ResultPromise<U, Error>()
    subscribe(thread) { result in
      switch result {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe(thread) { result in
          nextPromise.execute(result)
        }
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    
    return nextPromise
  }
  

  
}