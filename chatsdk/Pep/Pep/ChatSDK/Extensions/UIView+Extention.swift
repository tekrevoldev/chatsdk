
import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var backgroundImage: UIImage {
        get {
            return self.backgroundImage
        }
        set (backgroundImage){
            var bgUIImage : UIImage = backgroundImage
            let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            bgUIImage = bgUIImage.resizableImage(withCapInsets: myInsets)
            self.backgroundColor = UIColor.init(patternImage:bgUIImage)
        }
    }
    
}
