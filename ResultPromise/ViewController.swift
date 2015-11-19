//
//  ViewController.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let future = createPromise { completed in
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        completed(result: Result.Success(true))
      })
      }.then {
        
        print("1: \($0)")
        return true
      }.then { value in
        
        // explicitly declare parameters
        print("2: \(value)")
        return false
      }.then { value -> Bool in
        
        // explicitly declare parameters + return type
        print("3: \(value)")
        return true
      }.flatMap {
        
        return self.longTask($0)
      }.flatMap { value -> ResultPromise<Bool, FutureError> in
        
        // explicitly declare parameters + return type
        return self.errorTask(value)
      }.then { value in
        
        print("4: \(value)")
        return false
      }.catchAll { error in
        
        print("error: \(error)")
    }
    //    }.finally { (value) -> Void in
    //      print("5: \(value)")
    //    }
  }


  
  func longTask(value: Bool) -> ResultPromise<Bool, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Success(value))
      })
    }
  }
  
  
  func errorTask(value: Bool) -> ResultPromise<Bool, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(result: Result.Failure(FutureError.Fail))
      })
    }
  }
  

}

