//: Playground - noun: a place where people can play

import UIKit

//这是如何定义一个没有return值的closure函数
    //代表这个函数的变量名       closure函数的输入值                          输出值
let PFBackgroundClosure = { (gameScore : AnyObject?, error : NSError?) -> Void in
    
    print("working")
    
    if error != nil && gameScore != nil {
        
        print(gameScore!)
        
    } else {
        
        print(error)
        
    }
}

//这是如何定义一个有return值的closure函数
    //代表这个函数的变量名                closure函数的输入值                            输出值
let PFBackgroundClosureWithReturn = { (gameScore : AnyObject?, error : NSError?) -> AnyObject in
    
    print("working")
    
    if error != nil && gameScore != nil {
        
        print(gameScore!)
        
        return false
        
    } else {
        
        print(error)
        
        return true
        
    }
}


//举例一个会使用closure的class
class PFQuery {
    //class的内部变量
    var gameScore : AnyObject!
    var error : NSError!
    //一个可以储存closure返回值的变量
    var completionCallBack : AnyObject!

    //定义一个使用closure的函数                       此函数只需要了解传入的closure的输入和输出
    func getObjectInBackgroundWithId(str : String, completion : (AnyObject?, NSError?) -> Void) {
        
        let queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        ///这里可以写需要此函数做的事
        
        
        ///
        dispatch_async(queue, {
            
            //这里可以写一些需要异步处理的东西
            
            if(self.error != nil) {
                //这里是对于closure的调用，getObjectInBackgroundWithId－此函数只负责给closure传入变量
                //由于closure没有返回值，如此整个函数定义完毕
                completion(nil, self.error)
                
            } else {
                
                completion(self.gameScore, self.error)
                
            }
        })
        
    }
    
    //定义一个使用closure的函数                       此函数只需要了解传入的closure的输入和输出
    func getObjectInBackgroundWithIdWithReturn(str : String, completion : (AnyObject?, NSError?) -> Void) -> AnyObject {
        //上面AnyObject是getObjectInBackgroundWithIdWithReturn－函数的返回值，而非closure的返回值
        let queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        ///这里可以写需要此函数做的事
        
        
        ///
        dispatch_async(queue, {
            
            //这里可以写一些需要异步处理的东西
            
            if(self.error != nil) {
                //这里是对于closure的调用，getObjectInBackgroundWithId－此函数只负责给closure传入变量
                //由于closure没有返回值，如此整个函数定义完毕
                completion(nil, self.error)
                
            } else {
                
                completion(self.gameScore, self.error)
                
            }
        })
        
        return 1
        
    }
    
    //
    //定义一个使用有返回值的closure的函数                                此函数只需要了解传入的closure的输入和输出
    func getObjectInBackgroundWithIdWithClosureReturn(str : String, completion : (AnyObject?, NSError?) -> AnyObject) -> AnyObject {
        //上面AnyObject是getObjectInBackgroundWithIdWithReturn－函数的返回值，而非closure的返回值
        let queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        ///这里可以写需要此函数做的事
        
        
        ///
        dispatch_async(queue, {
            
            //这里可以写一些需要异步处理的东西
            
            if(self.error != nil) {
                
                //这里是对于closure的调用，getObjectInBackgroundWithId－此函数只负责给closure传入变量
                self.completionCallBack = completion(nil, self.error)
                
            } else {
                
                self.completionCallBack = completion(self.gameScore, self.error)
                
            }
        })
        
        return 1
        
    }

    
}

//下面是别的class调用本class的例子

//定义一个object
let example = PFQuery()

//运行一个带有已经定义过的closure的函数
//example.getObjectInBackgroundWithId("Player-ABC", completion: PFBackgroundClosure)

//同样，运行一个函数，同时定义它的closure，此函数运行，不仅定义closure而且运行了他，
//运行方式可以从getObjectInBackgroundWithId－函数中得到
//example.getObjectInBackgroundWithId("Player-ABC", completion: {
//    //这里gamescore和error是closure内部变量的名称，对外／getObjectInBackgroundWithId－函数可以是任何名字
//    (gameScore : AnyObject?, error : NSError?) in
//    
//    if error != nil {
//        
//        //        dispatch_async(dispatch_get_main_queue(), {
//        
//        print("We find score for the player")
//        
//        //        })
//        
//    } else if gameScore == nil {
//        
//        //        dispatch_async(dispatch_get_main_queue(), {
//        
//        print("Something wrong, we cannot find score for you")
//        
//        //        })
//        
//    } else {
//        
//        //        dispatch_async(dispatch_get_main_queue(), {
//        
//        print("Something wrong, we cannot find score for you")
//        
//        //        })
//    }
//})

//一个有返回值的函数的调用
var id1 = example.getObjectInBackgroundWithIdWithReturn("Player-ABC", completion: PFBackgroundClosure)

//一个有返回值的closure函数的调用, 此函数运行完，self.completionCallBack是有closure的返回值
var id2 = example.getObjectInBackgroundWithIdWithClosureReturn("Player-ABC", completion: PFBackgroundClosureWithReturn)