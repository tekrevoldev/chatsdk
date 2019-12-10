//
//  Extensions.swift
//  Bolwala
//
//  Created by Muhammad Muzammil on 4/4/18.
//  Copyright © 2018 Bol. All rights reserved.
//


import Foundation
import UIKit

extension UIViewController {
    
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
}

extension UITableViewCell {
    
    class var identifier: String {
        return "\(self)"
    }
}

extension UITableViewHeaderFooterView {
    
    class var identifier: String {
        return "\(self)"
    }
}

extension UICollectionViewCell {
    
    class var identifier: String {
        return "\(self)"
    }
}
extension UILabel {
    @IBInspectable var leftIcon: UIImage{
        get {
             return self.leftIcon
        } set (leftIcon) {
            let attachment: NSTextAttachment = NSTextAttachment()
            attachment.image = leftIcon
            let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text ?? "")
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString:attachmentString)
            mutableAttachmentString.append(strLabelText)
            attachment.bounds = CGRect(x:0, y: self.font.descender, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
            self.attributedText = mutableAttachmentString
            
        }
    }
    
}





public class LablePadding: UILabel {
    
    @IBInspectable public var bottomInset: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue; }
    }
    @IBInspectable public var leftInset: CGFloat {
        get { return padding.left }
        set { padding.left = newValue;  }
    }
    @IBInspectable public var rightInset: CGFloat {
        get { return padding.right }
        set { padding.right = newValue;  }
    }
    @IBInspectable public var topInset: CGFloat {
        get { return padding.top }
        set { padding.top = newValue; }
    }
    
    public var padding: UIEdgeInsets = .zero
    
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
}


extension UIView {
    
    func setCorner() {
        let pathWithRadius = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize.init(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = pathWithRadius.cgPath
        self.layer.mask = maskLayer
    }
    
    func disable() {
        self.alpha = 0.2
        self.isUserInteractionEnabled = false
    }
    
    func enable() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 1
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
    
    func animShow(){
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
//                       animations: {
//                        self.center.y -= self.bounds.height
//                        self.layoutIfNeeded()
//        }, completion: nil)
//        UIView.animate(withDuration: 0.5, animations: {
//            self.alpha = 1
//        }, completion:  nil)
       
        
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.isHidden = false
        })
       
    }
    func animHide(){
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
//                       animations: {
//                        self.center.y += self.bounds.height
//                        self.layoutIfNeeded()
//
//        },  completion: {(_ completed: Bool) -> Void in
//        })
        
//        UIView.animate(withDuration: 0.5/*Animation Duration second*/, animations: {
//            self.alpha = 0
//        }, completion:  {
//            (value: Bool) in
//            self.isHidden = true
//        })
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.frame  = CGRect(x: self.frame.minX, y: self.frame.minY - self.frame.height, width: self.frame.width, height: self.frame.height)
//        },completion: { (value: Bool) -> (Void) in
//            self.isHidden = true
//        })
//
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.isHidden = true
        })
    }
    
}
@IBDesignable
class CardView: UIView {
    @IBInspectable var corner: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = corner
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

private var __maxLengths = [UITextField: Int]()
private var paramNameAssociationKey: UInt8 = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
//    @IBInspectable
//    public var leftImage: UIImage? {
//        get {
//            if let imageview = self.leftView as? UIImageView, let image = imageview.image {
//                return image
//            } else {
//                return UIImage()
//            }
//        }
//        set (image) {
//            self.leftViewMode = UITextFieldViewMode.always
//            let imageView = UIImageView();
//            imageView.image = image;
//            self.leftView = imageView
//        }
//    }
    
    @IBInspectable var paramName: String {
        get {
            if let paramName = objc_getAssociatedObject(self,  &paramNameAssociationKey) as? String {
                return paramName
            }
            return ""
        } set (newValue) {
            objc_setAssociatedObject(self, &paramNameAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
}

extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func hexStringToUIColor() -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func isMe() -> Bool {
        return self == AppStateManager.sharedInstance.userId
    }
    
//    func substring(_ from: Int) -> String {
//        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
//    }
    
//    var length: Int {
//        return self.characters.count
//    }
    
    func toLengthOf(length:Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
    
    func tillLengthOf(length: Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}

extension Int {
    func value() -> Bool {
        return self == 1
    }
}

extension Bool {
    func value() -> Int {
        return self ? 1 : 0
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
} }


extension Date {
    func getDate() -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: self)
    }
    
    func getDate(format: DateFormats = DateFormats.DateTime) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}

extension UIImageView {
    @IBInspectable var isCircular: Bool {
        get {
            return self.isCircular
        }
        set (isCircular) {
            if isCircular {
                self.layer.borderWidth = 1.0
                self.layer.masksToBounds = false
                self.layer.borderColor = UIColor.white.cgColor
                self.layer.cornerRadius = self.frame.size.height/2
                self.clipsToBounds = true
            }
        }
    }
}

class CustomUITextView: UITextView ,UITextViewDelegate {
    
    private struct placeholderStruct {
        static var text: String = ""
    }
    
    @IBInspectable var placeholder: String {
        get {
            return self.placeholder
        }
        set {
            placeholderStruct.text = newValue
            self.text = placeholderStruct.text
            self.textColor = UIColor.lightGray //UIColor.lightGray
            self.delegate = self
        }
    }
    
    func setPlaceholder() {
        if self.text.isEmpty {
            self.text = placeholderStruct.text
            self.textColor = UIColor.lightGray
        } else {
           
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            self.text = ""
            self.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = placeholderStruct.text
            textView.textColor = UIColor.lightGray
        }
        return true
    }
    
    func isPlaceholder() -> Bool {
        return self.textColor == UIColor.lightGray
    }
    
    func getText() -> String {
        return self.isPlaceholder() ? "" : self.text
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

// Custom Fonts === < Start >
extension UIFont {
    
    func getFontWeight() -> FontsType {
        
        let fontAttributeKey = UIFontDescriptor.AttributeName.init(rawValue: "NSCTFontUIUsageAttribute")
        if let fontWeight = self.fontDescriptor.fontAttributes[fontAttributeKey] as? String {
            switch fontWeight {
                
            case "CTFontBoldUsage":
                return FontsType.Bold
                
            case "CTFontBlackUsage":
                return FontsType.Regular
                
            case "CTFontHeavyUsage":
                return FontsType.Heading
                
            case "CTFontUltraLightUsage":
                return FontsType.Regular

            case "CTFontThinUsage":
                return FontsType.Regular

            case "CTFontLightUsage":
                return FontsType.Light

            case "CTFontMediumUsage":
                return FontsType.Medium

            case "CTFontEmphasizedUsage":
                return FontsType.SemiBold

            case "CTFontRegularUsage":
                return FontsType.Regular

            default:
                return FontsType.Regular
            }
        }
        
        return FontsType.Regular
    }
}

extension UILabel {
    
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        if let font = self.font  {
//            guard let customFont = UIFont(name: font.getFontWeight().rawValue, size: font.pointSize) else {
//                print("Failed to load font")
//                return
//            }
//
//            self.font = customFont
//            self.adjustsFontForContentSizeCategory = true
//        }
//    }
    
    @IBInspectable var applyCustomFont: Bool {
        get {
            return self.applyCustomFont
        } set {
            if newValue {
                guard let customFont = UIFont(name: self.font.getFontWeight().rawValue, size: self.font.pointSize) else {
                    print("Failed to load font")
                    return
                }
                
                self.font = customFont
                self.adjustsFontForContentSizeCategory = true
            }
        }
    }
    
    @IBInspectable var HighlightText: String { // Provide here comma seperated words for hightlight
        get {
            return self.HighlightText
        } set {
            let words = newValue.split(separator: ",")
            let attributedText = NSMutableAttributedString.init(string: (self.text?.description)!)
            for item in words {
                if let word = self.text?.description as NSString? {
                    let range = word.range(of: item.description)
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: self.tintColor, range: range)
                    attributedText.addAttributes([NSAttributedString.Key.font : UIFont(name: FontsType.SemiBold.rawValue, size: font.pointSize)], range: range)
                }
            }
            self.attributedText = attributedText
        }
    }
    
    
}


extension UITextField {
    
    @IBInspectable var applyCustomFont: Bool {
        get {
            return self.applyCustomFont
        } set {
            if newValue, let font = self.font  {
                guard let customFont = UIFont(name: font.getFontWeight().rawValue, size: font.pointSize) else {
                    print("Failed to load font")
                    return
                }
                
                self.font = customFont
                self.adjustsFontForContentSizeCategory = true
            }
        }
    }
    
}

extension UIButton {
    
    @IBInspectable var applyCustomFont: Bool {
        get {
            return self.applyCustomFont
        } set {
            if newValue, let titleLabel = self.titleLabel  {
                guard let customFont = UIFont(name: titleLabel.font.getFontWeight().rawValue, size: titleLabel.font.pointSize) else {
                    print("Failed to load font")
                    return
                }
                
                titleLabel.font = customFont
                self.titleLabel?.adjustsFontForContentSizeCategory = true
            }
        }
    }
    
    @IBInspectable var applyShadow: Bool {
        get {
            return self.applyShadow
        } set {
            if newValue {
                self.backgroundColor = UIColor.clear
                self.layer.shadowColor = UIColor.darkGray.cgColor
                self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                self.layer.shadowOpacity = 1.0
                self.layer.shadowRadius = 2
                self.layer.masksToBounds = true
                self.clipsToBounds = false
            }
        }
    }
    
  
    
}


extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = shouldBeArchived
        newConstraint.identifier = identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

// Custom Fonts === < End >

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension Optional where Wrapped == Int {
    var unWrap: Int {
        return (self ?? -1)!
    }
}

extension Optional where Wrapped == String {
    var unWrap: String {
        return (self ?? "")!
    }
}

extension Float {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    func decimalPoints() -> String {
        return String(format: "%.2f", self)
    }
}

extension Double {
    func decimalPoints() -> String {
        return String(format: "%.2f", self)
    }
}


class UILabelPadding: UILabel {
    
    let padding = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    
    
}

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
        
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        
        return htmlToAttributedString?.string ?? ""
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension UITableView {
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
