//
//  Enums.swift

import Foundation
import UIKit

enum AppStoryboard : String {
    
    //Add all the storyboard names you wanted to use in your project
    case Main, Authetication, Popups, Home
    
    var instance : UIStoryboard {
        
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

enum EventName {
    case didCountrySelected
    case didTapOnCollapseExpand
}

enum Response : Int{
    case success = 200
    case serverError = 500
    case undefined = 0
}

enum Params : String {
    case deviceToken = "device_token"
    case deviceType = "device_type"
    case phone = "phone"
}

enum UserDefaultsKeys : String {
    case deviceToken = "device_token"
    case userId = "userId"
}

enum FontsType: String {
    case Heading = "Ailerons-Regular" 
    case Light = "Poppins-Light"
    case Regular = "Poppins-Regular"
    case Medium = "Poppins-Medium"
    case SemiBold = "Poppins-SemiBold"
    case Bold = "Poppins"
}

enum InteractionType: Int {
    case View = 10
    case Like = 20
    case Favorite = 30
    case MainCat = 40
    case Phone = 45
    case Request = 50
}

enum DateFormats: String {
    case Date = "dd-MMM-YY"
    case Time = "HH:mm a"
    case DateTime = "dd-MMM hh:mm a"
    case Brief = ""
}

enum Errors: String {
    case EnterName = "Please enter name"
    case EnterEmail = "Please enter your email."
    case EnterPassword = "Please enter your password."
    case InvalidData = "Please enter valid "
    case PasswordMismatch = "Password mismatch"
    case MinimumLength = "should be at 3 least characters long"
    case InvalidPhone = "Please enter valid Phone Number"
    case EnterReason = "Please enter Reason"
    case EmptyField = "Please enter "
    case EnterGroupTitle = "Please enter group title"
}

enum Messages: String {
    case EnterKeywordForSearch = "Please enter keyword for search"
}

enum Events : String {
    case onNewsUpdate = "onNewsUpdate"
    case onNewsSeen = "onNewsSeen"
    case onProfileUpdate = "onProfileUpdate"
}

enum Cell: String {
    case MessageRight = "MessageRightCell"
    case MessageLeft  = "MessageLeftCell"
    case ChatCell = "ChatCell"
}

enum ThreadUserRole: String {
    case Member = "member"
    case Admin = "admin"
}
