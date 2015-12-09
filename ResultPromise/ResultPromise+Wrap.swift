//
//  ResultPromise+Wrap.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 09/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

public extension ResultPromise {
  
  public func wrap<U>(f: (value: T, wrap: (Result<U> -> Void)) -> Void) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      switch result {
      case .Success(let value):
        f(value: value, wrap: { nextResult  in
          nextPromise.execute(nextResult)
        })
      case .Error(let error):
        nextPromise.execute(.Error(error))
      }
    }
    return nextPromise
  }
  
}