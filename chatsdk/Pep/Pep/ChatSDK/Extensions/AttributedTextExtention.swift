import UIKit
extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String, size: Int) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: CGFloat(size))!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String, size: Int)->NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: CGFloat(size))!]
        let normalString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(normalString)
        return self
    }
}
