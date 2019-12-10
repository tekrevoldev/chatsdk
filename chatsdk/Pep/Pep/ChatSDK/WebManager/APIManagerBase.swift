import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

typealias Parameters = [String: Any]
typealias DefaultAPIFailureClosure = (NSError) -> Void
typealias DefaultAPISuccessClosure = (Dictionary<String,AnyObject>) -> Void
typealias DefaultBoolResultAPISuccesClosure = (Bool) -> Void
typealias DefaultArrayResultAPISuccessClosure = (Dictionary<String,AnyObject>) -> Void

class APIManagerBase: NSObject
{
    var alamoFireManager : SessionManager!
    let baseURL = Constants.BaseURL
    let defaultRequestHeader = ["Content-Type": "application/json"]
    let defaultError = NSError(domain: "ACError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request Failed."])
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getAuthorizationHeader () -> Dictionary<String,String> {
        
        var str = "Bearer "
        return ["Authorization":str,"Accept":"application/json"]
        //
        //        var str = "Bearer kVu/Niz8AUOzPc3REQ2twIXLM909XObjnf9FNYYN9MR2ZDso52bzz41+j5AvvRIPAum3nUBPhWiZRRiu55ZRMa+Mwo0n3v1jgexT0i+IngbPm/Ys4lfQIg=="
        //        return ["Authorization":str,"Accept":"application/json"]
        
        //        return ["Content-Type":"application/json"]
    }
    
    func getErrorFromResponseData(data: Data) -> NSError? {
        do{
            let result = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String,AnyObject>>
            if let message = result?[0]["message"] as? String{
                let error = NSError(domain: "GCError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                return error;
            }
        }catch{
            NSLog("Error: \(error)")
        }
        
        return nil
    }
    
    
    func URLforRoute(route: String,params:Parameters) -> NSURL? {
        
        if let components: NSURLComponents  = NSURLComponents(string: (Constants.BaseURL+route)){
            var queryItems = [NSURLQueryItem]()
            for(key,value) in params{
                queryItems.append(NSURLQueryItem(name:key,value: value as? String))
            }
            components.queryItems = queryItems as [URLQueryItem]?
            
            return components.url as NSURL?
        }
        
        return nil;
    }
    
    
    func POSTURLforRoute(route:String) -> URL?{
        if let components: NSURLComponents = NSURLComponents(string: (Constants.BaseURL+route)){
            return components.url! as URL        }
        return nil
    }
    
    func POSTURLforRoute(routeOnly: String) -> URL?{
        if let components: NSURLComponents = NSURLComponents(string: (routeOnly)){
            return components.url! as URL
        }
        return nil
    }
    
    func GETURLfor(route:String) -> URL?{
        if let components: NSURLComponents = NSURLComponents(string: (Constants.BaseURL+route)){
            return components.url! as URL
        }
        return nil
    }

    // Pass paramaters same as post request. (But in string)
    func GETURLfor(route:String, parameters: Parameters) -> URL?{
        var queryParameters = ""
        for key in parameters.keys {
            if queryParameters.isEmpty {
                queryParameters =  "?\(key)=\((String(describing: (parameters[key]!))).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            } else {
                queryParameters +=  "&\(key)=\((String(describing: (parameters[key]!))).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
            queryParameters =  queryParameters.trimmingCharacters(in: .whitespaces)
            
        }
        if let components: NSURLComponents = NSURLComponents(string: (Constants.BaseURL+route+queryParameters)){
            return components.url! as URL
        }
        return nil
    }
    
    
    func postRequestWith<T : Codable>(route: URL,parameters: Parameters,
                                      success:@escaping (T) -> Void,
                                      responseType:T.Type,
                                      failure:@escaping DefaultAPIFailureClosure,
                                      errorPopup: Bool,
                                      showLoader: Bool = false){
        print(route)
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getAuthorizationHeader()).responseJSON{
            response in
            
            if showLoader {
                Utility.stopProgressLoading()
            }
            
            guard response.result.error == nil else {
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                failure(response.result.error as! NSError)
                
                if showLoader {
                    Utility.stopProgressLoading()
                }
                
                return
            }
            
            if response.response?.statusCode == 500 {
     //           Utility.showErrorWith(message: "Internal Server Error")
                if showLoader {
                    Utility.stopProgressLoading()
                }
                return
            }
            
            if response.response?.statusCode == 401 {
                Global.APP_DELEGATE.setupUX()
                return
            }
            
            if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                if let parsedResponse =  Utility.decodeJson(dictionary: jsonResponse, responseType: ResponseWrapper<T>.self) {
                    if !(parsedResponse.isSuccess ?? false) {
                        if errorPopup {
                            if let data = (jsonResponse["data"] as? Dictionary<String, AnyObject>), let errors = data["errors"] as? Dictionary<String, AnyObject>, let key = errors.keys.first, let messages = errors[key] as? [String], let message = messages.first {
//                                if response.response?.statusCode == 200 {
//                                   failure(NSError.init(domain: message, code: response.response?.statusCode ?? -1, userInfo: nil))
//                                }
                                if let status = response.response?.statusCode, status == 300 {
                                    let error = NSError.init(domain: "", code: response.response?.statusCode ?? 0, userInfo: nil)
                                    failure(error)
                                }

                                Utility.showErrorWith(message: message)
                            } else {
                                failure(NSError())
                            }
                        }
                        return
                    }
                    if let data = parsedResponse.data {
                        success(data)
                    }
                }
            } else {
                
            }
            if showLoader {
                Utility.stopProgressLoading()
            }
        }
    }
    
    func putRequestWith<T : Codable>(route: URL,parameters: Parameters,
                                      success:@escaping (T) -> Void,
                                      responseType:T.Type,
                                      failure:@escaping DefaultAPIFailureClosure,
                                      errorPopup: Bool,
                                      showLoader: Bool = false){
        print(route)
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: getAuthorizationHeader()).responseJSON{
            response in
            
            if showLoader {
                Utility.stopProgressLoading()
            }
            
            guard response.result.error == nil else {
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                failure(response.result.error as! NSError)
                
                if showLoader {
                    Utility.stopProgressLoading()
                }
                
                return
            }
            
            if response.response?.statusCode == 500 {
     //           Utility.showErrorWith(message: "Internal Server Error")
                if showLoader {
                    Utility.stopProgressLoading()
                }
                return
            }
            
            if response.response?.statusCode == 401 {
                Global.APP_DELEGATE.setupUX()
                return
            }
            
            if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                if let parsedResponse =  Utility.decodeJson(dictionary: jsonResponse, responseType: ResponseWrapper<T>.self) {
                    if !(parsedResponse.isSuccess ?? false) {
                        if errorPopup {
                            if let data = (jsonResponse["data"] as? Dictionary<String, AnyObject>), let errors = data["errors"] as? Dictionary<String, AnyObject>, let key = errors.keys.first, let messages = errors[key] as? [String], let message = messages.first {
                                Utility.showErrorWith(message: message)
                            }
                        }
                        return
                    }
                    if let data = parsedResponse.data {
                        success(data)
                    }
                }
            } else {
                
            }
            if showLoader {
                Utility.stopProgressLoading()
            }
        }
    }
    
    
    func postRequestWithBearer<T : Codable>(route: URL,parameters: Parameters,
                                            success:@escaping (T) -> Void,
                                            responseType:T.Type,
                                            failure:@escaping DefaultAPIFailureClosure,
                                            errorPopup: Bool,
                                            showLoader: Bool = false){
        print(route)
        
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getAuthorizationHeader()).responseJSON {
            response in
            guard response.result.error == nil else{
                
                print("error in calling post request")
                if errorPopup {
                    Utility.showErrorWith(message: response.result.error?.localizedDescription ?? "")
                }
                failure(response.result.error as! NSError)
                return;
            }
            
            
            if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                if let response =  Utility.decodeJson(dictionary: jsonResponse, responseType: responseType) {
                    success(response)
                }
            } else {
                
            }
            
            if showLoader {
                Utility.stopProgressLoading()            }
        }
    }
    
    
    func postVerificationRequestWith(route: URL,parameters: Parameters,
                                     success:@escaping DefaultArrayResultAPISuccessClosure,
                                     failure:@escaping DefaultAPIFailureClosure,
                                     errorPopup: Bool){
        print(route)
        alamoFireManager.request(route, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getAuthorizationHeader()).responseJSON{
            response in
            
            
            
            guard response.result.error == nil else{
                
                print("\n- Error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                failure(response.result.error as! NSError)
                return;
            }
            
            if let value = response.result.value {
                print (value)
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                    success(jsonResponse)
                } else {
                    success(Dictionary<String, AnyObject>())
                }
                
            }
            
            
            
        }
        
        
    }
    
    
    func showErrorMessage(error: Error)
    {
        
        if (error as NSError).code == -1009
        {
            Utility.showErrorWith(message: Constants.NO_INTERNET)
            
        }
        else
        {
            Utility.showErrorWith(message:(error as NSError).localizedDescription)
        }
        
        
        switch (error as NSError).code {
        case -1001:
            Utility.showErrorWith(message: ApiErrorMessage.TimeOut)
        case -1009:
            Utility.showErrorWith(message: ApiErrorMessage.NoNetwork)
        case 4:// Api Call Error
            Utility.showErrorWith(message: ApiErrorMessage.BadRequest)
        case -1005:
            Utility.showErrorWith(message: ApiErrorMessage.NoNetwork)
        default:
            Utility.showErrorWith(message: (error as NSError).localizedDescription)
        }
    }
    
    
    func getRequestWith<T : Codable>(route: URL,parameters: Parameters,
                                     success:@escaping (T) -> Void,
                                     responseType:T.Type,
                                     failure:@escaping DefaultAPIFailureClosure,
                                     errorPopup: Bool,
                                     showLoader: Bool = true) {
        print(route)
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .get, parameters: parameters, headers: getAuthorizationHeader()).responseJSON {
            response in
            
            guard response.result.error == nil else{
                if showLoader {
                    Utility.stopProgressLoading()
                }
                
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                failure(response.result.error! as NSError)
                
                return
            }
            
            
            if response.response?.statusCode == 500 {
//                Utility.showErrorWith(message: "Internal Server Error")
                if showLoader {
                    Utility.stopProgressLoading()
                }
                return
            }
            
            
            if response.response?.statusCode == 401 {
                return
            }
            
            if response.result.isSuccess {
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                    if let parsedResponse =  Utility.decodeJson(dictionary: jsonResponse,  responseType: ResponseWrapper<T>.self), let data = parsedResponse.data {
                        success(data)
                    } else {
                        failure(NSError())
                    }
                    
                }
                
            }
            
            if showLoader {
                Utility.stopProgressLoading()
            }
            
        }
        
    }
    
    func getRequestWith(route: URL,parameters: Parameters,
                                   onResponse:@escaping (Bool) -> Void,
                                   showLoader: Bool = true){
        
        print(route)
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .get, parameters: parameters, headers: getAuthorizationHeader()).responseJSON {
            response in
            
            guard response.result.error == nil else{
                if showLoader {
                    Utility.stopProgressLoading()
                }
                
                print("error in calling get request")
                self.showErrorMessage(error: response.result.error!)
                
                return
            }
            
            
            if response.response?.statusCode == 500 {
 //               Utility.showErrorWith(message: "Internal Server Error")
                if showLoader {
                    Utility.stopProgressLoading()
                }
                return
            }
            
            
            if response.response?.statusCode == 401 {
                Global.APP_DELEGATE.setupUX()
                return
            }
            
            if response.result.isSuccess {
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                    if let parsedResponse =  Utility.decodeJson(dictionary: jsonResponse,  responseType: BaseRespone.self), let isSuccess = parsedResponse.isSuccess {
                        onResponse(isSuccess)
                        if !isSuccess {
                            Utility.showAlert(title: "Error", message: parsedResponse.message)
                        }
                    }
                }
                
            }
            
            if showLoader {
                Utility.stopProgressLoading()
            }
            
        }
        
    }
    
    func postRequestWith(route: URL,parameters: Parameters,
                        onResponse:@escaping (Bool) -> Void,
                        showLoader: Bool = true){
        print(route)
        if showLoader {
            Utility.startProgressLoading()
        }
        
        alamoFireManager.request(route, method: .post, parameters: parameters, headers: getAuthorizationHeader()).responseJSON {
            response in
            
            guard response.result.error == nil else {
                if showLoader {
                    Utility.stopProgressLoading()
                }
                
                print("error in calling get request")
                self.showErrorMessage(error: response.result.error!)
                
                return
            }
            
            
            if response.response?.statusCode == 500 {
 //               Utility.showErrorWith(message: "Internal Server Error")
                if showLoader {
                    Utility.stopProgressLoading()
                }
                return
            }
            
            
            if response.response?.statusCode == 401 {
                Global.APP_DELEGATE.setupUX()
                return
            }
            
            if response.result.isSuccess {
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject> {
                    if let parsedResponse =  Utility.decodeJson(dictionary: jsonResponse,  responseType: BaseRespone.self), let isSuccess = parsedResponse.isSuccess {
                        onResponse(isSuccess)
                        if !isSuccess {
                            Utility.showErrorWith(message: parsedResponse.message ?? "")
                        } else {
                            Utility.showSuccessWith(message: parsedResponse.message ?? "")
                        }
                    }
                }
                
            }
            
            if showLoader {
                Utility.stopProgressLoading()
            }
            
        }
        
    }
    
    func putRequestWith(route: URL,parameters: Parameters,
                        success:@escaping DefaultArrayResultAPISuccessClosure,
                        failure:@escaping DefaultAPIFailureClosure,
                        errorPopup: Bool){
        print(route)
        Alamofire.request(route, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            
            
            
            guard response.result.error == nil else{
                
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                
                failure(response.result.error! as NSError)
                return;
            }
            
            
            
            if let value = response.result.value {
                print (value)
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                    success(jsonResponse)
                } else {
                    success(Dictionary<String, AnyObject>())
                }
                
            }
            
            
            
        }
        
        
    }
    
    
    
    
    func deleteRequestWith(route: URL,parameters: Parameters,
                           success:@escaping DefaultArrayResultAPISuccessClosure,
                           failure:@escaping DefaultAPIFailureClosure,
                           errorPopup: Bool){
        print(route)
        Alamofire.request(route, method: .delete, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            
            
            
            guard response.result.error == nil else{
                
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                
                failure(response.result.error! as NSError)
                return;
            }
            
            
            
            if let value = response.result.value {
                print (value)
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                    success(jsonResponse)
                } else {
                    success(Dictionary<String, AnyObject>())
                }
                
            }
        }
    }
    
    func deleteRequestForDictWith(route: URL,parameters: Parameters,
                           success:@escaping DefaultAPISuccessClosure,
                           failure:@escaping DefaultAPIFailureClosure,
                           errorPopup: Bool){
        print(route)
        //Alamofire.request(route, method: .delete, parameters: parametersheaders: getAuthorizationHeader(), encoding: JSONEncoding.default).responseJSON{
           // response in
            
            Alamofire.request(route, method: .delete, parameters: parameters, headers: getAuthorizationHeader()).responseJSON {
            response in
                
            guard response.result.error == nil else{
                
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                
                failure(response.result.error! as NSError)
                return;
            }
            
            
            
            if let value = response.result.value {
                print (value)
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                    success(jsonResponse)
                } else {
                    success(Dictionary<String, AnyObject>())
                }
                
            }
        }
    }
    
    func postRequestForDictWith(route: URL,parameters: Parameters,
                                  success:@escaping DefaultAPISuccessClosure,
                                  failure:@escaping DefaultAPIFailureClosure,
                                  errorPopup: Bool){
        print(route)
        //Alamofire.request(route, method: .delete, parameters: parametersheaders: getAuthorizationHeader(), encoding: JSONEncoding.default).responseJSON{
        // response in
        
        Alamofire.request(route, method: .post, parameters: parameters, headers: getAuthorizationHeader()).responseJSON {
            response in
            
            guard response.result.error == nil else{
                
                print("error in calling post request")
                if errorPopup {self.showErrorMessage(error: response.result.error!)}
                
                failure(response.result.error! as NSError)
                return;
            }
            
            
            
            if let value = response.result.value {
                print (value)
                if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                    success(jsonResponse)
                } else {
                    success(Dictionary<String, AnyObject>())
                }
                
            }
        }
    }

    
    func requestWithMultipart(URLSTR: URLRequest, route: URL,parameters: Parameters,
                              success:@escaping DefaultArrayResultAPISuccessClosure,
                              failure:@escaping DefaultAPIFailureClosure,
                              errorPopup: Bool){
        print(route)
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if parameters.keys.contains("photobase64") {
                let fileURL = URL(fileURLWithPath: parameters["photobase64"] as! String)
                multipartFormData.append(fileURL, withName: "profile_picture", fileName: "image.png", mimeType: "image/png")
            }
            
            var subParameters = Dictionary<String, AnyObject>()
            let keys: Array<String> = Array(parameters.keys)
            let values = Array(parameters.values)
            
            for i in 0..<keys.count {
                if ((keys[i] != "photobase64") && (keys[i] != "images")) {
                    subParameters[keys[i]] = values[i] as AnyObject
                }
            }
            
            if parameters.keys.contains("images") {
                let images = parameters["images"] as! Array<String>
                for i in 0  ..< images.count {
                    let fileURL = URL(fileURLWithPath: images[i])
                    multipartFormData.append(fileURL, withName: "image\(i+1)", fileName: "image\(i).png", mimeType: "image/png")
                }
            }
            
            for (key, value) in subParameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                //debug
                print(value)
            }
            
        }, with: URLSTR, encodingCompletion: {result in
            
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    guard response.result.error == nil else{
                        
                        print("error in calling post request")
                        if errorPopup {self.showErrorMessage(error: response.result.error!)}
                        
                        failure(response.result.error! as NSError)
                        return;
                    }
                    
                    
                    
                    if let value = response.result.value {
                        print (value)
                        if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                            success(jsonResponse)
                        } else {
                            success(Dictionary<String, AnyObject>())
                        }
                        
                    }
                    
                }
            case .failure(let encodingError):
                if errorPopup {self.showErrorMessage(error: encodingError)}
                
                failure(encodingError as NSError)
            }
        })
    }
    
    func putRequestWithMultipart_General(route: URL,parameters: Parameters,
                                         success:@escaping DefaultArrayResultAPISuccessClosure,
                                         failure:@escaping DefaultAPIFailureClosure,
                                         errorPopup: Bool){
        
        let URLSTR = try! URLRequest(url: route.absoluteString, method: HTTPMethod.put, headers: getAuthorizationHeader())
        
        requestWithMultipart(URLSTR: URLSTR, route: route, parameters: parameters, success: success, failure: failure , errorPopup: errorPopup)
    }
    
    func postRequestWithMultipart_General(route: URL,parameters: Parameters,
                                          success:@escaping DefaultArrayResultAPISuccessClosure,
                                          failure:@escaping DefaultAPIFailureClosure,
                                          errorPopup: Bool){
        
        let URLSTR = try! URLRequest(url: route.absoluteString, method: HTTPMethod.post, headers: getAuthorizationHeader())
        
        requestWithMultipart(URLSTR: URLSTR, route: route, parameters: parameters, success: success, failure: failure, errorPopup: errorPopup)
    }
    
    func postRequestWithMultipart(route: URL,parameters: Parameters,
                                  success:@escaping DefaultArrayResultAPISuccessClosure,
                                  failure:@escaping DefaultAPIFailureClosure,
                                  errorPopup: Bool){
        
        let URLSTR = try! URLRequest(url: route.absoluteString, method: HTTPMethod.post, headers: getAuthorizationHeader())
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            var subParameters = Dictionary<String, AnyObject>()
            let keys: Array<String> = Array(parameters.keys)
            let values = Array(parameters.values)
            
            for i in 0..<keys.count {
                //                if ((keys[i] != "file") && (keys[i] != "images")) {
                subParameters[keys[i]] = values[i] as AnyObject
            }
            
            
            for (key, value) in subParameters {
                if let data:Data = value as? Data {
                    
                    multipartFormData.append(data, withName: "file", fileName: "image.png", mimeType: "image/png")
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            
        }, with: URLSTR, encodingCompletion: {result in
            
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    guard response.result.error == nil else{
                        if errorPopup {self.showErrorMessage(error: response.result.error!)}
                        
                        print("error in calling post request")
                        failure(response.result.error as! NSError)
                        return;
                    }
                    
                    
                    
                    if let value = response.result.value {
                        print (value)
                        if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                            success(jsonResponse)
                        } else {
                            success(Dictionary<String, AnyObject>())
                        }
                        
                    }
                    
                }
            case .failure(let encodingError):
                if errorPopup {self.showErrorMessage(error: encodingError)}
                
                failure(encodingError as NSError)
            }
        })
    }
    
    func postRequestWithMultipartWithBearer(route: URL,parameters: Parameters,
                                            success:@escaping DefaultArrayResultAPISuccessClosure,
                                            failure:@escaping DefaultAPIFailureClosure,
                                            errorPopup: Bool){
        print(route)
        let URLSTR = try! URLRequest(url: route.absoluteString, method: HTTPMethod.post, headers: getAuthorizationHeader())
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            var subParameters = Dictionary<String, AnyObject>()
            let keys: Array<String> = Array(parameters.keys)
            let values = Array(parameters.values)
            
            for i in 0..<keys.count {
                //                if ((keys[i] != "file") && (keys[i] != "images")) {
                subParameters[keys[i]] = values[i] as AnyObject
            }
            
            
            for (key, value) in subParameters {
                if let data:Data = value as? Data {
                    multipartFormData.append(data, withName: "file", fileName: "image.png", mimeType: "image/png")
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            
        }, with: URLSTR, encodingCompletion: {result in
            
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    guard response.result.error == nil else{
                        
                        print("error in calling post request")
                        if errorPopup {self.showErrorMessage(error: response.result.error!)}
                        
                        failure(response.result.error as! NSError)
                        return;
                    }
                    
                    
                    
                    if let value = response.result.value {
                        print (value)
                        if let jsonResponse = response.result.value as? Dictionary<String, AnyObject>{
                            success(jsonResponse)
                        } else {
                            success(Dictionary<String, AnyObject>())
                        }
                        
                    }
                    
                }
            case .failure(let encodingError):
                if errorPopup {self.showErrorMessage(error: encodingError)}
                failure(encodingError as NSError)
            }
        })
    }
    
    
    fileprivate func multipartFormData(parameters: Parameters) {
        let formData: MultipartFormData = MultipartFormData()
        if let params:[String:AnyObject] = parameters as [String : AnyObject]? {
            for (key , value) in params {
                
                if let data:Data = value as? Data {
                    
                    formData.append(data, withName: "profile_picture", fileName: "image.png", mimeType: "image/png")
                } else {
                    formData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            
            print("\(formData)")
        }
    }
    
    
    
}

public extension Data {
    public var mimeType:String {
        get {
            var c = [UInt32](repeating: 0, count: 1)
            (self as NSData).getBytes(&c, length: 1)
            switch (c[0]) {
            case 0xFF:
                return "image/jpeg";
            case 0x89:
                return "image/png";
            case 0x47:
                return "image/gif";
            case 0x49, 0x4D:
                return "image/tiff";
            case 0x25:
                return "application/pdf";
            case 0xD0:
                return "application/vnd";
            case 0x46:
                return "text/plain";
            default:
                print("mimeType for \(c[0]) in available");
                return "application/octet-stream";
            }
        }
    }
}



