import Foundation
import UIKit
import Reachability

class AppStateManager: NSObject {
    
    static let sharedInstance = AppStateManager()
    
    let Network =  CEReachabilityManager.shared()
    var categoryFilterSelected: Any?
    
    override init() {
        super.init()
    }
    
    var userData: UserModel? {
        get{
            return Utility.getObject(key: Constants.USER_DATA_KEY, object: UserModel.self)
        }
        set {
            Utility.saveObject(key: Constants.USER_DATA_KEY, object: newValue)
        }
    }
    
    var userId: String {
        get{
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.userId.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userId.rawValue)
        }
    }
    
    func isUserLogin() -> Bool {
        return !userId.isEmpty
    }

    
}
