import Foundation
import UIKit

typealias Cells = (identifier:String, count:Int, height: CGFloat)
typealias CellWithoutHeight = (identifier:String, count:Int)
typealias CellWithSectionTitle = (identifier:String, count:Int, height: CGFloat, title: String)
typealias CellWithSection = (identifier:String, count:Int, headerIdentifier: String)

let UIWINDOW = UIApplication.shared.delegate!.window!

enum ButtonHeight: Float{
    
    case iPhone5  = 42.5
    case iPhone6  = 55.0
    case iPhone6p = 60.0
    
}

struct Global{
    static var APP_MANAGER                   = AppStateManager.sharedInstance   
    static var APP_DELEGATE                  = UIApplication.shared.delegate as! BaseAppDelegate
}

struct Constants{
    static let AppName = "Template"
    static let FETCH_DATA_LIMIT = 500
    
    static var CURRENCY_STRING = NSLocalizedString("AED", comment: "")
    static let kUserSessionKey = "userSessionKey"
    
    //    static let BaseURL                                        =    // Live
    //    http://caristocrat.stagingic.com/api/v1/
    static let BaseURL                                          = "http://designingcircle.com/" 
    //    static let BaseURL                                          = Constants.DEBUG_MODE ? "http://10.1.18.138/CaristoCratApp/api/v1/" : "http://caristocrat-dev.stagingic.com/api/v1/"
    static let NO_INTERNET                                      = NSLocalizedString("No internet connection!", comment: "")
    static let APP_COLOR                                        = UIColor(red: 197/255, green: 0/255, blue: 46/255, alpha: 1.0)
    static let kFONT_WIDTH_FACTOR                               = UIScreen.main.bounds.width / 414
    static let DEFAULT_IPHONE_5_HEIGHT                          = 47
    static let DEFAULT_IPHONE_6_HEIGHT                          = 55
    static let DEFAULT_IPHONE_6P_HEIGHT                         = 60
    static let kWINDOW_FRAME                                    = UIScreen.main.bounds
    static let kSCREEN_SIZE                                     = UIScreen.main.bounds.size
    static let kWINDOW_WIDTH                                    = UIScreen.main.bounds.size.width
    static let kWINDOW_HIEGHT                                   = UIScreen.main.bounds.size.height
    
    static let APP_DELEGATE                                     = UIApplication.shared.delegate as! BaseAppDelegate
    static let UIWINDOW                                         = UIApplication.shared.delegate!.window!
    static let MINIMUM_LENGTH                                   = 3
    
    
    // User Defaults Keys
    static let USER_DEFAULTS                                    = UserDefaults.standard
    static let ACCESS_TOKEN                                     = "access_token";
    static let REMEMBER_COUNTRY                                 = "remember_country";
    static let PLATFORM                                         = "ios"
    static let IS_TUTORIAL_SHOWN = "is_tutorial_shown";
    static let PLACEHOLDER_USER                                 = #imageLiteral(resourceName: "menu_profile")
    static let DEFAULT_DROP_DOWN_ANIMATION_TIME                 = 0.15
    static let FIELDS_TAG                                       = 100
    static let APP_PRIMARY_COlOR                                = UIColor(red:0.71, green:0.67, blue:0.54, alpha:1.0)
    static let USER_DATA_KEY = "user_data"
    static let FILTER_OPTIONS = "filter_options"
    static let CATEGORY_ORDER = "category_order"
    static let SUBCATEGORY_ORDER = "subcategory_order"
    static let LOCATION_KEY = "location_data"
    static let OFF = "% OFF"
    static let LOCATION_COULD_NOT_DETERMINED = "Your location could not be determined"
    static let NO_RESULT_FOUND = "No Result Found."
    static let DEBUG_MODE = false
    static let Units = ["HEIGHT": "MM",
                        "WIDTH": "MM",
                        "LENGTH": "MM",
                        "TRUNK": "L",
                        "WEIGHT": "KG",
                        "DISPLACEMENT": "CC",
                        "MAX SPEED": "KM/H",
                        "ACCELERATION 0-100": "SEC",
                        "TORQUE": "NM",
                        "FUEL CONSUMPTION": "L/100 KM",
                        "EMISSION": "GMCO2/KM",
                        "WARRANTY": "YEARS/KM",
                        "MAINTENANCE PROGRAM ": "YEARS/KM"]
        // Fonts
    static let rightMenuSelectedTextColor = UIColor.init(red: 65.0/255, green: 9.0/255, blue: 7.0/255, alpha: 1)
    static let redColor = "c20004".hexStringToUIColor()
    static let LOGOUT_MESSAGE = "Are you sure you want to Logout?"
    static let LUXURY_MARKET_CATEGORY_ID = 28
    
    //Colors
    static let cc_miscellaneous = "7f8c8d"
    static let cc_travel = "d92714"
    static let cc_transport = "6268a2"
    static let cc_service = "1436d5"
    static let cc_mobile = "ff7e00"
    static let cc_kids = "07b773"
    static let cc_home = "540657"
    static let cc_health = "92b806"
    static let cc_grocery = "cb4415"
    static let cc_food = "dfa711"
    static let cc_fashion = "b01fcf"
    static let cc_events = "673ab7"
    static let cc_electronic = "00bcd4"
    static let cc_education = "009688"
    static let cc_beauty = "eb4c4d"
    static let cc_art = "e41c64"
    
    static let PLACEHOLDER_COLOR = "888888"
    
    // USER DEFAULTS
    static let USER_LOGGED_IN = "user_logged_in"
    
    // APP CONSTANTS
    static let TUTORIAL_DESCRIPTIONS = ["Sample text:As harry squelched the deserted corridor he come across somebody who looked just as preoccupied as he was.Nearly Headless Nick, the ghost of Gryffindor Tower was starting morosely out of a window","Sample text:As harry squelched the deserted corridor he come across somebody who looked just as preoccupied as he was.Nearly Headless Nick, the ghost of Gryffindor Tower was starting morosely out of a window"]
    static let TUTORIAL_TITLES = ["WELCOME TO CARISTOCRAT","STAY AHEAD OF THE COMPETITION ALWAYS"]
    // Controls Titles here
    static let ALREADY_A_MEMEBER = "Already a member? "
    static let CLICK_HERE = "Click here"
    static let SIGNUP = "SIGN UP"
    static let SKIP = "SKIP"
    static let NEXT = "NEXT"
    static let CREATE_ACCOUNT = " to create a new account"
    static let WE_WILL_IN_TOUCH = "WE WILL BE IN TOUCH"
    static let THANK_YOU = "Thank you!"
    static let THANKS_POPUP_CONTENT = "Market experts will evaluate your car and come back to you with best prices."
    static let CAR_ADDED_SUCCESSFULLY = "Your car added successfully."
    static let EVALUATE_NOW = "Your car added successfully.\nDo you want to evaluate your car now?"
    static let LATER = "LATER"
    static let YES = "YES"
    static let NEW_CAR = "NEW CAR"
    static let AdditionalNotes = "Additional notes (if any)"
    
    static let UPLOAD_UPTO = "Upload upto %d Image"
    static let BIDS_TITLE = "Here are top %d offers for your vehicles %@ model with Chasis number %d"
}
struct ApiErrorMessage {
    static let NoNetwork = NSLocalizedString("No internet connection!", comment: "")
    static let TimeOut = NSLocalizedString("Connection Timeout.", comment: "")
    static let ErrorOccured = NSLocalizedString("An error occurred. Please try again.", comment: "")
    static let BadRequest = NSLocalizedString("Bad Request.", comment: "")
}
struct ApiResultFailureMessage {
    static let InvalidEmailPassword = NSLocalizedString("Invalid email or password.", comment: "")
    static let WrongEmailInForgotPassword = NSLocalizedString("User with entered email doesn’t exist.", comment: "")
}
struct FieldsErrorMessage {
    static let EmailExist = NSLocalizedString("User with entered email address already exists", comment: "")
    static let UsernameExist = NSLocalizedString("This username is already taken, please try another", comment: "")
    static let UsernameValidity = NSLocalizedString("Please enter a valid username", comment: "")
    static let EmailValidity = NSLocalizedString("Please enter a valid email address", comment: "")
    static let ShortPassword = NSLocalizedString("This password is too short", comment: "")
    static let NewOldPasswordMatch = NSLocalizedString("New password cannot be same as old password.", comment: "")
    static let PasswordMisMatch = NSLocalizedString("Passwords do not match.", comment: "")
}
struct PopupMessage {
    static let PasswordChanged = NSLocalizedString("An email has been sent to your account with new password.", comment: "")
    static let PasswordChangedSuccess = NSLocalizedString("Password changed successfully.", comment: "")
    static let InternetOffline = NSLocalizedString("Internet connection seems to be offline, Pleas try again.", comment: "")
}

extension Constants{
    static let SliderComputedValue = "SliderComputedValue"
    
}
