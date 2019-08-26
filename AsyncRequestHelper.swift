//
//  AsyncRequestHelper.swift
//  CommonXibDemo
//
//  Created by kETAN on 26/08/19.
//  Copyright © 2019 kETAN. All rights reserved.
//

import Foundation

import Alamofire

/*
 *      internal typealias AsyncCompletionBlock = (_ objRef : NSObject,_ resCode: Int,_ resMessage : String) -> Void
 *      fileprivate  var resCompletionBlock : AsyncCompletionBlock = {resObject , resCode, resMessage in}
 */

protocol AsyncRequestHelperDelegate {
    func asyncRequestHelperDelegate(_ action: String, responseData: Response)
}

class AsyncRequestHelper: NSObject {
    
    var delegate: AsyncRequestHelperDelegate? = nil
    var strAction:String = String()    
    
    let alamofireManager : SessionManager = {
        let policies:[String:ServerTrustPolicy] = [Constant.BASEURL: .disableEvaluation]
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(Constant.TIME_INTERVAL)
        
        let manager = SessionManager(configuration: sessionConfiguration, serverTrustPolicyManager: ServerTrustPolicyManager(policies:policies))
        
        return manager
        
    }()
    
    
    //======
    //MARK: POST Request
    func sendPostRequest(_ action: String, requestData: Request) {
        
        strAction = action
        let strUrl = Constant.BASEURL + action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("Header data : \(requestData.dictHeaderValues)")
        
        let url = URL(string: strUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.timeoutInterval = 3
        
        alamofireManager.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseJSON
            {
                (response:DataResponse<Any>) in
                
                switch(response.result) {
                    
                case .success(_):
                    print("res Dic : \(String(describing: response.result.value))")
                    let responsedictionary = (response.result.value as! [String:Any])
                    
                    let response = Response()
                    response.resposeObject = responsedictionary
                    
                    if self.delegate != nil {
                      self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    
                    break
                    
                case .failure(_):
                    print("Response FAILURE : \(response.result.error)")
                    let response = Response()
                    if self.delegate != nil {
                        self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    break
                }
        }
    }
    /*
    func sendPostRequestWithEnum(_ apiURL: APIURLS, requestData: Request) {
        
        strAction = getValidURLS(apiURL)
        let strUrl = Constant.BASEURL + getValidURLS(apiURL)
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("Header data : \(requestData.dictHeaderValues)")
        
        let url = URL(string: strUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.timeoutInterval = 3
        
        alamofireManager.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseJSON
            {
                (response:DataResponse<Any>) in
                
                switch(response.result) {
                    
                case .success(_):
                    print("res Dic : \(String(describing: response.result.value))")
                    let responsedictionary = (response.result.value as! [String:Any])
                    
                    let response = Response()
                    response.resposeObject = responsedictionary
                    
                    if (self.delegate?.responds(to: #selector(AsyncRequestHelperDelegate.asyncRequestHelperDelegate(_:responseData:))))!{
                        self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    break
                    
                case .failure(_):
                    print("Response FAILURE : \(response.result.error)")
                    
                    //                if error._code == NSURLErrorTimedOut
                    //                {
                    //                    GeneralUtill.appDelegate.hideProsess()
                    //                    print("Time out")
                    //                    break
                    //                }
                    //                else
                    //                {
                    let response = Response()
                    if (self.delegate?.responds(to: #selector(AsyncRequestHelperDelegate.asyncRequestHelperDelegate(_:responseData:))))!{
                        self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    break
                    // }
                }
        }
    }*/
    
    func sendPostRequestWithStringResponse(_ action: String, requestData: Request) {
        // not working string data not conver in to dictionnary
        strAction = action
        let strUrl = Constant.BASEURL + action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("Header data : \(requestData.dictHeaderValues)")
        
        alamofireManager.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseString { (response:DataResponse<String>) in
            
            print("string res status: \(response.result)")
            
            switch(response.result) {
                
            case .success(_):
                print("res Dic : \(response.result.value)")
                let responsedictionary = (response.result.value! as! [String:Any])
                let response = Response()
                response.resposeObject = responsedictionary
                
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                
                break
                
            case .failure(_):
                print("Response FAILURE : \(response.result.error)")
                let response = Response()
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
                
            }
        }
    }
    
    func sendPostRequestWithImage(_ action:String, withImageParamName:String, image:UIImage,requestData: Request){
        
        strAction = action
        let strUrl = Constant.BASEURL + action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("req data : \(requestData.dictHeaderValues)")
        print("image : \(image)")
        
        alamofireManager.upload(multipartFormData: { multipartFormData in
            
            if let imageData = UIImageJPEGRepresentation(image, 1) {
                //multipartFormData.append(imageData, withName: "file", fileName: "111.jpeg", mimeType: "image/jpeg")
                multipartFormData.append(imageData, withName: "\(withImageParamName)", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            }
            
            for (key, value) in requestData.dictParamValues {
                
                multipartFormData.append(((value as! String).data(using: .utf8))!, withName: key)
            }}, to: strUrl, method: .post, headers: requestData.dictHeaderValues,
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("porgressss  : \(progress.fractionCompleted)")
                        })
                        
                        upload.responseJSON { response in
                            
                            switch(response.result) {
                                
                            case .success(_):
                                print("res Dic : \(response.result.value)")
                                let responsedictionary = (response.result.value as! [String:Any])
                                
                                let response = Response()
                                response.resposeObject = responsedictionary
                                if self.delegate != nil {
                                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                                }
                                break
                                
                            case .failure(_):
                                print("Response FAILURE : \(response.result.error)")
                                let response = Response()
                                if self.delegate != nil {
                                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                                }
                                break
                                
                            }
                        }
                        break
                        
                    case .failure(let encodingError):
                        print(encodingError.localizedDescription)
                        break
                        
                    }
                    
        })
    }
    
    
    func sendPostRequestWithMultipleImage(_ action:String,withImageParamName:String, arrImageData:[UIImage],requestData: Request) {
        
        strAction = action
        let strUrl = Constant.BASEURL + action
        
        print("URL Action :" + strUrl)
        
        print("req data : \(requestData.dictParamValues)")
        print("req data : \(requestData.dictHeaderValues)")
        print("image Count : \(arrImageData.count)")
        
        alamofireManager.upload(multipartFormData: { multipartFormData in
            
            for imageData in arrImageData {
                if let imageData = UIImageJPEGRepresentation(imageData, 1) {
                    //multipartFormData.append(imageData, withName: "file", fileName: "111.jpeg", mimeType: "image/jpeg")
                    multipartFormData.append(imageData, withName: "\(withImageParamName)[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in requestData.dictParamValues {
                
                multipartFormData.append(((value as! String).data(using: .utf8))!, withName: key)
            }}, to: strUrl, method: .post, headers: requestData.dictHeaderValues,
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("porgressss  : \(progress.fractionCompleted)")
                        })
                        
                        upload.responseString(completionHandler: { (responseData) in
                            
                            let response = Response()
                            
                            if (responseData.error != nil) {
                                print("Image Upload Failed >>>>>>>>> \(responseData.error.debugDescription)")
                                response.resposeObject = NSDictionary(dictionary: self.stringJSONSerialiserToDictionary(text: (responseData.error?.localizedDescription)!)!)
                            } else {
                                response.resposeObject = NSDictionary(dictionary: self.stringJSONSerialiserToDictionary(text: responseData.value!)!)
                            }
                            if self.delegate != nil {
                                self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                            }
                            
                        })
                    case .failure(let encodingError):
                        print(encodingError.localizedDescription)
                        break
                        
                    }
                    
        })
    }
    
    func sendPostRequestDownloadFile(_ action: String, requestData: Request) {
        
        strAction = action
        let strUrl =  action
        
        let fileName = URL(fileURLWithPath: strUrl).lastPathComponent
        
        print("URL Action :" + strUrl)
        print("File Name: \(fileName)")
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(fileName)
            return (documentsURL, [.removePreviousFile])
        }
        
        alamofireManager.download(strUrl, to: destination).responseData { response in
            
            switch(response.result) {
            case .success(_):
                
                let response = Response()
                response.resposeObject = "success"
                response.completionStatus = true
                
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print("Res Failure : \(response.result.error)")
                let response = Response()
                response.resposeObject = "error"
                response.completionStatus = false
                
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
            }
        }
        
    }
    
    func stringJSONSerialiserToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK: Get Request
    func sendGetRequest(_ action: String, requestData: Request){
        
        strAction = action
        let strUrl = Constant.BASEURL + action
        print("URL Action :" + strUrl)
        
        Alamofire.request(strUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let responsedictionary = response.result.value//(response.result.value as! [[String:Any]])
                let response = Response()
                response.resposeObject = responsedictionary!
                
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                break
            }
        }
        
    }
    
    
    func sendGetRequestWithParams(_ action: String, requestData: Request) {
        
        strAction = action
        var strQueryString = ""
        
        var i = 1
        for (param,value) in requestData.dictQueryValues {
            
            if i == requestData.dictQueryValues.count {
                strQueryString += param + "=" + value
            }
            else {
                strQueryString += param + "=" + value + "&"
            }
            i += 1
        }
        
        //let strUrl = Constant.BASEURL + action + (strQueryString.length > 0 ? "?" + strQueryString : "")
        let strUrl = action + (strQueryString.count > 0 ? "?" + strQueryString : "")
        
        print("URL Action :" + strUrl)
        print("requestData.dicHeaders : \(requestData.dictHeaderValues)")
        
        Alamofire.request(strUrl, method: .get, parameters: requestData.dictParamValues, headers: requestData.dictHeaderValues).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                let statusCode = (response.response?.statusCode)!
                print("STATUS CODE : \(statusCode)")
                let responsedictionary = (response.result.value as! [String:Any])
                let response = Response()
                response.resposeObject = responsedictionary
                
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                let response = Response()
                if self.delegate != nil {
                    self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                }
                break
            }
        }
    }
    
    //MARK: JASON Request
    func sendJsonRequest(_ action: String, requestData: Request ) {
        
        strAction = action
        let strUrl = Constant.BASEURL + action
        
        print("URL Action :" + strUrl)
        print("requestData.dicHeaders : \(requestData.dictHeaderValues)")
        print("values : \(requestData.dictParamValues)")
        
        Alamofire.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: JSONEncoding.default,headers:requestData.dictHeaderValues)
            .responseJSON { response in
                
                switch(response.result) {
                    
                case .success(_):
                    let statusCode = (response.response?.statusCode)!
                    print("STATUS CODE : \(statusCode)")
                    let responsedictionary = (response.result.value as! [String:Any])
                    let response = Response()
                    response.resposeObject = responsedictionary
                    
                    if self.delegate != nil {
                        self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    
                    break
                    
                case .failure(_):
                    print("Res Failure : \(response.result.error!)")
                    let response = Response()
                    if self.delegate != nil {
                        self.delegate?.asyncRequestHelperDelegate(self.strAction, responseData: response)
                    }
                    break
                }
        }
    }
    
}
