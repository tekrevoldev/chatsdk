import Foundation
import UIKit
import MapKit
import AVFoundation
import SwiftMessages
import Alamofire
import TWMessageBarManager
import SVProgressHUD

class Utility {
    
    func roundAndFormatFloat(floatToReturn : Float, numDecimalPlaces: Int) -> String{
        
        let formattedNumber = String(format: "%.\(numDecimalPlaces)f", floatToReturn)
        return formattedNumber
        
    }
    
    static func getDataComponent() -> DateComponents {
        return Calendar.current.dateComponents([.year,.month], from: Date())
    }
    
    static func printFonts() {
        for familyName in UIFont.familyNames {
            print("\n-- \(familyName) \n")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print(fontName)
            }
        }
    }
    
    
    func topViewController(base: UIViewController? = (Constants.APP_DELEGATE).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    
    static func showAlert(title:String?, message:String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in })
        Utility().topViewController()!.present(alert, animated: true){}
    }
    
    static func showAlert(title:String?, message:String?,positiveText: String?,positiveClosure: @escaping ((UIAlertAction) -> Swift.Void),navgativeText: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: positiveText, style: .default, handler: positiveClosure))
        alert.addAction(UIAlertAction(title: navgativeText, style: .default) { _ in })
        Utility().topViewController()!.present(alert, animated: true){}
    }
    
    static func showAlert(title:String?, message:String?,positiveText: String?,positiveClosure: @escaping ((UIAlertAction) -> Swift.Void),
                          negativeClosure: @escaping ((UIAlertAction) -> Swift.Void),navgativeText: String?, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: positiveText, style: .default, handler: positiveClosure))
        alert.addAction(UIAlertAction(title: navgativeText, style: .default, handler: negativeClosure))
        if preferredStyle == .actionSheet {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        Utility().topViewController()!.present(alert, animated: true){}
    }
    
    static func resizeImage(image: UIImage,  targetSize: CGFloat) -> UIImage {
        
        guard (image.size.width > 1024 || image.size.height > 1024) else {
            return image;
        }
        
        var newRect: CGRect = CGRect.zero;
        
        if(image.size.width > image.size.height) {
            newRect.size = CGSize(width: targetSize, height: targetSize * (image.size.height / image.size.width))
        } else {
            newRect.size = CGSize(width: targetSize * (image.size.width / image.size.height), height: targetSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 1.0)
        image.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0,y:  0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform=true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    func showSelectionPopup(title: String,items: [String], delegate: ItemSelectionDelegate) {
        let selectionController = SelectionController.instantiate(fromAppStoryboard: .Popups)
        selectionController.titleText = title
        selectionController.delegate = delegate
        selectionController.items = items
        selectionController.modalPresentationStyle = .overCurrentContext
        selectionController.modalTransitionStyle = .crossDissolve
        topViewController()?.present(selectionController, animated: true)
    }
    
    func showSelectionPopup(title: String,items: [String], tapClouser: @escaping ((_ position: Int, _ tag: String) -> Void)) {
        let selectionController = SelectionController.instantiate(fromAppStoryboard: .Popups)
        selectionController.titleText = title
        selectionController.tapClouser = tapClouser
        selectionController.items = items
        selectionController.modalPresentationStyle = .overCurrentContext
        selectionController.modalTransitionStyle = .crossDissolve
        topViewController()?.present(selectionController, animated: true)
    }
    
    func showCustomPopup(titile: String, descTitle: String, desc: String, delegate: PopupDelgates) {
        let generalViewController = GeneralViewController.instantiate(fromAppStoryboard: .Popups)
        generalViewController.titleText = titile
        generalViewController.descTitle = descTitle
        generalViewController.desc = desc
        generalViewController.delegate = delegate
        generalViewController.modalPresentationStyle = .overCurrentContext
        generalViewController.modalTransitionStyle = .crossDissolve
        topViewController()?.present(generalViewController, animated: true)
    }
    
    static func delay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    static func getStarImage(_ starNumber: Double, _  rating: Double) -> UIImage {
        
        if round(rating) >= starNumber {
            return #imageLiteral(resourceName: "rate_yellowstar")
        } else {
            return #imageLiteral(resourceName: "rate_whitestar")
        }
    }
    
    static func timeParser(_ str: String) ->String
    {
        if(str != nil)
        {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dater = dateFormatter.date(from: "2017-08-11 "+str)
            
            dateFormatter.dateFormat = "h:mm a"
            let dateString = dateFormatter.string(from: dater!)
            return dateString.lowercased()
        }
        else
        {
            return ""
        }
        
    }
    //
    //    static func checkPhoneVerification(completion: @escaping () -> ())
    //    {
    //        if !AppStateManager.sharedInstance.loggedInUser.PhoneConfirmed
    //        {
    //            let alert = UIAlertController(title: "Alert", message: Constants.ERROR_VERIFICATION_MISSING, preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "Skip", style: .destructive) { _ in })
    //            alert.addAction(UIAlertAction(title: "Verify", style: .default) { _ in
    //                completion()
    //            })
    //
    //
    //            Utility().topViewController()!.present(alert, animated: true){}
    //
    //
    //        }
    //    }
    
    static func dateFormatterWithFormat(_ str: String, withFormat: String) ->String
    {
        if(str != nil)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let dater = dateFormatter.date(from: str)
            dateFormatter.dateFormat = withFormat
            dateFormatter.timeZone = TimeZone.current
            let dateString = dateFormatter.string(from: dater ?? Date())
            return dateString
        }
        else
        {
            return ""
        }
    }
    
    
    static func getAddressFromPlacemark(placemarks: CLPlacemark) -> String
    {
        return (placemarks.addressDictionary?["FormattedAddressLines"] as! NSArray).componentsJoined(by: ", ")
        
        
    }
    static func stringToDate (_ str: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: str)
        return date!
    }
    
    
    
    static func getResponse(_ result: Dictionary<String,AnyObject>) -> String
    {
        return result["Message"] as! String
    }
    
    static func getErrorMessage(_ result: Dictionary<String,AnyObject>) -> String
    {
        return (result["Result"] as! Dictionary<String, Any>)["ErrorMessage"] as! String
    }
    
    
    static func applyBlurEffectToView(toView: UIView) -> UIView? {
        if !UIAccessibility.isReduceTransparencyEnabled {
            toView.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = toView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.85
            toView.addSubview(blurEffectView)
            
            return blurEffectView
        } else {
            toView.backgroundColor = UIColor.black
            return nil
        }
    }
    
    
    
    
    static func saveObject<T : Codable>(key: String, object: T) {
        do {
            let json = try JSONEncoder().encode(object)
            UserDefaults.standard.set(json, forKey: key)
        } catch let error as NSError {
        }
        
    }
    
    static func getObject<T: Codable>(key: String, object: T.Type) -> T? {
        if let data2: Data = UserDefaults.standard.data(forKey: key) { // fetch data from disk
            return try! JSONDecoder().decode(T.self, from: data2)
        }
        return nil
    }
    
    
    //    static func saveObject(key: String, object: Any) {
    //        let userDefaults = UserDefaults.standard
    //        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
    //        userDefaults.set(encodedData, forKey: key)
    //        userDefaults.synchronize()
    //    }
    
    //    static func getObject(key: String) -> Any {
    //        let decoded  = UserDefaults.standard.object(forKey: key) as! Data
    //        return NSKeyedUnarchiver.unarchiveObject(with: decoded)
    //    }
    
    
    static func markNotificationRead(notificationId: String)
    {
        let parameters: Parameters = [
            "NotificationId": notificationId
        ]
        
        let successClosure: DefaultArrayResultAPISuccessClosure = {
            (result) in
            
            if self.getResponse(result) == "Success"
            {
                print("- Marked Notification as read.")
            }
            
        }
        let failureClosure: DefaultAPIFailureClosure = {
            (error) in
            print(error)
            
            if(error.code == -1009)
            {
                // No internet
            }
        }
        
        //        APIManager.sharedInstance.markNotificationRead(parameters: parameters, success:successClosure , failure: failureClosure)
    }
    
    static func showErrorWith(message: String, presentationStyle: SwiftMessages.PresentationStyle = .bottom){
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.error)
        error.configureContent(title: "", body: message)
        //error.button?.setTitle("Stop", for: .normal)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
        
    }
    static func showSuccessWith(message: String){
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.success)
        error.configureContent(title: "", body: message)
        //error.button?.setTitle("Stop", for: .normal)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
        
    }
    
    
    static func showInformationWith(message: String){
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.info)
        //        error.iconImageView?.image = UIImage
        error.configureIcon(withSize: CGSize(width: 40, height: 40), contentMode: UIView.ContentMode.scaleAspectFit )
        error.configureContent(title: "", body: message)
        //error.button?.setTitle("Stop", for: .normal)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
        
    }
    
    static func checkLogout() -> Bool
    {
        if(!(NetworkReachabilityManager()?.isReachable)!)
        {
            self.showErrorWith(message: Constants.NO_INTERNET)
            return false
        }
        else
        {
            return true
        }
    }
    
    static func isInternetConnected() -> Bool {
        if(!(NetworkReachabilityManager()?.isReachable)!)
        {
            self.showErrorWith(message: Constants.NO_INTERNET)
            return false
        }
        else
        {
            return true
        }
    }
    
    static func getCurrentMilli() -> Int64 {
        return  Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    static func decodeJson<T : Decodable>(dictionary: Dictionary<String, AnyObject>, responseType:T.Type) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            let gitData =  try JSONDecoder().decode(responseType, from: data)
            return gitData
        } catch {
            print(error)
        }
        
        return nil
    }
    
    static func startProgressLoading(){
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setForegroundColor(UIColor(red:0.71, green:0.67, blue:0.54, alpha:1.0)) // Constants.NAV_BAR_COLOR
        SVProgressHUD.setRingThickness(3.0)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.show()
    }
    
    static func stopProgressLoading(){
        SVProgressHUD.dismiss()
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func shareViewController(sourceView: UIView ,text: String) {
        let activityViewController = UIActivityViewController(activityItems: [text] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView
        Utility().topViewController()?.present(activityViewController, animated: true, completion: nil)
    }
    
    static func getWidthOfText(text: String)  -> CGSize?  {
        if let font = UIFont(name: "Helvetica", size: 15) {
            let fontAttributes = [NSAttributedString.Key.font: font]
            return (text).size(withAttributes: fontAttributes)
        }
        
        return nil
    }

    static func youtubeThumbnail(url : String) -> String{
        //https://img.youtube.com/vi/%s/mqdefault.jpg
        let token = url.components(separatedBy: "=")
        return "https://img.youtube.com/vi/\(token[1])/mqdefault.jpg"
    }
    static func commaSeparatedNumber(number:String)->String{
        let numberDouble = Double(number) ?? 0.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: numberDouble)) ?? "0.0"
    }
}

// Notification
func showInfoNotification(title: String?, desc: String?) {
    TWMessageBarManager.sharedInstance().showMessage(withTitle: title, description: desc, type: .info)
}
func showSuccessNotification(description desc: String?) {
    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: desc, type: .success)
}
func showErrorNotification(description desc: String?) {
    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: desc, type: .error)
}


func showAlertDialog(title: String?, desc: String?) {
    
    let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
    })
    
    if Utility().topViewController()! is UIAlertController {
        Utility().topViewController()!.dismiss(animated: true, completion: {
            Utility().topViewController()!.present(alert, animated: true){}
        })
        return
    }
    
    Utility().topViewController()!.present(alert, animated: true){}
    
}

func openURL(urlString: String) {
    guard let url = URL(string: urlString) else {
        return //be safe
    }
    
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

func dialNumber(number: String) {
    if let url = NSURL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url as URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url as URL)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
}

func chectEmptyText(textField: UITextField, message: String) -> Bool {
    if (textField.text?.isEmpty)! || (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
        showErrorNotification(description: message)
        return true
    }
    return false
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
