//
//  ViewController.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

enum FutureError: ErrorType {
  case Fail, NoError
}


class ViewController: UIViewController {
  


  override func viewDidLoad() {
    super.viewDidLoad()
    createPromise { completed in
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        completed(result: Result.Success(false))
      })
    }.then { result -> Bool in
      print("1: \(result)")
      return true
    }.then {
      print("2: \($0)")
    }.then { result -> ResultPromise<String, FutureError> in
      return self.stringTask(result)
    }.then { result in
      print("3: \(result)")
//    }.flatMap { result -> ResultPromise<String> in
//      return self.errorTask(true)
    }.then {
      print("4: \($0)")
//    }.catchAll {
//      print("error: \($0)")
    }.promisify { (value, completion: (Result<Bool, FutureError> -> Void)) -> Void in
      self.longTaskWithCompletionBlock(code: value, completion: completion)
    }.then {
      print("5: \($0)")
    }

    
    
  }


  
  func stringTask(value: Bool) -> ResultPromise<String, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Success("string!"))
      })
    }
  }
  
  
  func errorTask(value: Bool) -> ResultPromise<String, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Failure(FutureError.Fail))
      })
    }
  }
  
  func longTaskWithCompletionBlock(code code: String, completion: (result: Result<Bool, FutureError>) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      completion(result: .Success(true))
    })
  }
  


}

