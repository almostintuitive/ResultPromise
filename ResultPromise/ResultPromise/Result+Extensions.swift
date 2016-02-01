//
//  Result+Extensions.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 01/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

extension Result {
  
  public func onSuccess(@noescape f: T -> Void) {
    switch self {
    case .Success(let value):
      f(value)
    default: ()
    }
  }
  
  public func onFailure(@noescape f: Error -> Void) {
    switch self {
    case .Failure(let error):
      f(error)
    default: ()
    }
  }
    
}