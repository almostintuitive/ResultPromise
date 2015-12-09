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
    let future = createPromise { completed in
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        completed(result: Result.Success(false))
      })
    }.map { result -> Bool in
      print("1: \(result)")
      return true
    }.then {
      print("2: \($0)")
    }.flatMap { result -> ResultPromise<String> in
      return self.stringTask(result)
    }.then { result in
      print("3: \(result)")
//    }.flatMap { result -> ResultPromise<String> in
//      return self.errorTask(true)
    }.then {
      print("4: \($0)")
    }.catchAll {
      print("error: \($0)")
    }.wrap { (value, completion: (Result<Bool> -> Void)) -> Void in
      self.longTaskWithCompletionBlock(code: value, completion: completion)
    }.then {
      print("5: \($0)")
    }
    
    
  }


  
  func stringTask(value: Bool) -> ResultPromise<String> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Success("string!"))
      })
    }
  }
  
  
  func errorTask(value: Bool) -> ResultPromise<String> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Error(FutureError.Fail))
      })
    }
  }
  
  func longTaskWithCompletionBlock(code code: String, completion: (result: Result<Bool>) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      completion(result: .Success(true))
    })
  }
  


}

