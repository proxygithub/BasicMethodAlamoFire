import UIKit

typealias ReqCompletionBlock = (_ resObj : NSObject , _ resCode : Int , _ resMessage : String) ->Void

class RequestHelper: NSObject, NetworkAsyncRequestDelegate {
    
    private var completionBlock:ReqCompletionBlock = { resObj, resCode, resMessage in }
    
    //MARK:- API Response
    func NetworkAsyncRequestDelegate(_ action: String, responseData: Response) {
        
        if (responseData.resposeObject as? NSDictionary) == nil {
            completionBlock("" as NSObject, Constant.ResponseStatus.SUCCESS, "INTERNAL_SERVER_ERROR")
            return
        }
        
        var dicResponse = responseData.resposeObject as! [String:Any]
        
        if (dicResponse[Constant.ResponseParam.RESPONSE_MESSAGE] as? String) == nil
        {
            dicResponse[Constant.ResponseParam.RESPONSE_MESSAGE] = ""
        }
        
        if (action == Constant.API.LOGIN_USER) {
//            if (dicResponse[Constant.ResponseParam.RESPONSE_FLAG] as! Int == Constant.ResponseStatus.SUCCESS) {
//                if !(dicResponse[Constant.ResponseParam.RESPONSE_DATA] is NSNull)
//                {
//                    let resData = dicResponse[Constant.ResponseParam.RESPONSE_DATA] as! NSDictionary
//                    print("ResData : \(resData)")
////                    var objUserModel = UserModel()
////                    objUserModel = UserModel.dictToUserObjectConvertion(dictData: (dicUserData))
//                }
//            }
            completionBlock("" as NSObject, Constant.ResponseStatus.SUCCESS, dicResponse[Constant.ResponseParam.RESPONSE_MESSAGE]! as! String)
        }
    }
    
    //MARK:- API Request Call
    func loginAPI(objUser:User, resBlock:  @escaping ReqCompletionBlock) {
        
        completionBlock = resBlock
        
        let request = Request()
        request.dictParamValues["username"] = objUser.strUsername
        request.dictParamValues["password"] = objUser.strPassword
        
        let asyncRequest = NetworkAsyncRequest()
        asyncRequest.delegate = self
        asyncRequest.sendPostRequest(Constant.API.LOGIN_USER, requestData: request)
    }
   
}
