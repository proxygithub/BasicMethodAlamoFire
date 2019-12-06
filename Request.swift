import UIKit

class Request: NSObject {
    var dictParamValues : [String:Any] = [:]
    var dictHeaderValues : [String : String] = [:]
    var dictQueryValues : [String : String] = [:]
    
}

/*
//Obj - C Block Declaraion
1. Block Declaration
typedef void (^RequestComplitionBlock)(NSObject *resObj);

typedef <RETURN_TYPE> (^CLAUSER_NAME) (PARAMETERS)
=======
2. Object Declaration of Block
RequestComplitionBlock complitionBlock;
=======
3. Global Variable of Block use in Method
-(void)uploadAllDataToServer :(RequestComplitionBlock) reqBlock { 
    complitionBlock = reqBlock;
}
*/
