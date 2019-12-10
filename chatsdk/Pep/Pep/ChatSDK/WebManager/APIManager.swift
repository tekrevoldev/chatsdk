
import UIKit

protocol APIErrorHandler {
    func handleErrorFromResponse(response: Dictionary<String,AnyObject>)
    func handleErrorFromERror(error:NSError)
}

class APIManager: APIManagerBase {
    
    static let sharedInstance = APIManager()
    
   
}
