import UIKit
import Alamofire

@objc protocol NetworkAsyncRequestDelegate: NSObjectProtocol {
    @objc func NetworkAsyncRequestDelegate(_ action: String, responseData: Response)
}

class NetworkAsyncRequest: NSObject {
    
    var delegate: NetworkAsyncRequestDelegate? = nil
    var strAction:String = String()
    
    var pendingAction: String = String()
    var pendingReqData: Request = Request()
    
    //======
    //MARK: POST Request
    func sendPostRequest(_ action: String, requestData: Request) {
        
        strAction = action
        let strUrl =  action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("Header data : \(requestData.dictHeaderValues)")
        
        let url = URL(string: strUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.timeoutInterval = 3

        Alamofire.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseJSON
        {
            (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case .success(_):
                print("res Dic : \(String(describing: response.result.value))")
                let responsedictionary = (response.result.value as! [String:Any])
                
                let response = Response()
                response.resposeObject = responsedictionary
                
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
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
                    if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                        self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                    }
                    break
               // }
            }
        }
    }
    
    func sendPostRequestWithStringResponse(_ action: String, requestData: Request) {
        // not working string data not conver in to dictionnary
        strAction = action
        let strUrl =  action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("Header data : \(requestData.dictHeaderValues)")
    
        Alamofire.request(strUrl, method: .post, parameters: requestData.dictParamValues, encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseString { (response:DataResponse<String>) in
            
            print("string res status: \(response.result)")
            
            switch(response.result) {
                
            case .success(_):
                print("res Dic : \(response.result.value)")
                let responsedictionary = (response.result.value! as! [String:Any])
                let response = Response()
                response.resposeObject = responsedictionary
                
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print("Response FAILURE : \(response.result.error)")
                let response = Response()
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                }
                break
                
            }
        }
    }

    func sendPostRequestWithImage(_ action:String, withImageParamName:String, image:UIImage,requestData: Request){
        
        strAction = action
        let strUrl =  action
        
        print("URL Action :" + strUrl)
        print("req data : \(requestData.dictParamValues)")
        print("req data : \(requestData.dictHeaderValues)")
        print("image : \(image)")
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImage().jpegData(compressionQuality: 1.0) {
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
                                
                                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                                }
                                break
                                
                            case .failure(_):
                                print("Response FAILURE : \(response.result.error)")
                                let response = Response()
                                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
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
        let strUrl =  action
        
        print("URL Action :" + strUrl)
        
        print("req data : \(requestData.dictParamValues)")
        print("req data : \(requestData.dictHeaderValues)")
        print("image Count : \(arrImageData.count)")
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for imageData in arrImageData {
                if let imageData = UIImage().jpegData(compressionQuality: 1.0) {
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
                            
                            if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                                self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
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
        
        Alamofire.download(strUrl, to: destination).responseData { response in
            
            switch(response.result) {
            case .success(_):
                
                let response = Response()
                response.resposeObject = "success"
                response.completionStatus = true
                
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print("Res Failure : \(response.result.error)")
                let response = Response()
                response.resposeObject = "error"
                response.completionStatus = false
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
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
        let strUrl =  action
        
        print("URL Action :" + strUrl)
        
        Alamofire.request(strUrl, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: requestData.dictHeaderValues).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):

                let responsedictionary = (response.result.value as! [String:Any])
                let response = Response()
                response.resposeObject = responsedictionary
                
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
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
        
        //let strUrl =  action + (strQueryString.length > 0 ? "?" + strQueryString : "")
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
                
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                let response = Response()
                if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                    self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                }
                break
            }
        }
    }
    
    //MARK: JASON Request
    func sendJsonRequest(_ action: String, requestData: Request ) {
        
        strAction = action
        let strUrl =  action
        
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
                    
                    if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                        self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                    }
                    break
                    
                case .failure(_):
                    print("Res Failure : \(response.result.error!)")
                    let response = Response()
                    if (self.delegate?.responds(to: #selector(NetworkAsyncRequestDelegate.NetworkAsyncRequestDelegate(_:responseData:))))!{
                        self.delegate?.NetworkAsyncRequestDelegate(self.strAction, responseData: response)
                    }
                    break
                }
        }
    }
}
