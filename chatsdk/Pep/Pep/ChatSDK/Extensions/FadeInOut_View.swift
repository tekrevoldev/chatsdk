
import UIKit
public extension UIView{
    
    
    
        func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            
            animation.toValue = toValue
            animation.duration = duration
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode.forwards
            
            self.layer.add(animation, forKey: nil)
        }
        
   

    
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    
    var screenShotForCurrentView: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0);
        if let _ = UIGraphicsGetCurrentContext() {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
    
}
